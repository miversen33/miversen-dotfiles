local telescope_dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-live-grep-args.nvim'
}

local telescope_extensions = {
    "persisted"
}

local telescope_options = {
}

local telescope = {
    "nvim-telescope/telescope.nvim",
    dependencies = telescope_dependencies,
    cmd = {"Telescope"},
    opts = telescope_options,
    config = function()
        for _, extension in ipairs(telescope_extensions) do
            require("telescope").load_extension(extension)
        end
    end
}

return telescope
