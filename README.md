# Mint Post-Install Tweaks

An automated post-installation setup, optimization, and verification toolkit for **Linux Mint 22.3 (Cinnamon)**.

---

## What's Included

### 1. Post-Installation Script (`post-installation.sh`)
Run with `sudo` on a fresh Linux Mint installation to configure the system in 7 automated steps:
* **System Update:** Updates package repositories and upgrades all installed packages.
* **Essential Packages & Codecs:** Installs multimedia codecs (`mint-meta-codecs`), media/PDF utilities (`ffmpeg`, `imagemagick`, `ghostscript`, `poppler-utils`), CLI tools (`micro`, `htop`, `inxi`, `xclip`, `curl`, `git`), and desktop notifications (`libnotify-bin`).
* **Security:** Enables the **UFW firewall** automatically.
* **Performance Tuning:**
  * Lowers swap usage by setting `vm.swappiness=10` in `/etc/sysctl.d/99-mint-tweaks.conf`.
  * Enables periodic SSD maintenance (`fstrim.timer`).
  * Installs `preload` to speed up application launch times.
* **Custom `.bashrc` Aliases:** Adds convenient terminal shortcuts for the target user:
  * `update` — Runs `sudo apt update && sudo apt upgrade -y`
  * `cleanup` — Removes unused packages and cleans apt cache
  * `sysinfo` — Displays clean system hardware info (`inxi -Fz`)
  * `pdfcompress` — Compresses PDFs via Ghostscript (`/ebook` quality)
  * `png2webp` — Alias for ImageMagick `convert`
* **Nemo Actions Deployment:** Automatically copies all `.nemo_action` files into `~/.local/share/nemo/actions/` with proper ownership and permissions.
* **Cleanup:** Runs `apt autoremove` and `apt clean`.

### 2. Custom Nemo File Manager Actions
Adds right-click context menu shortcuts directly inside the Nemo file manager:
* **`convert-to-webp.nemo_action`** — Converts selected images to `.webp` format.
* **`open-in-vscode.nemo_action`** — Opens files or folders directly in Visual Studio Code.
* **`pdf-compress.nemo_action`** — Compresses PDF files right from the file manager.

### 3. Verification & Health Check Script (`verify_mint_setup.sh`)
A diagnostic script that audits your setup and prints a pass/fail summary across four areas:
* **CLI & GUI Dependencies:** Verifies `gs`, `convert`, `pdfinfo`, `ffmpeg`, `xclip`, `inxi`, `pdfarranger`, `xournalpp`, `okular`, `preload`, and `notify-send`.
* **System & Security Settings:** Confirms `vm.swappiness` equals `10`, `fstrim.timer` is enabled, and UFW is active.
* **Nemo Actions:** Checks that all three `.nemo_action` files exist in `~/.local/share/nemo/actions/`.
* **Desktop Notifications:** Sends a live `notify-send` test alert to verify D-Bus desktop notifications work properly.

---

## Usage

### 1. Clone the Repository
```bash
git clone https://github.com
cd Mint-post-install
```

### 2. Run the Setup Script
Make the scripts executable and run `post-installation.sh` with `sudo` (required for system-level changes, while user files still deploy to your normal home directory):
```bash
chmod +x post-installation.sh verify_mint_setup.sh
sudo ./post-installation.sh
```
*(Reload your shell with `source ~/.bashrc` afterward to activate the new terminal aliases.)*

### 3. Verify Your Installation
Run the verification script **without `sudo`** so it can properly test desktop notifications:
```bash
./verify_mint_setup.sh
```

---

## Notes
* **Optional GUI PDF/Note Tools:** The verification script also checks for `pdfarranger`, `xournalpp`, and `okular`. If you use those tools, install them via `sudo apt install pdfarranger xournalpp okular`.
* **Personal Reference:** See [`GIT_CHEATSHEET.md`](GIT_CHEATSHEET.md) for quick Git and GitHub CLI notes.
