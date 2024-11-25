local wezterm = require("wezterm")
local components = require("tab_components")
local config = wezterm.config_builder()
local THEME_NAME='Catppuccin Mocha'

---@class ColorMap
---@field black number
---@field red number
---@field bright_red number
---@field green number
---@field bright_green number
---@field yellow number
---@field bright_yellow number
---@field blue number
---@field bright_blue number
---@field magenta number
---@field bright_magenta number
---@field cyan number
---@field bright_cyan number
---@field white number
---@field bright_white number
---@field tab_bar_background number
---@field background number

---@param window any
---@param theme_name string|nil
---@return ColorMap
local function get_color_by_key(window, theme_name)
    local current_scheme
    if window then
        current_scheme = wezterm.color.get_builtin_schemes()[window:effective_config().color_scheme]
    else
        current_scheme = wezterm.color.get_builtin_schemes()[theme_name or THEME_NAME]
    end

    return {
        background = current_scheme.background,
        tab_bar_background = current_scheme.background,
        black = current_scheme.ansi[1],
        red = current_scheme.ansi[2],
        green = current_scheme.ansi[3],
        yellow = current_scheme.ansi[4],
        blue = current_scheme.ansi[5],
        magenta = current_scheme.ansi[6],
        cyan = current_scheme.ansi[7],
        white = current_scheme.ansi[8],
        bright_black = current_scheme.brights[1],
        bright_red = current_scheme.brights[2],
        bright_green = current_scheme.brights[3],
        bright_yellow = current_scheme.brights[4],
        bright_blue = current_scheme.brights[5],
        bright_magenta = current_scheme.brights[6],
        bright_cyan = current_scheme.brights[7],
        bright_white = current_scheme.brights[8],
    }
end

---@param config table
local function setup_font(config)
    local font_opts = {}
    wezterm.font_with_fallback({'JetBrains Mono', 'Fira Code', 'MesloLGS NF'}, font_opts)
    -- See if we can adjust the font size based on the program we are in?
    config.font_size = 14.0
end

local function setup_command_palette()
    wezterm.on('augment-command-palette', function(window, pane)
        local themes = {}
        for theme_name, theme in pairs(wezterm.get_builtin_color_schemes()) do
            table.insert(themes, {
                brief = string.format("Set theme to %s", theme_name),
                action = wezterm.action_callback(function(window, pane)
                    local new_config = window:get_config_overrides() or {}
                    new_config.color_scheme = theme_name
                    window:set_config_overrides(new_config)
                    local config_file_location = string.format("%s/.config/wezterm/wezterm.lua", wezterm.home_dir)
                    local config_file = io.open(config_file_location, 'r+')
                    local new_config_file_contents = {}
                    for line in config_file:lines() do
                        if line:find("^%s*local%sTHEME_NAME") then
                            line = string.format("local THEME_NAME='%s'", theme_name)
                        end
                        table.insert(new_config_file_contents, line .. '\n')
                    end
                    config_file:close()
                    config_file = io.open(string.format("%s", config_file_location), 'w')
                    for _, line in ipairs(new_config_file_contents) do
                        config_file:write(line)
                    end
                    config_file:close()

                    wezterm.GLOBAL.theme_color_map = get_color_by_key(nil, theme_name)
                end)
            })
        end
        return themes
    end)
end

---@param config table
local function setup_cursor(config)
    config.default_cursor_style = "BlinkingBar"
    config.cursor_blink_ease_in = "EaseIn" -- Or "Ease", "EaseIn", "EaseInOut", "Constant"
    config.cursor_blink_ease_out = "EaseInOut"
    config.cursor_blink_rate = 700
    config.cursor_thickness = "2px"
end

---@param config table
local function setup_keys(config)
    local keys = require("keys")
    config.leader = keys.leader
    config.keys = keys.mappings
end

