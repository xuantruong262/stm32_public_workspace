# Test plan: <project name>

## Test layers

| Layer | Purpose | Typical input | PASS evidence |
|---|---|---|---|
| Static/build | Compile, lint, format, size | Source revision | Tool output |
| Unit | Pure logic and edge cases | In-memory fixture | Test report |
| SIL | Cross-module policy without target hardware | Modelled I/O/fault injection | CTest/test binary log |
| HIL | Real peripherals, timing, toolchain, deployment | Board + probe + physical stimulus | J-Link/serial/capture report |
| System | User workflow and failure recovery | Full external interface | End-to-end report |

## Requirement matrix

| ID | Requirement / invariant | Test layer | Test input | Expected output | Evidence |
|---|---|---|---|---|---|
| R-001 | `<statement>` | `<layer>` | `<input>` | `<result>` | `<path>` |

## Negative and fault cases

- Invalid/short/corrupted input.
- Timeout, reset, disconnect, and retry at each state boundary.
- Resource exhaustion: size, capacity, sequence, memory, timing.
- Persistence/restart at every durable state transition.
- Security boundary violations where applicable.

## Test data policy

- Keep deterministic fixtures under version control.
- Hash generated binaries/dumps that are used as evidence.
- Never use production credentials or private keys in test artifacts.
