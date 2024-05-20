local current_path = ...
local ui_path = current_path .. '.'

local ui = {
    require(ui_path .. "vscode"),
    require(ui_path .. "screenkey"),
    require(ui_path .. "dressing"),
    require(ui_path .. "cokeline"),
    require(ui_path .. "lualine"),
    require(ui_path .. "dropbar"),
    require(ui_path .. "neotree"),
    require(ui_path .. "telescope"),
    require(ui_path .. "hydra"),
    require(ui_path .. "notify"),
    require(ui_path .. "fidget"),
    require(ui_path .. "lsplines"),
    require(ui_path .. "hlargs"),
    require(ui_path .. "hlchunk"),
    require(ui_path .. "vt_context"),
    require(ui_path .. "lspcolors"),
    require(ui_path .. "sunglasses"),
    require(ui_path .. "marks"),
    require(ui_path .. "illuminate"),
    require(ui_path .. "neoscroll"),
    require(ui_path .. "nvim-bufdel"),
    require(ui_path .. "registers"),
}

return ui
