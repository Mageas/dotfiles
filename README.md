
---

# ❤ My Personal Dotfiles ❤

Welcome to the repository where I keep the configuration files (dotfiles) for my beloved Arch Linux setup.

## What Are Dotfiles?

Dotfiles are the customization files that are used to personalize your Linux system. The "dot" prefix signifies that these files are typically hidden in your directory listings. They include settings for a wide array of applications, services, and even the shell environment itself. Managing these files effectively allows you to maintain a consistent setup across different machines or easily restore settings after a fresh install.

## Prerequisites

Before you use these dotfiles, make sure you have `GNU Stow`, a symlink farm manager, installed on your system. It helps to keep the dotfiles organized and to apply them to the home directory effortlessly.

On Arch Linux, you can install Stow using `pacman`:

```sh
sudo pacman -S stow
```

## Installation

To install the dotfiles for a particular application, navigate to the root of this dotfiles repository and run:

```sh
stow APPLICATION
```

Replace `APPLICATION` with the name of the directory containing the dotfiles you want to install. For example, if you want to install the dotfiles for Neovim, and they're in a directory named `mpv`, you would run:

```sh
stow mpv
```

This will create symlinks in your home directory to the files located in the `mpv` folder of this repository.

## Uninstallation

Removing the dotfiles is just as simple—if you decide that you want to uninstall them, simply run:

```sh
stow -D APPLICATION
```

This command will remove the symlinks created for the specified `APPLICATION` and your settings will revert to their state prior to the installation of these dotfiles.
