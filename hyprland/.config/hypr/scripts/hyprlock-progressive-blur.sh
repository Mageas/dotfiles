#!/bin/bash

# Remove old flag
rm -f /tmp/hypridle-stop-hyprlock-progressive-x

# Progressive blur: 20 steps over 10 seconds
for i in {1..20}; do
    # Check if flag exists to stop
    if [ -f /tmp/hypridle-stop-hyprlock-progressive-x ]; then
        exit 0
    fi

    # Calculate blur intensity (0.5 to 10)
    blur=$(echo "scale=2; $i * 0.5" | bc)

    cat > /tmp/blur-progressive.glsl << EOF
#version 320 es
precision mediump float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec2 texelSize = vec2(1.0) / vec2(textureSize(tex, 0));
    vec4 color = vec4(0.0);
    float radius = ${blur}f;

    // Simple box blur
    for (float x = -radius; x <= radius; x += 1.0) {
        for (float y = -radius; y <= radius; y += 1.0) {
            vec2 offset = vec2(x, y) * texelSize;
            color += texture(tex, v_texcoord + offset);
        }
    }

    float samples = (radius * 2.0 + 1.0) * (radius * 2.0 + 1.0);
    fragColor = color / samples;
}
EOF

    hyprctl keyword decoration:screen_shader /tmp/blur-progressive.glsl
    sleep 0.5
done

hyprctl keyword decoration:screen_shader "[[EMPTY]]"
sleep 0.1
hyprlock &>/dev/null &
