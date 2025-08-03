require("scripts.shim")

local editor_config = vim.g._config or {}


editor_config.shell = require("scripts.shell")
editor_config.lsp = require("scripts.lsp")

vim.g._config = editor_config
