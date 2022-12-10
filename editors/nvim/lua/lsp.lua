if not import then
    error("Unable to find import global function! Please install it via https://github.com/miversen33/import.nvim")
end
local status, lsp_settings = pcall(require, 'ls_settings')
if not status or lsp_settings == true or lsp_settings == false then
    print("Unable to find lsp settings")
    return
end

local lsp_handlers = {
    ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
    ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
}

-- Consider making your own lsp configuration?
import({ 'lspconfig', 'cmp_nvim_lsp', 'nvim-navic'}, function(modules)
    local nvim_navic = modules['nvim-navic']
    local lspconfig = modules.lspconfig
    local cmp_nvim_lsp = modules.cmp_nvim_lsp
    -- -- TODO: lsp_signature is really cool but currently nvim-cmp is also displaying doc on snippet. Disable that first
    -- local lsp_signature = modules.lsp_signature
    -- local lsp_signature_config = {
    --     debug = false, -- set to true to enable debug logging
    --     log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
    --     -- default is  ~/.cache/nvim/lsp_signature.log
    --     verbose = false, -- show debug line number
    --
    --     bind = true, -- This is mandatory, otherwise border config won't get registered.
    --     -- If you want to hook lspsaga or other signature handler, pls set to false
    --     doc_lines = 10, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
    --     -- set to 0 if you DO NOT want any API comments be shown
    --     -- This setting only take effect in insert mode, it does not affect signature help in normal
    --     -- mode, 10 by default
    --
    --     max_height = 12, -- max height of signature floating_window
    --     max_width = 80, -- max_width of signature floating_window
    --     noice = false, -- set to true if you using noice to render markdown
    --     wrap = true, -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long
    --
    --     floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
    --
    --     floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
    --     -- will set to true when fully tested, set to false will use whichever side has more space
    --     -- this setting will be helpful if you do not want the PUM and floating win overlap
    --
    --     floating_window_off_x = 1, -- adjust float windows x position.
    --     floating_window_off_y = 1, -- adjust float windows y position. e.g -2 move window up 2 lines; 2 move down 2 lines
    --
    --     close_timeout = 4000, -- close floating window after ms when laster parameter is entered
    --     fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
    --     hint_enable = false, -- virtual hint enable
    --     hint_prefix = "🐼 ", -- Panda for parameter, NOTE: for the terminal not support emoji, might crash
    --     hint_scheme = "String",
    --     hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
    --     handler_opts = {
    --         border = "rounded" -- double, rounded, single, shadow, none, or a table of borders
    --     },
    --
    --     always_trigger = false, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58
    --
    --     auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
    --     extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
    --     zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom
    --
    --     padding = '', -- character to pad on left and right of signature can be ' ', or '|'  etc
    --
    --     transparency = nil, -- disabled by default, allow floating win transparent value 1~100
    --     shadow_blend = 36, -- if you using shadow as border use this set the opacity
    --     shadow_guibg = 'Black', -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
    --     timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
    --     toggle_key = nil, -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
    --
    --     select_signature_key = nil, -- cycle to next signature, e.g. '<M-n>' function overloading
    --     move_cursor_key = nil, -- imap, use nvim_set_current_win to move cursor between current win and floating
    -- }
    -- lsp_signature.setup(lsp_signature_config)

    local lsp_capabilities = cmp_nvim_lsp.default_capabilities()
    lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true
    local language_servers = lsp_settings.get_lsp_settings()
    local lsp_on_attach = function(client, bufnr)
        nvim_navic.attach(client, bufnr)
        -- lsp_signature.on_attach(lsp_signature_config, bufnr)
    end
    for language_server, ls_config in pairs(language_servers) do
        if ls_config['on_attach'] then
            local _ = ls_config['on_attach']
            ls_config['on_attach'] = function(client, bufnr)
                lsp_on_attach(client, bufnr)
                _(client, bufnr)
            end
        else
            ls_config['on_attach'] = function(client, bufnr)
                lsp_on_attach(client, bufnr)
            end
        end
        ls_config['capabilities'] = lsp_capabilities
        ls_config['handlers'] = lsp_handlers
        lspconfig[language_server].setup(ls_config)
    end
end)

vim.fn.sign_define('DiagnosticSignError', {
    text = '',
    numhl = 'DiagnosticSignError',
    texthl = "DiagnosticSignError",
})
vim.fn.sign_define('DiagnosticSignWarn', {
    text = '⚠',
    numhl = 'DiagnosticSignWarn',
    texthl = "DiagnosticSignWarn"
})
vim.fn.sign_define('DiagnosticSignInformation', {
    text = '',
    numhl = 'DiagnosticSignInformation',
    texthl = "DiagnosticSignInformation"
})
vim.fn.sign_define('DiagnosticSignHint', {
    text = '',
    numhl = 'DiagnosticSignHint',
    texthl = "DiagnosticSignHint"
})
