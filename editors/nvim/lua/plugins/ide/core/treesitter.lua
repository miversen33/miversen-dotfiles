local treesitter_config = {
    -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
    highlight = { enable = true },
    auto_install = true,
    markid = { enable = true },
    playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
            toggle_query_editor = "o",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_anonymous_nodes = "a",
            toggle_language_display = "I",
            focus_language = "f",
            unfocus_language = "F",
            update = "R",
            goto_node = "<cr>",
            show_help = "?",
        },
    },
    query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
    },
    ensure_installed = {
        "python",
        "toml",
        "yaml",
        "markdown",
        "javascript",
        "java",
        "rust",
        "cpp",
        "lua",
        "c",
        "bash",
        "sql",
        "css",
        "html",
        "glsl",
        "zig",
        "php",
        "perl",
        "nix",
        "cmake",
        "make",
        "dockerfile",
        "diff",
        "embedded_template",
        "haskell",
        "json",
        "jsdoc",
        "kotlin",
        "luadoc",
        "ninja",
        "regex",
        "typescript",
        "tsv",
        "csv",
        "vue",
        "vim",
        "vimdoc",
        "xml",
        "nu"
    },
}

local treesitter_dependencies = {
    { "nushell/tree-sitter-nu", build = ":TSUpdate nu"}
}

---@module "lazy"
---@type LazySpec
return {
    "nvim-treesitter/nvim-treesitter",
    -- branch = "main", -- Can't use until illuminate updates and stops using nvim-treesitter.queries
    branch = "master",
    lazy = false,
    build = ":TSUpdate|TSInstall query",
    dependencies = treesitter_dependencies,
    main = "nvim-treesitter.configs",
    opts = treesitter_config
}
