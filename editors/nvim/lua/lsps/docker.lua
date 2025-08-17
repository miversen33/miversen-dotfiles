-- lsps/docker.lua

---@class DockerLspVersion
---@field release_date string The date of this release
---@field semantic string The semantic version of the release (sans 'v')

local uv = vim.uv or vim.loop
local jit = require("jit")
local shell = require("scripts.shell")

local os_map = {
    Linux = 'linux',
    OSX = 'darwin',
    Windows = 'windows'
}

local arch_map = {
    x64 = "amd64"
}

---@type Lsp
local docker = {
    url =
    "https://github.com/docker/docker-language-server/releases/download/v${VERSION}/docker-language-server-${OS}-${ARCH}-${VERSION}",
    name = "docker",
    _latest_version = nil,
    _current_version = nil,
    config = {
        -- We actually want this to only fire up on docker-compose.yml/docker-compose.yaml files
        filetypes = { "dockerfile", "yaml" },
        cmd = { "$LSP_BIN", "start", "--stdio" },
        root_dir = function(buffer, on_dir)
            local filename = vim.api.nvim_buf_get_name(buffer)
            if not filename or (
                    not filename:match('docker%-compose%.y[a]?ml$')
                    and not filename:match('[dD]ockerfile'))
            then
                return
            end
            on_dir(vim.fn.getcwd())
        end
    },
}

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function docker.get_binary_path(ignore)
    local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
    local editor_lsp = string.format("%s/lsps/docker/docker", editor_dir)
    if ignore or vim.fn.filereadable(editor_lsp) == 1 then
        return editor_lsp
    else
        return "MISSING BINARY"
    end
end

---@return boolean A true/false on if docker_lsp is installed
function docker.needs_install()
    return vim.fn.filereadable(docker.get_binary_path()) ~= 1
end

-- Gets the version of the currently installed docker language server
-- Note: Will return "-1" if it cannot find the lsp
---@return string
function docker.version()
    if not docker.needs_install() then
        docker._current_version = nil
        return "-1"
    end
    if docker._current_version then
        return docker._current_version
    end
    local editor_lsp = docker.get_binary_path()
    local docker_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not docker_current_version or #docker_current_version < 1 then
        docker._current_version = nil
        return "-1"
    end
    docker_current_version = docker_current_version[1]:gsub("^docker-language-server version ", "")
    if not docker_current_version then
        docker._current_version = nil
        return "-1"
    end
    -- Strip the commit hash
    docker_current_version = docker_current_version:gsub("-[%d%a]+$", "")
    if not docker_current_version then
        docker._current_version = nil
        return "-1"
    else
        docker._current_version = docker_current_version
        return docker_current_version
    end
end

-- For some fuckass reason, the docker language server doesn't
-- use semantic versioning, and even more stupid, the binary
-- doesn't return its actual version, just the date of its release
-- and its fucking commit hash. Because of course, why wouldn't they?
---@param callback fun(version: DockerLspVersion?)
local function get_docker_latest_version(callback)
    if docker._latest_version then
        callback(docker._latest_version)
        return
    end
    local docker_api = "https://api.github.com/repos/docker/docker-language-server/releases/latest"

    ---@param result Shell.Serial
    local complete = function(result)
        if not result or result.exit_code ~= 0 then
            docker._latest_version = nil
            callback()
            return
        end
        local output = vim.json.decode(result.stdout)
        if not output or not next(output) then
            docker._latest_version = nil
            callback()
        end
        local version = output.name
        if not version then
            docker._latest_version = nil
            callback()
        end
        local _date = ""
        _, _, version, _date = version:find('^v([%d.]+)%s*-%s*([%d-]+)')
        if not version or not _date then
            docker._latest_version = nil
            callback()
        else
            docker._latest_version = {
                release_date = _date,
                semantic = version
            }
            callback(docker._latest_version)
        end
    end

    local handle = shell:new(
        { "curl", "-fsSL", docker_api },
        {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "",
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete
        }
    ):run()
    if not handle then
        callback()
        return
    end
end

---@param callback fun(version: string?)
function docker.latest_version(callback)
    ---@param version DockerLspVersion?
    local complete = function(version)
        if not version then
            callback()
        else
            callback(version.semantic)
        end
    end
    get_docker_latest_version(complete)
end

-- Checks if we need an update
---@param callback fun(needs_update: boolean?)
function docker.needs_update(callback)
    local current_version = docker.version()
    ---@param latest_version DockerLspVersion?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
            return
        end
        callback(latest_version.release_date > current_version)
    end
    get_docker_latest_version(complete)
end

-- Installs docker language server
---@param success_callback fun() The function to call when install completes successfully
---@param error_callback fun(error: string, exit_code: number) The function to call when install fails
---@param opts LspInstallOpts? Options to use when installing
function docker.install(success_callback, error_callback, opts)
    opts = opts or {}
    local force = opts.force or false

    local editor_lsp = docker.get_binary_path(true)
    local editor_lsp_dir = vim.fs.dirname(editor_lsp)

    if vim.fn.filereadable(editor_lsp_dir) == 1 and not force then
        success_callback()
        return
    end

    vim.fs.rm(editor_lsp, { recursive = true, force = true })

    vim.fs.mkdir(editor_lsp_dir, 'p')
    local url = string.gsub(docker.url, "${OS}", os_map[jit.os]):gsub("${ARCH}", arch_map[jit.arch])
    if jit.os == 'Windows' then
        url = string.format("%s.exe", url)
    end
    if not url then
        error_callback("Unable to determine matching \"os\" or \"architecture\" for lsp url", -1)
        return
    end

    ---@param result Shell.Serial?
    local complete = function(result)
        if not result or result.exit_code ~= 0 then
            error_callback(result and result.stderr or "Unknown error occured while trying to download docker lsp",
                result and result.exit_code or -1)
            return
        end
        vim.fs.chmod(editor_lsp, "rwxr-xr-x")
        success_callback()
    end

    ---@param version string?
    local handle_version = function(version)
        if not version then
            error_callback("No version found for install of docker lsp", -1)
            return
        end
        url = url:gsub("${VERSION}", version)
        if not url then
            error_callback(string.format("Invalid version \"%s\" provided", version), -1)
            return
        end
        vim.notify(string.format("Downloading docker language server: %s", url), vim.log.levels.DEBUG)
        local handle = shell:new({ "curl", "-fsSL", url, "-o", editor_lsp }, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
            [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "",
            [shell.CONSTANTS.FLAGS.STDERR_JOIN] = ""
        }):run()
        if not handle then
            error_callback("Unable to download docker lsp", -1)
            return
        end
    end
    if opts.version then
        handle_version(opts.version)
    else
        get_docker_latest_version(function(version)
            if not version then
                error_callback("No docker language server version found to download", -1)
                return
            end
            handle_version(version.semantic)
        end)
    end
end

return {
    docker
}
