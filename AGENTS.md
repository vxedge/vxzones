# AGENTS.md — vxedge/vxzones

Authoritative zone manifests, VM images, and RTOS builds for the six zone roles
(`front-left`, `front-right`, `rear-left`, `rear-right`, `central-hpc`, `gateway`).
Master spec: `../docs/ARCHITECTURE.md` §6 (zone schema), §9 (virtualization stack).

## What lands here

- Zone manifests (YAML, schema §6.1 `zones:` block) — **authoritative for images and node IDs**.
- Image build recipes + publish scripts for guests:
  - Zephyr / FreeRTOS microVM images (QEMU `microvm` machine type)
  - QNX SDP 8 guest images (free non-commercial license — never commit QNX binaries/licensed
    artifacts; commit recipes and fetch instructions only)
  - Android Automotive (AAOS) emulator images for the infotainment zone
- All published images are tagged with SHA256 digests (reproducibility rule, §13).

## Rules

- The `jetson-device` skill targets this repo for memory/latency/telemetry evaluation of
  virtual ECUs (phase 4 hardware-in-loop).
- Guests must boot under the vxedge backends: libvirt domain (default) or raw-QEMU microvm.
  Every image recipe documents which `backend:` values it supports.
- Keep images minimal: agents from `vxagents` are injected per experiment, not baked in.
- Licensing hygiene: QNX and AAOS artifacts follow their upstream licenses; recipes must be
  runnable by anyone with their own license/SDK access.

## Project skills

AI/contributor skills in `.claude/skills/`: **testbed-quality** (the OEM-adoption bar —
reproducibility, fidelity honesty, interface stability, standards legibility).
