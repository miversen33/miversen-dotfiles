-- Have this auto setup JDTLS if it doesn't already exist...?
-- A helper lsp function would be wise
local lsp_dir = vim.fn.stdpath('data') .. "/mason/packages/jdtls"
local sysname = vim.loop.os_uname().sysname:lower()
if sysname == 'windows' then
    sysname = 'win'
elseif sysname == 'darwin' then
    sysname = 'mac'
else
    sysname = 'linux'
end

local _, jdtls = pcall(require, "jdtls")
if _ == nil then
    vim.notify("nvim-jdtls not found!", vim.log.levels.WARN)
    return
end
local jdt_launcher = vim.fn.glob(lsp_dir .. '/plugins/org.eclipse.equinox.launcher_*.jar')
if not jdt_launcher or #jdt_launcher == 0 then
    vim.notify("jdtls not found!", vim.log.levels.WARN)
    return
end
local project_root = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'})

local cmd = {
    "java",
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar',
    jdt_launcher,
    '-configuration',
    lsp_dir .. "/config_" .. sysname,
    "-data",
    project_root
}
local config = {
    cmd = cmd,
    root_dir = project_root
}
jdtls.start_or_attach(config)
