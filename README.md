# Icaro's dotfiles

Small set (hopefully) of dotfiles I keep for dealing with my basic *nix needs

## What's here

An ordinary git repository plus symlinks: each directory under `.config/` is linked into `~/.config`, `.xinitrc` into `$HOME`, and each script in `bin/` into `~/.local/bin`. Nothing is copied, so whatever a tool writes into its own config (nvim's `nvim-pack-lock.json`, for one) lands back in the repository and shows up in `git status`, and editing a script takes effect at once.

- `MANIFEST` lists everything that can be linked, with the capabilities each one needs.
- `.config/sh/` is the shell: `env.sh` (login environment), `rc.sh` (interactive shells), `lib/` (helpers the scripts source: `core.sh`, `term.sh`, `x11.sh`), and what only one OS or shell has in `env.d/<os>.sh` and `rc.d/<os>.sh`, `rc.d/<shell>.sh`. `.config/x11/xinitrc.d/<os>.sh` does the same for `.xinitrc`.
- `.config/sh/hosts/<hostname>.sh` holds one machine's own settings, which `env.sh` sources at login.
- `setup/` takes a fresh system to this environment, one script per OS.

The graphical tools are for X only.

## Installing

- `$ git clone https://github.com/IcaroPablo/dotfiles ~/Workspace/dotfiles`
- `$ cd ~/Workspace/dotfiles && make install`

`make install` links what `MANIFEST` gives this machine and removes this repository's links to anything it no longer gives. `make list` shows what that is, and what is left out and why; `make doctor` checks the links, whether the shell loads `rc.sh`, and each declared capability. `make uninstall` removes only links that point back at the repository, found by scanning the targets, so the link of a file deleted from here goes too.

>`make install` refuses to clobber: anything already sitting where a link belongs is reported and skipped, the rest still install, and the target exits non-zero. `FORCE=1` displaces the occupant into `~/.local/share/dotfiles/displaced` — dated, not deleted — rather than overwriting it.

>The Makefile is POSIX make, so it runs under bmake and OpenBSD's make as well as GNU make — no `wildcard`, `notdir` or `CURDIR`, and the lists come from shell globs. Use `cd` rather than `make -C`: OpenBSD's make has no `-C`.

### Capabilities

What a machine gets depends on the capabilities it declares, one word each in `~/.config/dotfiles/capabilities`. That file belongs to the machine, not to this repository: the setup scripts write it (below), or it can be written by hand. Without it, `make` stops and says so; an empty one declares nothing.

| Capability | What it is | Checked by |
|---|---|---|
| `x11` | an X session: Xorg, st, smawm, scrot, slop | `startx xrandr xsetroot xdpyinfo xclip st smawm scrot slop` |
| `sixel` | the sixel viewers' tools | `chafa ffmpeg ffprobe python3 pdfinfo pdftoppm djvused ddjvu` |
| `text-editing` | nvim and vis | `nvim tree-sitter rg vis-open` |
| `dvtm` | dvtm, for shpad | `dvtm` |
| `phone` | adb, for pull-files | `adb` |
| `host` | a physical machine's disks | `rsync cryptsetup\|bioctl` |
| `ocr` | tesseract, for scrotocr | `tesseract mogrify` |
| `yt-dlp` | yt-dlp, for igsaved | `yt-dlp` |
| `ghostty` | the Ghostty terminal | `ghostty\|/Applications/Ghostty.app` |

Each line of `MANIFEST` is `path : needs`, where needs are capabilities and OS tags (`linux`, `openbsd`, `macos`, from `uname`), `a|b` meaning either one; a file with no needs is linked everywhere. Only the declared capabilities are checked, against the commands above (in the Makefile's `CHECKS`), and if a declared one fails its check, `make install` stops before linking anything and names what's missing. What is installed but not declared is ignored.

vis is checked by its `vis-open`: the BSDs, Chimera's userland among them, have a `vis(1)` of their own, and name the editor `vise`.

>TODO: a declared `sixel` trusts the terminal. Only the viewers' tools are checked, as there is no reliable way to ask a terminal whether it draws sixel images.

### The shell

For sh and ksh, add these two lines to `~/.profile` (the setup scripts do):

```sh
ENV="$HOME/.config/sh/rc.sh"; export ENV
. "$HOME/.config/sh/env.sh"
```

>Order matters: `env.sh` ends in the tty1 auto-`startx`, which blocks until the X session dies, so exporting `ENV` afterwards would only take effect at logout and every terminal inside X would come up with no rc at all.

For bash, keep the same two lines in `~/.profile` (bash reads it when there is no `~/.bash_profile`) and add `. "$HOME/.config/sh/rc.sh"` to `~/.bashrc`: bash reads `ENV` only in POSIX mode.

zsh reads neither `~/.profile` nor `ENV`, so it gets them in its own files:

```sh
# ~/.zprofile
emulate sh -c '. "$HOME/.config/sh/env.sh"'
# ~/.zshrc
emulate sh -c '. "$HOME/.config/sh/rc.sh"'
```

>`emulate sh -c` loads them under sh's rules, and the functions they define keep those rules whenever they run; `rc.d/zsh.sh` gives the prompt zsh's escapes, vi keys and a history file of its own.

### Setting up a machine

`setup/chimera` (shire), `setup/openbsd` (fangorn, run by `fangorn rebuild`) and `setup/macos` take a fresh system to this environment: the base system and shell tools, the user, this repository cloned, the `.profile` lines, and then the capabilities chosen. Each script offers the capabilities it can install on its OS, asks about them one by one unless they're given as arguments (a rerun defaults to what's declared), installs the chosen ones, declares them, and runs `make install`. Dropping a capability on a rerun undeclares it without uninstalling anything; what isn't on a script's menu, declared by hand, stays declared.

| Script | Its capabilities |
|---|---|
| `setup/chimera` | `x11 sixel text-editing host phone ocr yt-dlp` |
| `setup/openbsd` | `sixel text-editing dvtm yt-dlp` |
| `setup/macos` | `ghostty text-editing` |

They source `setup/lib.sh`, so run them from a clone or from a copy of the whole `setup/` folder:

- `# sh setup/chimera [capability...]` (as root, also from the installer's chroot)
- `$ sh setup/macos [capability...]` (as yourself; no X)

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
