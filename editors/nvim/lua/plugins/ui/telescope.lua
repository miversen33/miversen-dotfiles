local telescope_dependencies = {
    'nvim-lua/plenary.nvim'
}

local telescope = {
    "nvim-telescope/telescope.nvim",
    dependencies = telescope_dependencies,
    cmd = {"Telescope"}

}

return telescope
