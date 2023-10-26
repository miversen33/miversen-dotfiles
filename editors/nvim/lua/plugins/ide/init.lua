local current_path = ... .. "."

local ide = {
    --- The chunky bois
    require(current_path .. "mason"),
    require(current_path .. "completion"),
    --- Utils
    require(current_path .. "netman"),
    require(current_path .. "dap-vtext"),
    require(current_path .. "sniprun"),
    require(current_path .. "pretty_hover"),
    require(current_path .. "icons"),
    require(current_path .. "indent"),
    require(current_path .. "move"),
    require(current_path .. "bufdelete"),
    require(current_path .. "clipboard"),
    require(current_path .. "glance"),
    require(current_path .. "comment"),
    require(current_path .. "gitsigns"),
    require(current_path .. "ccc"),
    require(current_path .. "toggleterm"),
    require(current_path .. "hlargs"),
    require(current_path .. "smartsplits"),
    require(current_path .. "treesitter"),
    require(current_path .. "hex"),
    require(current_path .. "trouble"),
    require(current_path .. 'muren'),
    require(current_path .. "vim-visual-multi"),
    --- Langauage Specific Stuff
    require(current_path .. "python"),
    require(current_path .. "rust"),
    require(current_path .. "svelte"),
}

return ide
