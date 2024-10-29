local wezterm = require('wezterm')

local OS_ICON_MAP = {
    windows = wezterm.nerdfonts.md_microsoft_windows,
    apple = wezterm.nerdfonts.md_apple,
    ['arch linux'] = wezterm.nerdfonts.md_arch
}


-- This isn't super clear but basically, this will
-- round the provided number down to the nearest number that
-- is a multiple of the target_multiple.
-- EG
-- lib.round_down_to_nearest(1107, 5) == 1105 (1105 is the nearest lower multiple of 5)
-- Thank roblox! Very cool!
-- https://devforum.roblox.com/t/rounding-numbers-to-the-nearest-5/443160/4
local function round_down_to_nearest(number, multiple)
    return math.floor(number / multiple) * multiple
end

local function compute_size_of_space(pixel_width, font_size)

end

---@param ssh_args string
local function parse_username_hostname_from_ssh_prog(ssh_args)
    -- So this might look like some black magic fuckery but
    -- basically, we are making the assumption that the last argument in the ssh string is the username and host.
    -- Technically this is incorrect as you can provide arguments after that are ran on the ssh client,
    -- but we are accepting that currently
    local ssh_substring = ssh_args:sub(#ssh_args - ssh_args:reverse():find(" ") + 2, #ssh_args)
    local username = ssh_substring:match("[^@]+@")
    if username then
        ssh_substring=ssh_substring:sub(#username + 1, #ssh_substring)
        username = username:sub(0, #username - 1)
    end
    local hostname = ssh_substring
    return {
        username = username,
        hostname = hostname
    }
end

local function parse_username_hostname_from_container(conatiner_args)
    return {
        username  = "",
        hostname = ""
    }
end

local function parse_os_icon(os_name)
    return OS_ICON_MAP[os_name] or wezterm.nerdfonts[string.format("md_%s", os_name)] or " "
end


local M = {}

---@param format_string string|nil
---       Default: %H:%M:%S %a %B %Y
M.time = function(format_string)
    --     If provided, sets the time/date format string
    format_string = format_string or '%H:%M:%S %a %B %Y'
    return function()
        return wezterm.strftime(format_string)
    end
end

---@param leader_string string|nil
---    Default: ↑
M.leader = function(leader_string)
    leader_string = leader_string or '↑'
    return function(window)
        local text = window:leader_is_active() and leader_string or ''
        local override_config = window:get_config_overrides() or {}
        -- TODO: Come up with a better way to show this????
        if override_config.leader then
            text = string.format("%s", wezterm.nerdfonts.md_cancel)
        end
        return text
    end
end

---@param tmux_string string|nil
---  Default: ﬑
M.tmux = function(tmux_string)
    tmux_string = tmux_string or '﬑'
    return function(_, pane)
        local _, user_vars = pcall(pane.get_user_vars, pane)
        if _ ~= true then
            return ''
        end
        local is_tmux =
        (user_vars.WEZTERM_IN_TMUX and user_vars.WEZTERM_IN_TMUX ~= "0")
        or (user_vars.WEZTERM_PROG and user_vars.WEZTERM_PROG:match('^tmux'))
        return is_tmux and tmux_string or ''
    end
end

M.debug_active_program = function()
    return function(_, pane)
        return string.format("%s %s %s", pane:get_user_vars().WEZTERM_PROG, pane:get_user_vars().WEZTERM_IN_TMUX, pane:get_foreground_process_name())
    end
end

---@param opts table<string, number>|nil
--     Default: 0.2
--     If provided, this is the discharge level at which
--     we warn you that the battery needs to be charged.
--     NOTE: Should be between 0 and 1
M.battery = function(opts)
    opts = opts or {}
    local show_percentage = opts.show_percentage
    local warn_threshold = opts.warn_threshold or 0.2
    return function()
        local battery_info = wezterm.battery_info()
        -- Short circuit if we cant read the battery for some reason
        if not battery_info or not next(battery_info) then return '' end
        battery_info = battery_info[1]
        local current_charge_level = battery_info.state_of_charge
        local rounded_charge_level = math.floor(round_down_to_nearest(current_charge_level, .10) * 100)
        local current_charge_state = battery_info.state
        local remaining = (current_charge_state == 'Charging' or current_charge_state == 'Full') and battery_info.time_to_full or battery_info.time_to_empty
        -- Fail safe just in case this is nil
        if not remaining then remaining = 0 end
        local warn_state = ''
        if rounded_charge_level <= warn_threshold then
            warn_state = wezterm.nerdfonts.fa_exclamation
        end
        local nerdfont_query_string = 'md_battery_%s'
        if current_charge_state == 'Charging' then
            if remaining < 20 then
                -- For some reason there is no nerdfont for charging 10 percent
                remaining = 20
            end
        elseif current_charge_state == 'Full' then
            nerdfont_query_string = 'md_battery'
        end
        nerdfont_query_string = string.format(nerdfont_query_string, rounded_charge_level)
        local battery_percentage = show_percentage and current_charge_level and string.format(" %s%%", math.floor(current_charge_level * 100)) or ''
        local charge_icon =
        current_charge_state == 'Charging' and wezterm.nerdfonts.cod_arrow_up
        or current_charge_state == 'Discharging' and wezterm.nerdfonts.cod_arrow_down
        or ''
        local battery_icon = string.format("%s%s%s%s", warn_state, wezterm.nerdfonts[nerdfont_query_string] and wezterm.nerdfonts[nerdfont_query_string] .. ' ', charge_icon, battery_percentage)
        return battery_icon
    end
end

---@param domain_icon_map table<string, string>|nil
---    Default: { "local" = "" }
M.domain = function(domain_icon_map)
    domain_icon_map = domain_icon_map or {}
    domain_icon_map['local'] = ""
    domain_icon_map['unix'] = wezterm.nerdfonts.md_home
    return function()
        local _d = wezterm.mux.get_domain()
        local _domain = " "
        if _d and _d:name() then
            _domain = domain_icon_map[_d:name()] or _d:name()
            _domain = string.format("%s ", _domain)
        end
        return _domain
    end
end

M.os = function()
    return function(_, pane)
        if
            not pane
            or not pane.get_user_vars
            or not pane:get_user_vars()
        then
            return " "
        end
        local os = wezterm.target_triple
        if os:match('windows') then
            os = 'windows'
        elseif os:match('darwin') then
            os = 'apple'
        else
            os = 'linux'
        end
        if OS_ICON_MAP[os] then
            return OS_ICON_MAP[os]
        end
        os = pane:get_user_vars()['WEZTERM_HOST_OS']
        if not os then return " " end
        return parse_os_icon(os:lower())
    end
end

---@param sanitize_dir_func fun(cwd: string): string|nil
---    Default: nil
M.cwd = function(sanitize_dir_func)
    return function(_, pane)
        if
            not pane
            or not pane.get_current_working_dir
            or not pane:get_current_working_dir()
        then
            return ""
        end
        local cwd = pane:get_current_working_dir().file_path
        cwd = sanitize_dir_func and sanitize_dir_func(cwd) or cwd
        return cwd or ""
    end
end

M.caps_indicator = function(icon)
    icon = icon or 'בּ'
    return function(window)
        -- We can't use this yet as there doesn't appear to be a way
        -- to tell if caps lock is currently "enabled" or not?
        local caps_enabled = false
        if window and window.keyboard_modifiers then
            local _, leds = window:keyboard_modifiers()
            caps_enabled = leds == 'CAPS_LOCK'
        end
        return caps_enabled and string.format("%s", icon) or ''
    end
end

---@param padding number|nil
---    Default: If not provided, this will consume all space available
---    NOTE: if set to -1, it will consume only enough space to center the tab bar.
---    Otherwise, this will return a string of `padding` number of white space characters
M.spacer = function(padding)
    

    return function(window, pane)
        return " "
        -- return string.format("%-" .. string.format("%ss", padding or 1), '')
    end
end

M.user = function()
    return function(_, pane)
        local _, user_vars = pcall(pane.get_user_vars, pane)
        if _ ~= true then
            return ''
        end
        return user_vars.WEZTERM_USER or ""
    end
end

M.host = function()
    return function(_, pane)
        local _, user_vars = pcall(pane.get_user_vars, pane)
        if _ ~= true then
            return ''
        end
        return user_vars.WEZTERM_HOST or ""
    end
end

M.ssh = function()
    return function(window, pane)
        local ssh_details = {
            hostname = "",
            username = "",
            os = "",
            os_icon = "",
            is_ssh = false
        }
        local _, user_vars = pcall(pane.get_user_vars, pane)
        if _ ~= true then
            return ssh_details
        end
        if user_vars.WEZTERM_PROG then
            -- check to see if the user is ssh'd into another system
            if user_vars.WEZTERM_PROG:match("^[%s]*ssh") then
                local remote_os = pane:get_user_vars()['WEZTERM_SSH_HOST_OS']
                ssh_details = parse_username_hostname_from_ssh_prog(user_vars.WEZTERM_PROG)
                ssh_details.is_ssh = true
                ssh_details.hostname = user_vars.WEZTERM_SSH_HOST and user_vars.WEZTERM_SSH_HOST or ssh_details.hostname
                ssh_details.username = user_vars.WEZTERM_SSH_USER and user_vars.WEZTERM_SSH_USER or ssh_details.username
                if remote_os then
                    ssh_details.os = remote_os:lower()
                    ssh_details.os_icon = parse_os_icon(ssh_details.os)
                end
            end
        end
        return ssh_details
    end
end

M.docker = function()
    return function(window, pane)
        local docker_details = {
            hostname = "",
            username = "",
            os = "",
            os_icon = "",
            is_container = false
        }
        local _, user_vars = pcall(pane.get_user_vars, pane)
        if _ ~= true then
            return docker_details
        end
        if user_vars.WEZTERM_PROG then
            -- check to see if the user is ssh'd into another system
            if user_vars.WEZTERM_PROG:match("^[%s]*docker%s+run") then
                local remote_os = pane:get_user_vars()['WEZTERM_CONTAINER_HOST_OS']
                docker_details = parse_username_hostname_from_container(user_vars.WEZTERM_PROG)
                docker_details.is_container = true
                docker_details.hostname = user_vars.WEZTERM_CONTAINER_HOST and user_vars.WEZTERM_CONTAINER_HOST or docker_details.hostname
                docker_details.username = user_vars.WEZTERM_CONTAINER_USER and user_vars.WEZTERM_CONTAINER_USER or docker_details.username
                if remote_os then
                    docker_details.os = remote_os:lower()
                    docker_details.os_icon = parse_os_icon(docker_details.os)
                end
            end
        end
        return docker_details
    end
end

M.workspace = function()
    return function()
        return wezterm.mux.get_active_workspace()
    end
end

return M
