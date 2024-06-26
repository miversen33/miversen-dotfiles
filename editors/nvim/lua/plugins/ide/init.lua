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
    require(current_path .. "session"),
    require(current_path .. "trouble"),
    require(current_path .. 'muren'),
    require(current_path .. "hlslens"),
    require(current_path .. "vim-visual-multi"),
    require(current_path .. "neotest"),
    require(current_path .. "scissors"),
    require(current_path .. "wakatime"),
    require(current_path .. "grug-far"),
    --- Langauage Specific Stuff
    require(current_path .. "python"),
    require(current_path .. "rust"),
    require(current_path .. "svelte"),
    require(current_path .. "haskell"),
    require(current_path .. "neovim"),
    require(current_path .. "glsl"),
    require(current_path .. "java")
}

return ide
