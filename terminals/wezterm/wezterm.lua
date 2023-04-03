local lib = require("lib")
local wezterm = require("wezterm")
local nerdfonts = wezterm.nerdfonts

-- Your custom configuration. This will be merged with the default config.
-- This will take "precidence" over any options in the default configuration
-- Note, to "cancel" something in the default configuration, set its value to
-- "none"
-- EG: pref_fonts = "none"
local user_config = {
    pref_fonts = {'JetBrains Mono', 'MesloLGS NF'},
    env_vars = { NOTMUX = "1" },
    tab_bar_appearance = 'Retro',
    tab_bar_location = 'Bottom',
    cursor_style = 'BlinkingBar',
    inactive_pane_hsb = {
        saturation = 0.7,
        brightness = 0.2
    },
    opacity = { window = 0.85 },
    raw = {
        window_close_confirmation = 'NeverPrompt'
    }
}

return lib.load(user_config)
