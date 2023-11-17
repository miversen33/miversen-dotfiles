
local persisted_config = {
    use_git_branch = true,
    should_autosave = true,
    autoload = true,
    ignored_dirs = {
      vim.uv and vim.uv.os_homedir() or vim.loop.os_homedir(),
      "/tmp",
      "/",
    }
}

local persisted = {
  "olimorris/persisted.nvim",
  config = true,
  opts = persisted_config,
}

return persisted
