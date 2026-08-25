/*
 * shpad-run - an interactive shell whose input can also arrive from a fifo.
 *
 * Runs $SHELL (or /bin/sh) on a pty of its own and forwards two sources into
 * that pty: this program's stdin, so the pane stays a normal terminal you can
 * type into, and a fifo, so an editor elsewhere can hand it a command.
 *
 * The shell is not modified, wrapped or configured. It sees a pty and a
 * controlling terminal and behaves exactly as it would anywhere else --
 * job control, ^C, password prompts and full-screen programs included.
 *
 * The fifo carries bytes, not a protocol. `printf 'ls\n' > $SHPAD_FIFO` from
 * any other terminal drives this shell, which is also how you debug it.
 *
 * The pty's line discipline echoes whatever arrives, so an injected command
 * appears in the scrollback as though it had been typed. That is what makes
 * the pane a transcript rather than a log of results.
 */

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

/* Saved only when stdin is a terminal; `have_orig` says whether to put it back. */
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

/* Set only when this process created the fifo, so a path handed to us by
 * somebody else is left where we found it. */
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

/* cfmakeraw(3) written out, because it is not POSIX. Everything the outer
 * terminal would interpret is turned off, so keystrokes reach the inner pty
 * untouched and it is that pty's line discipline -- not this one -- that does
 * the erasing, killing and signal generation. */
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

/* The fifo is opened twice on purpose. A read-only fifo with no writer is
 * always ready for reading and hands back end-of-file, which would spin
 * select() in a tight loop and then look like a closed channel. Holding a
 * write end of our own means there is always a writer, so the fifo simply
 * stays quiet until an editor writes to it. O_RDWR on a fifo would do the same
 * but POSIX leaves it undefined. */
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

/* Everything the child needs is done between fork and exec: a session of its
 * own, the pty slave as its controlling terminal, and that slave on all three
 * standard descriptors. */
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
#ifdef TIOCSCTTY
    if (ioctl(sfd, TIOCSCTTY, 0) < 0)
        _exit(EXIT_FAILURE);
#endif
    if (dup2(sfd, STDIN_FILENO) < 0 || dup2(sfd, STDOUT_FILENO) < 0 || dup2(sfd, STDERR_FILENO) < 0)
        _exit(EXIT_FAILURE);
    if (sfd > STDERR_FILENO)
        close(sfd);

    execl(shell, shell, "-i", (char *)NULL);
    _exit(EXIT_FAILURE);
}

/* Read once and hand the bytes on, retrying a short write until the whole
 * chunk is gone. Returns 0 when the source is finished. */
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
    const char *fifo = argc > 1 ? argv[1] : getenv("SHPAD_FIFO");
    const char *shell = getenv("SHPAD_SHELL");
    const char *slave;
    struct sigaction sa;
    int mfd, rfd;
    pid_t child;
    int stdin_open = 1;

    if (!fifo) {
        fprintf(stderr, "usage: shpad-run [fifo]   (or set $SHPAD_FIFO)\n");
        return EXIT_FAILURE;
    }
    if (!shell || !*shell)
        shell = "/bin/sh";

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

        FD_ZERO(&rd);
        FD_SET(mfd, &rd);
        FD_SET(rfd, &rd);
        if (stdin_open) {
            FD_SET(STDIN_FILENO, &rd);
            if (STDIN_FILENO > nfds)
                nfds = STDIN_FILENO;
        }

        if (select(nfds + 1, &rd, NULL, NULL, NULL) < 0 && errno != EINTR)
            break;

        if (got_winch) {
            got_winch = 0;
            copy_winsize(mfd);
        }

        /* The shell exiting is what ends the session. Fall through first, so
         * whatever it printed on the way out still reaches the screen. */
        if (got_chld) {
            got_chld = 0;
            if (waitpid(child, NULL, WNOHANG) == child) {
                while (pump(mfd, STDOUT_FILENO))
                    ;
                break;
            }
        }

        if (FD_ISSET(mfd, &rd) && !pump(mfd, STDOUT_FILENO))
            break;
        if (FD_ISSET(rfd, &rd))
            pump(rfd, mfd);
        /* Our own stdin running dry is not the end of anything -- it is what
         * happens when this is driven from a script rather than a terminal.
         * Stop watching it and keep serving the fifo. */
        if (stdin_open && FD_ISSET(STDIN_FILENO, &rd) && !pump(STDIN_FILENO, mfd))
            stdin_open = 0;
    }

    cleanup();
    return EXIT_SUCCESS;
}
