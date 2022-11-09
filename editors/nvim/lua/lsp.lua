if not import then
    error("Unable to find import global function! Please install it via https://github.com/miversen33/import.nvim")
end
local status, lsp_settings = pcall(require, 'ls_settings')
if not status or lsp_settings == true or lsp_settings == false then
    print("Unable to find lsp settings")
    return
end

local lsp_handlers = {
    ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded'}),
    ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = 'rounded'})
}

local lsp_on_attach = function(client, bufnr)
    -- import('illuminate', function(illuminate)
    --     illuminate.on_attach(client)
    -- end)
    -- import('aerial', function(aerial)
    --     aerial.on_attach(client, bufnr)
    -- end)
end

local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true
-- lsp_capabilities.textDocument.foldingRange = {dynamicRegistration = false, lineFoldingOnly = true}
-- import('cmp_nvim_lsp', function(cmp_nvim_lsp)
--     capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
-- end)

-- Consider making your own lsp configuration?
import('lspconfig', function(lspconfig)
    local language_servers = lsp_settings.get_lsp_settings()
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
    text='',
    numhl='DiagnosticSignError',
    texthl="DiagnosticSignError",
})
vim.fn.sign_define('DiagnosticSignWarn', {
    text='⚠',
    numhl='DiagnosticSignWarn',
    texthl="DiagnosticSignWarn"
})
vim.fn.sign_define('DiagnosticSignInformation', {
    text='',
    numhl='DiagnosticSignInformation',
    texthl="DiagnosticSignInformation"
})
vim.fn.sign_define('DiagnosticSignHint', {
    text='',
    numhl='DiagnosticSignHint',
    texthl="DiagnosticSignHint"
})
