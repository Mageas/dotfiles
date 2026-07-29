-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/ for workspace rules

-- Example windowrule
-- hl.window_rule({ match = { class = "^(kitty)$", title = "^(kitty)$" }, float = true })

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Privacy filter
hl.window_rule({ match = { class = "^(discord)$" }, no_screen_share = true })

-- Discord on workspace 10
hl.window_rule({ match = { class = "^(discord)$" }, workspace = "10" })

-- Center new floating windows
hl.window_rule({ match = { float = true }, center = true })

-- For any dialog windows (you can customize the class name)
hl.window_rule({ match = { class = "^(.*dialog.*)$" }, float = true, center = true })

-- Kitty terminal settings (manage opacity on hypr instead of kitty so it doesn't break the gnome colors setup)
hl.window_rule({ match = { class = "^(kitty)$" }, opacity = "0.8 override" })

-- NM Connection Editor settings
hl.window_rule({
    match  = { class = "^(nm-connection-editor)$" },
    float  = true,
    center = true,
    size   = { 800, 600 },
})

-- Pavucontrol settings
hl.window_rule({
    match  = { class = "^(org.pulseaudio.pavucontrol)$" },
    float  = true,
    center = true,
    size   = { 800, 600 },
})

-- Blur wlogout
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })

hl.layer_rule({
    match     = { namespace = "rofi" },
    blur      = true,
    animation = "popin 95%",
})
