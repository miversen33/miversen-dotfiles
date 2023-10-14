local glance_opts = {
    height = 25,
    border = {
        enable = true
    },
    list = {
        position = "left"
    },
    theme = {
        mode = "darken"
    }
}

local glance = {
    "dnlhc/glance.nvim",
    config = true,
    opts = glance_opts
}

return glance
