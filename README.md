# Ventoy Autoinstall Seed Images

Pre-built [cloud-init](https://cloud-init.io/) autoinstall images for unattended Ubuntu Server 26.04 installations via [Ventoy](https://www.ventoy.net/).

## Download

Grab the latest `base.img`, `docker.img`, and `ventoy.json` from the [Releases](https://github.com/kaevee/Ventoy/releases) page — no build needed.

## Variants

| Variant | Hostname | Description |
|---------|----------|-------------|
| **base** | `ubuntu-minimal` | Minimal Ubuntu Server with core tools (curl, wget, htop, vim, etc.), SSH, and UFW |
| **docker** | `ubuntu-docker` | Base + [Docker CE](https://docs.docker.com/engine/install/ubuntu/) with Buildx and Compose plugins |

Both variants create a `sysadmin` user with SSH access and UFW enabled.

## Prerequisites

### Windows (PowerShell + WSL)

- [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) with `dosfstools` and `mtools` installed inside WSL

### Linux

- `dosfstools` (provides `mkfs.vfat`)
- `mtools` (provides `mcopy`)

Install on Debian/Ubuntu:
```bash
sudo apt-get install dosfstools mtools
```

## Building

### Windows

```powershell
.\scripts\build.ps1
```

### Linux

```bash
chmod +x scripts/build.sh
./scripts/build.sh
```

Both scripts produce `.img` files in the `build/` directory.

## Deploying to Ventoy USB

### Quick Install (from GitHub Releases)

**PowerShell (Windows):**
```powershell
iex "& { $(irm https://raw.githubusercontent.com/kaevee/Ventoy/main/scripts/install.ps1) } -Drive D:"
```

**Bash (Linux/macOS):**
```bash
curl -fsSL https://raw.githubusercontent.com/kaevee/Ventoy/main/scripts/install.sh | bash -s -- /mnt/usb
```

This downloads the latest release and places everything in the right directories on your Ventoy USB.

### Manual Install

1. Download `base.img`, `docker.img`, and `ventoy.json` from the [Releases](https://github.com/kaevee/Ventoy/releases) page.

2. Copy them to your Ventoy USB:
   ```
   <USB>/ventoy/ventoy.json
   <USB>/ventoy/autoinstall/base.img
   <USB>/ventoy/autoinstall/docker.img
   ```

3. Boot from the USB — Ventoy will prompt you to choose a template (base or docker) for the unattended install.

## Default Credentials

> **⚠️ Change the password before production use!**

- **Username:** `sysadmin`
- **Password:** `changeme`

To generate a new password hash:
```bash
openssl passwd -6
```

Then replace the `password` field in `configs/ubuntu-*/user-data`.

## Project Structure

```
├── .github/workflows/
│   ├── build.yml                 # CI: validates + builds on push/PR
│   └── release.yml               # CD: publishes to GitHub Releases on tags
├── configs/
│   ├── ventoy.json               # Ventoy auto_install mapping
│   ├── ubuntu-base/              # Base variant cloud-init
│   │   ├── user-data
│   │   └── meta-data
│   └── ubuntu-docker/            # Docker variant cloud-init
│       ├── user-data
│       └── meta-data
├── scripts/
│   ├── build.ps1                 # Windows build script (WSL)
│   ├── build.sh                  # Linux build script
│   ├── install.ps1               # Windows installer (from GitHub Releases)
│   └── install.sh                # Linux/macOS installer (from GitHub Releases)
└── build/                        # Output directory (git-ignored)
```

## CI

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| **Build** | Push/PR to `main`/`master` | Validates configs, builds images, uploads as workflow artifacts (7-day retention) |
| **Release** | Push a `v*` tag | Builds images and publishes them as GitHub Release assets |

To publish a release:
```powershell
git tag v1.0.0
git push origin v1.0.0
```
