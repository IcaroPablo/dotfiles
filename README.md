# Icaro's dotfiles

Small set (hopefully) of dotfiles I keep for dealing with my basic *nix needs

## What's here

An ordinary git repository plus symlinks: each directory under `.config/` is linked into `~/.config`, `.xinitrc` into `$HOME`, and each script in `bin/` into `~/.local/bin`. Nothing is copied, so whatever a tool writes into its own config (nvim's `nvim-pack-lock.json`, for one) lands back in the repository and shows up in `git status`, and editing a script takes effect at once.

- `MANIFEST` lists everything that can be linked, with what each one needs and uses.
- `.config/sh/` is the shell: `env.sh` (login environment), `rc.sh` (interactive shells), `lib/` (helpers the scripts source: `core.sh`, `term.sh`, `x11.sh`), and what only one OS or shell has in `env.d/<os>.sh` and `rc.d/<os>.sh`, `rc.d/<shell>.sh`. `.config/x11/xinitrc.d/<os>.sh` does the same for `.xinitrc`.
- `.config/sh/hosts/<host>.sh` describes one machine (below).
- `setup/` takes a fresh system to this environment, one script per OS.

The graphical tools are for X only.

## Installing

- `$ git clone https://github.com/IcaroPablo/dotfiles ~/Workspace/dotfiles`
- `$ cd ~/Workspace/dotfiles && make install`

`make install` links what `MANIFEST` gives this machine and removes this repository's links to anything it no longer gives. `make list` shows what that is, and what is left out and why; `make doctor` checks the links, whether the shell loads `rc.sh`, and the tools each linked file uses. `make uninstall` removes only links that point back at the repository, found by scanning the targets, so the link of a file deleted from here goes too.

>`make install` refuses to clobber: anything already sitting where a link belongs is reported and skipped, the rest still install, and the target exits non-zero. `FORCE=1` displaces the occupant into `~/.local/share/dotfiles/displaced` — dated, not deleted — rather than overwriting it.

>The Makefile is POSIX make, so it runs under bmake and OpenBSD's make as well as GNU make — no `wildcard`, `notdir` or `CURDIR`, and the lists come from shell globs. Use `cd` rather than `make -C`: OpenBSD's make has no `-C`.

### Machines

Each line of `MANIFEST` is `path : needs : uses`. A file is linked when the machine meets everything in its needs, where each word is either a tag or a command that must be installed (`a|b`: either one):

- the OS tag (`linux`, `openbsd`, `macos`) comes from `uname`;
- `host` (a physical machine), `x11` and `sixel` (a terminal that shows sixel images) come from the machine's `.config/sh/hosts/<host>.sh`, as `HAS='host x11 sixel'`.

The host is `hostname -s`, or `make install HOST=name`. A machine with no host file still gets everything that needs no host tags, and `make` says so; a new machine only needs its file for X, sixel or hardware tools. The same file holds the machine's own settings, which `env.sh` sources at login.

### The shell

For sh and ksh, add these two lines to `~/.profile` (the setup scripts do):

```sh
ENV="$HOME/.config/sh/rc.sh"; export ENV
. "$HOME/.config/sh/env.sh"
```

>Order matters: `env.sh` ends in the tty1 auto-`startx`, which blocks until the X session dies, so exporting `ENV` afterwards would only take effect at logout and every terminal inside X would come up with no rc at all.

For bash, keep the same two lines in `~/.profile` (bash reads it when there is no `~/.bash_profile`) and add `. "$HOME/.config/sh/rc.sh"` to `~/.bashrc`: bash reads `ENV` only in POSIX mode. zsh isn't covered yet: it would need its own `rc.d/zsh.sh` for the prompt.

### Setting up a machine

`setup/chimera` (shire), `setup/openbsd` (fangorn, run by `fangorn rebuild`) and `setup/macos` take a fresh system to this environment: packages, the user, this repository cloned and installed, and the `.profile` lines. They source `setup/lib.sh`, so run them from a clone or from a copy of the whole `setup/` folder:

- `# sh setup/chimera` (as root, also from the installer's chroot)
- `$ sh setup/macos` (as yourself; no X, just the shell and Ghostty)

Each is safe to rerun; `setup/chimera` and `setup/macos` end listing what was already installed but isn't theirs.

## OpenBSD post-install guide

>Although these are general purpose dotfiles, they are primarily focused on my OpenBSD desktop setup

- Update to current
  - `# sysupgrade -s`

- Add wheel to doas.conf
  - `# echo 'permit persist :wheel' >> /etc/doas.conf`

- Download fonts
  - [Cozette](https://github.com/slavfox/Cozette) (my go-to for low res monitors)
  - [Korean]()
  - [Japanese]()
  - [Chinese]()
 
- Remove bold style
  - `$ mkdir "$HOME/.config/fontconfig";`
  - `$ touch "$HOME/.config/fontconfig/fonts.conf";`
  - ```shell
    $ echo '<?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
       <match target="pattern">
         <test qual="any" name="family">
           <string>CozetteVector</string>
         </test>
         <test name="weight" compare="more">
           <const>medium</const>
         </test>
         <edit name="weight" mode="assign" binding="same">
           <const>medium</const>
         </edit>
       </match>
      </fontconfig>' > $HOME/.config/fontconfig/fonts.conf;
    ```
  - `$ fc-cache;`

- Install packages (usually exported with `$ pkg_info -mz > pkg_list.txt`)
  - `$ pkg_add -l pkg_list.txt`
 
- Install my graphical environment (I use Xorg)
    - [st](https://github.com/IcaroPablo/st)
    - [smawm](https://github.com/IcaroPablo/sowm/tree/smawm)

- Setup my dotfiles: see [Installing](#installing)

- Properly configure autohotplug

    - (todo)

- Follow multimedia config on [FAQ](https://www.openbsd.org/faq/faq13.html)

- Properly configure kernel flags (/etc/sysctl.conf)
    ```shell
    kern.video.record=1
    kern.audio.record=1
    net.inet.ip.forwarding=1
    # Enable hyperthreading
    hw.smt=1

    # default: 1310
    kern.maxproc=8192
    # default: 7030
    kern.maxfiles=32768
    # default: 1950
    kern.maxthread=16384

    # shared memory settings
    # default: 8192
    kern.shminfo.shmall=536870912
    # default: 33554432
    kern.shminfo.shmmax=2147483647
    # default: 1024
    kern.shminfo.shmmni=4096
    ```
    - https://romanzolotarev.com/
    - https://www.c0ffee.net/blog/openbsd-on-a-laptop/
    - https://mizik.sk/blog/how-to-optimize-performance-on-openbsd-desktop/index.html
    - https://www.youtube.com/watch?v=f8lloCtrpdk
    - https://www.youtube.com/watch?v=LBozd4_GwIo
    - https://calomel.org/network_performance.html

## Chimera

- Recreate the boot entry if the firmware loses it
  - `# efibootmgr --create --disk /dev/sda --part 1 --loader '/EFI/chimera/grubx64.efi' --label "chimera" --unicode`
