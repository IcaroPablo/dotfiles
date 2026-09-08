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
    - [dwm](https://github.com/IcaroPablo/dwm)
    - [dmenu](https://github.com/IcaroPablo/dmenu)

- Setup my dotfiles
    >The gitdir lives outside the work-tree (which is `$HOME`), so git never finds it by accident — a stray `git` command in a home subdirectory won't touch these files. The repository is *not* bare: `core.worktree` points at `$HOME`, which is what lets [dot](.config/sh/bin/dot) pass only `--git-dir`.
    - download only the [dot script](.config/sh/bin/dot)
    - `$ dot start https://github.com/IcaroPablo/dotfiles`
    - `$ dot setup`

    >`dot start` moves aside anything already sitting where a tracked file belongs, saving it as `<name>.dot-bak.<timestamp>`: a fresh install always has a `.profile` or `.bashrc` in the way, and a checkout aborts entirely on the first collision. `dot setup` wires the shell and runs `dot doctor`, which reports what is installed and what is missing. Any other verb goes straight to git — `dot status`, `dot commit`, `dot push`.

- Install the standalone scripts
    >Utilities that don't depend on this configuration live in their own repository, with a Makefile that symlinks them into `~/.local/bin`. The ones that *are* part of the environment — the fzf `preview`, `openfile`, the `bar` of the xinitrc, the `shpad` broker — live here instead, in `.config/sh/bin`, next to the `rc.sh` that calls them. The split is by dependency, not by taste.
    - `$ make -C ~/Workspace/scripts install`

- Properly configure rc.local e rc.shutdown to mount/umount encrypted discs using the following reference scripts
    - [mount_encrypted](.local/scripts/mount_encrypted)
    - [umount_encrypted](.local/scripts/umount_encrypted)

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
