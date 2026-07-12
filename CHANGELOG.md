# Changelog

All notable changes to this repo are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/) once the first tag is cut (see
`docs/VERSIONING.md` in the `docs` repo — no `v0.1.0` yet, pre-phase-1-gate).

## [Unreleased]

### Added
- `linux-probe` guest bundle builder (`scripts/build-guest-bundle.sh`): host kernel +
  busybox initramfs + static-musl `vxprobe` reflector, SHA256-digested `meta.json`
  (2026-07-11). Used by exp-002/exp-002b's microvm/libvirt arms.

### Known gaps
- Real-RTOS bundles (Zephyr, FreeRTOS) not started — `vxzones/TASKS.md`.
- QNX SDP 8 / AAOS image recipes are phase-2 scope.
