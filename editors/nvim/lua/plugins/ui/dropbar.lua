local function dropbar_ignore_buffer(buf, win)
    local ft = vim.bo[buf].filetype
    local acceptable =
        not vim.api.nvim_win_get_config(win).zindex
        and ft ~= ''
        and vim.api.nvim_buf_get_name(buf) ~= ''
        and not vim.wo[win].diff
    for _, buftype in ipairs(vim.g._config.excluded_filetypes) do
        if ft == buftype then
            acceptable = false
            break
        end
    end
    return acceptable
end

local dropbar_opts = {
    bar = {
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

---@type LazySpec
return {
    "Bekaboo/dropbar.nvim",
    lazy = false,
    opts = dropbar_opts
}
