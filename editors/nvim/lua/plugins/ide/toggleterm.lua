local HEIGHT_SCALE = 0.05
local WIDTH_SCALE = 0.3

local terms = {}
local termopts = {
    float = {
        cmd = "$SHELL",
        direction = "float",
        close_on_exit = false,
    },
    right = {
        cmd = "$SHELL",
        direction = "vertical",
        close_on_exit = false,
        auto_scroll = true
    },
    bottom = {
        cmd = "$SHELL",
        direction = "horizontal",
        close_on_exit = false,
        auto_scroll = true
    }
}

local function get_term(termtype)
    if terms[termtype] then
        return terms[termtype]
    end
    local opts = termopts[termtype]
    local term = require("toggleterm.terminal").Terminal:new(opts)
    terms[termtype] = term
    return term
end

local function register_user_funcs()
    vim.api.nvim_create_user_command(
        'CFloatTerm',
        function()
            get_term('float'):toggle()
        end,
        {}
    )
    vim.api.nvim_create_user_command(
        'CSplitTerm',
        function(args)
            local direction = ''
            local term_type = ''
            if args.fargs[1] == 'vertical' then
                term_type = 'right'
            elseif args.fargs[1] == 'horizontal' then
                term_type = 'bottom'
            else
                vim.notify(string.format("I have no idea what direction `%s` is...", direction), vim.log.levels.WARN)
                return
            end
            get_term(term_type):toggle()
        end,
        {
            nargs = 1,
            complete = function() return {'vertical', 'horizontal'} end
        }
    )
end

local function setup_toggleterm()
    local toggleterm = require('toggleterm')
    local c_width = function(width_weight)
        local width = vim.o.columns * width_weight
        return width - (width % 1)
    end

    local c_height = function(height_weight)
        local height = vim.o.columns * height_weight
        return height - (height % 1)
    end
    toggleterm.setup({
        shade_terminals = false,
        persist_size = false,
        size = function(term)
            if term.direction == 'horizontal' then
                return c_height(HEIGHT_SCALE)
            elseif term.direction == 'vertical' then
                return c_width(WIDTH_SCALE)
            end
        end,
        float_opts = {
            border = 'curved',
            -- Doing some shitty truncation math because we don't actually need the float percent to be "accurate"
            -- just around 90% of the vim global window
            width = function()
                return c_width(.90)
            end,
            height = function()
                return c_height(.90)
            end
        }
    })
    register_user_funcs()
end

local toggleterm = {
    "akinsho/toggleterm.nvim",
    config = true,
    init = setup_toggleterm
}

return toggleterm
