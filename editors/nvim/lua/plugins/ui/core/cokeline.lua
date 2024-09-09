-- We should consider using cokeline for tab groups and dropbar for actual file information
local function convert_highlight_group_to_rgb( highlight_group_name )
    local hl = highlight_group_name and
                   vim.api.nvim_get_hl( 0, { name = highlight_group_name } )
    local get_color = require( "cokeline.hlgroups" ).get_hl_attr
    if not hl or vim.fn.empty( hl ) == 1 then
        return { bg = nil, fg = get_color( "Normal", "fg" ) }
    end
    return {
        bg = vim.fn.synIDattr( vim.fn.synIDtrans( vim.fn.hlID(
                                                      highlight_group_name ) ),
                               "bg#" ),
        fg = vim.fn.synIDattr( vim.fn.synIDtrans( vim.fn.hlID(
                                                      highlight_group_name ) ),
                               "fg#" )
    }
end

local function cokeline_opts()
    local inactive_bg_color =
        convert_highlight_group_to_rgb( "StatusLineNC" ).bg
    vim.api.nvim_set_hl( 0, "Cokeline_bufferline", { bg = inactive_bg_color } )

    local get_color = require( "cokeline.hlgroups" ).get_hl_attr
    local warn_color = convert_highlight_group_to_rgb('NotifyWARNIcon').fg
    local max_error_limit = 10
    local error_color = convert_highlight_group_to_rgb( "NotifyERRORIcon" ).fg
    local get_active_color = function()
        local current_mode = vim.api.nvim_get_mode().mode
        local converted_modes = {
            n = convert_highlight_group_to_rgb( "lualine_a_normal" ),
            nt = convert_highlight_group_to_rgb( "lualine_a_normal" ),
            t = convert_highlight_group_to_rgb( "lualine_a_normal" ),
            i = convert_highlight_group_to_rgb( "lualine_a_insert" ),
            v = convert_highlight_group_to_rgb( "lualine_a_visual" ),
            V = convert_highlight_group_to_rgb( "lualine_a_visual" ),
            r = convert_highlight_group_to_rgb( "lualine_a_replace" ),
            R = convert_highlight_group_to_rgb( "lualine_a_replace" ),
            no = convert_highlight_group_to_rgb( "lualine_a_replace" ),
            c = convert_highlight_group_to_rgb( "lualine_a_command" )
        }
        return converted_modes[current_mode] or
                   {
                fg = get_color( "Normal", "fg" ),
                bg = get_color( "Normal", "bg" )
            }
    end
    local setup = {
        mappings = { cycle_prev_next = true },
        fill_hl = "Cokeline_bufferline",
        default_hl = {
            fg = function( buffer )
                return buffer.is_focused and get_active_color().fg or
                           get_color( "Normal", "fg" )
            end,
            bg = function( buffer )
                return buffer.is_focused and get_active_color().bg or
                           inactive_bg_color
            end
        },
        tabs = {
            placement = "left",
            components = {
                {
                    ---@module "cokeline.tabs"
                    ---@param tabpage TabPage
                    text = function( tabpage )
                        return tabpage.is_active and get_active_color().bg and
                                   "" or " "
                    end,
                    bg = "NONE",
                    fg = function( tabpage )
                        return tabpage.is_active and get_active_color().bg
                    end,
                    style = function( tabpage )
                        return tabpage.hovered and "undercurl"
                    end
                }, {
                    ---@module "cokeline.tabs"
                    ---@param tabpage TabPage
                    text = function( tabpage )
                        return "Tab #" .. tabpage.number .. ""
                    end,
                    bg = function( tabpage )
                        return tabpage.is_active and get_active_color().bg
                    end,
                    fg = function( tabpage )
                        return tabpage.is_active and get_active_color().fg
                    end
                }, {
                    ---@module "cokeline.tabs"
                    ---@param tabpage TabPage
                    text = function( tabpage )
                        if not tabpage.focused or not tabpage.focused.buffer then
                            return ""
                        end
                        local buffer = tabpage.focused.buffer
                        if buffer.is_readonly then
                            return " "
                        end
                        if buffer.is_modified then
                            return " "
                        end
                        return ""
                    end,
                    ---@module "cokeline.tabs"
                    ---@param tabpage TabPage
                    fg = function( tabpage )
                        if not tabpage.focused or not tabpage.focused.buffer then
                            return get_active_color().fg
                        end
                        local buffer = tabpage.focused.buffer
                        if buffer.is_readonly or buffer.is_modified then
                            return warn_color
                        end
                        return get_active_color().fg
                    end,
                    bg = function( tabpage )
                        return tabpage.is_active and get_active_color().bg
                    end
                }, {
                    ---@module "cokeline.tabs"
                    ---@param tabpage TabPage
                    text = function( tabpage )
                        if not tabpage or not tabpage.focused or
                            not tabpage.focused.buffer then
                            return ""
                        end
                        local buffer = tabpage.focused.buffer
                        return " " .. buffer.devicon.icon
                    end,
                    ---@module "cokeline.tabs"
                    ---@param tabpage TabPage
                    fg = function( tabpage )
                        if not tabpage or not tabpage.focused or
                            not tabpage.focused.buffer then
                            return get_active_color().fg
                        end
                        local buffer = tabpage.focused.buffer
                        return buffer.devicon.color
                    end,
                    bg = function( tabpage )
                        return tabpage.is_active and get_active_color().bg
                    end
                }, {
                    ---@module "cokeline.tabs"
                    ---@param tabpage TabPage
                    text = function( tabpage )
                        local tab_title = ""
                        if tabpage.focused and tabpage.focused.buffer then
                            local buffer = tabpage.focused.buffer
                            local prefix = buffer.unique_prefix or ""
                            tab_title = prefix .. "" .. buffer.filename
                        else
                            tab_title = " " .. #tabpage.windows .. " windows"
                        end
                        return tab_title
                    end,
                    bg = function( tabpage )
                        return tabpage.is_active and get_active_color().bg
                    end,
                    fg = function( tabpage )
                        return tabpage.is_active and get_active_color().fg
                    end
                }, {
                    text = " ",
                    bg = function( tabpage )
                        return tabpage.is_active and get_active_color().bg
                    end,
                    fg = function( tabpage )
                        return tabpage.is_active and get_active_color().fg
                    end
                }, {
                    ---@module "cokeline.tabs"
                    ---@param tabpage TabPage
                    text = function( tabpage )
                        if not tabpage.focused or not tabpage.focused.buffer then
                            return ""
                        end
                        local buffer = tabpage.focused.buffer
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
                    fg = function( tabpage )
                        if not tabpage.focused or not tabpage.focused.buffer then
                            return get_active_color().fg
                        end
                        local buffer = tabpage.focused.buffer
                        return buffer.diagnostics.errors > 0 and
                                   buffer.diagnostics.errors <= max_error_limit and
                                   error_color
                    end,
                    bg = function( tabpage )
                        return tabpage.is_active and get_active_color().bg
                    end
                }, {
                    text = "",
                    on_click = function( _, _, _, _, tabpage )
                        tabpage:close()
                    end,
                    bg = function( tabpage )
                        return tabpage.is_active and get_active_color().bg
                    end,
                    fg = function( tabpage )
                        return tabpage.is_active and get_active_color().fg
                    end

                }, {
                    text = " ",
                    bg = function( tabpage )
                        return tabpage.is_active and get_active_color().bg
                    end,
                    fg = function( tabpage )
                        return tabpage.is_active and get_active_color().fg
                    end

                }, {
                    ---@module "cokeline.tabs"
                    ---@param tabpage TabPage
                    text = function( tabpage )
                        return tabpage.is_active and get_active_color().bg and
                                   "" or ""
                    end,
                    bg = "NONE",
                    fg = function( tabpage )
                        return tabpage.is_active and get_active_color().bg
                    end
                }
            }
        },
        components = {}
    }
    return setup
end

---@module "lazy"
---@type LazySpec
return {
    "willothy/nvim-cokeline",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    priority = 998,
    event = "VeryLazy",
    opts = cokeline_opts
}
