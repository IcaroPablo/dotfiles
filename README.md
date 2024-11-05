# Icaro's dotfiles

Small set (hopefully) of dotfiles I keep for dealing with my basic *nix needs

## OpenBSD post-install guide

>Although these are general purpose dotfiles, they are primarily focused on my OpenBSD desktop setup

- Update to current
  - `# sysupgrade -s`

- Add wheel to doas.conf
  - `#cat 'permit persist :wheel' >> /etc/doas.conf`

- Download fonts (and remove bold style with an [utility script](.local/scripts/disableboldfont.sh))
  - [Cozette](https://github.com/slavfox/Cozette) (my go-to for low res monitors)
  - [Korean]()
  - [Japanese]()
  - [Chinese]()
 
- Remove bold style
  ```shell
  mkdir "$HOME/.config/fontconfig";
  touch "$HOME/.config/fontconfig/fonts.conf";
  
  echo '<?xml version="1.0"?>
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

  fc-cache;
  ```

- Install packages (usually exported with `$ pkg_info -mz > pkg_list.txt`)
  - `$ pkg_add -l pkg_list.txt`
 
- Install my graphical environment (I use Xorg)
    - [st](https://github.com/IcaroPablo/st)
    - [dwm](https://github.com/IcaroPablo/dwm)
    - [dmenu](https://github.com/IcaroPablo/dmenu)

- Setup my dotfiles
    >These dotfiles are managed using the [git bare repo method](https://www.atlassian.com/git/tutorials/dotfiles) through a small shellscript called "dot" for ease of use.
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
    - https://romanzolotarev.com/
    - https://www.c0ffee.net/blog/openbsd-on-a-laptop/
    - https://mizik.sk/blog/how-to-optimize-performance-on-openbsd-desktop/index.html
    - https://www.youtube.com/watch?v=f8lloCtrpdk
    - https://www.youtube.com/watch?v=LBozd4_GwIo
    - https://calomel.org/network_performance.html
