# Environment: <project name>

## Reproducible baseline

| Item | Required version / identity | Verify command or evidence |
|---|---|---|
| Host OS | `<version>` | `<command>` |
| Compiler / SDK | `<version>` | `<command>` |
| Build system | `<version>` | `<command>` |
| Test runtime | `<version>` | `<command>` |
| Debug probe / device | `<model, serial if needed>` | `<command / photo / log>` |
| Target board | `<part number, revision>` | `<log / label>` |

## Single project runner

```text
<tools/Invoke-Project.ps1|sh|py>
  Build     -> configure + compile + static checks
  Test      -> unit/SIL tests
  Deploy    -> explicit opt-in physical target write
  Capture   -> logs, dumps, measurements
  All       -> Build + Test + Deploy + Capture
```

- Destructive actions require an explicit flag such as `-AllowFlash`.
- A capture-only mode must never erase/program the target.
- The runner writes generated evidence into `input/test_input/auto_collected/`
  and hardware evidence into `input/test_input/user_provided/`.

## Setup and recovery

1. `<install/setup command>`
2. `<connect board/device>`
3. `<build command>`
4. `<safe test command>`
5. `<how to identify/recover target after a failed deployment>`

## Known environment hazards

- `<port may change after reset>`
- `<tool requires a specific driver or privilege>`
- `<generated code may overwrite only USER CODE regions>`
