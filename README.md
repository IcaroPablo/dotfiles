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
    >An ordinary git repository plus symlinks. `make install` links each directory under `.config/` into `~/.config`, and `.xinitrc` into `$HOME` — nothing is copied, so whatever a tool writes into its own config (nvim's `nvim-pack-lock.json`, for one) lands back in the repository and shows up in `git status`.
    - `$ git clone https://github.com/IcaroPablo/dotfiles ~/Workspace/dotfiles`
    - `$ make -C ~/Workspace/dotfiles install`
    - add the two lines below to `~/.profile` (`~/.zprofile` for zsh)

    ```sh
    ENV="$HOME/.config/sh/rc.sh"; export ENV      # ksh/sh only
    . "$HOME/.config/sh/env.sh"
    ```

    >Order matters: `env.sh` ends in the tty1 auto-`startx`, which blocks until the X session dies, so exporting `ENV` afterwards would only take effect at logout and every terminal inside X would come up with no rc at all. For bash and zsh, put `env.sh` in the profile and `. "$HOME/.config/sh/rc.sh"` in the rc file instead.

    >`make install` refuses to clobber: anything already sitting where a link belongs is reported and skipped, the rest still install, and the target exits non-zero. `FORCE=1` displaces the occupant into `~/.local/share/dotfiles/displaced` — dated, not deleted — rather than overwriting it. `make uninstall` removes only links that point back at the repository. `dot` reports what this machine has and what it is missing.

- Install my [shell scripts collection](https://github.com/IcaroPablo/posix-shell-scripts-collection)

- Properly configure rc.local e rc.shutdown to mount/umount encrypted discs using the following reference scripts
    - [mount_encrypted](https://github.com/IcaroPablo/posix-shell-scripts-collection/blob/main/bin/mount_encrypted)
    - [umount_encrypted](https://github.com/IcaroPablo/posix-shell-scripts-collection/blob/main/bin/umount_encrypted)

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
