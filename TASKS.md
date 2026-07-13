# TASKS.md — vxedge/vxzones

## Phase 1 (critical path: minimal guests for exp-001)

- [x] `linux-probe` guest bundle builder (2026-07-11, `scripts/build-guest-bundle.sh`):
      host kernel + busybox initramfs + static-musl vxprobe reflector, SHA256-digested
      `meta.json` → `images/linux-probe/bundle/`. Used by exp-002/exp-002b's microvm and
      libvirt arms — which also proved the boot-under-vxedge contract for both VM
      backends (H3 numbers measured on this bundle)
- [ ] Repo layout: `manifests/`, `images/<guest>/`, `scripts/publish/`
- [ ] Zone manifests for the six roles (schema §6.1), initially with placeholder nodes
- [ ] Zephyr microVM image: virtio-net, boots <1s, runs a UDP echo/probe payload
- [ ] FreeRTOS microVM image: same contract
- [ ] Digest tooling: build → sha256 tag → publish script (local registry/dir first;
      `meta.json` digests exist for linux-probe — generalize per-guest)

## Phase 2

- [ ] QNX SDP 8 guest recipe (x86-64 QEMU): fetch/build instructions, virtio drivers, probe
      payload; document the QNX-Hypervisor-inversion caveat in the recipe README
- [ ] AAOS emulator image for `rear-left`/`rear-right` infotainment nodes (virtio-gpu;
      GPU passthrough variant documented)
- [ ] Sensor-node image variant emitting camera/lidar-shaped traffic (pre-CARLA synthetic)

## Phase 3

- [ ] Kuksa client / VSS signal emitters in zone guests (vehicle manifest support)
- [ ] rmw_zenoh-capable guest variant for ROS2-speaking nodes
- [ ] ARM64 image variants (Jetson AGX hosts; Snapdragon vSoC / Graviton cloud
      virtual-ECU parity)
- [ ] CAN-capable guest variants: QEMU CAN controller / SocketCAN in guests, emitting
      realistic sensor frames onto `type: can` links
- [ ] RSU node image (`type: rsu`): V2I endpoint sourcing/sinking ETSI ITS-style messages
- [ ] Restbus node images: DBC-driven CAN sensor/actuator emitters (per manifest
      `sensors:`/`actuators:` blocks)
- [ ] Renode firmware targets: Zephyr/FreeRTOS builds runnable under `backend: renode`
      (register-level GPIO/ADC/CAN peripherals)

## Phase 4 (optional)

- [ ] Zone images validated on physical Jetson / DRIVE AGX hardware
