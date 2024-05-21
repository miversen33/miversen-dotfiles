local function config_notify()
    local notify = require("notify")
    vim.notify = notify
    notify.setup({
        background_colour = "#1e1e1e"
    })
end

local notify = {
    "rcarriga/nvim-notify",
    config = config_notify,
    priority = 900
}

return notify
