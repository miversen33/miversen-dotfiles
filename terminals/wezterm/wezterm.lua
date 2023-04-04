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
    color_scheme = 'MaterialDesignColors',
    colors = {
        tab_bar = {
            background = 'BLACK',
            new_tab = {
                bg_color = 'BLACK',
                fg_color = 'WHITE'
            },
            new_tab_hover = {
                bg_color = wezterm.color.parse('BLACK'):lighten(.40),
                fg_color = 'WHITE',
                italic = true
            }
        },
    },
    raw = {
        window_close_confirmation = 'NeverPrompt',
    }
}

return lib.load(user_config)
