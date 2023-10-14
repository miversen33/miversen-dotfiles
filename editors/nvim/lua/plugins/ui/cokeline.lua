local cokeline_dependencies = {
    "nvim-lua/plenary.nvim",
    "kyazdani42/nvim-web-devicons",
    "Mofiqul/vscode.nvim",
}

local function cokeline_opts(cokeline)
    local get_color = require("cokeline.hlgroups").get_hl_attr
    -- local get_hex = require("cokeline/utils").get_hex
    local colors = require("vscode.colors").get_colors()
    local line_background = "NONE"
    -- Needs light mode color
    active_bg = colors["vscViolet"]
    local active_bg_color = active_bg
    local inactive_bg_color = colors["vscBlack"]
    local warn_color = colors["vscGitStageModified"]
    local error_color = colors["vscGitConflicting"]
    local max_error_limit = 9
    local setup = {
        mappings = {
            cycle_prev_next = true,
        },
        fill_hl = "BufferLineFill",
        default_hl = {
            fg = function(buffer)
                return buffer.is_focused
                and get_color('ColorColumn', 'bg')
                or get_color('Normal', 'fg')
            end,
            bg = function(buffer)
                return buffer.is_focused and active_bg_color or inactive_bg_color
            end,
        },
        components = {
            {
                text = function(buffer)
                    return buffer.is_focused and "" or " "
                end,
                fg = inactive_bg_color, -- line_background, -- This should be line_background but due to a bug, we cant
                bg = function(buffer)
                    return buffer.is_focused and active_bg_color or inactive_bg_color
                end,
                style = function(buffer)
                    return buffer.is_hovered and "undercurl"
                end,
            },
            {
                text = function(buffer)
                    return buffer.is_readonly and " " or buffer.is_modified and " " or " "
                end,
                fg = function(buffer)
                    return buffer.is_focused and (buffer.is_readonly or buffer.is_modified) and warn_color
                end,
            },
            {
                text = function(buffer)
                    return buffer.devicon.icon
                end,
                fg = function(buffer)
                    return buffer.devicon.color
                end,
            },
            {
                text = function(buffer)
                    return buffer.unique_prefix
                end,
                fg = get_color('Comment', 'fg'),
                style = "italic",
            },
            {
                text = function(buffer)
                    return buffer.filename .. " "
                end,
                style = function(buffer)
                    if buffer.is_hovered and not buffer.is_focused then
                        return "underline"
                    end
                end,
            },
            {
                text = function(buffer)
                    local errors = buffer.diagnostics.errors
                    if errors == 0 then
                        errors = ""
                    elseif errors <= max_error_limit then
                        errors = ""
                    else
                        errors = "🙃"
                    end
                    return errors .. " "
                end,
                fg = function(buffer)
                    return buffer.diagnostics.errors > 0
                        and buffer.diagnostics.errors <= max_error_limit
                        and error_color
                end,
            },
            {
                text = "",
                on_click = function(_, _, _, _, buffer)
                    buffer:delete()
                end,
            },
            {
                text = function(buffer)
                    return buffer.is_focused and "" or ""
                end,
                bg = function(buffer)
                    return buffer.is_focused and line_background or get_color('ColorColumn', 'bg')
                end,
                fg = function(buffer)
                    return buffer.is_focused and active_bg_color or inactive_bg_color
                end,
            },
        },
    }
    return setup
end

local cokeline = {
    "willothy/nvim-cokeline",
    dependencies = cokeline_dependencies,
    config = true,
    opts = cokeline_opts
}

return cokeline
