# SIL test report

## Current baseline

The host SIL suite contains 24 named tests in
`tests/sil/test_bootloader.c`.  It verifies Flash-model rules, image and
trailer validation, update sequencing, first install, confirmed boot,
TEST/CONFIRMED/REVERT policy, malformed input recovery, trailer capacity, and
the USB protocol model.

Run the suite through the unified runner:

```powershell
.\tools\sprint0\Invoke-Sprint0.ps1 -Scope S9 -Operation Build
```

The command builds the target firmware and runs CTest for the SIL executable.
Its current build log is stored in
`input/test_input/auto_collected/S09_build.log`; board-level proof belongs in
the corresponding `input/test_input/user_provided/S09_*` evidence.

## Interpretation

- SIL is a logic and regression gate; it is not a substitute for HIL.
- HIL S0-S9 evidence is retained separately and includes the actual single-bank
  RAM-Flash behavior that a host Flash model cannot reproduce.
- Neither SIL nor S9 proves power-fail safety during a scratch swap.  That is
  the explicit S10 exit criterion.
