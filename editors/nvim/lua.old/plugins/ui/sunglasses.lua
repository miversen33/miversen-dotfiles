---@module "sunglassess"
local sunglasses_opts = {
    filter_percent = .35,
    log_level = "TRACE2"
}

---@module "lazy"
---@type LazySpec
return {
    "miversen33/sunglasses.nvim",
    -- commit = '9175716',
    opts = sunglasses_opts,
    event = "VeryLazy",
    enabled = false,
}
