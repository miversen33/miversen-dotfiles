-- lsps/sh.lua

---@class BashLsp
---@field configrued boolean Is bash configured yet?
---@field lsps table<string, Lsp> Lsps associated with bash

---@type BashLsp
local bash = {}

local shell = require("scripts.shell")

local M = {}

local SHELLCHECK_URL =
"https://github.com/koalaman/shellcheck/releases/download/v${VERSION}/shellcheck-v${VERSION}.${OS}.${ARCH}.tar.xz"
-- For some reason they have an entirely different url for windows
local SHELLCHECK_WINDOWS_URL =
"https://github.com/koalaman/shellcheck/releases/download/v${VERSION}/shellcheck-v${VERSION}.zip"

local SHELLFMT_URL = "https://github.com/mvdan/sh/releases/download/v${VERSION}/shfmt_v${VERSION}_${OS}_amd64"
-- Fun fact, we are going to have to build this bitch manually
local BASH_LSP_URL = "https://github.com/bash-lsp/bash-language-server/archive/refs/tags/server-${VERSION}.tar.gz"
local jit = require("jit")
local uv = vim.uv or vim.loop

local os_map = {
    Linux = 'linux',
    OSX = 'darwin',
    Windows = 'win32'
}

local BASH_LSP_DOCKERFILE = [[
FROM node:24-bookworm

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN \
    apt update  -y &&\
    apt upgrade -y &&\
    apt install -y \
        curl \
        tar \
        gzip \
        zip \
        wget

RUN \
    if ! getent group ${GROUP_ID} >/dev/null 2>&1; then \
        groupadd -g ${GROUP_ID} nvimuser; \
    fi &&\
    if ! getent passwd ${USER_ID} >/dev/null 2>&1; then \
        useradd -u ${USER_ID} -g ${GROUP_ID} -m nvimuser; \
    fi

USER ${USER_ID}:${GROUP_ID}

RUN \
    wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -

USER root
RUN echo "export PATH=$(getent passwd ${USER_ID} | cut -d: -f6)/.local/share/pnpm:\$PATH" >> /etc/profile

USER ${USER_ID}:${GROUP_ID}

WORKDIR /app

ENTRYPOINT [ "/bin/bash", "-l" ]
]]

---@diagnostic disable-next-line: missing-fields
---@type Lsp
local shellcheck = {
    name = "shellcheck",
    config = {},
    required = true,
    enable = false,
    _current_version = nil,
    _latest_version = nil
}

---@diagnostic disable-next-line: missing-fields
---@type Lsp
local shellfmt = {
    name = "shellfmt",
    config = {},
    required = true,
    enable = false,
    _current_version = nil,
    _latest_version = nil
}

---@diagnostic disable-next-line: missing-fields
---@type Lsp
local bashls = {
    name = "bashls",
    dependencies = { "shellcheck", "shellfmt" },
    _current_version = nil,
    _latest_version = nil
}

local function _get_editor_language_dir()
    return string.format("%s/miversen/lsps/bash", vim.fn.stdpath("data"))
end

