---@module "lazy"
---@type LazySpec
local snacks = {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@module "snacks"
  ---@type snacks.Config
  opts = {
    input = { enabled = true },
  },
}

return snacks
