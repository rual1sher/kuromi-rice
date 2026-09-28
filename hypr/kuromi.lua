-- Kuromi rice: bindings and look. Loaded from hyprland.lua via require("hypr.kuromi").

local bin = os.getenv("HOME") .. "/.local/bin"

-- Kuromi rice: open cava, clock, live fastfetch and now-playing on an empty workspace.
o.bind("SUPER + SHIFT + K", "Kuromi rice", bin .. "/kuromi-rice")

-- Kuromi power menu (was: System menu, now moved to SUPER+SHIFT+ESCAPE).
hl.unbind("SUPER + ESCAPE")
o.bind("SUPER + ESCAPE", "Power menu", "omarchy-shell shell toggle rualisher.powermenu '{}'")
o.bind("SUPER + SHIFT + ESCAPE", "System menu", "omarchy-menu toggle system")

-- Kuromi rice: soft rounded glassy windows with lavender borders.
hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 12,
    border_size = 2,
  },
  decoration = {
    rounding = 6,
    active_opacity = 0.94,
    inactive_opacity = 0.88,
    blur = {
      enabled = true,
      size = 6,
      passes = 3,
      vibrancy = 0.2,
    },
  },
})
