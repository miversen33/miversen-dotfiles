-- Check if the lua language server is in our path
local uv = vim.uv or vim.loop
local jit = require("jit")

local local_dir = jit.os ~= 'Windows' and '.local/bin/lsps' or 'AppData/local/bin/lsps'
local lua_lsp_location = string.format("%s/%s/lua-language-server", uv.os_homedir(), local_dir)
local temp_dir = string.format("%s/neovim_miversen_lsp_download-lua-%s", vim.uv.os_tmpdir(), vim.fn.strftime("%Y%m%d%H%M%S"))

local os_map = {
    Linux = 'linux',
    darwin = 'darwin',
    Windows = 'win32'
}

local architecture = jit.arch
LUA_LSP_VERSION = "3.15.0"
LUA_LSP_URL = "https://github.com/LuaLS/lua-language-server/releases/download/${VERSION}/lua-language-server-${VERSION}-${OS}-${ARCH}.tar.gz"

function cleanup_temp(callback)
    local cmd =
        vim.fn.has('win32') == 1
            and {'rmdir', '/s', '/q', temp_dir}
            or {'rm', '-rf', temp_dir}

    -- Note: This might not work in your callback context
    vim.system(cmd, {}, function(result)
        callback(result.code == 0 and nil or "Failed to remove directory")
        end)
    end

function extract_complete()
    -- schedule this so its on the main thread
    vim.schedule(function()
        setup_lsp()
    end)
end

function download_complete(downloaded_lsp)
    -- check if file is empty
    -- Check to see if the downloaded file exists
    if not uv.fs_stat(downloaded_lsp) then
        -- complain that the file didn't get downloaded
        print("Lua lsp was not successfully downloaded", downloaded_lsp)
        return
    end
    -- Will this work in windows?
    local tar_command = {
        "tar",
        "-C",
        lua_lsp_location,
        "-xzf",
        downloaded_lsp
    }
    vim.system(tar_command, {}, function(result)
        -- Doesn't matter if it worked or not, clean up
        local next_func = function()
            if result.code ~= 0 then
                print("Unable to extract lua lsp server")
                print(result.stderr or "Unknown error occured")
                return
            else
                extract_complete()
            end
        end
        cleanup_temp(next_func)
    end)
end

function download_lua_lsp()
    if _G.__miversen_lsp['lua'] == 'Downloading' then
        return
    end

    _G.__miversen_lsp['lua'] = "Downloading"
    vim.fn.mkdir(temp_dir, 'p')
    vim.fn.mkdir(lua_lsp_location, 'p')
    local url = string.gsub(LUA_LSP_URL, '${VERSION}', LUA_LSP_VERSION)
    url = string.gsub(url, '${OS}', os_map[jit.os])
    url = string.gsub(url, '${ARCH}', architecture)
    local output_file = string.format("%s/lua-language-server.tar.gz", temp_dir)
    vim.log.debug(string.format("Downloading lua lsp from %s", url))
    _G.async_curl(url, { "-fsLS", "-o", output_file}, function(result, err)
        if err then
            print(result, err)
            -- idk complain?
            return
        end
        download_complete(output_file)
    end)
end

if vim.fn.filereadable(string.format("%s/bin/lua-language-server", lua_lsp_location)) then
    return
end

vim.notify('Lua LSP not found, downloading now', vim.log.levels.WARNING)
download_lua_lsp()
