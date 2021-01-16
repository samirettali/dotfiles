# Dotfiles

Someone once said:
> Show me your dotfiles and I'll tell you who you are.

## Why `stow`?

## Why `stow`?

I previously used a bare git repository to manage my dotfiles[^1] but it became a bit unmanageable with time.

## Advantages
* No more accidental staging of random files that leads to having to mess with git
* Much more structured filesystem, see below
* Removing dotfiles is really easy, just `stow -D <config>`
* A `README`, finally
* Git gitter, finally

## Features

The `install` script basically checks the current operating system, selects what modules to install and uses stow to link each folder.

At the moment my dotfiles are split between three modules, as called by stow, which are `common`, `linux` and `mac`, and every module contains software specific configurations:

```
├── common
│   ├── ack
│   ├── alacritty
│   ├── bc
│   ├── git
│   ├── mpd
│   ├── ncmpcpp
│   ├── nvim
│   ├── ripgrep
│   ├── scripts
│   ├── tmux
│   ├── tmuxinator
│   └── zsh
├── linux
│   ├── xdefaults
│   └── xinit
└── mac
    ├── espanso
    └── karabiner
```

This allows me to have a main configuration in `common` and additional OS specific configurations in `linux` or `mac`. I use this for `zsh` for example, where I have a `.zshrc_local` where I set different options for Mac OS and Linux.

Plugins are managed using git submodules inside the corresponding application
folder.

## Missing
My suckless configurations, I'll add them as soon as I'll find a good way to
integrate them.


[^1]: https://www.atlassian.com/git/tutorials/dotfiles
