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
    >A plain git repository plus symlinks, managed by a small POSIX shell script called [dot](.local/scripts/dot). The only things written into `$HOME` are the links themselves and one marked block in the shell profile — `dot setup --uninstall` reverses both.
    - `$ git clone https://github.com/IcaroPablo/dotfiles ~/Workspace/dotfiles`
    - `$ ~/Workspace/dotfiles/.local/scripts/dot setup`

    >`dot doctor` reports what is linked, what is installed and what is missing. `dot link --force` moves aside anything already sitting where a link belongs, instead of clobbering it. There is no manifest of what-links-where: the list comes from the repository tree, so a new directory under `.config/` is picked up on its own.

    >**Future goal — deploying this on a host I don't own.** Getting my shell and editor config onto someone else's machine without touching their dotfiles is achievable: the configs are XDG-native, and every shell has an entry point that loads config from an arbitrary path (`ENV=` for ksh, `--rcfile` for bash, `ZDOTDIR=` for zsh), so no host file needs patching. What does not travel is the tools — fzf, eza, nvim, dvtm are binaries, and there is no portable way to get them onto an arbitrary unix host. So the realistic target is config portability with graceful degradation, not an identical environment everywhere.

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
