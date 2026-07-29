-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Workspaces 1-5 on the main monitor (DP-1)
for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
end

-- Workspaces 9-0 on the secondary monitor (DP-2)
hl.workspace_rule({ workspace = "9",  monitor = "DP-2" })
hl.workspace_rule({ workspace = "10", monitor = "DP-2", default = true })
