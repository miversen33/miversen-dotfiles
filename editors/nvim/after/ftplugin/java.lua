-- Have this auto setup JDTLS if it doesn't already exist...?
-- A helper lsp function would be wise
local lsp_dir = vim.fn.stdpath('data') .. "/mason/packages/jdtls/"

import('jdtls', function(jdtls)
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
        lsp_dir .. "/plugins/org.eclipse.equinox.launcher.jar",
        '-configuration',
        lsp_dir .. "/config_linux",
        "-data",
        project_root
    }
    local config = {
        cmd = cmd,
        root_dir = project_root
    }
    jdtls.start_or_attach(config)
end)
