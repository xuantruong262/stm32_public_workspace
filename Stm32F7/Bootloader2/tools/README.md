# Tools

`sprint0/Invoke-Sprint0.ps1` is the only persistent build, Flash, and capture
entry point in this repository.  Older one-off scripts were deliberately
removed to prevent test and production flows from diverging.

```powershell
# Build and SIL checks for the A/B integration scope
.\tools\sprint0\Invoke-Sprint0.ps1 -Scope S9 -Operation Build

# Hardware test (programs/erases the board)
.\tools\sprint0\Invoke-Sprint0.ps1 -Scope S9 -Operation All -AllowFlash -RecoveryCdcPort COM11

# Complete a previously interrupted S9 capture without programming Flash
.\tools\sprint0\Invoke-Sprint0.ps1 -Scope S9 -Operation Capture -RecoveryCdcPort COM11
```

`-AllowFlash` is mandatory for every operation that erases or programs the
physical board.  See `sprint0/README.md` for the scope matrix.
