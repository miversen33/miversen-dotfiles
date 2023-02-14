local M = {}

local HEIGHT_SCALE = 0.3
local WIDTH_SCALE = 0.3

local lang_repl_map = {
    term = {
        direction = "float",
        close_on_exit = false,
    },
    vterm = {
        direction = "vertical",
        close_on_exit = false
    },
    hterm = {
        direction = "horizontal",
        close_on_exit = false
    }
}

local ignored_repl_map = {}
local new_terms = {}
local active_term = nil

function M.get_lang_repl(filetype)
    if new_terms[filetype] then return new_terms[filetype] end
    if ignored_repl_map[filetype] or not lang_repl_map[filetype] then
        print("Unable to find repl for " .. tostring(filetype))
        ignored_repl_map[filetype] = 1
        return
    end
    local repl_map = lang_repl_map[filetype]
    local term = new_terms[filetype] or require("toggleterm.terminal").Terminal:new(repl_map)
    new_terms[filetype] = term
    return term
end

function M.init()
    if M._inited then return end
    import('toggleterm', function(toggleterm)
        local calculate_width = function (width_weight)
            local width = vim.o.columns * width_weight
            return width - (width % 1)
        end
        local calculate_height = function (height_weight)
            local height = vim.o.lines * height_weight
            return height - (height % 1)
        end
        toggleterm.setup({
            shade_terminals = false,
            size = function(term)
                if term.direction == "horizontal" then
                    return calculate_height(HEIGHT_SCALE)
                elseif term.direction == "vertical" then
                    return calculate_width(WIDTH_SCALE)
                end
            end,
            float_opts = {
                border = 'curved',
                -- Doing some shitty truncation math because we don't actually need the float percent to be "accurate"
                -- just around 90% of the vim global window
                width = function()
                    return calculate_width(.90)
                end,
                height = function()
                    return calculate_height(.90)
                end
            }
        })
        vim.api.nvim_create_user_command('CFloatTerm', function() M.get_lang_repl('term'):toggle() end, {})
        -- Split term dies if you already have one open???
        vim.api.nvim_create_user_command('CSplitTerm', function(args)
            local split = args.fargs[1]
            local term = ''
            if split == 'vertical' then
                term = 'vterm'
            elseif split == 'horizontal' then
                term = 'hterm'
            else
                print(string.format("Unknown split type \"%s\"", split))
                return
            end
            M.get_lang_repl(term):toggle()
        end, {nargs=1})
        vim.api.nvim_create_user_command('CReplTerm', function()
            if active_term then
                active_term:toggle()
                active_term = nil
                return
            end
            local filetype = vim.api.nvim_buf_get_option(0, 'filetype')
            local term = M.get_lang_repl(filetype)
            if term then
                term:toggle()
                active_term = term
            end
        end,
        {})
        M._inited = true
    end)
end

M.init()

