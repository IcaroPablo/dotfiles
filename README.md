# Icaro's dotfiles

Small set (hopefully) of dotfiles I keep for dealing with my basic *nix needs

## OpenBSD post-install guide

>Although these are general purpose dotfiles, they are primarily focused on my OpenBSD desktop setup

- Update to current
  - `# sysupgrade -s`

- Add wheel to doas.conf
  - `# cat 'permit persist :wheel' >> /etc/doas.conf`

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

- Setup my dotfiles
    >An ordinary git repository plus symlinks: each directory under `.config/` is linked into `~/.config`, `.xinitrc` into `$HOME`, and each script in `bin/` into `~/.local/bin`. Nothing is copied, so whatever a tool writes into its own config (nvim's `nvim-pack-lock.json`, for one) lands back in the repository and shows up in `git status`, and editing a script takes effect at once.
    - `$ git clone https://github.com/IcaroPablo/dotfiles ~/Workspace/dotfiles`
    - `$ cd ~/Workspace/dotfiles && make install SETS="0 1"`
    - add the two lines below to `~/.profile`

    ```sh
    ENV="$HOME/.config/sh/rc.sh"; export ENV      # ksh/sh only
    . "$HOME/.config/sh/env.sh"
    ```

    >Order matters: `env.sh` ends in the tty1 auto-`startx`, which blocks until the X session dies, so exporting `ENV` afterwards would only take effect at logout and every terminal inside X would come up with no rc at all. For bash, put `env.sh` in the profile and `. "$HOME/.config/sh/rc.sh"` in the rc file instead.

    >Configs and scripts come in sets, picked per machine: set 0 is common, set 1 is the graphical host (shire), set 2 is the VM (fangorn). Sets 1 and 2 depend only on set 0, never on each other. `SETS` defaults to all three; `make install` also removes this repository's links to whatever is outside the chosen sets, and `make list` shows what a choice would link.

    >`make install` refuses to clobber: anything already sitting where a link belongs is reported and skipped, the rest still install, and the target exits non-zero. `FORCE=1` displaces the occupant into `~/.local/share/dotfiles/displaced` — dated, not deleted — rather than overwriting it. `make uninstall` removes only links that point back at the repository, found by scanning the targets, so the link of a file deleted from here goes too. `make doctor SETS=...` reports which links are in place, whether the shell is wired, and which tools the chosen sets need.

    >The Makefile is POSIX make, so it runs under bmake and OpenBSD's make as well as GNU make — no `wildcard`, `notdir` or `CURDIR`, and the lists come from shell globs. Use `cd` rather than `make -C`: OpenBSD's make has no `-C`.

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
