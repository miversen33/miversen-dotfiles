local extended_mode_map = {
    dap="",
    repl="ﲵ",
    lsp="",
    test="ﭧ",
    search="",
}

-- TODO: Add hydra mode and color of some kind?
local function lualine_config()
    vim.g.gitblame_display_virtual_text = 0
    vim.api.nvim_set_hl(0, 'Gitblame', {
        fg = "#744F82",
        italic = true
    })
    vim.g.gitblame_highlight_group = "Gitblame"
    local lualine = require("lualine")
    local git_blame = require("gitblame")
    local get_buf_filetype = function()
        return vim.api.nvim_get_option_value('filetype', { buf = 0})
    end
    ---@param output string
    local format_name = function(output)
        for _, excluded_filetype in ipairs(_G.__miversen_config_excluded_filetypes_array) do
            if excluded_filetype == get_buf_filetype() then
                output = ""
                break
            end
        end
        local output_limit = 40
        if output:len() > output_limit - 3 then
            local new_first = output:len() - (output_limit - 3)
            output = "..." .. output:sub(new_first)
        end
        return output
    end
    local branch_max_width = 40
    local branch_min_width = 10
    lualine.setup({
        options = {
            theme = "vscode",
            globalstatus = true,
        },
        sections = {
            lualine_a = {
                {
                    "mode",
                    fmt = function(output)
                        return output:len() > 0 and output:sub(1,1):upper() or ""
                    end
                },
                {
                    function()
                        return extended_mode_map[vim.g.__miversen_extended_mode] or ''
                    end
                },
                {
                    "branch",
                    fmt = function(output)
                        local win_width = vim.o.columns
                        local max = branch_max_width
                        if win_width * 0.25 < max then
                            max = math.floor(win_width * 0.25)
                        end
                        if max < branch_min_width then
                            max = branch_min_width
                        end
                        if max % 2 ~= 0 then
                            max = max + 1
                        end
                        if output:len() >= max then
                            return output:sub(1, (max / 2) - 1)
                            .. "..."
                            .. output:sub(-1 * ((max / 2) - 1), -1)
                        end
                        return output
                    end,
                },
            },
            lualine_b = {
                {
                    "filename",
                    file_status = false,
                    path = 1,
                    fmt = format_name,
                },
                {
                    "diagnostics",
                    update_in_insert = true,
                },
            },
            lualine_c = {
                {
                    git_blame.get_current_blame_text,
                    cond = git_blame.is_blame_text_available,
                    color = { fg = "#ABABAB", gui = "italic" },
                },
            },
            lualine_x = {
                {
                    function()
                        local icon = require("nvim-web-devicons").get_icon_by_filetype(
                            vim.api.nvim_get_option_value("filetype", { buf = 0 })
                        )
                        local lsps = vim.lsp.get_clients({ bufnr = 0 })
                        if not lsps or #lsps == 0 then return icon or "" end
                        local names = {}
                        for _, lsp in ipairs(lsps) do
                            table.insert(names, lsp.name)
                        end
                        return string.format("%s | %s", icon, table.concat(names, ", "))
                    end,
                    on_click = function()
                        vim.api.nvim_command("LspInfo")
                    end,
                    color = function()
                        local _, color = require("nvim-web-devicons").get_icon_cterm_color_by_filetype(
                            vim.api.nvim_get_option_value("filetype", { buf = 0 })
                        )
                        return { fg = color }
                    end,
                },
                "encoding",
                "progress",
            },
            lualine_y = {},
            lualine_z = {
                "location",
                {
                    function()
                        local starts = vim.fn.line("v")
                        local ends = vim.fn.line(".")
                        local count = starts <= ends and ends - starts + 1 or starts - ends + 1
                        return count .. "V"
                    end,
                    cond = function()
                        return vim.fn.mode():find("[Vv]") ~= nil
                    end,
                },
            },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {
                {
                    "filetype",
                    icon_only = true,
                },
                {
                    "filename",
                    path = 1,
                    fmt = format_name,
                },
            },
            lualine_x = {},
            lualine_y = {},
            lualine_z = {},
        },
    })
end

local lualine = {
    "nvim-lualine/lualine.nvim", -- Neovim status line
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "onsails/lspkind-nvim",
        "f-person/git-blame.nvim",
    },
    lazy = false,
    priority = 999,
    config = lualine_config
}

return lualine
