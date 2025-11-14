#!/usr/bin/env python3
"""
Generate hyprlock.conf from matugen colors.conf
Converts hex colors to rgba() format
"""

import re
import os
import sys


def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple"""
    hex_color = hex_color.lstrip("#")
    if len(hex_color) == 6:
        r = int(hex_color[0:2], 16)
        g = int(hex_color[2:4], 16)
        b = int(hex_color[4:6], 16)
        return (r, g, b)
    return None


def get_colors_from_conf(colors_file):
    """Extract all color values from colors.conf"""
    colors = {}
    try:
        with open(colors_file, "r") as f:
            for line in f:
                # Match lines like: $primary = rgba(82d3e2ff)
                match = re.search(r"\$(\w+)\s*=\s*rgba\(([0-9a-fA-F]{6})ff\)", line)
                if match:
                    color_name = match.group(1)
                    hex_color = match.group(2)
                    colors[color_name] = hex_to_rgb(hex_color)
    except FileNotFoundError:
        print(f"Error: {colors_file} not found", file=sys.stderr)
        sys.exit(1)
    return colors


def get_image_path(colors_file):
    """Extract image path from colors.conf"""
    try:
        with open(colors_file, "r") as f:
            for line in f:
                match = re.search(r"\$image\s*=\s*(.+)", line)
                if match:
                    return match.group(1).strip()
    except FileNotFoundError:
        pass
    return None


def generate_hyprlock_conf(template_file, output_file, colors_file):
    """Generate hyprlock.conf with RGB values"""

    colors = get_colors_from_conf(colors_file)
    image_path = get_image_path(colors_file)

    # Read template
    with open(template_file, "r") as f:
        content = f.read()

    # Replace image path (handle both {{image}} placeholder and existing paths)
    if image_path:
        content = re.sub(r"path = .+", f"path = {image_path}", content)
        content = content.replace("{{image}}", image_path)

    # Replace color placeholders
    color_replacements = {
        "BACKGROUND": colors.get("background", (14, 20, 22)),
        "PRIMARY": colors.get("primary", (130, 211, 226)),
        "SECONDARY": colors.get("secondary", (177, 203, 208)),
        "ON_SURFACE": colors.get("on_surface", (222, 227, 229)),
        "ON_SURFACE_VARIANT": colors.get("on_surface_variant", (191, 200, 202)),
        "ERROR": colors.get("error", (255, 180, 171)),
        "TERTIARY": colors.get("tertiary", (187, 197, 234)),
    }

    for placeholder, rgb in color_replacements.items():
        content = content.replace(f"{placeholder}_R", str(rgb[0]))
        content = content.replace(f"{placeholder}_G", str(rgb[1]))
        content = content.replace(f"{placeholder}_B", str(rgb[2]))

    # Write output
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, "w") as f:
        f.write(content)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: generate-hyprlock.py <template_file> <output_file> <colors_file>")
        sys.exit(1)

    template_file = os.path.expanduser(sys.argv[1])
    output_file = os.path.expanduser(sys.argv[2])
    colors_file = os.path.expanduser(sys.argv[3])

    generate_hyprlock_conf(template_file, output_file, colors_file)
