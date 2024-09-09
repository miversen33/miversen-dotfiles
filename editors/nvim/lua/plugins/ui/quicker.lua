---@module "quicker"
---@type quicker.SetupOptions
local quicker_opts = {}

---@module "lazy"
---@type LazySpec
return {
    "stevearc/quicker.nvim",
    event = "Filetype qf",
    opt = quicker_opts
}
