# boot-menu

Native Android boot menu built on [Stratum](https://github.com/BrotherBoard/stratum). Runs before the Android framework via KernelSU's `post-fs-data` stage, giving you a fullscreen GLES2 overlay to redirect boot before anything else starts.

## What's in here

This repo is the KernelSU module — ready to build and flash:

```
├── module.prop
├── post-fs-data.sh
└── system/
    ├── bin/stratum, stratum_binary
    └── lib64/libstratum.so, stub.so
```

The source lives in the [Stratum](https://github.com/BrotherBoard/stratum) repo under `stratum-boot/`. Build it with `scripts/build_module.sh` there, then the output drops here.

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
- Device supported by Stratum — see [StratumConfig.h](https://github.com/BrotherBoard/stratum/blob/main/include/StratumConfig.h)

## Related

- [Stratum](https://github.com/BrotherBoard/stratum) — the framework this is built on

## License

Copyright (C) 2026 BrotherBoard — GNU General Public License v3.0. See [LICENSE](LICENSE).
