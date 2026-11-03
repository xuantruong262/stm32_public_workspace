# Sprint plan: <project name>

Use one scope per unknown behavior.  Finish a scope only when its evidence is
captured and its report is updated.

| Scope | Objective | Change boundary | Status |
|---|---|---|---|
| S0 | Toolchain and observation baseline | No product policy change | Planned |
| S1 | Smallest end-to-end happy path | One interface + one output | Planned |
| S2 | Validation and rejection rules | Input boundary only | Planned |
| S3 | Persistent state / recovery behavior | State machine only | Planned |
| S4 | Full nominal integration | Defined integration boundary | Planned |

## Scope card: S<n> <title>

- **Objective:** `<single observable result>`
- **Implementation:**
  - `<small change 1>`
  - `<small change 2>`
- **Test input:**
  - `<artifact, command, fixture, or board condition>`
- **Expected output:**
  - `<precise output/state/measurement>`
- **PASS gate:**
  - `<automated test result>`
  - `<hardware/system observation and required evidence>`
- **Rollback/recovery:** `<how to return to a known state>`
- **Evidence path:** `input/test_input/<auto_collected|user_provided>/S<n>_*`

## Gate discipline

- S0 must prove the build and observation path before product behavior changes.
- A failed gate creates a focused diagnostic scope; do not extend feature scope
  until the cause is understood.
- A scope report records PASS, FAIL, or BLOCKED and the exact revision/artifact.
