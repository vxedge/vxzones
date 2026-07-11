#!/usr/bin/env bash
# Build the `linux-probe` guest bundle: host kernel + minimal busybox initramfs
# that autostarts a static vxprobe reflector. Boots under both zone VM
# backends (qemu-microvm direct kernel boot, libvirt direct kernel boot).
#
# Usage:  ./scripts/build-guest-bundle.sh [out-dir]     (default images/linux-probe/bundle)
# Needs:  busybox-static (apt install busybox-static), rustup musl target
#         (added automatically), readable /boot/vmlinuz-$(uname -r).
#
# Guest contract: kernel cmdline `vx.ip=<cidr>` configures eth0; the payload
# (vxprobe reflect on 0.0.0.0:9800) starts as PID-1 child. Serial console
# carries logs. Bundle files are digest-recorded in meta.json (§13).
set -euo pipefail

OUT="${1:-images/linux-probe/bundle}"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WS="$(dirname "$REPO_DIR")"
cd "$REPO_DIR"

KVER="$(uname -r)"
KERNEL="/boot/vmlinuz-$KVER"
if [[ ! -r "$KERNEL" ]]; then
  echo "error: $KERNEL not readable — on Ubuntu:  sudo chmod 644 $KERNEL" >&2
  echo "       (or copy it somewhere readable and set KERNEL=...)" >&2
  exit 1
fi

BUSYBOX="$(command -v busybox || true)"
if [[ -z "$BUSYBOX" ]]; then
  echo "error: busybox not found —  sudo apt install busybox-static" >&2
  exit 1
fi
if ! file -b "$BUSYBOX" | grep -q "statically linked"; then
  echo "error: $BUSYBOX is not static —  sudo apt install busybox-static" >&2
  exit 1
fi

# Static vxprobe (musl) — pure-Rust deps, links with rustup's bundled musl.
echo "== building static vxprobe (x86_64-unknown-linux-musl)"
rustup target add x86_64-unknown-linux-musl >/dev/null 2>&1 || true
( cd "$WS/vxagents" && cargo build --release --target x86_64-unknown-linux-musl -p vxprobe )
VXPROBE="$WS/vxagents/target/x86_64-unknown-linux-musl/release/vxprobe"
file -b "$VXPROBE" | grep -Eq "statically linked|static-pie linked" || {
  echo "error: vxprobe did not link statically" >&2; exit 1; }

echo "== assembling initramfs"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE"/{bin,dev,proc,sys,etc}
cp "$BUSYBOX" "$STAGE/bin/busybox"
cp "$VXPROBE" "$STAGE/bin/vxprobe"
for app in sh ip mount sleep cat grep; do ln -s busybox "$STAGE/bin/$app"; done

cat > "$STAGE/init" <<'INIT'
#!/bin/sh
# vxzones linux-probe guest init: network from cmdline, then the payload.
/bin/mount -t proc proc /proc
/bin/mount -t sysfs sys /sys
/bin/mount -t devtmpfs dev /dev 2>/dev/null

CIDR=""
for tok in $(cat /proc/cmdline); do
  case "$tok" in vx.ip=*) CIDR="${tok#vx.ip=}";; esac
done
/bin/ip link set lo up
if [ -n "$CIDR" ]; then
  /bin/ip addr add "$CIDR" dev eth0
fi
/bin/ip link set eth0 up
echo "vxzones guest up: eth0=$CIDR — starting vxprobe reflector :9800"
exec /bin/vxprobe reflect --listen 0.0.0.0:9800
INIT
chmod +x "$STAGE/init"

mkdir -p "$OUT"
( cd "$STAGE" && find . -print0 | cpio --null -o -H newc 2>/dev/null | gzip -9 ) \
  > "$OUT/initrd.img"
cp "$KERNEL" "$OUT/vmlinuz"

python3 - "$OUT" "$KVER" <<'EOF'
import hashlib, json, pathlib, sys
out = pathlib.Path(sys.argv[1])
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
meta = {
    "bundle": "linux-probe",
    "kernel_version": sys.argv[2],
    "payload": "vxprobe reflect :9800 (static musl)",
    "files": {p.name: sha(out / p.name) for p in [out/"vmlinuz", out/"initrd.img"]},
}
(out / "meta.json").write_text(json.dumps(meta, indent=2) + "\n")
print(json.dumps(meta, indent=2))
EOF

echo "== bundle ready: $OUT (vmlinuz, initrd.img, meta.json)"
echo "== unprivileged boot check:"
echo "   qemu-system-x86_64 -M microvm,acpi=off -m 128m -nographic -nodefaults -no-user-config \\"
echo "     -serial stdio -kernel $OUT/vmlinuz -initrd $OUT/initrd.img \\"
echo "     -append 'console=ttyS0 vx.ip=10.0.0.2/24' -netdev user,id=n0 -device virtio-net-device,netdev=n0"
