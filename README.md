<h1 align="center">
  <img src="https://avatars.githubusercontent.com/u/195541893?v=4" width="80" alt="caelestia logo" /><br/>
  caelestia · hyprland · arch
</h1>

<p align="center">
  My personal <strong>Hyprland</strong> desktop setup on <strong>Arch Linux</strong>, built on top of the
  <a href="https://github.com/caelestia-dots/shell">caelestia-shell</a> framework and heavily tweaked to my workflow.
</p>

<p align="center">
  <a href="https://drive.google.com/file/d/1Dkxp99A5qGVc-XsV0gYNUfT3ySAIVME8/view?usp=sharing">
    <img src="https://img.shields.io/badge/Demo-Google%20Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white" alt="Demo" />
  </a>
  <img src="https://img.shields.io/badge/OS-Arch%20Linux-1793D1?style=for-the-badge&logo=archlinux&logoColor=white" alt="Arch Linux" />
  <img src="https://img.shields.io/badge/WM-Hyprland-00AAFF?style=for-the-badge&logo=hyprland&logoColor=white" alt="Hyprland" />
</p>

---

## Overview

This is my personal dotfiles and configuration for a polished, functional Arch Linux desktop using Hyprland as the window manager and the [caelestia-shell](https://github.com/caelestia-dots/shell) as the UI framework (built on Quickshell/QML). The base was installed from upstream, but everything has been customised to match my taste, workflow, and hardware.

---
## Demo

<p align="center">
  <a href="https://drive.google.com/file/d/1Dkxp99A5qGVc-XsV0gYNUfT3ySAIVME8/view?usp=sharing">
 <img width="900" alt="Thumbnail" src="https://github.com/user-attachments/assets/266c871b-fe31-42eb-b0da-be821fb8cd42" />

  </a>
</p>

---

## Screenshots

<img width="1920" height="1200" alt="2026-06-07_11-35-22" src="https://github.com/user-attachments/assets/777c5bcf-81b8-4c75-9c08-bf3dd4c97d88" />

<img width="1920" height="1200" alt="2026-06-07_11-39-04" src="https://github.com/user-attachments/assets/f3f58ac5-2623-4216-8dee-858ac0148782" />

<img width="1920" height="1200" alt="screen_lock" src="https://github.com/user-attachments/assets/1d12150f-d65a-44a6-aaa5-815e8ad34a78" />

<img width="1920" height="1200" alt="2026-06-07_11-58-11" src="https://github.com/user-attachments/assets/10439925-a42f-44d2-ba19-1ba44daaf81d" />



---

## Stack

| Role | Tool |
|---|---|
| OS | [Arch Linux](https://archlinux.org) |
| Window Manager | [Hyprland](https://hyprland.org) |
| Shell Framework | [caelestia-shell](https://github.com/caelestia-dots/shell) |
| Widget Engine | [Quickshell](https://quickshell.outfoxxed.me) |
| Terminal | [kitty](https://sw.kovidgoyal.net/kitty/) |
| File Manager | [Nautilus](https://apps.gnome.org/Nautilus/) |

---

## Installation

> This setup is known to work with the exact versions listed below. Newer versions of Hyprland, QuickShell, or Caelestia Shell may introduce breaking changes.

### Working Versions

| Component       | Version                                                   |
| --------------- | --------------------------------------------------------- |
| Hyprland        | 0.55.3-1                                                  |
| QuickShell      | 0.3.0 (revision d99d87d5e5ec4e696815348692fdaaf0b6be1b2c) |
| Caelestia Shell | 1.6.2-2                                                   |

---

### Install Hyprland 0.55.3-1

Check cache first:

```bash
ls /var/cache/pacman/pkg/hyprland*
```

If available:

```bash
sudo pacman -U /var/cache/pacman/pkg/hyprland-0.55.3-1-*.pkg.tar.zst
```

Otherwise use Arch Archive:

```bash
sudo pacman -U https://archive.archlinux.org/packages/h/hyprland/hyprland-0.55.3-1-x86_64.pkg.tar.zst
```

Verify:

```bash
pacman -Qi hyprland | grep Version
```

Expected:

```text
Version : 0.55.3-1
```

---

### Install QuickShell 0.3.0

Remove existing package:

```bash
yay -R quickshell-git
```

Clone AUR repository:

```bash
git clone https://aur.archlinux.org/quickshell-git.git
cd quickshell-git
```

Checkout exact revision:

```bash
git checkout d99d87d5e5ec4e696815348692fdaaf0b6be1b2c
```

Build:

```bash
makepkg -si
```

Verify:

```bash
qs --version
```

Expected:

```text
Quickshell 0.3.0
revision d99d87d5e5ec4e696815348692fdaaf0b6be1b2c
```

---

### Install Caelestia Shell 1.6.2-2

Clone AUR package:

```bash
git clone https://aur.archlinux.org/caelestia-shell.git ~/.config/quickshell/caelestia
cd caelestia
```

Checkout the last 1.6.2 release commit:

```bash
git checkout 8e46b3c66ee700c451641450d1c8f9112174ef9e
```

Verify:

```bash
grep pkgver PKGBUILD
```

Expected:

```text
pkgver=1.6.2
```

Build:

```bash
makepkg -si
```

Verify:

```bash
pacman -Qi caelestia-shell | grep Version
```

Expected:

```text
Version : 1.6.2-2
```

---

### Clone My Configuration

Clone the repository:

```bash
git clone https://github.com/WiTheR60334/obsidian-dots.git ~/obsidian-dots
```

Remove existing configurations:

```bash
rm -rf ~/.config/hypr
rm -rf ~/.config/kitty
rm -rf ~/.config/quickshell
rm -rf ~/.config/fuzzel
rm -rf ~/.config/caelestia
```

Copy the configurations from this repository:

```bash
cp -r ~/obsidian-dots/hypr ~/.config/
cp -r ~/obsidian-dots/kitty ~/.config/
cp -r ~/obsidian-dots/quickshell ~/.config/
cp -r ~/obsidian-dots/fuzzel ~/.config/
cp -r ~/obsidian-dots/caelestia ~/.config/

cp ~/obsidian-dots/chrome-flags.conf ~/.config/
```

## Prevent Accidental Upgrades

Edit:

```bash
sudo nano /etc/pacman.conf
```

Add:

```ini
IgnorePkg = hyprland caelestia-shell
```

For AUR packages:

```bash
yay -Syu --ignore hyprland,caelestia-shell,quickshell-git
```

or:

```bash
yay -Syu --ignore caelestia-shell,quickshell-git
```

---

## Updating

```sh
# If installed from AUR
yay -Syu caelestia-shell

# If installed manually — pull latest and rebuild
cd ~/.config/quickshell/caelestia
git pull
cmake --build build
sudo cmake --install build
```

---

## Credits

- [caelestia-dots/shell](https://github.com/caelestia-dots/shell) — the upstream shell this is based on
- [Quickshell](https://quickshell.outfoxxed.me) — the widget framework powering the UI
- [Hyprland](https://hyprland.org) — the window manager

---

<p align="center">
  <sub>Built on Arch · Powered by Hyprland · Styled with caelestia</sub>
</p>
