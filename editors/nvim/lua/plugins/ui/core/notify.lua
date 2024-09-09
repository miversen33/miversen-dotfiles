local function config_notify()
    local notify = require("notify")
    vim.notify = notify
    notify.setup({
        background_colour = vim.g.__miversen_background_color
    })
end

local notify = {
    "rcarriga/nvim-notify",
    config = config_notify,
    lazy = false,
    priority = 999
}

return notify
