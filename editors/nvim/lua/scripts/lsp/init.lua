local language = require("vim.treesitter.language")
---@class LspInstallOpts
---@field force boolean? Indicates if you want to forcibly install this lsp
---@field version string? If provided, tells the lsp to install this version specifically. If not provided, treat as "latest"

---@class Lsp
---@field name string The name of the lsp
---@field dependencies string[]? A list of lsp/tools that this lsp is dependent on. Note, the name of the lsp/tool _must_ match the name of a registered (or soon to be registered) lsp/tool.
---@field url string? The url to download the lsp from
---@field enable boolean? Should this lsp be enabled? Default is true
---@field required boolean? If provided, should we install this lsp? Default is false. Can be used with enable=false to ensure installation but not enablement of lsp. Useful if your lsp is managed by plugins
---@field pin string? If provided, we will tell the installer to only use this version and prevent update checks
---@field get_binary_path fun(): string A function we can call to retrieve the path to the binary for this LSP
---@field version fun(): string A function to call to get current version of this LSP
---@field latest_version fun(callback: fun(version: string?)) A function to call to get the most recent version of this LSP
---@field config vim.lsp.Config The valid lsp configuration to use for this LSP
---@field needs_install fun(): boolean A function that we can call to check if the LSP needs to be installed
---@field needs_update fun(callback: fun(needs_update: boolean)) A function that we can call to check if an update is available for this LSP
---@field get_venv fun()?: string A function that can be called to get the venv for the editor for this lsp
---@field install fun(success_callback: fun(), error_callback: fun(error: string, exit_code: number), opts: LspInstallOpts?) A function to call to install the LSP

---@class LspDetails
---@field languages string[] The language(s) this lsp works with
---@field last_update_check number The last time (in seconds after epoch) since we last checked
---@field next_update_check number The next time we should perform an update check. Useful if the user told us to shut the fuck up
---@field last_install_check number The last time we asked the user if they want to install this LSP.
---@field next_install_check number The next time we should as the user if they want to install thie LSP. Useful if the user told us to shut the fuck up

vim.lsp.inlay_hint.enable(true)
local EDITOR_DIR = string.format("%s/miversen/lsps", vim.fn.stdpath("data"))
local BACKING_FILE = string.format("%s/lsp_details.json", EDITOR_DIR)
if vim.fn.isdirectory(EDITOR_DIR) ~= 1 then
    vim.fn.mkdir(EDITOR_DIR, 'p')
end

local lsp = {
    -- A list of registered lsps
    ---@type table<string, Lsp>
    lsps = {},
    -- A mapping of each language to their list of Lsps
    ---@type table<string, string[]>
    language_map = {},
    -- A mapping of each lsp to their details
    ---@type table<string, LspDetails>
    lsp_details = {},
    ---@type boolean
    _loaded = false
}

local function load_lsp_details()
    if lsp._loaded then
        return
    end
    if vim.fn.filereadable(BACKING_FILE) == 1 then
        -- We have lsp_details saved
        local raw_content = vim.fn.readfile(BACKING_FILE)
        if #raw_content > 0 then
            local config_as_json = table.concat(raw_content, '\n')
            local ok, result = pcall(vim.fn.json_decode, config_as_json)
            if ok then
                lsp.lsp_details = result
                lsp._loaded = true
            end
        end
    end
end

local function save_lsp_details()
    local ok, config_as_json = pcall(vim.fn.json_encode, lsp.lsp_details)
    if not ok then
        -- probably should complain
        vim.notify("Unable to serialize lsp config to json", vim.log.levels.WARN)
        return
    end

    if vim.fn.isdirectory(EDITOR_DIR) ~= 1 then
        vim.fn.mkdir(EDITOR_DIR, 'p')
    end

    -- Split the JSON string into lines for writefile
    local lines = vim.split(config_as_json, '\n')

    local write_ok = vim.fn.writefile(lines, BACKING_FILE)
    if write_ok ~= 0 then
        vim.notify("Unable to save lsp details to disk!", vim.log.levels.WARN)
        return
    end
    return
end

---@param lsp_name string The name of the lsp to get the dtails for
---@return LspDetails
function lsp.get_details(lsp_name)
    if not lsp.lsp_details[lsp_name] then
        lsp.lsp_details[lsp_name] = {
            last_update_check  = -1,
            next_update_check  = -1,
            last_install_check = -1,
            next_install_check = -1,
            languages          = {},
        }
    end
    return lsp.lsp_details[lsp_name]
end

