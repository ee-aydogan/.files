# Arch Linux Install Guide

> Custom install steps for my personal setup.
> Review each section and decide what to keep/change.

---

## Table of Contents

- [0. Pre-flight](#0-pre-flight)
- [1. Disk Partitioning](#1-disk-partitioning)
- [2. Filesystems](#2-filesystems)
- [3. Mount](#3-mount)
- [4. Mirrors + CachyOS Repos](#4-mirrors--cachyos-repos)
- [5. Base Install](#5-base-install)
- [6. fstab](#6-fstab)
- [7. Download pre-built kernel packages](#7-download-pre-built-kernel-packages)
- [8. Chroot](#8-chroot)
- [9. Timezone & Locale](#9-timezone--locale)
- [10. Hostname](#10-hostname)
- [11. Users & Sudo](#11-users--sudo)
- [12. Install Custom Kernel](#12-install-custom-kernel)
- [13. systemd-networkd](#13-systemd-networkd)
- [14. UKI Boot (mkinitcpio)](#14-uki-boot-mkinitcpio)
- [15. CPU & Kernel Tuning](#15-cpu--kernel-tuning)
- [16. AMD GPU](#16-amd-gpu)
- [17. adios (NVMe Scheduler)](#17-adios-nvme-scheduler)
- [18. Theming](#18-theming)
- [19. Exit & Reboot](#19-exit--reboot)
- [20. Post-Boot](#20-post-boot)

---

## 0. Pre-flight

```bash
# Verify UEFI boot mode (should print 64)
cat /sys/firmware/efi/fw_platform_size

# Set keyboard layout (Turkish Q)
loadkeys trq

# Check internet
ip link
ping -c 3 archlinux.org

# Enable NTP
timedatectl set-ntp true
```

---

## 1. Disk Partitioning

```bash
# Identify your drive
lsblk
fdisk -l

# Partition with gdisk (GPT)
gdisk /dev/nvme0n1
```

### Layout

| Partition | Size | Type Code | Mount |
|---|---|---|---|
| nvme0n1p1 | 1 GiB | EF00 | /boot/efi |
| nvme0n1p2 | Remainder | 8300 | / |

> No separate swap — use swapfile or zram post-install.
> **gdisk commands:** `n` = new, `t` = type, `w` = write

---

## 2. Filesystems

### EFI Partition

```bash
mkfs.fat -F32 /dev/nvme0n1p1
```

### Root — ext4

```bash
mkfs.ext4 \
  -L archroot \
  -E lazy_itable_init=0,lazy_journal_init=0 \
  -O dir_index,filetype,extent,flex_bg,sparse_super2,large_file \
  -b 4096 \
  -m 1 \
  /dev/nvme0n1p2
```

### Optional: tune after creation

```bash
tune2fs -o journal_data_writeback /dev/nvme0n1p2
tune2fs -c 0 -i 0 /dev/nvme0n1p2
```

---

## 3. Mount

```bash
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi
```

---

## 4. Mirrors + CachyOS Repos

### Official mirrors

```bash
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

reflector \
  --country Turkey,Germany,France \
  --age 12 \
  --protocol https \
  --sort rate \
  --save /etc/pacman.d/mirrorlist
```

### CachyOS repos

```bash
curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz
cd cachyos-repo
sudo ./cachyos-repo.sh
```

> This adds CachyOS repos to pacman.conf and imports GPG keys.
> Also sets up optimized makepkg.conf with `-march=native -O3` flags.

---

## 5. Base Install

```bash
pacstrap -K /mnt \
  base base-devel \
  linux-firmware \
  amd-ucode \
  git neovim \
  man-db man-pages \
  efibootmgr \
  systemd-networkd
```

> No `linux linux-headers` — we install the pre-built CachyOS kernel from GitHub release.
> No systemd-resolved (DHCP handles DNS).
> No systemd-ukify (using mkinitcpio for UKI).

---

## 6. fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
nvim /mnt/etc/fstab
```

### Root ext4 — change options line to:

```
UUID=xxxx  /  ext4  rw,noatime,nodiratime,data=writeback  0 1
```

### EFI — keep as-is from genfstab, already fine.

### Add tmpfs line at the end:

```
tmpfs  /tmp  tmpfs  rw,nosuid,nodev,noatime,size=16G,mode=1777  0 0
```

> Adjust `size=16G` to ~half your RAM (you have 32G).

---

## 7. Download pre-built kernel packages

```bash
mkdir -p /mnt/root/kernel-build

curl -L https://github.com/eydgn/.files/releases/download/kernel-7.0.11/linux-cachyos-bore-lto-7.0.11-1-x86_64.pkg.tar.zst \
  -o /mnt/root/kernel-build/linux-cachyos-bore-lto-7.0.11-1-x86_64.pkg.tar.zst

curl -L https://github.com/eydgn/.files/releases/download/kernel-7.0.11/linux-cachyos-bore-lto-headers-7.0.11-1-x86_64.pkg.tar.zst \
  -o /mnt/root/kernel-build/linux-cachyos-bore-lto-headers-7.0.11-1-x86_64.pkg.tar.zst

curl -L https://github.com/eydgn/.files/releases/download/kernel-7.0.11/linux-cachyos-bore-lto-r8125-7.0.11-1-x86_64.pkg.tar.zst \
  -o /mnt/root/kernel-build/linux-cachyos-bore-lto-r8125-7.0.11-1-x86_64.pkg.tar.zst
```

> Kernel packages are staged at `/root/kernel-build/` and will be installed in Section 12.
> Update version numbers and tag when you rebuild the kernel.

---

## 8. Chroot

```bash
arch-chroot /mnt
```

---

## 9. Timezone & Locale

```bash
ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
hwclock --systohc

nvim /etc/locale.gen
# Uncomment: en_US.UTF-8 UTF-8 and tr_TR.UTF-8 UTF-8
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=trq" > /etc/vconsole.conf
```

---

## 10. Hostname

```bash
echo "archforge" > /etc/hostname

nvim /etc/hosts
```

```
127.0.0.1   localhost
::1         localhost
127.0.1.1   archforge.localdomain archforge
```

---

## 11. Users & Sudo

```bash
passwd  # Set root password

useradd -m -G wheel,video,audio,storage,optical -s /bin/fish ee-aydogan
passwd ee-aydogan

EDITOR=nvim visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

---

## 12. Install Custom Kernel

```bash
cd /root/kernel-build
pacman -U linux-cachyos-bore-lto-*.pkg.tar.zst \
           linux-cachyos-bore-lto-headers-*.pkg.tar.zst \
           linux-cachyos-bore-lto-r8125-*.pkg.tar.zst
```

> Kernel was pre-built on your old system and published as a GitHub release (Section 7).
> Packages are already downloaded at `/root/kernel-build/`.

---

## 13. systemd-networkd

```bash
systemctl enable systemd-networkd
```

### Wired interface (`/etc/systemd/network/20-wired.network`)

```ini
[Match]
Name=enp*

[Network]
DHCP=yes
```

> No DNS config — DHCP handles it automatically.

---

## 14. UKI Boot (mkinitcpio)

### Kernel cmdline

```bash
mkdir -p /etc/kernel

echo "root=UUID=$(blkid -s UUID -o value /dev/nvme0n1p2) rw quiet loglevel=3 nowatchdog amd_pstate=active amdgpu.ppfeaturemask=0xffffffff mitigations=off threadirqs" > /etc/kernel/cmdline
```

### mkinitcpio hooks (`/etc/mkinitcpio.conf`)

```
MODULES=(amdgpu)
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck)
```

### mkinitcpio preset

> Use your saved `.preset` file (copy to `/etc/mkinitcpio.d/`).

```
ALL_kver="/boot/vmlinuz-linux"

PRESETS=('default' 'fallback')

default_uki="/boot/efi/Linux/arch-linux.efi"
default_options="--splash /usr/share/systemd/bootctl/splash-arch.bmp"

fallback_uki="/boot/efi/Linux/arch-linux-fallback.efi"
fallback_options="-S autodetect"
```

```bash
mkdir -p /boot/efi/Linux
mkinitcpio -P
```

### pacman hook — auto-rebuild UKI on kernel updates

```bash
mkdir -p /etc/pacman.d/hooks
nvim /etc/pacman.d/hooks/uki-update.hook
```

```ini
[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
Target = usr/lib/modules/*/vmlinuz
Target = boot/amd-ucode.img

[Action]
Description = Rebuilding UKI...
When = PostTransaction
Exec = /usr/bin/mkinitcpio -P
NeedsTargets
```

### efibootmgr — create boot entry

```bash
efibootmgr \
  --create \
  --disk /dev/nvme0n1 \
  --part 1 \
  --label "Arch Linux" \
  --loader "\\Linux\\arch-linux.efi" \
  --unicode

efibootmgr -v
```

---

## 15. CPU & Kernel Tuning

```bash
pacman -S cpupower irqbalance
systemctl enable cpupower irqbalance

nvim /etc/default/cpupower
# governor='performance'
```

### sysctl (`/etc/sysctl.d/99-sysctl.conf`)

```
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5
```

### makepkg — build on tmpfs

```bash
nvim /etc/makepkg.conf
# BUILDDIR=/tmp/makepkg
```

> CachyOS repo setup may already configure this.

---

## 16. AMD GPU

```bash
pacman -S mesa vulkan-radeon vulkan-mesa-layers mesa-utils rocm-smi-lib
```

---

## 17. adios (NVMe Scheduler)

```bash
mkdir -p /etc/udev/rules.d
nvim /etc/udev/rules.d/60-ioschedulers.rules
```

```
# HDD
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", \
    ATTR{queue/scheduler}="bfq"

# SSD
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \
    ATTR{queue/scheduler}="adios"

# NVMe SSD
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \
    ATTR{queue/scheduler}="adios"
```

---

## 18. Theming

### GTK

```bash
# Catppuccin GTK theme (AUR)
paru -S catppuccin-gtk-theme

# Icons — install Papirus from their repo (too large for package list):
# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
# Or use default Adwaita icons
```

Config files (already in `.files/`):
- `~/.config/gtk-3.0/settings.ini`
- `~/.config/gtk-4.0/settings.ini`

Env vars in `mango/env.conf`:
```
env=GDK_BACKEND,wayland
```

### Qt

```bash
pacman -S qt6ct
```

Env vars in `mango/env.conf`:
```
env=QT_QPA_PLATFORM,wayland
env=QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env=QT_QPA_PLATFORMTHEME,qt6ct
env=QT_AUTO_SCREEN_SCALE_FACTOR,1
```

Configure via GUI:

```bash
qt6ct
```

In the GUI:
1. **Appearance → Style**: `Fusion`
2. **Appearance → Palette**: pick a color scheme (e.g. Catppuccin-Mocha-Blue)
3. **Fonts**: set your preferred font and size
4. **Apply**

Manual config (`~/.config/qt6ct/qt6ct.conf`):

```ini
[Appearance]
style=Fusion
custom_palette=true
color_scheme_path=/home/ee-aydogan/.config/qt6ct/colors/catppuccin-mocha-blue.conf
```

> Make sure `color_scheme_path` uses your actual username, not the old `eydgn`.

Optional: Kvantum for more advanced Qt theming:

```bash
pacman -S kvantum
```

---

## 19. Exit & Reboot

```bash
exit
umount -R /mnt
reboot
```

---

## 20. Post-Boot

After reboot, log in as `ee-aydogan`.

### 20.1 Paru (AUR helper)

```bash
git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si
```

### 20.2 Dotfiles

```bash
git clone git@github.com:eydgn/.files.git ~/.files
```

Then symlink your configs (adjust paths as needed):

```bash
ln -sf ~/.files/bash_profile ~/.bash_profile
ln -sf ~/.files/bashrc ~/.bashrc
ln -sf ~/.files/gitconfig ~/.gitconfig
ln -sf ~/.files/modprobed.db ~/.config/modprobed.db

# Autologin
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo ln -sf ~/.files/autologin.conf /etc/systemd/system/getty@tty1.service.d/autologin.conf
```

### 20.3 GPG / SSH / Gopass

> **Before the reinstall**, back up these from your current system.
> Save them to a USB drive or encrypted cloud.

#### Pre-install backup (on current system)

```bash
# Export GPG secret keys (armored)
gpg --export-secret-keys --armor -o gpg-private-keys.asc
gpg --export-ownertrust -o gpg-ownertrust.txt

# Export SSH keys
cp -r ~/.ssh ssh-backup/
```

#### Post-install restore

```bash
# Copy your backup files into ~/ (from USB, cloud, etc.)
# Then:
gpg --import gpg-private-keys.asc
gpg --import-ownertrust gpg-ownertrust.txt

# Restore SSH keys
cp -r ssh-backup ~/.ssh
chmod 600 ~/.ssh/git       # or whatever your key is named
chmod 644 ~/.ssh/git.pub
eval $(ssh-agent)
ssh-add ~/.ssh/git

# Verify GPG and SSH
gpg --list-secret-keys
ssh -T git@github.com
```

#### Gopass (if you use a git remote store)

```bash
# Clone your remote password store
git clone git@github.com:eydgn/gopass.git ~/.local/share/gopass

# Init gopass with your master key ID
gopass init --path ~/.local/share/gopass 086EC6258AB3BCDF
gopass setup --remote git@github.com:eydgn/gopass.git

# Verify
gopass list
```

> Replace `086EC6258AB3BCDF` with your actual gopass master key ID if different.
> If your store is local-only (no git remote), just copy the `~/.local/share/gopass` directory instead.

### 20.4 Install packages

```bash
# Official
sudo pacman -S --needed - < ~/.files/pkgs-official.txt

# AUR
paru -S --needed - < ~/.files/pkgs-aur.txt

# Paru itself (if not already installed)
paru -S --needed paru-git
```

### 20.5 Enable services

```bash
systemctl enable --user pipewire pipewire-pulse wireplumber mako syncthing
```

---

## Sections to review / customize

| # | Section | Status |
|---|---|---|---|---|
| 0-3 | Boot, disks, fs, mount | Keep |
| 4 | Mirrors + CachyOS | Keep |
| 5 | Base install (no linux, no build deps) | Keep |
| 6 | fstab (genfstab + manual edits) | Keep |
| 7 | Download pre-built kernel from GitHub release | Keep |
| 8-11 | Chroot, tz, hostname, users | Keep |
| 12 | Install kernel (pacman -U, no build) | Keep |
| 13 | systemd-networkd only (no DNS) | Keep |
| 14 | UKI boot | Keep |
| 15 | CPU/kernel tuning | Keep |
| 16 | AMD GPU | Keep |
| 17 | adios scheduler | Keep |
| 18 | Qt/GTK Theming | Keep |
| 19 | Exit & reboot | Keep |
| 20 | Post-boot (paru, dotfiles, gpg/ssh/gopass, packages, services) | Keep |
