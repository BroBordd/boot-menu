# boot-menu

Native Android boot menu built on [Stratum](https://github.com/BroBordd/stratum). Runs before the Android framework via KernelSU's `post-fs-data` stage, giving you a fullscreen GLES2 overlay to redirect boot before anything else starts.

Supports touch and hardware buttons. Prebuilt for **aarch64**.

![boot menu](https://github.com/user-attachments/assets/91b93f88-13d5-4b70-900c-408eb571822b)

## What's in here

This repo is the KernelSU module — ready to flash:

```
├── module.prop
├── post-fs-data.sh
└── system/
    ├── bin/stratum, stratum_binary
    └── lib64/libstratum.so, stub.so
```

Source lives in [Stratum](https://github.com/BroBordd/stratum) under `stratum-boot/`. Build with `scripts/build_module.sh` there.

## Actions

| Entry | Command |
|---|---|
| Continue to System | *(exit, let boot proceed)* |
| Reboot | `reboot` |
| Recovery | `reboot recovery` |
| Download Mode | `reboot download` |
| Power Off | `reboot -p` |

## Controls

| Input | Action |
|---|---|
| Volume Up / Down | Navigate |
| Power | Confirm |
| Tap item | Select / open confirm dialog |

Auto-boots into system after a configurable timeout if no input is received.

## Requirements

- KernelSU
- aarch64 device supported by Stratum — see [StratumConfig.h](https://github.com/BroBordd/stratum/blob/main/include/StratumConfig.h)

## Related

- [Stratum](https://github.com/BroBordd/stratum) — the framework this is built on

## License

Copyright (C) 2026 BrotherBoard — GNU General Public License v3.0. See [LICENSE](LICENSE).
