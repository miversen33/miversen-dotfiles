local wezterm = require("wezterm")

local OS_SEP = wezterm.target_triple:match('windows') and '\\' or '/'

-- Do some quick hostname checks to see if we are running inside
-- a dev container
local DEV_CONTAINER_NAME = "dev_env"
local dev_env_socket = wezterm.home_dir .. OS_SEP .. ".dev_env_mux.sock"

local domains = {
    default = "localhost socket",
    unix = {
        {name = "localhost socket"},
    },
    ssh = { default = true }
}

if dev_env_socket then
    local _ = io.open('/.dockerenv', 'r')
    if _ ~= nil then
        _:close()
        if wezterm.hostname() == DEV_CONTAINER_NAME then
            table.insert(domains.unix, {
                name = "Dev Environment",
                socket_path = dev_env_socket,
                skip_permissions_check = true
            })
        end
    end
end



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
    opacity = { window = 0.90 },
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
    domains = domains,
    raw = {
        window_close_confirmation = 'NeverPrompt',
    }
}

return user_config
