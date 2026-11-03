# Bootloader handoff

## Current working state

The project implements and has hardware-tested a training A/B bootloader for
STM32H723ZG.  The current board demonstration is:

- `app_1`: PG7 blink every 500 ms.
- `app_2`: PG7 blink every 3000 ms.
- App-to-bootloader request over USB CDC, Secondary download over USB CDC,
  scratch-assisted activation, TEST boot, and application confirmation.
- Sprint S0-S9 have recorded PASS evidence.  Sprint S9 proves app_1 to app_2
  normal A/B activation and preservation of app_1 in Secondary.

The system is functional but not yet power-fail-safe during swap.  Treat it as
a learning/integration baseline, not production secure firmware.

## Start here

1. Read `design.md` for the current architecture and limitations.
2. Read `BOOTLOADER_SPRINT_PLAN.md` for verified scope and next work.
3. Use only `tools/sprint0/Invoke-Sprint0.ps1` for build, flash, and capture.
4. Use `flashing_tool/flashing_app.py` to perform normal USB updates.
5. Reuse `project_template/` when starting the next project; it contains the
   generic charter, environment, design, test, evidence, and handoff skeleton.

## Important locations

| Item | Location |
|---|---|
| Bootloader project | `bootloader/bootloader` |
| Reusable app API | `app_bootloader` |
| Training app source | `app/app_1` |
| Host flashing GUI | `flashing_tool/flashing_app.py` |
| Build/flash/test runner | `tools/sprint0/Invoke-Sprint0.ps1` |
| Hardware and build evidence | `input/test_input` |

## Current operating rule

The running-app CDC port and bootloader CDC port are normally both `COM11` on
the training workstation, but Windows may reassign the port after USB
re-enumeration.  The GUI accepts both ports explicitly.  It sends only raw
application `.bin` data to Secondary; never program a downloaded image
directly into Primary with a debugger.
