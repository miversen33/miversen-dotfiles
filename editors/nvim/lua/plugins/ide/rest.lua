local rest_opts = {}

local function rest_init()
    vim.g.rest_nvim = rest_opts
end

-- Pick one mate
---@module "lazy"
---@type LazySpec
return {
    {
    "mistweaverco/kulala.nvim",
       opts = rest_opts
    },
    {
        "rest-nvim/rest.nvim",
        init = rest_init
    }
}