-- Registers an LSP with a langauge
---@param languages string[]|string The language(s) that this LSP should be associated with
---@param new_lsp Lsp The LSP to manage
function lsp.register(languages, new_lsp)
    if lsp.lsps[new_lsp.name] then
        -- This lsp is already registered, fuck off
        return
    end
    -- logging?
    local lsp_details = lsp.get_details(new_lsp.name)
    if type(languages) == 'string' then
        languages = { languages }
    end
    if not lsp.lsps[new_lsp.name] then
        lsp.lsps[new_lsp.name] = new_lsp
    end

    if not languages or #languages == 0 then
        -- There is nothing to do with this LSP
        return
    end
    for _, in_language in ipairs(languages) do
        if not lsp.language_map[in_language] then
            lsp.language_map[in_language] = {}
        end
        vim.notify(string.format("Registering LSP \"%s\" with language \"%s\"", new_lsp.name, in_language),
            vim.log.levels.DEBUG)
        table.insert(lsp.language_map[in_language], new_lsp.name)
        local matched_language = false
        for _, language in ipairs(lsp_details.languages) do
            if in_language == language then
                matched_language = true
                break
            end
        end
        if not matched_language then
            table.insert(lsp_details.languages, in_language)
        end
    end
    vim.api.nvim_create_autocmd("FileType", {
        pattern = new_lsp.config.filetypes or {},
        callback = function(ev)
            lsp.activate(new_lsp.name)
        end,
        desc = string.format("Auto lsp handler for %s", lsp.name),
        once = true -- There is never a reason to have this fire more than once ever
    })
end

