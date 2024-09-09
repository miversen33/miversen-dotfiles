local function clipboard_config()
    local osc52 = require("osc52")
    osc52.setup({
        max_length = 0,
        silent = false,
        trim = false,
    })

    local function copy(lines, _)
        osc52.copy(table.concat(lines, "\n"))
    end

    local function paste()
        return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
    end

    vim.keymap.set("n", "<leader>c", osc52.copy_operator, { expr = true })
    vim.keymap.set("n", "<leader>cc", "<leader>c_", { remap = true })
    vim.keymap.set("x", "<leader>c", osc52.copy_visual)

    vim.g.clipboard = {
        name = "osc52",
        copy = {
            ["+"] = copy,
            ["*"] = copy,
        },
        paste = {
            ["+"] = paste,
            ["*"] = paste,
        },
    }

end

---@module "lazy"
---@type LazySpec
return {
    "ojroques/nvim-osc52", -- Neovim clipboard integration
    config = clipboard_config
}
