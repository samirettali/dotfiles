# Dotfiles

Someone once said:
> Show me your dotfiles and I'll tell you who you are.

## Why `stow`?

I previously used a bare git repository to manage my dotfiles[^1] but it became a bit
unmanageable with time.

The main problems are accidental add of files and not being able to manage
different configurations for Mac OS and Linux, or even between different Linux
distributions.

Also if I wanted to remove a machine

## Features

The `install.sh` script basically checks the current operating system, selects
what modules to install and uses stow to link each package's folder.

At the moment my dotfiles are split between three modules, as called by stow,
which are `common`, `linux` and `mac`, and every module contains applications
specific configurations:

```
.
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

Software specific plugins are managed using git submodules inside the
corresponding application folder.

## Missing
My suckless configurations, I'll add them as soon as I'll find a good way to
integrate them.


[^1]: https://www.atlassian.com/git/tutorials/dotfiles
