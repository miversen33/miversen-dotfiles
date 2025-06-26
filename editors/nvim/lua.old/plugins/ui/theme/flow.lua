local flow_opts = {}

-- Potentially new theme if in the future it gets more options
-- Uncomment this if you want to use the flow theme
-- vim.g.__miversen_set_theme('flow')

---@module "lazy"
---@type LazySpec
return {
  "0xstepit/flow.nvim",
  lazy = false,
  priority = 1000,
  opts = flow_opts,
}
