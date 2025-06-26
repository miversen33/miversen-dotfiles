vim.api.nvim_buf_set_keymap(0, "n", "<CR>", "", { noremap = true, silent = true, desc = "Runs HTTP Request", callback = function() require("kulala").run() end})
