local telescope_dependencies = {
    'nvim-lua/plenary.nvim'
}

local telescope_extensions = {
    "persisted"
}

local telescope = {
    "nvim-telescope/telescope.nvim",
    dependencies = telescope_dependencies,
    cmd = {"Telescope"},
    config = function()
        for _, extension in ipairs(telescope_extensions) do
            require("telescope").load_extension(extension)
        end
    end
}

return telescope
