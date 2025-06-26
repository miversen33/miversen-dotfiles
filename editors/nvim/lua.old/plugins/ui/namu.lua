---@module "lazy"
---@type LazySpec

return {
  "bassamsdata/namu.nvim",
  opts = {
      namu_symbols = {
        enable = true,
        options = {
            row_position = "top10",
            preserve_order = true,
        }, -- here you can configure namu
      },
    }
}
