-- lsps/yaml.lua

local shell = require("scripts.shell")

local uv = vim.uv or vim.loop

local YAML_LSP_DOCKERFILE = [[
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
local yaml = {
    name = "yamlls",
    url = "https://github.com/redhat-developer/yaml-language-server/archive/refs/tags/${VERSION}.tar.gz",
    config = {
        filetypes = { "yaml", "yml" },
        cmd = { "node", "$LSP_BIN", "--stdio" }
    },
    pin = "1.18.0",
    _current_version = nil,
    _latest_version = nil
}

local function _get_editor_language_dir()
    return string.format("%s/miversen/lsps/yaml", vim.fn.stdpath("data"))
end

-- Creates a docker container and builds the yaml lsp server in that container. It then removes the container after finishing
---@param success_callback fun() The function to call after successfully building the yaml lsp server
---@param error_callback fun(error: string, exit_code: number?) The function to call if there is an error that prevents us from success
---@param install_opts LspInstallOpts? Any options we need to use to install
function yaml.install(success_callback, error_callback, install_opts)
    install_opts = install_opts or { force = false }
    local node_compile_image = "miversen-nvim-pnpm-compiler"
    local node_compile_image_version = "0.0.1"
    local target_path = _get_editor_language_dir()
    if vim.fn.isdirectory(target_path) ~= 1 then
        vim.fs.mkdir(target_path, 'p')
    end
    local temp_dir = string.format("%s/neovim_miversen_lsp_download-yaml-%s", uv.os_tmpdir(),
        os.date("%Y%m%d%H%M%S"))

    local cleanup = function()
        vim.fs.rm(temp_dir, { force = true, recursive = true })
    end

    ---@param version string The version of yaml to compile
    local function build_lsp(version)
        vim.notify("Building yaml", vim.log.levels.DEBUG)
        local dir = string.format("%s/yaml-language-server-%s", temp_dir, version)
        local cmd = { "docker", "run", "--rm", "-v", string.format("%s:/app", dir),
            string
                .format("%s:%s",
                    node_compile_image, node_compile_image_version), "-c",
            "npm install && pnpm run build" }
        ---@param result Shell.Serial
        local complete = function(result)
            if result.exit_code ~= 0 then
                cleanup()
                error_callback(result.stderr, result.exit_code)
                return
            end
            local compiled_yaml_server = string.format("%s/out/server/src/server.js",
                dir)
            if vim.fn.filereadable(compiled_yaml_server) == 0 then
                cleanup()
                error_callback("Compiled yaml language server not found!", -1)
                return
            end
            vim.fs.mv(dir, string.format("%s/yaml-language-server", target_path))
            cleanup()
            vim.notify("Yaml Language Server Build Complete", vim.log.levels.INFO)
            success_callback()
        end
        local handle = shell:new(cmd, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
            [shell.CONSTANTS.FLAGS.STDERR_JOIN] = "",
        }):run()
        if not handle then
            cleanup()
            error_callback("Unable to build yaml language server", -1)
        end
    end

    ---@param version string The version of yaml to download
    local function download_lsp_source(version)
        local url = string.gsub(yaml.url, '${VERSION}', version)

        vim.fs.mkdir(temp_dir, 'p')

        local output_file = string.format("%s/yaml.tar.gz", temp_dir)
        vim.notify("Downloading yaml", vim.log.levels.DEBUG, {})

        ---@param result Shell.Serial
        local extract_complete = function(result)
            if result.exit_code ~= 0 then
                error_callback("Unable to extract yaml language server", result.exit_code)
                return
            end
            local dir = string.format("%s/yaml-language-server-%s", temp_dir, version)
            print(result)
            vim.notify(dir, vim.log.levels.DEBUG)
            if vim.fn.isdirectory(dir) == 0 then
                -- cleanup()
                error_callback("Unable to locate extracted yaml language server", -1)
                return
            end
            build_lsp(version)
        end

        ---@param result Shell.Serial
        local download_complete = function(result)
            if result.exit_code ~= 0 then
                cleanup()
                error_callback("Unable to download most recent version of yaml language server", result.exit_code)
                return
            end
            if vim.fn.filereadable(output_file) == 0 then
                -- Complain
                cleanup()
                error_callback("yaml langauge server didn't download????")
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
                error_callback("Unable to begin extraction of yaml language server?", -1)
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
            error_callback("Unable to start download yaml language server source", -1)
            return
        end
    end

    ---@param version string The version of yaml to build
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
            _handle.write(YAML_LSP_DOCKERFILE)
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
        yaml.latest_version(build_image)
    else
        build_image(install_opts.version)
    end
end

---@return boolean
function yaml.needs_install()
    return yaml.get_binary_path() == "MISSING BINARY"
end

---@param ignore boolean? Do we ignore if the path doesn't exist?
function yaml.get_binary_path(ignore)
    local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
    local editor_lsp = string.format("%s/lsps/yaml/yaml-language-server/out/server/src/server.js", editor_dir)
    if ignore or vim.fn.filereadable(editor_lsp) == 1 then
        return editor_lsp
    else
        return "MISSING BINARY"
    end
end

---@param yes_callback fun() A callback we call if we can indeed run
local function can_we_run(yes_callback)
    if yaml.get_binary_path() ~= "MISSING BINARY" then
        -- Doesn't matter if we can build it or not if it already exists
        yes_callback()
    end
    -- Best plan of attack here I think is to check if docker is available,
    -- if it is, create the binary in a container and then copy it to where we need it
    -- Otherwise complain that you can't find docker and die
    if vim.fn.executable("docker") == 0 then
        vim.notify("Unable to locate docker, cannot build yaml language server", vim.log.levels.DEBUG, {})
        return
    end
    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 then
            vim.notify("Unable to run docker, cannot build yaml language server", vim.log.levels.DEBUG, {})
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
function yaml.version()
    if yaml._current_version then
        return yaml._current_version
    end
    local package_json = string.format("%s/miversen/lsps/yaml/yaml-language-server/package.json", vim.fn.stdpath("data"))
    if not vim.fn.filereadable(package_json) then
        yaml._current_version = nil
        return "-1"
    end
    ---@type string[]
    package_json = vim.fn.readfile(package_json)
    if not package_json then
        yaml._current_version = nil
        return "-1"
    end
    ---@type string
    package_json = vim.json.decode(table.concat(package_json, ""))
    if not package_json then
        yaml._current_version = nil
        return "-1"
    end
    local version = package_json.version
    if not version then
        yaml._current_version = nil
        return "-1"
    else
        yaml._current_version = version
        return version
    end
end

---@param callback fun(version: string?) If provided, we will provide the latest version (or nothing if we can't find it)
function yaml.latest_version(callback)
    if yaml._latest_version then
        callback(yaml._latest_version)
        return
    end
    local yaml_api = "https://api.github.com/repos/redhat-developer/yaml-language-server/tags"

    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 or result.stdout:len() == 0 then
            yaml._latest_version = nil
            callback()
            return
        end
        local output = vim.json.decode(result.stdout)
        if not output then
            yaml._latest_version = nil
            callback()
            return
        end
        local last_release = output[#output]
        if not last_release then
            yaml._latest_version = nil
            callback()
            return
        end
        local version = last_release.name
        if not version then
            yaml._latest_version = nil
            callback()
            return
        end
        yaml._latest_version = version
        callback(version)
    end

    local handle = shell:new({ "curl", "-fsSL", yaml_api }, {
        [shell.CONSTANTS.FLAGS.ASYNC] = true,
        [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
        [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = ""
    }):run()
    if not handle then
        callback()
    end
end

---@param callback fun(needs_update: boolean?) The function for us to call after determining if we need an update
function yaml.needs_update(callback, error)
    local current_version = yaml.version()
    ---@param version string?
    local complete = function(version)
        callback(version > current_version)
    end
    yaml.latest_version(complete)
end

local lsps = {
    yaml,
}

if not vim.fn.executable("node") then
    -- Node isn't available, complain and die
    vim.notify("Unable to start yaml language server as it requires node and we couldn't find node", vim.log.levels
        .DEBUG)
    return {}
end

if yaml.get_binary_path() ~= "MISSING BINARY" then
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
vim.notify("Unable to locate docker, cannot build yaml language server", vim.log.levels.DEBUG)
return {}
