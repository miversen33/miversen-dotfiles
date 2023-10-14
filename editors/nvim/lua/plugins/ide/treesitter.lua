local auto_treesitter_installer = function()
    -- TODO: Setup a thing to automatically install
    -- missing Treesitter parsers as needed
end

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
        "latex",
        "ninja",
        "regex",
        "typescript",
        "tsv",
        "csv",
        "vue",
        "vim",
        "vimdoc",
        "xml",
    },
}

local function setup()
    require("nvim-treesitter.configs").setup(treesitter_config)
    auto_treesitter_installer()
end

local treesitter_dependencies = {
    "nvim-treesitter/playground"
}

local treesitter = {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate|TSInstall query",
    dependencies = treesitter_dependencies,
    config = setup
}

return treesitter
