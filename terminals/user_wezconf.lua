local wezterm = require("wezterm")

-- Do some quick hostname checks to see if we are running inside
-- a dev container
local DEV_CONTAINER_NAME = "dev_env"

local domains = {
    default = "localhost socket",
    unix = {
        {name = "localhost socket"},
    },
    ssh = { default = true },
    tls = {
        servers = {},
        clients = {}
    }
}

if not wezterm.GLOBAL.precheck then
    local _ = io.open('/.dockerenv', 'r')
    if _ ~= nil then
        _:close()
        if wezterm.hostname() == DEV_CONTAINER_NAME then
            wezterm.GLOBAL.is_dev_container = true
        end
    end
    wezterm.GLOBAL.precheck = true
end

if wezterm.GLOBAL.is_dev_container then
    local port = os.getenv('DEV_PORT')
    if port then
        table.insert(domains.tls.servers, {
            name = "Dev Environment",
            bind_address = string.format("localhost:%s", port),
            skip_permissions_check = true
        })
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
