local wezterm = require 'wezterm'
local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return {
    color_scheme = "Dark Solarized",
    color_schemes = {
        ["Dark Solarized"] = {
            foreground = "#B6ADFF",
            background = "#1E282C",
            cursor_bg  = "#BFBFBF",
            cursor_fg  = "#FFFFFF",
            split      = "#B6ADFF"
        }
    },
    default_cursor_style = "BlinkingBar",
    hide_tab_bar_if_only_one_tab = true,
    font_size = 12.0,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    },
    default_gui_startup_args = { 'ssh', 'dev-miversen' }
}