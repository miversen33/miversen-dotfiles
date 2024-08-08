local prettier = {
  "prettier",
  args = {
    "--use-tabs=false"
  }
}

local clang_format = {
  "clang-format",
  args = {}
}

local shell_format = {
  "shfmt",
  args = {}
}
local conform_opts = {
  formatters_by_ft = {
    python = {
      "isort", "ruff server"
    },
    lua = {
      "lua-format",
      args = {
        "--indent-width=4",
        "--column-limit=80",
        "--continuation-indent-width=4",
        "--no-use-tab",
        "--indent-width=4",
        "--keep-simple-control-block-one-line",
        "--keep-simple-function-one-line",
        "--align-args",
        "--no-break-after-functioncall-lp",
        "--no-break-before-functioncall-rp",
        "--align-parameter",
        "--no-break-after-functiondef-lp",
        "--no-break-before-functiondef-rp",
        "--align-table-field",
        "--break-after-table-lb",
        "--break-before-table-rb",
        "--single-quote-to-double-quote",
        "--spaces-inside-functiondef-parens",
        "--spaces-inside-functioncall-parens",
        "--spaces-inside-table-braces",
        "--spaces-around-equals-in-field",
            "$FILENAME"
      }
    },
    rust = {
      "rustfmt"
    },
    html = prettier,
    javascript = prettier,
    css = prettier,
    svelte = prettier,
    c = clang_format,
    cpp = clang_format,
    java = clang_format,
    sh = shell_format,
    bash = shell_format,
    zsh = shell_format,
  }
}

return {
  'stevearc/conform.nvim',
  opts = conform_opts,
}
