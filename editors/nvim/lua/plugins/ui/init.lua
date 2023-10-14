local current_path = ... .. "."

local ui = {
    require(current_path .. "vscode"),
    require(current_path .. "dressing"),
    require(current_path .. "cokeline"),
    require(current_path .. "lualine"),
    require(current_path .. "dropbar"),
    require(current_path .. "neotree"),
    require(current_path .. "hydra"),
    require(current_path .. "telescope"),
    require(current_path .. "lspcolors"),
    require(current_path .. "notify"),
    require(current_path .. "fidget"),
    require(current_path .. "vt_context"),
    require(current_path .. "lsplines"),
}

return ui