local function setup_status_bars(config)
    local LEFT_STATUS_SEPERATOR = wezterm.nerdfonts.ple_right_half_circle_thick
    local RIGHT_STATUS_SEPERATOR = wezterm.nerdfonts.ple_left_half_circle_thick

    local new_tab_style = {
        { Background = { Color = wezterm.GLOBAL.theme_color_map.background }},
        { Foreground = { Color = wezterm.GLOBAL.theme_color_map.black }},
        { Text = " " },
        { Foreground = { Color = wezterm.GLOBAL.theme_color_map.black}},
        { Background = { Color = wezterm.GLOBAL.theme_color_map.background }},
        { Text = RIGHT_STATUS_SEPERATOR },
        { Foreground = { Color = wezterm.GLOBAL.theme_color_map.background }},
        { Background = { Color = wezterm.GLOBAL.theme_color_map.black }},
        { Text = "+" },
        -- These colors are a bit weird???
        { Foreground = { Color = wezterm.GLOBAL.theme_color_map.black }},
        { Background = { Color = wezterm.GLOBAL.theme_color_map.tab_bar_background }},
        { Text = LEFT_STATUS_SEPERATOR }
    }
    local new_tab_hover_style = {
        { Background = { Color = wezterm.GLOBAL.theme_color_map.background }},
        { Foreground = { Color = wezterm.GLOBAL.theme_color_map.black }},
        { Text = " " },
        { Foreground = { Color = wezterm.GLOBAL.theme_color_map.white }},
        { Background = { Color = wezterm.GLOBAL.theme_color_map.background }},
        { Text = RIGHT_STATUS_SEPERATOR },
        { Foreground = { Color = wezterm.GLOBAL.theme_color_map.background }},
        { Background = { Color = wezterm.GLOBAL.theme_color_map.white }},
        { Text = "+" },
        -- These colors are a bit weird???
        { Foreground = { Color = wezterm.GLOBAL.theme_color_map.white }},
        { Background = { Color = wezterm.GLOBAL.theme_color_map.tab_bar_background }},
        { Text = LEFT_STATUS_SEPERATOR }
    }

    config.tab_bar_style = {
        new_tab = wezterm.format(new_tab_style),
        new_tab_hover = wezterm.format(new_tab_hover_style)
    }
    -- config.tab_bar_style.new_tab_hover = wezterm.format(new_tab_hover_style)
    local cwd_max_length = 15
    local home_dir = wezterm.home_dir

    local leader_component = components.leader()
    local battery_component = components.battery()
    local time_component = components.time()
    local caps_lock_component = components.caps_indicator()
    local tmux_component = components.tmux()
    local os_component = components.os()

    local hostname_component = components.host()
    local ssh_component = components.ssh()
    local docker_component = components.docker()
    local workspace_component = components.workspace()
    local domain_component = components.domain()
    local user_component = components.user()
    -- local cwd_component = components.cwd(cwd_sanitizer)

    local function get_background()
        return wezterm.color.get_default_colors().background
    end

    wezterm.on('update-status', function(window, pane)
        local color_map = wezterm.GLOBAL.theme_color_map
        local ssh_details = ssh_component(window, pane)
        local hostname = hostname_component(window, pane)
        local username = user_component(window, pane)
        local host_os = os_component(window, pane)
        if ssh_details.is_ssh then
            hostname = ssh_details.hostname
            username = ssh_details.username
            host_os = ssh_details.os_icon or wezterm.nerdfonts.md_cloud_question
        end
        local docker_details = docker_component(window, pane)
        -- if docker_details.is_container then
        --     hostname = docker_details.container
        --     username = docker_details.username
        -- end
        -- local mux_window = window:mux_window()
        -- local show_cwd = false
        -- if mux_window and mux_window.tabs and #mux_window:tabs() > 1 then
        --     show_cwd = true
        -- end

        local component_color_map = {
            home = {
                fg = color_map.tab_bar_background,
                bg = color_map.magenta
            },
            workspace = {
                fg = color_map.tab_bar_background,
                bg = color_map.yellow,
            },
            sys = {
                fg = color_map.tab_bar_background,
                bg = color_map[username == "root" and "red" or 'cyan'],
            },
            context = {
                fg = color_map.tab_bar_background,
                bg = color_map.bright_white
            },
            time = {
                fg = color_map.white,
                bg = color_map.black
            }
        }

        local sys_text = string.format(" %s@%s", username, hostname)
        if username == "" then
            sys_text = ""
        end

        local remote_details = ""
        if ssh_details.is_ssh then
            remote_details = string.format("%s ", wezterm.nerdfonts.md_server_network)
        end
        if docker_details.is_container then
            remote_details = string.format("%s ", wezterm.nerdfonts.linux_docker)
        end
        -- if docker_details.is_container then
        --     remote_details = wezterm.nerdfonts.linux_docker
        -- end
        -- If we are on a small screen, omit this one
        -- local cwd = cwd_component(window, pane)
        -- if not show_cwd then
        --     cwd = ""
        -- else
        --     cwd = string.format(" %s", cwd)
        -- end

        local left_status = {
            { Foreground = { Color = component_color_map.home.fg }},
            { Background = { Color = component_color_map.home.bg }},
            { Text = remote_details },
            { Text = host_os },
            { Text = " " },
            { Text = domain_component() },
            { Foreground = { Color = component_color_map.home.bg }},
            { Background = { Color = component_color_map.workspace.bg } },
            { Text = LEFT_STATUS_SEPERATOR },
            { Foreground = { Color = component_color_map.workspace.fg }},
            { Background = { Color = component_color_map.workspace.bg }},
            { Text = " " },
            { Text = workspace_component() },
            { Foreground = { Color = component_color_map.workspace.bg }},
            { Background = { Color = component_color_map.sys.bg }},
            { Text = LEFT_STATUS_SEPERATOR },
            { Background = { Color = component_color_map.sys.bg }},
            { Foreground = { Color = component_color_map.sys.fg }},
            { Text = sys_text },
            -- { Text = cwd },
            { Background = { Color = color_map.tab_bar_background } },
            { Foreground = { Color = component_color_map.sys.bg }},
            { Text = wezterm.nerdfonts.ple_right_half_circle_thick },
            { Text = " " }
        }

        local right_status = {
            { Text = tmux_component(window, pane) },
            { Text = caps_lock_component(window) },
            { Text = leader_component(window) },
            { Text = " "},
            { Foreground = { Color = component_color_map.time.bg }},
            { Background = { Color = color_map.tab_bar_background }},
            { Text = RIGHT_STATUS_SEPERATOR },
            { Foreground = { Color = component_color_map.time.fg }},
            { Background = { Color = component_color_map.time.bg }},
            { Text = battery_component() },
            { Text = time_component() }
        }

        window:set_left_status(wezterm.format(left_status))
        window:set_right_status(wezterm.format(right_status))
    end)
