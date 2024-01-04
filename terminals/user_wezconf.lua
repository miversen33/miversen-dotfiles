local wezterm = require("wezterm")

local M = {}


function M.generate()
    -- local success, stdout, stderr = require("wezterm").run_child_process { 'ls', '-l' }
    -- print(stdout)
    -- Do some quick hostname checks to see if we are running inside
    -- a dev container
    -- local DEV_CONTAINER_NAME = "dev_env"
    -- local OS_SEP = wezterm.target_triple:match('windows') and '\\' or '/'
    -- local DEV_SOCKET = os.getenv("DEV_SOCK") or wezterm.home_dir .. OS_SEP .. '.dev_env.sock'
    -- local dev_domain = {
    --     name = "Dev Environment",
    --     socket_path = DEV_SOCKET,
    --     skip_permissions_check = true
    -- }
    local domains = {
        default = "Localhost",
        unix = {
            {name = "Localhost"},
        },
        ssh = { default = true },
    }

    if not wezterm.GLOBAL.precheck then
        local success, stdout, _ = wezterm.run_child_process({"docker", "--version"})
        if not success then
            wezterm.GLOBAL.has_docker = false
        end
        wezterm.GLOBAL.has_docker = stdout and stdout:match('[dD]ocker%s[Vv]ersion') and true or false
    end

    -- -- if wezterm.GLOBAL.is_dev_container then
    -- --     table.insert(domains.unix, dev_domain)
    -- -- else
    -- --     
    -- -- end

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
        format_tab = 'arrow',
        cursor_style = 'BlinkingBar',
        inactive_pane_hsb = {
            saturation = 0.7,
            brightness = 0.2
        },
        opacity = { window = 0.90 },
        color_scheme = "MaterialOcean",
        default_shell = {
            windows = 'pwsh'
        },
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
        blur = false,
        raw = {
            window_close_confirmation = 'NeverPrompt',
            -- Stop telling me glyphs are missing
            warn_about_missing_glyphs = false
        }
    }

    return user_config
end

return M
