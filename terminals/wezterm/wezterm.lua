local wezterm = require("wezterm")
local os_info = {
    os = "",
    arch = "",
    sep = "",
    home_dir = ""
}
local OS = {
    LINUX = 'LINUX',
    WINDOWS = 'WINDOWS',
    MAC = 'MAC',
}


local function generate_global()
    if wezterm.target_triple:match('linux') then
        os_info.os = OS.LINUX
        os_info.sep = "/"
    elseif wezterm.target_triple:match('windows') then
        os_info.os = OS.WINDOWS
        os_info.sep = "\\"
    else
        os_info.os = OS.MAC
        os_info.os = "/"
    end
    os_info.home_dir = wezterm.home_dir
    -- I mean, probably shouldn't just default to MAC if no
    -- match but 🤷
end


local function get_color_scheme()
    return 'vscode-dark'
end

local function get_font()
    return wezterm.font_with_fallback({'MesloLGS NF'})
end

local function generate_window_frame()
    local frame = {}
    -- frame.font = get_font()
    return frame
end

-- consider a config for windows and a config for linux?

local function generate_windows_launch_menu()

end

local function generate_linux_launch_menu()
    -- Include checking for tmux and screen
    local get_shells_cmd = "cat /etc/shells && command -v tmux && command -v screen"
    local output = io.popen(get_shells_cmd, "r")
    local shells = {}
    for line in output:lines() do
        -- Ignore comments and whitespace only lines
        if line:match('^[#%s]+') or line:match('^%s*$') then goto continue end
        -- Probably want to ensure we don't have "duplicate" shells?
        local shell = {}
        for _ in line:gmatch('([^/]+)') do
            table.insert(shell, _)
        end
        local exec = shell[#shell]
        -- This shell already exists
        if shells[exec] then goto continue end
        shells[exec] = {
            label = exec,
            args = shell
        }
        ::continue::
    end
    local launch_menu = {}
    for _, menu_item in pairs(shells) do
        table.insert(launch_menu, menu_item)
    end
    return launch_menu
end

local function get_shell()
    -- Figure out the OS and launch one of the following items
    -- 1) default wsl instance?
    -- 2) powershell?
    -- 3) user default shell
end

local function generate_launch_menu()

    if os_info.os == OS.WINDOWS then
        return generate_windows_launch_menu()
    else
        return generate_linux_launch_menu()
    end
end

local function get_window_decor()
    return 'RESIZE'
end

local function get_env_vars()
    return {
        NOTMUX="1"
    }
end

generate_global()

local M =  {
    set_environment_variables = get_env_vars(),
    font = get_font(),
    window_frame = generate_window_frame(),
    launch_menu = generate_launch_menu(),
    use_fancy_tab_bar = true,
    prefer_egl = true,
    -- tab_bar_at_bottom = true,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    },
    window_decorations = get_window_decor(),
    color_scheme_dirs = { string.format("%s%s.config%swezterm%scolors", os_info.home_dir, os_info.sep, os_info.sep, os_info.sep) },
    color_scheme = get_color_scheme(),
}

-- for key, value in pairs(require("keybinds")) do
--     M[key] = value
-- end

return M