end

local function setup_tabs(config)
    config.use_fancy_tab_bar = false
    -- local LEFT_ICON = wezterm.nerdfonts.ple_lower_right_triangle
    -- -- local LEFT_ICON = wezterm.nerdfonts.ple_upper_right_triangle
    -- local RIGHT_ICON = wezterm.nerdfonts.ple_lower_left_triangle
    local RIGHT_ICON = wezterm.nerdfonts.ple_right_half_circle_thick
    local LEFT_ICON = wezterm.nerdfonts.ple_left_half_circle_thick
    local function format(tab, tabs, panes, config, hover, max_width)
        local color_map = wezterm.GLOBAL.theme_color_map
        local foreground = color_map.tab_bar_background
        local background = color_map.green
        local title = string.format("%s: %s", tab.tab_id, tab.active_pane.title)
        if #title >= max_width - 1 then
            title = title:sub(0, max_width - 2)
        end
        local formatted_title = {}
        if tab.is_active then
            formatted_title = {
                { Foreground = { Color = background }},
                { Background = { Color = foreground }},
                { Text = LEFT_ICON },
                { Foreground = { Color = foreground }},
                { Background = { Color = background }},
                { Text = title },
                { Foreground = { Color = background }},
                { Background = { Color = foreground }},
                { Text = RIGHT_ICON },
            }
        else
            formatted_title = {
                { Background = { Color = foreground }},
                { Foreground = { Color = foreground }},
                { Text = LEFT_ICON },
                { Foreground = { Color = background }},
                { Attribute = { Italic = hover }},
                { Attribute = { Intensity = hover and "Bold" or "Half"}},
                { Attribute = { Underline = tab.active_pane.has_unseen_output and "Single" or "None" }},
                { Text = title },
                { Foreground = { Color = foreground }},
                { Text = RIGHT_ICON },
            }
        end
        return formatted_title
    end
    wezterm.on('format-tab-title', format)
    -- local RIGHT_ICON = wezterm.nerdfonts.ple_upper_right_triangle
    -- config.tab_bar_style = {
    --     active_tab_left = wezterm.format({
    --     }),
    --     active_tab_right = wezterm.format({
    --         { Background = { Color = '#C295DC' }},
    --         { Foreground = { Color = 'gray' }},
    --         { Text = RIGHT_ICON }
    --     }),
    --     inactive_tab_left = wezterm.format({
    --         { Background = { Color = wezterm.color.get_default_colors().background }},
    --         { Foreground = { Color = 'gray' }},
    --         { Text = LEFT_ICON }
    --     }),
    --     inactive_tab_right = wezterm.format({
    --         { Background = { Color = wezterm.color.get_default_colors().background }},
    --         { Foreground = { Color = 'gray' }},
    --         { Text = RIGHT_ICON }
    --     })
    -- }
