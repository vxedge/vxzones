# Changelog

All notable changes to this repo are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/) — see `docs/VERSIONING.md` in the `docs` repo.

## [Unreleased]

## [0.1.0] - 2026-07-13

**Phase-1 gate passed**: H1, H3, and H4 all have reproducible numbers (`vxperiments`),
using this repo's guest bundle. Note: this repo is already public (has been since before
the phase-1 gate); the other phase-1 repos stay private for now — see `docs/STATUS.md`
for the public-visibility punch list being applied to them before they follow.

### Added
- `linux-probe` guest bundle builder (`scripts/build-guest-bundle.sh`): host kernel +
  busybox initramfs + static-musl `vxprobe` reflector, SHA256-digested `meta.json`
  (2026-07-11). Used by exp-002/exp-002b's microvm/libvirt arms.

### Known gaps
- Real-RTOS bundles (Zephyr, FreeRTOS) not started — `vxzones/TASKS.md`.
- QNX SDP 8 / AAOS image recipes are phase-2 scope.
