
local persisted_config = {
    use_git_branch = true,
    should_autosave = true,
    autoload = true,
    ignored_dirs = {
      "/tmp",
      { "/", exact = true },
      { vim.uv and vim.uv.os_homedir() or vim.loop.os_homedir(), exact = true}
    }
}

local persisted = {
  "olimorris/persisted.nvim",
  config = true,
  opts = persisted_config,
}

return persisted
