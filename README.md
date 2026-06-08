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

▶️ [Watch Demo Video](https://drive.google.com/file/d/1Dkxp99A5qGVc-XsV0gYNUfT3ySAIVME8/view?usp=sharing)

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

> This is a **personal configuration**, not a general-purpose installer. These steps are for reference or if you want to replicate my setup.

### 1. Install caelestia-shell (Arch)

```sh
# Stable AUR package
yay -S caelestia-shell

# Or bleeding-edge
yay -S caelestia-shell-git
```

For manual installation with local edits (recommended for customisation):

```sh
mkdir -p ~/.config/quickshell/caelestia
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/ \
  -DINSTALL_QSCONFDIR=~/.config/quickshell/caelestia
cmake --build build
sudo cmake --install build
sudo chown -R $USER ~/.config/quickshell/caelestia
```

### 2. Install dependencies

```sh
yay -S caelestia-cli quickshell-git ddcutil brightnessctl app2unit \
       libcava networkmanager lm-sensors fish aubio libpipewire \
       qt6-declarative qt6-base swappy libqalculate \
       ttf-rubik-vf material-symbols-rounded-git \
       caskaydia-cove-nerd-font
```

### 3. Copy my config

```sh
cp shell.json ~/.config/caelestia/shell.json
mkdir -p ~/.config/caelestia/monitors/eDP-1
cp monitors/eDP-1/shell.json ~/.config/caelestia/monitors/eDP-1/shell.json
```

### 4. Add custom components

```sh
cp -r components/cards/FanSpeedCard.qml ~/.config/quickshell/caelestia/components/cards/
cp -r components/cards/fan-blades-icon.svg ~/.config/quickshell/caelestia/components/cards/
```

### 5. Autostart with Hyprland

Add to your `hyprland.conf`:

```ini
exec-once = caelestia shell -d
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

> ⚠️ After updating, re-apply the `FanSpeedCard.qml` component if the `components/cards/` directory is overwritten.

---

## Keybinds

All shell keybinds use Hyprland [global shortcuts](https://wiki.hyprland.org/Configuring/Binds/#dbus-global-shortcuts). Refer to the [caelestia keybinds reference](https://github.com/caelestia-dots/caelestia/blob/main/hypr/hyprland/keybinds.conf) for the full list. IPC commands are accessible via:

```sh
caelestia shell <command>
```

For example:

```sh
caelestia shell controlCenter open
caelestia wallpaper -r     # random wallpaper
caelestia wallpaper -h     # wallpaper help
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
