-- An abstraction/wrapper to make creating wezterm configurations a bit easier

local wezterm = require("wezterm")
local nerdfonts = wezterm.nerdfonts

local lib = {}
wezterm.miversen_wezconf = lib

-- Helper functions

function lib.action_exists(action)
    local status = pcall(function()
        local _ = wezterm.action[action]
    end)
    return status
end

function lib.generate_action(action_name, non_exist_msg, action_closure)
    if not lib.action_exists(action_name) then
        return wezterm.action_callback(function()
            wezterm.log_warn(string.format("miversen wezconf: %s", non_exist_msg))
        end)
    end
    return action_closure()
end

-- This isn't super clear but basically, this will
-- round the provided number down to the nearest number that
-- is a multiple of the target_multiple.
-- EG
-- lib.round_down_to_nearest(1107, 5) == 1105 (1105 is the nearest lower multiple of 5)
-- Thank roblox! Very cool!
-- https://devforum.roblox.com/t/rounding-numbers-to-the-nearest-5/443160/4
function lib.round_down_to_nearest(number, multiple)
    return math.floor(number / multiple) * multiple
end

function lib.deepcopy(orig)
    -- Yoinked from https://stackoverflow.com/a/640645/2104990
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[lib.deepcopy(orig_key)] = lib.deepcopy(orig_value)
        end
        setmetatable(copy, lib.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function lib.merge_table(base_table, apply_table)
    for key, value in pairs(apply_table) do
        if value == 'none' then
            base_table[key] = nil
        else
            if type(value) == 'table' then
                base_table[key] = lib.merge_table(base_table[key] or {}, value)
            else
                base_table[key] = lib.deepcopy(value)
            end
        end
    end
    return base_table
end

function lib.generate_statusbar(window, pane, statusbar, location)
    -- It would be pretty slick if we could allow
    -- components to also control their color??
    local components = {}
    local status_bar = {}
    local default_soft_div = statusbar.soft_div_icon or nerdfonts[string.format('pl_%s_soft_divider', location:lower())]
    local default_hard_div = statusbar.hard_div_icon or nerdfonts[string.format("pl_%s_hard_divider", location:lower())]
    local default_foreground = statusbar.foreground or wezterm.color.get_default_colors().foreground
    local default_background = statusbar.background or wezterm.color.get_default_colors().background
    local default_attributes = statusbar.attributes or {}
    for _, group in ipairs(statusbar) do
        -- Iterating over each indivdual group in the statusbar
        local foreground = group.foreground    or default_foreground
        local background = group.background    or default_background
        local attributes = group.attributes    or default_attributes
        local soft_div   = group.soft_div_icon or default_soft_div
        local hard_div   = group.hard_div_icon or default_hard_div
        local used_hard_div = false
        for key, value in pairs(group) do
            -- Iterate through every component the group
            -- Note, we are using pairs here because this
            -- can be a mix of integer indexes and string keys
            if type(key) == 'number' then
                -- Found a component
                local component  =
                    -- If the value is a function, call it
                    type(value) == 'function' and value(window, pane)
                    -- If its a string or number, cast it to a string and just 
                    -- create the basic wezterm component of it
                    or ( type(value) == 'string' or type(value) == 'number' )
                        and string.format("%s", value)
                if component then
                    local pre_comp = {
                        div = soft_div,
                    }
                    if not used_hard_div and location == 'right' then
                        pre_comp.div = hard_div
                        pre_comp.comp_end = true
                        used_hard_div = true
                    end
                    pre_comp.text = string.format("%s", component)
                    pre_comp.background = background
                    pre_comp.foreground = foreground
                    pre_comp.attributes = attributes
                    table.insert(components, pre_comp)
                end
            end
        end
        if #components > 0 and location == 'left' then
            components[#components].div = hard_div
            components[#components].comp_end = true
        end
    end
    table.insert(status_bar, 'ResetAttributes')
    local previous_foreground = nil
    local previous_background = nil
    for _, component in ipairs(components) do
        if location == 'right' then
            local foreground = component.foreground or previous_foreground or default_foreground
            local background = component.background or previous_background or default_background
            if component.comp_end then
                foreground = background
                if _ == 1 then
                    -- TODO: Mike Get the tab bar background, this
                    -- should be that
                    background = nil
                else
                    background = previous_background or default_background
                end
            end
            if foreground then
                table.insert(status_bar, { Foreground = { Color = foreground }})
            end
            if background then
                table.insert(status_bar, { Background = { Color = background }})
            end
            table.insert(status_bar, { Text = component.div })
        end
        table.insert(status_bar, { Foreground = { Color = component.foreground }})
        table.insert(status_bar, { Background = { Color = component.background }})
        if component.attributes then
            if component.attributes.underline then
                table.insert(status_bar, { Attribute = { Underline = component.attributes.underline }})
            end
            if component.attributes.intensity then
                table.insert(status_bar, { Attribute = { Intensity = component.attributes.intensity }})
            end
            if component.attributes.italic then
                table.insert(status_bar, { Attribute = { Italic = component.attributes.italic }})
            end
        end
        table.insert(status_bar, { Text = component.text })

        if location == 'left' then
            -- Add the div last
            local foreground = component.foreground or previous_foreground or default_foreground
            local background = component.background or previous_background or default_background
            if component.comp_end then
                foreground = background
                if _ == #components then
                    -- TODO: Mike Get the tab bar background, this
                    -- should be that
                    background = nil
                else
                    local next_comp = components[_ + 1]
                    background = next_comp and next_comp.background and next_comp.background or default_background
                end
            end
            table.insert(status_bar, 'ResetAttributes')
            if foreground then
                table.insert(status_bar, { Foreground = { Color = foreground }})
            end
            if background then
                table.insert(status_bar, { Background = { Color = background }})
            end
            table.insert(status_bar, { Text = component.div })
        end
        previous_background = component.background
        previous_foreground = component.foreground
        table.insert(status_bar, 'ResetAttributes')
    end
    local compiled_status_bar = wezterm.format(status_bar)
    return compiled_status_bar
end


-- This is the "meat and potatoes" of this config
-- This will take the "custom" configuration and
-- convert it into something wezterm expects
function lib.compile_config_to_wez(config)
    local wez_conf = wezterm.config_builder and wezterm.config_builder() or {}
    -- Little bit of garbage to handle startup args because apparently
    -- wezterm.config_builder returns a special table that
    -- doesn't allow us to append items to a table inside of it...
    local startup_args = {}
    if config.startup_args then
        wezterm.log_info("miversen wezconf: Compiling Startup Args")
        for _, arg in ipairs(config.startup_args) do
            table.insert(startup_args, arg)
        end
    end
    if config.detect_password_input then
        wez_conf.detect_password_input = true
    end
    if config.color_scheme then
        wez_conf.color_scheme = config.color_scheme
    end
    wez_conf.prefer_egl = config.prefer_egl and config.prefer_egl or false
    if config.colors then
        wez_conf.colors = config.colors
    end
    if config.window_frame then
        wez_conf.window_frame = config.window_frame
    end
    if config.pref_fonts then
        local font_opts = config.font_opts or {}
        wezterm.log_info("miversen wezconf: Compiling Font")
        wez_conf.font = wezterm.font_with_fallback(config.pref_fonts, font_opts)
    end
    if config.keys then
        wezterm.log_info("miversen wezconf: Compiling Key Bindings")
        wez_conf.leader = config.keys.leader or nil
        wez_conf.keys = config.keys.maps or {}
        wez_conf.key_tables = config.keys.tables or {}
    end
    if config.env_vars then
        wezterm.log_info("miversen wezconf: Compiling Env Vars")
        wez_conf.set_environment_variables = config.env_vars
    end
    -- Current work around pending tab bar change
    if config.tab_bar_appearance then
        wezterm.log_info("miversen wezconf: Compiling Tab Bar Appearance")
        if config.tab_bar_appearance == 'Retro' then
            -- TODO: Update this to deal with some sort of version check
            -- to figure out _how_ to display this?
            wez_conf.use_fancy_tab_bar = false
        elseif config.tab_bar_appearance == 'Fancy' then
            wez_conf.use_fancy_tab_bar = true
        else
            wez_conf.tab_bar_appearance = config.tab_bar_appearance
        end
    end
    if config.tab_bar_location then
        wezterm.log_info("miversen wezconf: Compiling Tab Bar Location")
        if config.tab_bar_location == 'Bottom' then
            wez_conf.tab_bar_at_bottom = true
        else
            wez_conf.tab_bar_at_bottom = false
        end
    end
    if config.audible_bell then
        wezterm.log_info("miversen wezconf: Compiling Audible Bell")
        wez_conf.audible_bell = config.audible_bell
    end
    if config.visual_bell then
        wezterm.log_info("miversen wezconf: Compiling Visual Bell")
        wez_conf.visual_bell = config.visual_bell
    end
    if config.cursor_style then
        wezterm.log_info("miversen wezconf: Compiling Default Cursor Style")
        wez_conf.default_cursor_style = config.cursor_style
    end
    if config.window_decorations then
        wezterm.log_info("miversen wezconf: Compiling Window Decorations")
        wez_conf.window_decorations = config.window_decorations
    end
    if config.window_padding then
        wezterm.log_info("miversen wezconf: Compiling Window Padding")
        wez_conf.window_padding = config.window_padding
    end
    if config.inactive_pane_hsb then
        wezterm.log_info("miversen wezconf: Compiling Inactive Window Styling")
        wez_conf.inactive_pane_hsb = config.inactive_pane_hsb
    end
    if config.opacity then
        if config.opacity.window then
            wezterm.log_info("miversen wezconf: Compiling Window Opacity")
            wez_conf.window_background_opacity = config.opacity.window
        end
        if config.opacity.text then
            wezterm.log_info("miversen wezconf: Compiling Text Opacity")
            wez_conf.text_background_opacity = config.opacity.text
        end
    end
    if config.format_tab then
        wezterm.log_info("miversen wezconf: Setting Format Tab Event Callback")
        wezterm.on('format-tab-title', function(tab, tabs, panes, _config, hover, max_width)
            return config.format_tab(tab, tabs, panes, _config, hover, max_width)
        end)
    end
    if config.domains then
        wezterm.log_info("miversen wezconf: Compiling Domains")
        local default_domain = nil
        for domain_name, opts in pairs(config.domains) do
            local domain_key = domain_name ~= 'tls' and string.format("%s_domains", domain_name) or 'tls_servers'
            opts.name = domain_name
            if opts.default then
                opts.default = nil
                default_domain = domain_name
            end
            wez_conf[domain_key] = {opts}
        end
        if default_domain then
            table.insert(startup_args, 'connect')
            table.insert(startup_args, default_domain)
        end
    end

    local left_status_bar_callback = nil
    local right_status_bar_callback = nil
    if config.raw_left_status_bar then
        wezterm.log_info("miversen wezconf: Compiling Custom Left Status Bar")
        left_status_bar_callback = config.raw_left_status_bar
    elseif config.left_status_bar then
        wezterm.log_info("miversen wezconf: Compiling Left Status Bar")
        left_status_bar_callback = function(window, pane)
            return lib.generate_statusbar(window, pane, config.left_status_bar, 'left')
        end
    end
    if config.raw_right_status_bar then
        wezterm.log_info("miversen wezconf: Compiling Custom Right Status Bar")
        right_status_bar_callback = config.raw_right_status_bar
    elseif config.right_status_bar then
        wezterm.log_info("miversen wezconf: Compiling Right Status Bar")
        right_status_bar_callback = function(window, pane)
            return lib.generate_statusbar(window, pane, config.right_status_bar, 'right')
        end
    end
    if left_status_bar_callback or right_status_bar_callback then
        wezterm.log_info("miversen wezconf: Setting Status Bar Event Callback")
        wezterm.on('update-status', function(window, pane)
            if left_status_bar_callback then
                window:set_left_status(left_status_bar_callback(window, pane))
            end
            if right_status_bar_callback then
                window:set_right_status(right_status_bar_callback(window, pane))
            end
        end)
    end
    wezterm.on('toggle-leader', function(window, pane)
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

    if #startup_args > 0 then
        wez_conf.default_gui_startup_args = startup_args
    end

    if config.raw then
        for key, value in pairs(config.raw) do
            wezterm.log_info(string.format("miversen wezconf: Compiling Raw Option %s", key))
            if config[key] then
                wezterm.log_warn(string.format("miversen wezconf: Caution %s is overwritting a previously configured option in your user configuration", key))
            end
            wez_conf[key] = value
        end
    end

    return wez_conf
end

-- Every function will have at minimum an optional
-- text_format_opts param. Some functions may have additional
-- params, they will be documented below.
--
-- @param text_format_opts: Table
-- This table can contain any of the following keys
--     - Attribute
--     - Foreground
--     - Background
-- This table will be applied to the text that is generated in
-- via the function returned
--
-- Note: You do not _have_ to use one of these components,
-- they are just designed to make your life easier in designing
-- your statusbar. If you opt to make your own components
-- and use them in your groupings, your functions must
-- return the following 2 items
--     - wezterm.format compatible array of attributes
--     - a table that contains the colors to use (background and foreground) for the component. Yes, this should also be in your format array but it helps the organizer to know explicitly what colors to use
lib.components = {
    test = function(comp_opts)
        local message = comp_opts.msg or ''
        return function(window, pane)
            return message
        end
    end,
    caps_indicator = function(icon)
        icon = icon or 'בּ'
        return function()
            -- We can't use this yet as there doesn't appear to be a way
            -- to tell if caps lock is currently "enabled" or not?
            local caps_enabled = false
            return caps_enabled and string.format("%s", icon) or ''
        end
    end,
    spacer = function(padding)
        return function()
            return string.format("%-" .. string.format("%ss", padding or 1), '')
        end
    end,
    user = function()
        return function(window, pane)
            return pane:get_user_vars() and pane:get_user_vars().WEZTERM_USER
        end
    end,
    host = function()
        return function(window, pane)
            return pane:get_user_vars() and pane:get_user_vars().WEZTERM_HOST
        end
    end,
    workspace = function()
        return function(window, pane)
            return wezterm.mux.get_active_workspace()
        end
    end,
    -- @param format_string: string
    --     Default: %H:%M:%S %a %B %Y
    --     If provided, sets the time/date format string
    time = function(format_string)
        format_string = format_string or '%H:%M:%S %a %B %Y'
        return function(window, pane)
            return wezterm.strftime(format_string)
        end
    end,
    -- @param icon: string
    --     Default: ↑
    --     If provided, sets the icon to display if the leader key is activated
    --     NOTE: If the leader key is actively disabled, this will display "ﰸ"
    --     instead
    leader = function(icon)
        icon = icon or '↑'
        return function(window, pane)
            local text = window:leader_is_active() and icon or ''
            local override_config = window:get_config_overrides()
            -- TODO: Come up with a better way to show this????
            if override_config.leader then
                text = text .. " " .. nerdfonts.mdi_cancel
            end
            return text
        end
    end,
    tmux = function(icon)
        icon = icon or '﬑ '
        return function(window, pane)
            if not pane:get_user_vars() then return end
            local is_tmux =
                (pane:get_user_vars().WEZTERM_IN_TMUX and pane:get_user_vars().WEZTERM_IN_TMUX ~= "0")
                or (pane:get_user_vars().WEZTERM_PROG and pane:get_user_vars().WEZTERM_PROG:match('^tmux'))
            return is_tmux and icon
        end
    end,
    -- @param warn_threshold: double
    --     Default: 0.2
    --     If provided, this is the discharge level at which
    --     we warn you that the battery needs to be charged.
    --     NOTE: Should be between 0 and 1
    battery = function(opts)
        opts = opts or {}
        local show_percentage = opts.show_percentage
        local warn_threshold = opts.warn_threshold or 0.2
        return function(window, pane)
            local battery_info = wezterm.battery_info()
            -- Short circuit if we cant read the battery for some reason
            if not battery_info or not next(battery_info) then return end
            battery_info = battery_info[1]
            local current_charge_level = battery_info.state_of_charge
            local rounded_charge_level = math.floor(lib.round_down_to_nearest(current_charge_level, .10) * 100)
            local current_charge_state = battery_info.state
            local remaining = (current_charge_state == 'Charging' or current_charge_state == 'Full') and battery_info.time_to_full or battery_info.time_to_empty
            -- Fail safe just in case this is nil
            if not remaining then remaining = '' end
            local warn_state = ''
            if rounded_charge_level <= warn_threshold then
                warn_state = nerdfonts.fa_exclamation
            end
            local nerdfont_query_string = 'mdi_battery'
            if current_charge_state == 'Charging' then
                nerdfont_query_string = nerdfont_query_string .. "_charging_%s"
                if remaining < 20 then
                    -- For some reason there is no nerdfont for charging 10 percent
                    remaining = 20
                end
            elseif current_charge_state == 'Full' then
                nerdfont_query_string = 'mdi_battery'
            else
                nerdfont_query_string = nerdfont_query_string .. "_%s"
            end
            nerdfont_query_string = string.format(nerdfont_query_string, rounded_charge_level)
            local battery_percentage = show_percentage and string.format(" %s%%", math.floor(current_charge_level * 100)) or ''
            local charge_icon =
                current_charge_state == 'Charging' and nerdfonts.cod_arrow_up
                or current_charge_state == 'Discharging' and nerdfonts.cod_arrow_down
                or ''
            local battery_icon = string.format("%s%s%s%s", warn_state, nerdfonts[nerdfont_query_string] and nerdfonts[nerdfont_query_string] .. ' ', charge_icon, battery_percentage)
            return battery_icon
        end
    end
}

local function space_tabbar(tab_bar, location)
    location = location or 'left'
end

lib.tab_styles = {
    diamond = function(background, foreground, spacer)
        spacer = spacer or 1
        background = background or 'BLACK'
        foreground = foreground or 'WHITE'
        local scale = .30
        local orig_background = background
        local orig_foreground = foreground
        background = wezterm.color.parse(background)
        foreground = wezterm.color.parse(foreground)
        local inactive_background = wezterm.color.parse(orig_background):darken(scale)
        local inactive_foreground = wezterm.color.parse(orig_foreground):darken(scale)
        local hover_background = wezterm.color.parse(orig_background):lighten(scale)
        local hover_foreground = wezterm.color.parse(orig_foreground):lighten(scale)

        return function(tab, tabs, panes, config, hover, max_width, location)
            local tab_background =
            hover and hover_background
            or tab.is_active and background
            or inactive_background
            local tab_foreground =
            hover and hover_foreground
            or tab.is_active and foreground
            or inactive_foreground
            local title = wezterm.truncate_right(tab.active_pane.title, max_width - 5)
            title = string.format("%s %s", tab.tab_id, title)
            local tab_components = {}
            if wezterm.miversen_wezconf.merged_conf.tab_bar_appearance ~= 'Fancy' then
                local spacer_background = spacer and { Background = { Color = inactive_foreground }}
                local spacer_text = spacer and { Text = string.format("%-" .. string.format("%ss", spacer), '') }
                tab_components = {
                    { Foreground = { Color = tab_background }},
                    { Background = { Color = inactive_foreground }},
                    { Attribute = { Intensity = 'Bold'}},
                    { Text =  nerdfonts.pl_right_hard_divider },
                    { Background = { Color = tab_background }},
                    { Foreground = { Color = tab_foreground }},
                    { Text = title },
                    { Foreground = { Color = tab_background }},
                    { Background = { Color = inactive_foreground }},
                    { Text = nerdfonts.pl_left_hard_divider },
                }
                if spacer then
                    table.insert(tab_components, 1, spacer_text)
                    table.insert(tab_components, 1, spacer_background)
                end
            else
                tab_components = {
                    { Attribute = { Intensity = 'Bold'}},
                    { Background = { Color = tab_background }},
                    { Foreground = { Color = tab_foreground }},
                    { Text = title },
                }
            end
            return tab_components
        end
    end,
    diamond = function(background, foreground)
        background = background or 'BLACK'
        foreground = foreground or 'WHITE'
        local scale = .30
        local orig_background = background
        local orig_foreground = foreground
        background = wezterm.color.parse(background)
        foreground = wezterm.color.parse(foreground)
        local inactive_background = wezterm.color.parse(orig_background):darken(scale)
        local inactive_foreground = wezterm.color.parse(orig_foreground):darken(scale)
        local hover_background = wezterm.color.parse(orig_background):lighten(scale)
        local hover_foreground = wezterm.color.parse(orig_foreground):lighten(scale)
        return lib.tab_styles.basic_custom(nerdfonts.pl_right_hard_divider, nerdfonts.pl_left_hard_divider, background, inactive_background, hover_background, foreground, inactive_foreground, hover_foreground)
    end
}

lib.default_config = {
    -- Font attributes
    pref_fonts = {'JetBrains Mono'},
    -- font_opts = { weight = 'Bold', style = 'Italic' }
    -- if specified, will apply the options below to the fonts listed in pref_fonts
    -- will only be used if pref_fonts are found
    --
    -- raw = {}
    -- If provided, raw will have its key/value pairs passed _directly_ to wezterm
    -- Anything in raw will override anything provided in the user configuration
    -- or in the default configuration. Consider this a way to directly pass
    -- things that I don't care enough to abstract into wezterm
    --
    -- env_vars = {}
    -- If provided, we will use this to set the global environment of any program
    -- started under us
    --
    -- startup_args = {}
    -- If provided, we will use these args for the `default_gui_startup_args` option
    tab_bar_appearance = 'Fancy',
    -- Passed directly to wezterm
    --
    tab_bar_location = 'Top',
    -- If provided, sets the tab bar at the top of the window. Alternatively,
    -- this can be 'Bottom' and that will put it at the bottom
    --
    audible_bell = 'Disabled',
    -- Passed directly to wezterm. Fuck Audible bells lol
    --
    cursor_style = 'SteadyBlock',
    -- Passed directly to wezterm
    --
    window_decorations = 'RESIZE',
    -- Passed directly to wezterm
    --
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    },
    -- Passed directly to wezterm
    --
    inactive_pane_hsb = {
        hue = 1,
        saturation = 0.9,
        brightness = 0.9
    },
    -- Passed directly to wezterm
    --
    opacity = {
        window = 1,
        text = 1
    },
    -- The opacity to use for windows and the text on them
    -- for details, refer to wezterm doc for window_background_opacity and
    -- text_background_opacity
    -- Usually documentation is below the item but keys is a bigger boi so
    -- doc is above. Sue me
    -- Keys has can have any of the 3 following keys in it
    --     - leader
    --         - The leader key. Passed raw into wezterm
    --     - maps
    --         - The list of key maps. Passed raw into wezterm
    --     - tables
    --         - The list of key_table maps. Passed raw into wezterm
    -- Note, setting maps or tables in your user config will completely
    -- override the presets. This is because I don't feel like trying
    -- to compare the presets to yours to figure out which to keep or not.
    keys = {
        leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000},
        maps = {
            -- Toggle Leader
            { key = 'b', mods = "CTRL", action = wezterm.action.EmitEvent('toggle-leader') },
            -- Nasty work around to deal with the fact that CTRL+/ doesn't actually pass through...
            { key = '/', mods = 'CTRL', action=wezterm.action.SendString("\x1f") },
            -- Wezterm Specific Stuff
            -- Sends CTRL+A to the underlying program, since we are using it as the leader
            { key = "a", mods = "LEADER|CTRL", action = wezterm.action.SendString('\x01') },
            -- Splits bois
            { key = "-", mods = "LEADER", action = wezterm.action.SplitPane({
                direction = "Down",
            })},
            { key = "_", mods = "LEADER|SHIFT", action = wezterm.action.SplitPane({
                direction = "Right",
            })},

            -- Navigation!
            -- Jumping between panes
            { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left")},
            { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right")},
            { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down")},
            { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up")},
            -- Make pane big boi
            { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState},
            -- Tabs
            { key = ".", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1)},
            { key = ",", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1)},
            { key = "n", mods = "LEADER|CTRL", action = wezterm.action.SpawnTab('CurrentPaneDomain')},
            { key = "c", mods = "LEADER", action = wezterm.action.SwitchToWorkspace },
            {
                key = '$',
                mods = 'LEADER|SHIFT',
                action = lib.generate_action(
                    'PromptInputLine',
                    'Your current version of wezterm does not support active workspace rename.'
                        .. ' Consider using `wezterm cli rename-workspace` instead',
                    function()
                        return wezterm.action.PromptInputLine({
                            description = wezterm.format {
                                { Attribute = { Intensity = 'Bold' } },
                                { Foreground = { AnsiColor = 'Fuchsia' } },
                                { Text = 'Enter name for new workspace' },
                            },
                            action = wezterm.action_callback(function(window, pane, line)
                                -- line will be `nil` if they hit escape without entering anything
                                -- An empty string if they just hit enter
                                -- Or the actual line of text they wrote
                                if line then
                                    wezterm.mux.rename_workspace(
                                        wezterm.mux.get_active_workspace(),
                                        line
                                    )
                                end
                            end)
                        })
                    end
                    )},
                {
                    key = "s",
                    mods = 'LEADER',
                    action = lib.generate_action(
                        'InputSelector',
                        'Your current version of wezterm does not support the "InputSelector" action.'
                        .. ' Please consider upgrading your wezterm version',
                        function()
                            return wezterm.action_callback(function(window, pane)
                                local workspaces = {}
                                for _, workspace in ipairs(wezterm.mux.get_workspace_names()) do
                                    table.insert(workspaces, { label = workspace })
                                end
                                window:perform_action(
                                    wezterm.action.InputSelector({
                                        action = wezterm.action_callback(function(window, pane, id, label)
                                            if not id and not label then
                                                return
                                            end
                                            window:perform_action(wezterm.action.SwitchToWorkspace({ name = label}), pane)
                                        end),
                                        title = 'Workspace Selector',
                                        choices = workspaces,
                                    }),
                                    pane
                                )
                            end)
                        end)
                },
                -- Switch to previous workspace
                { key = "9", mods = "LEADER", action = wezterm.action.SwitchWorkspaceRelative(-1) },
                -- Switch to next workspace
                { key = "0", mods = "LEADER", action = wezterm.action.SwitchWorkspaceRelative(1)  }
       }
    },
    -- Once again, doc is above code. Deal with it
    -- First a quick break down on terms here
    -- - status_bar
    --      An array of groups that are compiled and passed through to wezterm
    -- - group
    --      A set of components that should be contained "together"
    -- - component
    --      A function that when called returns a string or nil. This string is the text
    --      content that will be rendered into the group which in turn is rendered into the
    --      status bar. See lib.components for some pre-made components that you can use
    --      NOTE: You can also simply use a string here instead of a function if you
    --      have some static string you want to represent.
    -- - options
    --      A key value entry that specifies an attribute of some kind to apply to the that level and below by default
    --      An example, setting the "background" of a status bar will set the background
    --      for all components in the status bar (unless the component specifies its _own_
    --      background)
    --      Options Apply top down and are can be overriden by applying the same option
    --      at a lower level
    -- - dividers
    --      A divider is broken up into 2 styles. Soft and Hard.
    -- - soft divider
    --      A special divider used to separate individual components within a group. By default
    --      this is 'wezterm.nerdfonts.pl_left_soft_divider' or 'wezterm.nerdfonts.pl_right_soft_divider' (depending on if the status bar is a right or left status bar)
    -- - hard divider
    --      A special divider used to separate individual groups within the status bar.
    --      By default, this is 'wezterm.nerdfonts.pl_left_hard_divider' or 'wezterm.nerdfonts.pl_right_hard_divider' (depending on if the status bar is a right or left status bar)
    -- treated as a "group" of components to use.
    --
    -- The long short, a status bar is an array of groups that can also have optional attributes at any level in the status bar (which apply down as specified in the options definition).
    -- Note: You can have as many items in a group and as many groups as you would like,
    -- up to whatever wezterm will allow. This just provides a (IMO) easier way to create
    -- a "standard" status bar
    -- Valid "options"
    --     - background
    --         Anything that wezterm.color.parse accepts
    --     - foreground
    --         Anything that wezterm.color.parse accepts
    --     - attributes
    --         A table representation of the "Attribute" object
    --         used in wezterm.format
    --         A table that can contain any of the following attributes
    --         - intensity
    --             - Valid options include 'Normal', 'Bold', 'Half'
    --         - underline
    --             - Valid options include 'Single', 'Double', 'Curley', 'Dotted', 'Dashed'
    --         - italic
    --             - Valid options include true, false
    --     - soft_div_icon
    --         The icon to display for soft dividers
    --     - hard_div_icon
    --         The icon to display for hard dividers
    left_status_bar = {
        {
            lib.components.user(),
            background = '#5cf19e',
            foreground = 'BLACK',
        },
        {
            lib.components.host(),
            background = '#fc669b',
            foreground = 'BLACK',
        },
        {
            lib.components.workspace(),
            background = '#808080',
            foreground = '#ffffff',
        },
        soft_div_icon = nerdfonts.pl_left_soft_divider,
        hard_div_icon = nerdfonts.pl_left_hard_divider,
        attributes = {
            intensity = 'Bold',
        },
    },
    right_status_bar = {
        -- This is built left to right
        {
            lib.components.tmux(),
            lib.components.leader(),
            lib.components.spacer(),
            lib.components.caps_indicator(),
            lib.components.battery({show_percentage=true}),
            lib.components.spacer(),
            soft_div_icon = ''
        },
        {
            lib.components.time(),
            attributes = {
                italic = true
            },
            background = 'WHITE',
            foreground = 'BLACK'
        },
    },
    format_tab = lib.tab_styles.diamond('#37b6ff', 'BLACK'),
    -- If you don't like how I have the "groups" configured,
    -- you can instead provide the following keys, with a valid callback function.
    -- Note, if these are provided, we will ignore whatever is in the "non raw" version
    -- if its in the config.
    -- EG: raw_left_status_bar will supercede left_status_bar (and only left_status_bar).
    -- This callback function will be passed straight to wezterm
    -- raw_left_status_bar = function(),
    -- raw_right_status_bar = function()
    --
    tab_bar_alignment = 'Center',
    -- This can be 'Left', 'Center', or 'Right'
    -- and will align the tab bar to any of those locations
    -- as best it can
    prefer_egl = true,
    -- Passed directly to wezterm
    domains = {
        unix = {
            -- Valid unix domain defaults can be placed here
            -- Note, a special _default_ key can be provided to 
            -- **any** of the items you put in domains.
            -- If there are multiple defaults, the last alphabetical domain
            -- is used (just how lua pairs works. Dont set multiple defaults
            -- you nonce)
            default = true
        }
    },
    detect_password_input = true
    -- Passed directly to wezterm
}

function lib.merge_config(user_config)
    user_config = user_config or {}
    local merged_conf = lib.merge_table(
        lib.deepcopy(lib.default_config),
        user_config
    )
    -- Some shenanigans to deal with weirdness in merging
    if user_config.keys then
        if user_config.keys.maps then
            merged_conf.keys.maps = user_config.keys.maps
        end
        if user_config.keys.tables then
            merged_conf.keys.tables = user_config.keys.tables
        end
    end
    wezterm.miversen_wezconf.merged_conf = merged_conf
    return merged_conf
end

function lib.load(user_config)
    return lib.compile_config_to_wez(lib.merge_config(user_config))
end

return lib
