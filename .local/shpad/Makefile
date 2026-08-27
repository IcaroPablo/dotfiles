# shpad - build the pty broker.
#
# No -std= on purpose: posix_openpt, TIOCSCTTY and TIOCGWINSZ each sit behind a
# different feature macro depending on the libc, and the compiler default
# exposes all three on macOS, glibc and the BSDs. Pinning a standard here means
# maintaining that macro dance instead, which is deferred along with the rest
# of the portability work.

CFLAGS ?= -Wall -Wextra -O2

all: shpad-run

shpad-run: shpad-run.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f shpad-run

.PHONY: all clean