end

---@param config table
local function setup_ui(config)
    config.window_decorations = "TITLE|RESIZE"
    config.integrated_title_button_alignment = "Left"
    config.detect_password_input = true
    config.tab_bar_at_bottom = true
    config.color_scheme = THEME_NAME
    config.win32_system_backdrop = 'Acrylic'
    config.inactive_pane_hsb = {
        saturation = 0.4,
        brightness = 0.2
    }
    config.window_background_opacity = .9
    config.prefer_egl = true
    -- wezterm.on("window-focus-changed", function()
    --     -- We should only do this if we are on KDE and X11, and even then it doesn't seem to work properly
    --     os.execute('xdotool search -classname org.wezfurlong.wezterm | xargs -I{} xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id {}')
    -- end)
    wezterm.GLOBAL.theme_color_map = get_color_by_key()
    setup_tabs(config)
end

wezterm.on('toggle-leader', function(window)
    local override_config = window:get_config_overrides() or {}
    if not override_config.leader then
        override_config.leader = {
            key = '', mods = "CTRL|SHIFT|ALT", timeout_milliseconds = 2
        }
    else
        override_config.leader = nil
    end
    window:set_config_overrides(override_config)
end)


config.colors = {}
setup_font(config)
setup_cursor(config)
setup_keys(config)
setup_command_palette()
setup_ui(config)
if wezterm.target_triple:find('windows') then
    config.default_prog = { 'pwsh', '-NoLogo', '-NoExit', '-File', 'C:\\users\\miver\\git\\miversen-dotfiles\\shells\\profile.ps1' }
end
config.audible_bell = "Disabled"
config.scrollback_lines = 5000
config.warn_about_missing_glyphs = false -- I don't care. Leave me alone
-- config.visual_bell = {
--    fade_in_function = "EaseIn",
--    fade_in_duration = 150,
--    fade_out_function = "EaseOut",
--    fade_out_durection = 150
-- }
-- config.colors.visual_bell = "#202020"
-- -- We could also do a thing when a bell is ran on a pane
-- wezterm.on('bell', function(window, pane) end)
setup_status_bars(config)

return config
