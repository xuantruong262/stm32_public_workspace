# Unified bootloader runner

`Invoke-Sprint0.ps1` is the single reproducible runner for all completed
bootloader scopes.  It creates build artifacts and places hardware evidence in
`input/test_input/`.

## Commands

```powershell
# Build only: safe, no board writes
.\tools\sprint0\Invoke-Sprint0.ps1 -Scope S9 -Operation Build

# Build, flash, and capture: writes the connected board
.\tools\sprint0\Invoke-Sprint0.ps1 -Scope S9 -Operation All -AllowFlash -RecoveryCdcPort COM11

# Flash only, after a successful build
.\tools\sprint0\Invoke-Sprint0.ps1 -Scope S8 -Operation Flash -AllowFlash

# Capture current S9 results after an interrupted external tool session;
# does not erase/program Flash, but may reset the board to inspect it.
.\tools\sprint0\Invoke-Sprint0.ps1 -Scope S9 -Operation Capture -RecoveryCdcPort COM11
```

The runner auto-detects J-Link when installed in its normal SEGGER location;
`-JLinkPath` overrides it.  `-RecoveryCdcPort` defaults to `COM11` for this
workstation only.  Check Windows Device Manager after a USB re-enumeration.

## Scope matrix

| Scope | What it proves |
|---|---|
| S0 | Recovery bootloader baseline |
| S1 | Direct bootloader-to-PG7 smoke hand-off |
| S2 | Image/header/vector rejection rules |
| S3 | Confirmed Primary stable boot |
| S4 | TEST confirmation and no-confirm behavior |
| S5 | Invalid Primary recovery |
| S6 | USB protocol error handling |
| S7 | Secondary download and abort isolation |
| S8 | First install from erased Primary |
| S9 | A/B update: app_1 to app_2 through USB and Scratch |

S0-S9 are completed.  Their exact commands, expected behavior, and reports
are retained in `input/BOOTLOADER_SPRINT_PLAN.md` and the evidence folders.
