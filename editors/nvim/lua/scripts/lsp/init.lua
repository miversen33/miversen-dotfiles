local lsp = {}

---@class LspOpts
---@field enable bool Should we enable the lsp (Default: true)
---@field override bool Should we override an existing lsp definition?

-- Activates and potentially enables a new lsp configuration
---@param lsp_name string The name of the the lsp
---@param lsp_config vim.lsp.Config The configuration to apply to the lsp
---@param opts LspOpts? Any additional options that you wish to provide for us
function lsp.activate(lsp_name, lsp_config, opts)
    opts = opts or { jenable = true }
    vim.notify(string.format("Activating lsp \"%s\"", lsp_name), vim.log.levels.DEBUG, {})
    if vim.lsp.config[lsp_name] and not opts.override then
        vim.notify(string.format("A configuration for lsp \"%s\" already exists and opts.override is false. Ignoring", lsp_name), vim.log.levels.DEBUG, {})
        return
    end
    vim.lsp.config[lsp_name] = lsp_config
    if lsp_config.enable ~= false and opts.enable ~= false then
        vim.notify(string.format("Enabling lsp \"%s\"", lsp_name), vim.log.levels.INFO, {})
        vim.lsp.enable(lsp_name)
    end
end

-- Register a function for us to call when we are prompted to update
-- your language tools.
---@param language_name string The name of the language you are going to handle
---@param update_function fun(tool_name: string?): bool The function for us to call when we need to update a language. Return a boolean telling us the update worked (true) or the update failed (false). Handle your own logging
function lsp._register_language_updater(language_name, update_function)

end

-- Register a function for us to call when we want to check for
-- your language tools
---@param language_name string The name of the language you are going to handle
---@param update_checker_function fun(tool_name: string?): bool The function for us to call to check for updates. Return boolean telling us we need to update (true) or we don't need to update (false)
function lsp._register_language_update_checker(language_name, update_checker_function)

end

function lsp._update_tool(lsp_name)

end

function lsp._update_all_language_tools(language)

end

-- Updates either a specific tool (lsp or otherwise) for a language,
-- all tools related to a specified language, or all tools in general
---@param item string? The name of a specific tool (lsp or otherwise), a langauge, or nil
function lsp.update(item)
    if not item then
        -- Do stuff for all langages
    end
end

return lsp
