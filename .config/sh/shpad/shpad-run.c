#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <termios.h>
#include <unistd.h>

#define BUFSIZE 4096

static volatile sig_atomic_t got_winch;
static volatile sig_atomic_t got_chld;

static struct termios orig;
static int have_orig;

static void on_winch(int sig) {
    (void)sig;
    got_winch = 1;
}

static void on_chld(int sig) {
    (void)sig;
    got_chld = 1;
}

/* Only when we created it; a path handed to us is left where it was found. */
static const char *owned_fifo;

static void cleanup(void) {
    if (have_orig)
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);
    if (owned_fifo)
        unlink(owned_fifo);
}

static void die(const char *what) {
    cleanup();
    fprintf(stderr, "shpad-run: %s: %s\n", what, strerror(errno));
    exit(EXIT_FAILURE);
}

/* cfmakeraw(3) written out, because it is not POSIX. Erasing, killing and
 * signal generation belong to the inner pty, not to this one. */
static void raw_mode(void) {
    struct termios raw;

    if (!isatty(STDIN_FILENO))
        return;
    if (tcgetattr(STDIN_FILENO, &orig) < 0)
        die("tcgetattr");
    have_orig = 1;

    raw = orig;
    raw.c_iflag &= ~(tcflag_t)(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
    raw.c_oflag &= ~(tcflag_t)OPOST;
    raw.c_lflag &= ~(tcflag_t)(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
    raw.c_cflag &= ~(tcflag_t)(CSIZE | PARENB);
    raw.c_cflag |= CS8;
    raw.c_cc[VMIN] = 1;
    raw.c_cc[VTIME] = 0;

    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) < 0)
        die("tcsetattr");
}

static void copy_winsize(int mfd) {
    struct winsize ws;

    if (!isatty(STDIN_FILENO))
        return;
    if (ioctl(STDIN_FILENO, TIOCGWINSZ, &ws) == 0)
        ioctl(mfd, TIOCSWINSZ, &ws);
}

/* Opened twice: read-only with no writer is always ready and returns EOF,
 * which spins select(). Our own write end keeps it quiet. O_RDWR would do the
 * same, but POSIX leaves that undefined. */
static int open_fifo(const char *path) {
    int rfd;

    if (mkfifo(path, S_IRUSR | S_IWUSR) < 0) {
        if (errno != EEXIST)
            die("mkfifo");
    } else {
        owned_fifo = path;
    }
    if ((rfd = open(path, O_RDONLY | O_NONBLOCK)) < 0)
        die("open fifo for reading");
    if (open(path, O_WRONLY | O_NONBLOCK) < 0)
        die("open fifo for writing");

    return rfd;
}

/* $SHELL so the pane reads its own rc and arrives with your functions; a bare
 * `sh -i` reads one only through $ENV, which is empty under zsh. Absolute or
 * nothing: a relative $SHELL would resolve against wherever this started. */
static const char *pick_shell(void) {
    const char *s = getenv("SHPAD_SHELL");

    if (!s || !*s)
        s = getenv("SHELL");
    if (!s || *s != '/')
        s = "/bin/sh";

    return s;
}

static pid_t spawn_shell(const char *slave, const char *shell) {
    pid_t pid = fork();
    int sfd;

    if (pid < 0)
        die("fork");
    if (pid > 0)
        return pid;

    if (setsid() < 0)
        _exit(EXIT_FAILURE);
    if ((sfd = open(slave, O_RDWR)) < 0)
        _exit(EXIT_FAILURE);
    if (ioctl(sfd, TIOCSCTTY, 0) < 0)
        _exit(EXIT_FAILURE);
    if (dup2(sfd, STDIN_FILENO) < 0 || dup2(sfd, STDOUT_FILENO) < 0 || dup2(sfd, STDERR_FILENO) < 0)
        _exit(EXIT_FAILURE);
    if (sfd > STDERR_FILENO)
        close(sfd);

    execl(shell, shell, "-i", (char *)NULL);
    _exit(EXIT_FAILURE);
}

/* Returns 0 when the source is finished. */
static int pump(int from, int to) {
    char buf[BUFSIZE];
    ssize_t r = read(from, buf, sizeof buf);
    ssize_t off = 0;

    if (r < 0)
        return (errno == EINTR || errno == EAGAIN) ? 1 : 0;
    if (r == 0)
        return 0;

    while (off < r) {
        ssize_t w = write(to, buf + off, (size_t)(r - off));
        if (w < 0) {
            if (errno == EINTR)
                continue;
            return 0;
        }
        off += w;
    }
    return 1;
}

int main(int argc, char *argv[]) {
    const char *fifo;
    const char *shell = pick_shell();
    const char *slave;
    struct sigaction sa;
    int mfd, rfd;
    pid_t child;
    int stdin_open = 1;

    if (argc < 2) {
        fprintf(stderr, "usage: shpad-run <fifo>\n");
        return EXIT_FAILURE;
    }
    fifo = argv[1];

    if ((mfd = posix_openpt(O_RDWR | O_NOCTTY)) < 0)
        die("posix_openpt");
    if (grantpt(mfd) < 0)
        die("grantpt");
    if (unlockpt(mfd) < 0)
        die("unlockpt");
    if (!(slave = ptsname(mfd)))
        die("ptsname");

    copy_winsize(mfd);

    memset(&sa, 0, sizeof sa);
    sa.sa_handler = on_winch;
    sigaction(SIGWINCH, &sa, NULL);
    sa.sa_handler = on_chld;
    sigaction(SIGCHLD, &sa, NULL);
    sa.sa_handler = SIG_IGN;
    sigaction(SIGPIPE, &sa, NULL);

    rfd = open_fifo(fifo);
    child = spawn_shell(slave, shell);
    raw_mode();

    for (;;) {
        fd_set rd;
        int nfds = mfd > rfd ? mfd : rfd;
        int r;

        FD_ZERO(&rd);
        FD_SET(mfd, &rd);
        FD_SET(rfd, &rd);
        if (stdin_open) {
            FD_SET(STDIN_FILENO, &rd);
            if (STDIN_FILENO > nfds)
                nfds = STDIN_FILENO;
        }

        r = select(nfds + 1, &rd, NULL, NULL, NULL);
        if (r < 0 && errno != EINTR)
            break;

        if (got_winch) {
            got_winch = 0;
            copy_winsize(mfd);
        }

        /* Drain first: what it printed on the way out still has to land. */
        if (got_chld) {
            got_chld = 0;
            if (waitpid(child, NULL, WNOHANG) == child) {
                while (pump(mfd, STDOUT_FILENO))
                    ;
                break;
            }
        }

        /* The fd_sets are unspecified after an error. Reading them anyway meant
         * a blocking read on the master, which a resize could park the loop in. */
        if (r < 0)
            continue;

        if (FD_ISSET(mfd, &rd) && !pump(mfd, STDOUT_FILENO))
            break;
        if (FD_ISSET(rfd, &rd))
            pump(rfd, mfd);
        /* Running dry is what a script-driven run looks like, not an ending. */
        if (stdin_open && FD_ISSET(STDIN_FILENO, &rd) && !pump(STDIN_FILENO, mfd))
            stdin_open = 0;
    }

    cleanup();
    return EXIT_SUCCESS;
}
