local function tbl_to_lines(tbl, indent)
    local result = {}
    indent = indent or ""
    if type(tbl) == 'string' then
        result = vim.split(tbl, "\n")
        return result
    end

    local len = #tbl
    local index = 0
    for key, value in pairs(tbl) do
        index = index + 1
        -- table.insert(result, string.format("%s{", indent))
        local key_line = type(key) == "number" and "" or string.format("%s = ", key)
        if type(value) == "table" then
            if not next(value) then
                table.insert(result, string.format("%s%s{ }%s", indent, key_line, index == len and "" or ","))
            else
                key_line = string.format("%s%s{", indent, key_line)
                table.insert(result, key_line)
                for _, sub_value in ipairs(tbl_to_lines(value, indent .. "    ")) do
                    table.insert(result, sub_value)
                end
                table.insert(result, string.format("%s}%s", indent, index == len and "" or ","))
            end
        else
            if type(value) == "string" then
                value = string.format('"%s"', value)
            end

            table.insert(result, string.format("%s%s%s%s", indent, key_line, tostring(value), index == len and "" or "," ))
        end
    end
    return result

end

local function write_table_to_scratch_buffer(output)
  -- Close existing scratch windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if pcall(vim.api.nvim_win_get_var, win, "scratch") then
      vim.api.nvim_win_close(win, true)
    end
  end

  output = tbl_to_lines(output)
  -- local part = 128
  -- local part_output = {}
  -- for i = 1, #output / part do
  --   part_output[i] = output[i]
  -- end
  -- print(string.format("There are %s lines to print", #part_output))
  -- print(part_output)
  -- Create and open a scratch buffer
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)

  -- Open buffer in a vertical split
  vim.cmd("vsplit")
  vim.api.nvim_set_current_buf(bufnr)

  -- Set buffer options
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].swapfile = false
  vim.api.nvim_buf_set_var(bufnr, "scratch", true)
end

local function get_output_from_command(command)
  -- Check if the command contains Lua syntax
  if command:match("^print") then
    -- For Lua commands, capture output via :redir and :messages
    vim.cmd("redir => g:__redir_output | silent messages | redir END")
    vim.cmd("lua " .. command)  -- Execute Lua command
    output = vim.split(vim.g.__redir_output or "", "\n")
    vim.g.__redir_output = nil -- Clear global variable
  elseif command:match("^vim") or command:match("^require") then
    local chunk, err = load("return ".. command)
    _, output = pcall(chunk)
  else
    -- For Vim commands, capture output with nvim_exec2()
    local result = vim.api.nvim_exec2(command, { output = true })
    output = vim.split(result.output, "\n")
  end
  write_table_to_scratch_buffer(output)
end

vim.api.nvim_create_user_command(
"Rediro",
function(opts)
        get_output_from_command(opts.args)
    end,
    { nargs = "+" }
)

