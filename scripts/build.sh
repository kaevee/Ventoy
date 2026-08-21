#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$ROOT_DIR/build"

mkdir -p "$OUT_DIR"

VARIANTS=("base" "docker")

for variant in "${VARIANTS[@]}"; do
    echo "Building $variant variant..."
    variant_dir="$ROOT_DIR/configs/ubuntu-$variant"
    img_path="$OUT_DIR/$variant.img"

    truncate -s 2M "$img_path"
    mkfs.vfat -n cidata "$img_path"
    mcopy -i "$img_path" "$variant_dir/user-data" "$variant_dir/meta-data" ::

    echo "Successfully built $img_path"
    echo
done

echo "Done! You can now copy configs/ventoy.json and the .img files in the build/ directory to your Ventoy USB."
