local smart_splits_config = {
    tmux_integration = false
}

---@module "lazy"
---@type LazySpec
return {
    "mrjones2014/smart-splits.nvim",
    opts = smart_splits_config,
    event = "VeryLazy"

}
