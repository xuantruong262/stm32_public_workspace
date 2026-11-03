# Bootloader sprint plan

This plan keeps each scope small, observable, and reversible.  Source/build
evidence is in `input/test_input/auto_collected`; physical-board evidence is
in `input/test_input/user_provided`.

| Scope | Objective | Result |
|---|---|---|
| S0 | Bootloader recovery baseline | PASS |
| S1 | Direct Primary hand-off to PG7 smoke app | PASS |
| S2 | Image validation decision | PASS |
| S3 | Confirmed Primary stable boot | PASS |
| S4 | TEST-to-CONFIRMED and no-confirm control | PASS |
| S5 | Invalid Primary recovery | PASS |
| S6 | USB protocol negative cases | PASS |
| S7 | Secondary download and abort boundary | PASS |
| S8 | First install from empty Primary | PASS |
| S9 | Normal A/B swap: app_1 (500 ms) to app_2 (3000 ms) | PASS |
| S10 | Power-fail-safe swap journal and recovery | NEXT |
| S11 | Secure boot: signature, anti-rollback, key protection | FUTURE |

## PASS definition for every scope

- **Build input:** the named firmware/profile builds with no errors; SIL tests
  pass when the scope changes boot policy or protocol.
- **Hardware input:** J-Link capture, raw Flash dump, CDC transcript, and/or
  PG7 behavior named by the scope report.
- **Expected output:** expected address, state record, and observable behavior
  agree; no unexpected change occurs in a protected slot.
- **Evidence:** runner-generated report exists under
  `input/test_input/user_provided/Sxx_*` and identifies the result.

## S10: power-fail-safe swap journal

- **Implementation:** define phase records for `PRIMARY_TO_SCRATCH`,
  `SECONDARY_TO_PRIMARY`, and `SCRATCH_TO_SECONDARY`; persist sector and phase
  after each step; resume deterministically after reset.
- **Test input:** inject reset/power cut after every sector-copy phase for each
  of the three sectors, with old and new images distinguishable.
- **Expected output:** on every restart, bootloader either resumes safely or
  returns one complete valid image; it never jumps to a mixed/corrupt image.
- **Pass gate:** exhaustive phase/sector fault matrix passes in SIL and HIL.

## S11: secure boot

- **Implementation:** add signed image manifest, public-key verification,
  protected key material, and monotonic anti-rollback version policy.
- **Test input:** valid signature, invalid signature, modified payload,
  modified header, old version, and interrupted update.
- **Expected output:** only an authentic allowed version can become PENDING or
  boot; failed candidates cannot modify confirmed Primary.
- **Pass gate:** all negative cases remain in recovery with the last confirmed
  image intact.
