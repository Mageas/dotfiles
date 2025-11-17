#!/bin/bash

SELECTED_THEME='catppuccin-mocha'

# script path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SELECTED_THEME_PATH="${SCRIPT_DIR}/themes/${SELECTED_THEME}"

cp "${SELECTED_THEME_PATH}/kitty/colors.conf" "${HOME}/.config/kitty/styles/colors.conf" > /dev/null 2>&1
