local disabled_languages = {
    json = true
}

-- I hate that we have to do this...
local function should_disable_ts(lang, bufnr)
    return false
    -- MAX_LINE_COUNT = 5000
    -- return disabled_languages[lang] or vim.api.nvim_buf_line_count(bufnr) > MAX_LINE_COUNT
end

local treesitter_config = {
    -- -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
    highlight = {
        enable = true,
        disable = should_disable_ts
    },
    indent = {
        enable = true,
    },
    disable = should_disable_ts,
    -- auto_install seems to cause a noticable perf issues
    auto_install = true
}

local treesitter_dependencies = {
    { "nushell/tree-sitter-nu", build = ":TSUpdate nu"}
}

---@module "lazy"
---@type LazySpec
return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- Can't use until illuminate updates and stops using nvim-treesitter.queries
    -- branch = "master",
    lazy = false,
    enabled = true,
    build = ":TSUpdate|TSInstall query",
    dependencies = treesitter_dependencies,
    main = "nvim-treesitter.configs",
    opts = treesitter_config
}
