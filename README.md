# Icaro's dotfiles

Small set (hopefully) of dotfiles I keep for dealing with my basic *nix needs

## OpenBSD install guide

>Although these are general purpose dotfiles, they are primarily focused on my OpenBSD desktop setup

>These dotfiles are managed using the [git bare repo method](https://www.atlassian.com/git/tutorials/dotfiles) though a small shellscript called "[dot](.local/scripts/dot)" for ease of use.

- Update to current

  `# sysupgrade -s`

- Download fonts (and remove bold style with an [utility script](.local/scripts/disableboldfont.sh))

  - [Cozette](https://github.com/slavfox/Cozette) (my go-to for low res monitors)
  - [Korean]()
  - [Japanese]()
  - [Chinese]()

- Install packages (usually exported with `$ pkg_info -mz > pkg_list.txt`)

  `$ pkg_add -l pkg_list.txt`
 
- Install my graphical environment (I use Xorg)
    - [st](https://github.com/IcaroPablo/st)
    - [dwm](https://github.com/IcaroPablo/dwm)
    - [dmenu](https://github.com/IcaroPablo/dmenu)

- Setup my dotfiles
    - download only the [dot script](.local/scripts/dot)
    - `$ dot start https://github.com/IcaroPablo/dotfiles`

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
