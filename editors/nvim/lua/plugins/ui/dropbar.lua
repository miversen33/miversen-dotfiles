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
    }
}

local dropbar = {
    "Bekaboo/dropbar.nvim",
    opts = dropbar_opts,
}

return dropbar
