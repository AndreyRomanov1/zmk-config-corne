#!/usr/bin/env bash
# Локальная сборка прошивки в Docker-образе ZMK. Результат — firmware/*.uf2
set -euo pipefail
repo="$(cd "$(dirname "$0")" && pwd)"
ws="${ZMK_WS:-$HOME/.cache/zmk-ws}"
mkdir -p "$ws/config" "$repo/firmware"
cp "$repo/config/west.yml" "$ws/config/"
docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "$ws:/ws" -v "$repo:/cfg" -w /ws zmkfirmware/zmk-build-arm:stable bash -ec '
    [ -d .west ] || west init -l config
    west update --narrow -o=--depth=1
    west zephyr-export >/dev/null
    for shield in corne_left corne_right settings_reset; do
      west build -p -s zmk/app -d build/$shield -b nice_nano_v2 -- \
        -DSHIELD=$shield -DZMK_CONFIG=/cfg/config
      cp build/$shield/zephyr/zmk.uf2 /cfg/firmware/$shield.uf2
    done'
ls -la "$repo/firmware"
