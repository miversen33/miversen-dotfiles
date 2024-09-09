local function dropbar_ignore_buffer(buf, win)
    local ft = vim.bo[buf].filetype
    local acceptable =
        not vim.api.nvim_win_get_config(win).zindex
        and ft ~= ''
        and vim.api.nvim_buf_get_name(buf) ~= ''
        and not vim.wo[win].diff
    for _, buftype in ipairs(_G.__miversen_config_excluded_filetypes_array) do
        if ft == buftype then
            acceptable = false
            break
        end
    end
    return acceptable
end

local dropbar_opts = {
    general = {
        enable = dropbar_ignore_buffer,
    },
    icons = {
        ui = {
            bar = {
                separator = "  ",
            }
        }
    },
    sources = {
        ---@module "dropbar.utils.menu"
        ---@type dropbar_select_opts_t
        path = {
            ---@param item any
            ---@return string, string[][]?
            format_item = function(item)
                return "name"
            end
        }
    }
}

---@module "lazy"
---@type LazySpec
return {
    "Bekaboo/dropbar.nvim",
    requires = {
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make"
        },
    },
    lazy = false,
    opts = dropbar_opts
}
