local persisted_config = {
    use_git_branch = true,
    should_autosave = true,
    autoload = true,
}

local persisted = {
  "olimorris/persisted.nvim",
  config = true,
  opts = persisted_config,
}

return persisted
