#!/usr/bin/env bash
set -e

IMAGE="demo-linux.img"
MEMORY="1024"   # 1GiB default

usage() {
  cat <<EOF
Usage:
  ./run-qemu.sh --demo
    Download a tiny demo disk image and run it.

  ./run-qemu.sh --image path/to/disk.img [--mem 2048]
    Run a custom disk image with optional memory size in MiB.

Notes:
  - If /dev/kvm exists and is usable, QEMU will use -enable-kvm.
  - Otherwise, it will fall back to software emulation (TCG).
EOF
}

has_kvm() {
  if [ -e /dev/kvm ]; then
    return 0
  else
    return 1
  fi
}

download_demo_image() {
  # Tiny example: download a small prebuilt Linux VM image.
  # This URL is just an example; replace with any raw/qcow2 image you like.
  local url="https://cloud-images.ubuntu.com/minimal/releases/focal/release/ubuntu-20.04-minimal-cloudimg-amd64.img"
  local out="$IMAGE"

  if [ -f "$out" ]; then
    echo "Demo image already exists: $out"
    return
  fi

  echo "Downloading demo image..."
  wget -O "$out" "$url"
}

run_qemu() {
  local disk="$1"
  local mem="$2"
  local accel_opts=""

  if has_kvm; then
    echo "INFO: /dev/kvm found. Using hardware acceleration (-enable-kvm)."
    accel_opts="-enable-kvm"
  else
    echo "WARNING: /dev/kvm not found. Falling back to software emulation (-accel tcg)."
    accel_opts="-accel tcg"
  fi

  echo "Starting QEMU with disk=$disk, mem=${mem}M"
  qemu-system-x86_64 \
    $accel_opts \
    -m "$mem" \
    -drive file="$disk",if=virtio,format=qcow2 \
    -nographic \
    -serial mon:stdio
}

# --------- main ---------

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  usage
  exit 0
fi

if [ "$1" = "--demo" ]; then
  download_demo_image
  run_qemu "$IMAGE" "$MEMORY"
  exit 0
fi

if [ "$1" = "--image" ]; then
  shift
  if [ -z "$1" ]; then
    echo "ERROR: --image requires a path to a disk image."
    usage
    exit 1
  fi
  IMG="$1"
  shift

  while [ $# -gt 0 ]; then
    case "$1" in
      --mem)
        shift
        MEMORY="$1"
        ;;
      *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done

  if [ ! -f "$IMG" ]; then
    echo "ERROR: image not found: $IMG"
    exit 1
  fi

  run_qemu "$IMG" "$MEMORY"
  exit 0
fi

echo "ERROR: no valid option given."
usage
exit 1
