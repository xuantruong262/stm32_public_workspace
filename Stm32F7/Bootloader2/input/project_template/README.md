# Reusable project skeleton

Copy this folder into a new project before implementation.  Replace every
`<placeholder>` and keep the documents small enough to remain useful after a
long break from the project.

```text
project-root/
  input/
    project_template/              <- this reusable skeleton
    test_input/
      auto_collected/              <- reproducible generated evidence
      user_provided/               <- hardware/manual evidence
  docs/                            <- optional published/exported documents
  source/                          <- product source code
  tests/                           <- automated tests and fixtures
  tools/                           <- one approved project runner
```

## Required documents

| Document | Owns | Update when |
|---|---|---|
| `PROJECT_CHARTER.md` | Why, scope, success, constraints | A goal/scope changes |
| `ENVIRONMENT.md` | Reproducible tools and board setup | Toolchain, board, or command changes |
| `DESIGN.md` | Architecture, contracts, limitations | A design decision changes |
| `SPRINT_PLAN.md` | Small execution scopes and gates | Starting/completing a scope |
| `TEST_PLAN.md` | Test matrix and required evidence | A requirement or risk changes |
| `TEST_REPORT.md` | Current verified result | A test run completes |
| `DECISION_LOG.md` | Durable decision rationale | A non-trivial trade-off is made |
| `HANDOFF.md` | Current state and next action | Pausing or transferring work |

## Operating rules

1. A design claim is not complete until it names the source owner and test
   that proves it.
2. One persistent runner builds, tests, flashes/deploys, and captures evidence.
   Delete or archive one-off scripts once their behavior is absorbed there.
3. Separate generated/reproducible evidence from physical-board or manually
   collected evidence.
4. Every scope has a narrow observable outcome, explicit inputs, and a PASS
   gate.  Do not merge multiple unknowns into one hardware test.
5. Record limitations explicitly; a known unsupported condition is safer than
   an implied guarantee.

Start with `PROJECT_CHARTER.md`, then define the environment and design before
writing the first implementation scope.
