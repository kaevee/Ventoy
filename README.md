# Ventoy Autoinstall Seed Images

Pre-built [cloud-init](https://cloud-init.io/) autoinstall images for unattended Ubuntu Server 22.04 installations via [Ventoy](https://www.ventoy.net/).

## Variants

| Variant | Hostname | Description |
|---------|----------|-------------|
| **base** | `ubuntu-minimal` | Minimal Ubuntu Server with core tools (curl, wget, htop, vim, etc.), SSH, and UFW |
| **docker** | `ubuntu-docker` | Base + Docker Engine and Docker Compose v2 |

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

1. Copy the ISO to your Ventoy USB:
   ```
   <USB>/iso/ubuntu-22.04-live-server-amd64.iso
   ```

2. Copy the autoinstall images:
   ```
   <USB>/ventoy/autoinstall/base.img
   <USB>/ventoy/autoinstall/docker.img
   ```

3. Copy the Ventoy config:
   ```
   <USB>/ventoy/ventoy.json
   ```

4. Boot from the USB — Ventoy will prompt you to choose a template (base or docker) for the unattended install.

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
├── .github/workflows/build.yml   # CI: builds images on push/PR
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
│   └── build.sh                  # Linux build script
└── build/                        # Output directory (git-ignored)
```

## CI

The GitHub Actions workflow automatically builds the `.img` files on every push/PR to `main`/`master`. Artifacts are available for download for 7 days.
