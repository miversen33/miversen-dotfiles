local smear_opts = {
    stiffness = 0.8,
    trailing_stiffness = 0.6,
    trailing_exponent = 0,
    distance_stop_animating = 0.5,
    hide_target_hack = false,
}

---@module "lazy"
---@type LazySpec
return {
    "sphamba/smear-cursor.nvim",
    opts = smear_opts
}
