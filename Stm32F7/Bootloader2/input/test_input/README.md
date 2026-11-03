# Test evidence archive

```text
test_input/
  auto_collected/  reproducible build artifacts, generated cases, manifests
  user_provided/   J-Link, CDC, Flash dumps, and human/HIL reports
```

## Rules

- Keep completed Sprint evidence immutable; add a new `Sxx_*` item for a new
  run rather than overwriting a report used to justify a prior result.
- Raw Flash dumps must state the base address (`0x08000000`) in the companion
  log or filename.
- Store J-Link output as `Sxx_jlink_*.txt`; store CDC/flashing GUI output as
  `Sxx_update_*` or the scope report.
- `auto_collected/ARTIFACT_MANIFEST.md` records rebuildable snapshots and
  hashes.  Refresh it when testing a new revision.
- Never place private signing keys, credentials, or unrelated personal files
  here.

The current scope result and evidence requirements are in
`../BOOTLOADER_SPRINT_PLAN.md`.