---@param lsp_name string
function lsp.activate(lsp_name)
    local new_lsp = lsp.lsps[lsp_name]
    if not new_lsp then
        vim.notify(string.format("No lsp associated with %s", lsp_name), vim.log.levels.DEBUG)
        return
    end
    local lsp_details = lsp.get_details(lsp_name)
    local function complete()
        vim.schedule(function()
            save_lsp_details()
        end)
    end
    local function activate_lsp()
        vim.schedule(function()
            lsp._activate(new_lsp)
        end)
        complete()
    end

    if (new_lsp.needs_install() and lsp_details.next_install_check > os.time()) then
        -- We have nothing to do, we were told to go away
        complete()
        return
    end

    ---@param _lsp Lsp
    ---@param _lsp_details LspDetails
    ---@param complete_callback fun()
    ---@param activate_callback fun()? If not provided, we will use activate_lsp
    local _needs_install = function(_lsp, _lsp_details, complete_callback, activate_callback)
        _lsp_details.last_install_check = os.time()
        activate_callback = activate_callback or activate_lsp
        local yes_callback = function()
            local error_callback = function(error, _)
                vim.notify(error, vim.log.levels.DEBUG)
                -- In the event that an install fails, lets timeout for 15 minutes
                _lsp_details.next_install_check = os.time() + (15 * 60)
                vim.notify(string.format("Unable to install lsp %s, trying again in 15 minutes", _lsp.name),
                    vim.log.levels.INFO)
                complete_callback()
                return
            end
            lsp._install(_lsp.name, activate_callback, error_callback)
            return
        end
        local no_callback = function()
            _lsp_details.next_install_check = os.time() + (60 * 60)
            complete_callback()
            return
        end
        -- Lets delay this a bit so you aren't hit with it immediately
        vim.defer_fn(function()
            lsp._prompt_user(string.format("%s is not installed, install it? [Y/n]", _lsp.name), yes_callback,
                no_callback)
        end, 1000)
        return
    end
    -- We're running into an issue where the dependencies for an LSP may be being registered later
    -- It might make sense to push all of this logic to activate instead of register
    ---@type Lsp[]
    local missing_deps = {}
    local fail = false
    for _, dep_name in ipairs(new_lsp.dependencies and new_lsp.dependencies or {}) do
        local dep = lsp.lsps[dep_name]
        if not dep then
            -- Complain about missing dependency
            vim.notify(string.format("Unable to locate dependency %s for lsp %s", dep_name, new_lsp.name),
                vim.log.levels.DEBUG)
            fail = true
        else
            if dep.needs_install() then
                table.insert(missing_deps, dep)
            end
        end
    end
    if fail then
        -- We cannot activate this lsp
        vim.notify(string.format("Unable to locate dependencies for %s. Check :Notifications for details", new_lsp.name),
            vim.log.levels.WARN)
        return
    end
    if (new_lsp.needs_install() or #missing_deps > 0) and lsp_details.next_install_check <= os.time() and (new_lsp.enable ~= false or new_lsp.required == true) then
        local missing_dep_count = #missing_deps
        local _complete = function()
            missing_dep_count = missing_dep_count - 1
            if missing_dep_count <= 0 then
                if new_lsp.needs_install() then
                    _needs_install(new_lsp, lsp_details, function() end, activate_lsp)
                else
                    activate_lsp()
                end
            end
        end
        if #missing_deps > 0 then
            vim.notify(string.format("Installing dependencies for %s", new_lsp.name), vim.log.levels.DEBUG)
            -- Lets fine every dep that needs to be installed
            for _, dep in ipairs(missing_deps) do
                local dep_details = lsp.get_details(dep.name)
                _needs_install(dep, dep_details, function() end, _complete)
            end
        else
            _complete()
        end
        return
    end
    activate_lsp()

    -- TODO: Do we add another item for "install" so that we can have an lsp disabled but still require install so other tools can work?
    if (new_lsp.pin and new_lsp.version() ~= new_lsp.pin) and lsp_details.next_update_check <= os.time() and new_lsp.enable ~= false then
        -- Preliminary check passed, lets actually check if an update is available
        lsp_details.last_update_check = os.time()
        local yes_callback = function()
            local error_callback = function(error, _exit_code)
                vim.notify(error, vim.log.levels.DEBUG)
                -- In the event that an install fails, lets timeout for 15 minutes
                lsp_details.next_update_check = os.time() + (15 * 60)
                vim.notify(string.format("Unable to install lsp %s, trying again in 15 minutes", new_lsp.name),
                    vim.log.levels.INFO)
                complete()
                return
            end

            lsp._install(new_lsp.name, activate_lsp, error_callback, true)
            return
        end
        local no_callback = function()
            lsp_details.next_update_check = os.time() + (60 * 60)
            activate_lsp()
            return
        end

        local _complete = function(needs_update)
            if not needs_update then
                -- Nothing to do
                return
            end
            -- Lets delay this a bit so you aren't hit with it immediately
            vim.defer_fn(function()
                lsp._prompt_user(string.format("There is an update available for %s, update it? [Y/n]", new_lsp.name),
                    yes_callback, no_callback)
            end, 1000)
        end
        new_lsp.needs_update(_complete)
    end
end

-- Asks the user if they want to perform an action
---@param message string The message/action to display
---@param yes_callback fun() The function to call if they say "yes"
---@param no_callback fun() The function to call if they say no
function lsp._prompt_user(message, yes_callback, no_callback)
    vim.ui.input({
        prompt = message,
        default = "Y",
    }, function(response)
        if not response then
            no_callback()
            return
        end
        -- Convert to lowercase and trim whitespace
        local normalized = vim.trim(response:lower())

        -- Check for "yes" responses
        if normalized == "y" or normalized == "yes" then
            yes_callback()
        else
            -- Everything else is treated as "no"
            no_callback()
        end
    end)
end

-- Performs in place substitutions of known variables in place of strings. Valid Substitution Strings are
-- - $LSP_BIN = This will be replaced with the path to the binary of the lsp as declared by lsp.get_binary_path
---@param intable table<string, any> A map that contains items we need to process
---@param replacement_map table<string, string> A map that contains known variables and their replacement values
---@param builder table<string, any>? The map we are building
---@return table<string, any> Our built substitution table
local function substitute_vars(intable, replacement_map, builder)
    assert(replacement_map, "no replacement_map provided")
    builder = builder or {}
    local iter_func = nil
    if #intable ~= 0 then
        -- This is a list and we need to process it as such
        iter_func = ipairs
    else
        iter_func = pairs
    end
    for key, item in iter_func(intable) do
        if type(item) == "table" then
            builder[key] = substitute_vars(item, replacement_map)
        elseif type(item) == "string" then
            local replaced = false
            for rep_key, rep_item in pairs(replacement_map) do
                if item:match(rep_key) then
                    local rep = item:gsub(rep_key, rep_item)
                    builder[key] = rep
                    replaced = true
                end
            end
            if not replaced then
                builder[key] = item
            end
        else
            builder[key] = item
        end
    end
    return builder
end

-- Activates and potentially enables a new lsp configuration
---@param target_lsp Lsp The lsp to enable
function lsp._activate(target_lsp)
    if vim.lsp.config[target_lsp.name] then
        vim.notify(
            string.format("A configuration for lsp \"%s\" already exists and opts.override is false. Ignoring",
                target_lsp.name),
            vim.log.levels.DEBUG, {})
        return
    end
    local replacement_map = {
        ["$LSP_BIN"] = target_lsp.get_binary_path(),
        ["$VENV_PATH"] = target_lsp.get_venv and target_lsp.get_venv() or "NO VENV"
    }
    vim.lsp.config[target_lsp.name] = substitute_vars(target_lsp.config, replacement_map)
    if target_lsp.enable ~= false then
        vim.lsp.enable(target_lsp.name)
    end
end

-- Tells the lsp to install itself
---@param lsp_name string The name of the lsp to install
---@param success_callback fun(): nil A function to call after successful installation
---@param error_callback fun(error: string, exit_code: number): nil A function to call after failed installation
---@param is_update boolean? If provided, we will update the lsp's update check times instead of the install check times
function lsp._install(lsp_name, success_callback, error_callback, is_update)
    success_callback = success_callback or function() end
    error_callback = error_callback or function(_, _) end
    local op_lsp = lsp.lsps[lsp_name]
    if not op_lsp then
        error_callback(string.format("Unable to locate lsp \"%s\"", lsp_name), -1)
        return
    end
    local lsp_details = lsp.lsp_details[op_lsp.name]
    lsp_details.last_update_check = os.time()
    ---@param version string?
    local complete = function(version)
        if op_lsp.pin and op_lsp.bin == version then
            -- Nothing to do
            success_callback()
            return
        end
        if is_update then
            lsp_details.last_update_check = os.time()
        else
            lsp_details.last_install_check = os.time()
        end
        if not version then
            -- Nothing to do
            error_callback(string.format("%s was not able to provide most recent version to install", lsp_name))
            return
        end
        vim.schedule(function()
            op_lsp.install(success_callback, error_callback, { force = true, version = version })
        end)
    end
    if op_lsp.pin then
        complete(op_lsp.pin)
    else
        op_lsp.latest_version(complete)
    end
end

-- Updates either a specific tool (lsp or otherwise) for a language,
-- all tools related to a specified language, or all tools in general
---@param item string? The name of a specific tool (lsp or otherwise), a langauge, or nil
function lsp.update(item)
    local success_callback = function(_sub_item)
        vim.schedule(function()
            vim.lsp.enable(_sub_item, false)
            vim.notify(string.format("Successfully updated %s", _sub_item), vim.log.levels.INFO, {})
            vim.lsp.enable(_sub_item, true)
        end)
        return
    end

    local error_callback = function(_sub_item, error, exit_code)
        vim.notify(string.format("Unable to update %s. See :Notifications for details", _sub_item), vim.log.levels.WARN,
            {})
        vim.notify(string.format("Encountered error while trying to update %s: %s", _sub_item, error),
            vim.log.levels.DEBUG, {})
        return
    end
    local function do_update(_item)
        vim.notify(string.format("Received request to update lsp \"%s\"", _item), vim.log.levels.INFO, {})
        lsp._install(_item, function() success_callback(_item) end, function(_, __) error_callback(_item, _, __) end,
            true)
        return
    end
    if not item then
        -- Do stuff for all langages
        vim.notify("Updating all LSPs", vim.log.levels.INFO, {})
        for lsp_name, _ in pairs(lsp.lsps) do
            do_update(lsp_name)
        end
        return
    else
        local mapped_language = lsp.language_map[item]
        if lsp.lsps[item] ~= nil then
            vim.notify(string.format("Found lsp associated with %s", item), vim.log.levels.DEBUG)
            do_update(item)
        elseif mapped_language and #mapped_language > 0 then
            vim.notify(string.format("%s is a language, getting all lsps associated with it", item), vim.log.levels
                .DEBUG)
            for _, lsp_name in ipairs(mapped_language) do
                do_update(lsp_name)
            end
        else
            vim.notify(string.format("Unable to locate an lsp associated with %s", item), vim.log.levels.WARN, {})
            return
        end
    end
end

local function setup_commands()
    vim.api.nvim_create_user_command(
        "LspUpdate",
        ---@param lsp_update_args vim.api.keyset.create_user_command.command_args
        function(lsp_update_args)
            -- Lets first see if all is in here
            local update_all = false
            for _, item in ipairs(lsp_update_args.fargs) do
                if item:lower() == 'all' then
                    update_all = true
                    break
                end
            end
            if update_all and #lsp_update_args.fargs > 1 then
                -- Complain and only do an all update
                vim.notify(
                    "Request to update all LSPs and some LSPS. That's naughty, don't do that. Updating all LSPs and ignoring whatever other shit you gave me",
                    vim.log.levels.WARN, {})
                lsp.update()
                return
            end
            for _, argument in ipairs(lsp_update_args.fargs) do
                lsp.update(argument)
            end
        end,
        {
            nargs = "*",
            complete = function()
                local opts = {}
                for language_name, lsps in pairs(lsp.language_map) do
                    table.insert(opts, language_name)
                    for _, lsp_name in ipairs(lsps) do
                        table.insert(opts, lsp_name)
                    end
                end
                table.sort(opts, function(a, b) return a:lower() < b:lower() end)
                return opts
            end
        }
    )
end

load_lsp_details()
save_lsp_details()
setup_commands()
return lsp
