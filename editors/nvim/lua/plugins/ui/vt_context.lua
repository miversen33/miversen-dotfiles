local vt_context_config = {
    highlight = "LspInlayHint"
}

---@module "lazy"
---@type LazySpec
return {
    "haringsrob/nvim_context_vt",
    event = "VeryLazy",
    opts = vt_context_config
}