-- Creates a docker container and builds the bash lsp server in that container. It then removes the container after finishing
---@param success_callback fun() The function to call after successfully building the bash lsp server
---@param error_callback fun(error: string, exit_code: number?) The function to call if there is an error that prevents us from success
---@param install_opts LspInstallOpts? Any options we need to use to install
function bashls.install(success_callback, error_callback, install_opts)
    install_opts = install_opts or { force = false }
    local node_compile_image = "miversen-nvim-pnpm-compiler"
    local node_compile_image_version = "0.0.1"
    local target_path = _get_editor_language_dir()
    if vim.fn.isdirectory(target_path) ~= 1 then
        vim.fs.mkdir(target_path, 'p')
    end
    local temp_dir = string.format("%s/neovim_miversen_lsp_download-bashls-%s", uv.os_tmpdir(),
        os.date("%Y%m%d%H%M%S"))

    local cleanup = function()
        vim.fs.rm(temp_dir, { force = true, recursive = true })
    end

    ---@param version string The version of bashls to compile
    local function build_lsp(version)
        vim.notify("Building bashls", vim.log.levels.DEBUG)
        local dir = string.format("%s/bash-language-server-server-%s", temp_dir, version)
        local cmd = { "docker", "run", "--rm", "-v", string.format("%s:/app", dir),
            string
                .format("%s:%s",
                    node_compile_image, node_compile_image_version), "-c",
            "pnpm install && pnpm compile" }
        ---@param result shell.Serial
        local complete = function(result)
            if result.exit_code ~= 0 then
                cleanup()
                error_callback(result.stderr, result.exit_code)
                return
            end
            local compiled_bash_server = string.format("%s/vscode-client/node_modules/bash-language-server/out/cli.js",
                dir)
            if vim.fn.filereadable(compiled_bash_server) == 0 then
                cleanup()
                error_callback("Compiled bash language server not found!", -1)
                return
            end
            vim.fs.mv(dir, string.format("%s/bash-language-server", target_path))
            cleanup()
            vim.notify("Bash Language Server Build Complete", vim.log.levels.DEBUG)
            success_callback()
        end
        local handle = shell:new(cmd, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
            [shell.CONSTANTS.FLAGS.STDERR_JOIN] = "",
        }):run()
        if not handle then
            cleanup()
            error_callback("Unable to build bash language server", -1)
        end
    end

    ---@param version string The version of bashls to download
    local function download_lsp_source(version)
        local url = string.gsub(BASH_LSP_URL, '${VERSION}', version)

        vim.fs.mkdir(temp_dir, 'p')

        local output_file = string.format("%s/bashls.tar.gz", temp_dir)
        vim.notify("Downloading bashls", vim.log.levels.DEBUG, {})

        ---@param result Shell.Serial
        local extract_complete = function(result)
            if result.exit_code ~= 0 then
                error_callback("Unable to extract bash language server", result.exit_code)
                return
            end
            local dir = string.format("%s/bash-language-server-server-%s", temp_dir, version)
            if vim.fn.isdirectory(dir) == 0 then
                cleanup()
                error_callback("Unable to locate extracted bash language server", -1)
                return
            end
            build_lsp(version)
        end

        ---@param result Shell.Serial
        local download_complete = function(result)
            if result.exit_code ~= 0 then
                cleanup()
                error_callback("Unable to download most recent version of bash language server", result.exit_code)
                return
            end
            if vim.fn.filereadable(output_file) == 0 then
                -- Complain
                cleanup()
                error_callback("bash langauge server didn't download????")
                return
            end
            local cmd = { "tar", "-C", temp_dir, "-xzf", output_file }
            local handle = shell:new(cmd, {
                [shell.CONSTANTS.FLAGS.ASYNC] = true,
                [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = extract_complete
            }):run()
            if not handle then
                -- TODO: We should clean up first?
                cleanup()
                error_callback("Unable to begin extraction of bash language server?", -1)
                return
            end
        end

        local cmd = { "curl", "-fsS", "-L", url, "-o", output_file }
        local handle = shell:new(cmd, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = download_complete
        }):run()

        if not handle then
            cleanup()
            error_callback("Unable to start download bash language server source", -1)
            return
        end
    end

    ---@param version string The version of bashls to build
    local function build_image(version)
        ---@type string[]
        local cmd = { "docker", "image", "ls", "--all", "--format", "json", string.format("%s:%s", node_compile_image,
            node_compile_image_version) }
        local _build_image = function()
            -- The version of the image we have is bunk, we need to create a new version of it
            cmd = {
                "docker",
                "build",
                "--tag", string.format("%s:%s", node_compile_image, node_compile_image_version),
                "--build-arg", string.format("USER_ID=%d", uv.getuid()),
                "--build-arg", string.format("GROUP_ID=%d", uv.getgid()),
                "-" }
            ---@param result Shell.Serial
            local _complete = function(result)
                if result.exit_code ~= 0 then
                    -- We failed to build the image
                    error_callback(result.stderr, result.exit_code)
                    cleanup()
                    return
                end
                -- It worked, onto downloading the source
                download_lsp_source(version)
            end
            local _handle = shell:new(cmd, {
                [shell.CONSTANTS.FLAGS.ASYNC] = true,
                [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = _complete,
                [shell.CONSTANTS.FLAGS.STDERR_JOIN] = "",
            }):run()
            if not _handle then
                -- Failed to start build
                cleanup()
                error_callback(string.format("Unable to start build of docker image %s:%s", node_compile_image,
                    node_compile_image_version))
                return
            end
            _handle.write(BASH_LSP_DOCKERFILE)
            _handle.close()
        end
        ---@param result Shell.Serial
        local complete = function(result)
            if result.exit_code ~= 0 then
                cleanup()
                -- Something bad happened
                error_callback(result.stderr, result.exit_code)
                return
            end
            if #result.stdout == 0 then
                -- It worked but we didn't get anything back, the image doesn't exist
                _build_image(version)
                return
            end
            local output = vim.json.decode(result.stdout)
            -- lets check the version and
            local tag = output.Tag
            if tag ~= node_compile_image_version then
                _build_image()
            else
                download_lsp_source(version)
            end
        end
        local handle = shell:new(cmd, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
            [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = ""
        }):run()
        if not handle then
            cleanup()
            error_callback(string.format("Unable to check if docker image %s exists", node_compile_image), -1)
            return
        end
    end
    if not install_opts.version then
        bashls.latest_version(build_image)
    else
        build_image(install_opts.version)
    end
end

---@return boolean
function bashls.needs_install()
    return bashls.get_binary_path() == "MISSING BINARY"
end

---@return boolean
function shellcheck.needs_install()
    return shellcheck.get_binary_path() == "MISSING BINARY"
end

---@return boolean
function shellfmt.needs_install()
    return shellfmt.get_binary_path() == "MISSING BINARY"
end

---@param ignore boolean? Do we ignore if the path doesn't exist?
function bashls.get_binary_path(ignore)
    local binary_path = string.format("%s/bash-language-server/vscode-client/node_modules/.bin/bash-language-server",
        _get_editor_language_dir())
    if not ignore and vim.fn.filereadable(binary_path) == 0 then
        return "MISSING BINARY"
    end
    return binary_path
end

---@param ignore boolean? Do we ignore if the path doesn't exist?
function shellcheck.get_binary_path(ignore)
    local binary_path = string.format("%s/shellcheck/shellcheck", _get_editor_language_dir())
    if not ignore and vim.fn.filereadable(binary_path) == 0 then
        return "MISSING BINARY"
    end
    return binary_path
end

---@param ignore boolean? Do we ignore if the path doesn't exist?
function shellfmt.get_binary_path(ignore)
    local binary_path = string.format("%s/shellfmt/shellfmt", _get_editor_language_dir())
    if not ignore and vim.fn.filereadable(binary_path) == 0 then
        return "MISSING BINARY"
    end
    return binary_path
end

---@param yes_callback fun() A callback we call if we can indeed run
local function can_we_run(yes_callback)
    if bashls.get_binary_path() ~= "MISSING BINARY" then
        -- Doesn't matter if we can build it or not if it already exists
        yes_callback()
    end
    -- Best plan of attack here I think is to check if docker is available,
    -- if it is, create the binary in a container and then copy it to where we need it
    -- Otherwise complain that you can't find docker and die
    if vim.fn.executable("docker") == 0 then
        vim.notify("Unable to locate docker, cannot build bash language server", vim.log.levels.DEBUG, {})
        return
    end
    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 then
            vim.notify("Unable to run docker, cannot build bash language server", vim.log.levels.DEBUG, {})
            return
        end
        yes_callback()
    end
    -- Lets try running docker quick and seeing if it complains
    local cmd = { "docker", "ps" }
    local handle = shell:new(cmd, {
        [shell.CONSTANTS.FLAGS.ASYNC] = true,
        [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete
    }):run()
    if not handle then
        -- Complain that we can't run our command????
        vim.notify("Unable to check if docker exists", vim.log.levels.DEBUG, {})
        return
    end
end

---@return string Returns the version or -1
function bashls.version()
    if bashls._current_version then
        return bashls._current_version
    end
    local binary_path = bashls.get_binary_path()
    if binary_path == "MISSING BINARY" then
        bashls._current_version = nil
        return "-1"
    end
    local cmd = { binary_path, "--version" }
    ---@type Shell.Serial
    local result = shell:new(cmd, { [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "" }):run()
    if result.exit_code ~= 0 then
        bashls._current_version = nil
        vim.notify("Unable to get version of bashls", vim.log.levels.DEBUG)
        return "-1"
    end
    bashls._current = result.stdout
    return result.stdout
end

---@return string Returns the version or -1
function shellfmt.version()
    if shellfmt._current_version then
        return shellfmt._current_version
    end
    local binary_path = shellfmt.get_binary_path()
    if binary_path == "MISSING BINARY" then
        shellfmt._current_version = nil
        return "-1"
    end
    local cmd = { binary_path, "--version" }
    ---@type Shell.Serial
    local result = shell:new(cmd, { [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "" }):run()
    if result.exit_code ~= 0 then
        shellfmt._current_version = nil
        vim.notify("Unable to get version of bashls", vim.log.levels.DEBUG)
        return "-1"
    end
    local version = result.stdout and result.stdout:gsub("^v", "") or "-1"
    shellfmt._current = version
    return version
end

---@return string Returns the version or -1
function shellcheck.version()
    if shellcheck._current_version then
        return shellcheck._current_version
    end
    local binary_path = shellcheck.get_binary_path()
    if binary_path == "MISSING BINARY" then
        shellcheck._current_version = nil
        return "-1"
    end
    local cmd = { binary_path, "--version" }
    ---@type Shell.Serial
    local result = shell:new(cmd):run()
    if result.exit_code ~= 0 then
        shellcheck._current_version = nil
        vim.notify("Unable to get version of bashls", vim.log.levels.DEBUG)
        return "-1"
    end
    local version = "-1"
    for _, line in ipairs(result.stdout) do
        if line:match("^version:") then
            version = line:gsub("^version: ", "")
            break
        end
    end
    shellcheck._current = version
    return version
end

---@return string Returns the version or -1
function bashls.version()
    if bashls._current_version then
        return bashls._current_version
    end
    local binary_path = bashls.get_binary_path()
    if binary_path == "MISSING BINARY" then
        bashls._current_version = nil
        return "-1"
    end
    local cmd = { binary_path, "--version" }
    ---@type Shell.Serial
    local result = shell:new(cmd, { [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "" }):run()
    if result.exit_code ~= 0 then
        bashls._current_version = nil
        vim.notify("Unable to get version of bashls", vim.log.levels.DEBUG)
        return "-1"
    end
    bashls._current = result.stdout
    return result.stdout
end

---@param callback fun(version: string?) If provided, we will provide the latest version (or nothing if we can't find it)
function shellcheck.latest_version(callback)
    if shellcheck._latest_version then
        callback(shellcheck._latest_version)
        return
    end
    local shellcheck_api = "https://api.github.com/repos/koalaman/shellcheck/releases/latest"

    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 or result.stdout:len() == 0 then
            shellcheck._latest_version = nil
            callback()
            return
        end
        local output = vim.json.decode(result.stdout)
        local version = output.tag_name
        if not version then
            shellcheck._latest_version = nil
            callback()
            return
        end
        version = version:gsub('^v', '')
        callback(version)
    end

    local handle = shell:new({ "curl", "-fsSL", shellcheck_api }, {
        [shell.CONSTANTS.FLAGS.ASYNC] = true,
        [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
        [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = ""
    }):run()
    if not handle then
        callback()
    end
end

---@param callback fun(version: string?) If provided, we will provide the latest version (or nothing if we can't find it)
function shellfmt.latest_version(callback)
    if shellfmt._latest_version then
        callback(shellfmt._latest_version)
        return
    end
    local shellfmt_api = "https://api.github.com/repos/mvdan/sh/releases/latest"

    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 or result.stdout:len() == 0 then
            shellfmt._latest_version = nil
            callback()
            return
        end
        local output = vim.json.decode(result.stdout)
        local version = output.tag_name
        if not version then
            shellfmt._latest_version = nil
            callback()
            return
        end
        version = version:gsub('^v', '')
        callback(version)
    end

    local handle = shell:new({ "curl", "-fsSL", shellfmt_api }, {
        [shell.CONSTANTS.FLAGS.ASYNC] = true,
        [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
        [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = ""
    }):run()
    if not handle then
        callback()
    end
end

---@param callback fun(version: string?) If provided, we will provide the latest version (or nothing if we can't find it)
function bashls.latest_version(callback)
    if bashls._latest_version then
        callback(bashls._latest_version)
        return
    end
    local bashls_api = "https://api.github.com/repos/bash-lsp/bash-language-server/releases/latest"

    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 or result.stdout:len() == 0 then
            bashls._latest_version = nil
            callback()
            return
        end
        local output = vim.json.decode(result.stdout)
        local version = output.tag_name
        if not version then
            bashls._latest_version = nil
            callback()
            return
        end
        version = version:gsub('^server%-', '')
        callback(version)
        return
    end

    local handle = shell:new({ "curl", "-fsSL", bashls_api }, {
        [shell.CONSTANTS.FLAGS.ASYNC] = true,
        [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
        [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = ""
    }):run()
    if not handle then
        callback()
    end
end

---@param callback fun(needs_update: boolean?) The function for us to call after determining if we need an update
function shellcheck.needs_update(callback, error)
    local current_version = shellcheck.version()
    ---@param version string?
    local complete = function(version)
        callback(version > current_version)
    end
    shellcheck.latest_version(complete)
end

---@param callback fun(needs_update: boolean?) The function for us to call after determining if we need an update
function bashls.needs_update(callback, error)
    local current_version = bashls.version()
    ---@param version string?
    local complete = function(version)
        callback(version > current_version)
    end
    bashls.latest_version(complete)
end

---@param callback fun(needs_update: boolean?) The function for us to call after determining if we need an update
function shellfmt.needs_update(callback, error)
    local current_version = shellfmt.version()
    ---@param version string?
    local complete = function(version)
        callback(version > current_version)
    end
    shellfmt.latest_version(complete)
end

-- Installs shellcheck
---@param success_callback fun() The function to call on successful installation
---@param error_callback fun(error_message: string, exit_code: number?) The function to call on a failure
---@param install_opts LspInstallOpts? Any options to provide during installation
function shellcheck.install(success_callback, error_callback, install_opts)
    install_opts = install_opts or { force = false }

    local temp_dir = string.format("%s/neovim_miversen_lsp_download-shellcheck-%s", uv.os_tmpdir(),
        os.date("%Y%m%d%H%M%S"))

    local cleanup = function()
        vim.fs.rm(temp_dir, { force = true, recursive = true })
    end

    local target_path = shellcheck.get_binary_path(true)
    local parent_dir
    for parent in vim.fs.parents(target_path) do
        parent_dir = parent
        break
    end

    if vim.fn.isdirectory(parent_dir) ~= 1 then
        vim.fs.mkdir(parent_dir, 'p')
    end

    if vim.fn.isdirectory(temp_dir) == 1 then
        cleanup()
    end

    vim.fs.mkdir(temp_dir, 'p')

    local url = jit.os == "Windows" and SHELLCHECK_WINDOWS_URL or SHELLCHECK_URL
    url = url:gsub('${ARCH}', 'x86_64')
    if jit.os ~= "Windows" then
        url = url:gsub("${OS}", os_map[jit.os])
    end

    local output_file = string.format("%s/shellcheck.%s", temp_dir, jit.os ~= "Windows" and "xz" or "zip")
    ---@param result Shell.Serial
    local complete = function(result)
        -- Dunno how we unzip on windows?
        if result.exit_code ~= 0 then
            error_callback(result.stderr, result.exit_code)
            return
        end
        local result = shell:new({ "tar", "-C", temp_dir, "-xf", output_file }):run()
        if not result or result.exit_code ~= 0 then
            cleanup()
            error_callback("Unable to extract shellcheck", result.exit_code and result.exit_code or -1)
        end

        ---@type string?
        local extract_dir = nil
        ---@param item string
        for item in vim.fs.dir(temp_dir, { depth = 1 }) do
            if item:match("^shellcheck%-v") then
                -- We found the directory
                extract_dir = item
                break
            end
        end
        if not extract_dir then
            cleanup()
            error_callback("Unable to locate extracted shellcheck binary", -1)
            return
        end
        vim.fs.mv(string.format("%s/%s/shellcheck", temp_dir, extract_dir), target_path)
        cleanup()
        success_callback()
    end

    ---@param version string?
    local handle_version = function(version)
        if not version then
            error_callback("Unable to locate verion of shellcheck to install", -1)
            return
        end
        url = url:gsub("${VERSION}", version)
        vim.notify(string.format("Reaching out to download shellcheck from %s", url, vim.log.levels.DEBUG))
        local handle = shell:new({ "curl", "-fsSL", url, "-o", output_file }, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
            [shell.CONSTANTS.FLAGS.STDERR_JOIN] = ""
        }):run()
        if not handle then
            cleanup()
            error_callback("Unable to download shellcheck", -1)
            return
        end
    end

    if not install_opts.version then
        shellcheck.latest_version(handle_version)
    else
        handle_version(install_opts.version)
    end
end

-- Installs shellfmt
---@param success_callback fun() The function to call on successful installation
---@param error_callback fun(error_message: string, exit_code: number?) The function to call on a failure
---@param install_opts LspInstallOpts? Any options to provide during installation
function shellfmt.install(success_callback, error_callback, install_opts)
    install_opts = install_opts or { force = false }

    local temp_dir = string.format("%s/neovim_miversen_lsp_download-shellfmt-%s", uv.os_tmpdir(),
        os.date("%Y%m%d%H%M%S"))

    local cleanup = function()
        vim.fs.rm(temp_dir, { force = true, recursive = true })
    end

    local target_path = shellfmt.get_binary_path(true)
    local parent_dir
    for parent in vim.fs.parents(target_path) do
        parent_dir = parent
        break
    end

    if vim.fn.isdirectory(parent_dir) ~= 1 then
        vim.fs.mkdir(parent_dir, 'p')
    end

    if vim.fn.isdirectory(temp_dir) == 1 then
        cleanup()
    end

    vim.fs.mkdir(temp_dir, 'p')

    local url = SHELLFMT_URL
    -- local url = jit.os == "Windows" and SHELLCHECK_WINDOWS_URL or SHELLCHECK_URL
    url = url:gsub('${ARCH}', 'x86_64')
    url = url:gsub('${OS}', os_map[jit.os])

    ---@param result Shell.Serial
    local complete = function(result)
        -- Dunno how we unzip on windows?
        if result.exit_code ~= 0 then
            error_callback(result.stderr, result.exit_code)
            return
        end
        vim.fs.chmod(target_path, 'rwxrwxr-x')
        cleanup()
        success_callback()
    end

    ---@param version string?
    local handle_version = function(version)
        if not version then
            error_callback("Unable to locate verion of shellfmt to install", -1)
            return
        end
        url = url:gsub("${VERSION}", version)
        vim.notify(string.format("Reaching out to download shellfmt from %s", url, vim.log.levels.DEBUG))
        local handle = shell:new({ "curl", "-fsSL", url, "-o", target_path }, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
            [shell.CONSTANTS.FLAGS.STDERR_JOIN] = ""
        }):run()
        if not handle then
            cleanup()
            error_callback("Unable to download shellfmt", -1)
            return
        end
    end

    if not install_opts.version then
        shellfmt.latest_version(handle_version)
    else
        handle_version(install_opts.version)
    end
end

bashls.config = {
    cmd = { "$LSP_BIN", "start" },
    filetypes = { "sh", "bash", "zsh" },
    cmd_env = {
        SHELLCHECK_PATH = shellcheck.get_binary_path(true),
        SHFMT_PATH = shellfmt.get_binary_path(true),
    }
}


local lsps = {
    bashls,
    shellcheck,
    shellfmt
}

if bashls.get_binary_path() ~= "MISSING BINARY" then
    -- Doesn't matter if we can build it or not if it already exists
    return lsps
end
-- Best plan of attack here I think is to check if docker is available,
-- if it is, create the binary in a container and then copy it to where we need it
-- Otherwise complain that you can't find docker and die
if vim.fn.executable("docker") == 1 then
    -- lets assume docker is available and we can run it
    return lsps
end
-- We can fail gracefully if docker is available and we can't run it
vim.notify("Unable to locate docker, cannot build bash language server", vim.log.levels.DEBUG)
return {}
