# boot-menu

A bare-metal boot menu for rooted Android devices, built on [Stratum](https://github.com/BroBordd/stratum). Runs before the Android framework starts, giving you full control over the boot process.

![Boot Menu](https://github.com/user-attachments/assets/07c84df3-df0b-45ab-9b35-8c32846863a0)

## Features

- Continue to system, reboot, recovery, download mode, or power off
- Confirms all destructive actions before executing
- Tracks Android boot status in real time — animated progress bar while booting, solid green when ready
- Launches extra utility apps from the extras folder via the Advanced menu
- Touch and hardware key navigation (volume up/down to navigate, power to confirm)
- Auto-continues to system after a configurable timeout
- Dry-run mode for testing without executing commands

## Installation

Flash the zip via KernelSU or compatible root manager. The module installs to `/data/adb/modules/boot-menu/` and hooks into early boot via `post-fs-data.sh`. The zip is built for a specific device — check the filename for your target.

## Extras

Drop any [Stratum](https://github.com/BroBordd/stratum)-based binary into `/data/adb/modules/boot-menu/extras/` and it will appear in the Advanced menu. The following extras from [stratum-apps](https://github.com/BroBordd/stratum-apps) are included by default:

- **terminal** — PTY-backed terminal emulator with touch keyboard
- **calculator** — Lightweight expression calculator
- **brickbreaker** — Arcade-style brick breaker game
- **signal** — Real-time signal and waveform visualizer
- **sysinfo** — System information and diagnostics viewer

## Building

### 1. Clone with submodules

```bash
git clone --recurse-submodules https://github.com/BroBordd/boot-menu
cd boot-menu
```

Or if already cloned:

```bash
git submodule update --init --recursive
```

### 2. Build Stratum for your device

Your device must have a folder under `stratum/devices/<model>/` with `StratumConfig.h`. See [Stratum](https://github.com/BroBordd/stratum) for details on adding a new device.

```bash
bash stratum/scripts/build.sh <device> -l
```

### 3. Build boot-menu

```bash
bash scripts/build.sh <device>         # build everything
bash scripts/build.sh <device> -m      # bootmenu only
bash scripts/build.sh <device> -e      # extras only
```

Output zip: `<device>-boot-menu.zip`

### 4. Run for testing (without flashing)

```bash
bash scripts/run.sh <device>
```

## License

Copyright (C) 2026 BrotherBoard — GNU General Public License v3.0. See [LICENSE](LICENSE).
