#!/bin/bash

# Remove old flag
rm -f /tmp/hypridle-stop-hyprlock-progressive-x

# Progressive dim: 20 steps over 10 seconds
for i in {20..1}; do
    # Check if flag exists to stop
    if [ -f /tmp/hypridle-stop-hyprlock-progressive-x ]; then
        exit 0
    fi

    intensity=$(echo "scale=2; $i / 20" | bc)

    cat > /tmp/dim-progressive.glsl << EOF
#version 320 es
precision mediump float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

void main() {
    fragColor = texture(tex, v_texcoord) * ${intensity}f;
}
EOF

    hyprctl keyword decoration:screen_shader /tmp/dim-progressive.glsl
    sleep 0.5
done

hyprctl keyword decoration:screen_shader "[[EMPTY]]"
sleep 0.1
hyprlock &>/dev/null &
