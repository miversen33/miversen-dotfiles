local success, toggleterm = pcall(require, 'toggleterm')
if not success then
    vim.notify("Unable to locate toggle term. Disabling any custom terms. Good luck!", vim.log.levels.WARN)
    return
end

local HEIGHT_SCALE = 0.05
local WIDTH_SCALE = 0.3

local M = {
    __inited = false
}

local term_map = {
    float = {
        direction = "float",
        close_on_exit = false,
    },
    vert = {
        direction = "vertical",
        close_on_exit = false,
        auto_scroll = true
    },
    hori = {
        direction = "horizontal",
        close_on_exit = false,
        auto_scroll = true
    }
}

local base_repl_map = {
    term = {
        prefer = '$SHELL',
        fallback = '/bin/sh',
    },
    python = {
        prefer = 'ptpython',
        fallback = 'python3'
    },
    lua = {
        prefer = 'croissant',
        fallback = 'lua'
    },
    javascript = {
        fallback = "node"
    }
}
base_repl_map['vterm'] = {prefer = base_repl_map.term.prefer, fallback = base_repl_map.term.fallback}
base_repl_map['hterm'] = {prefer = base_repl_map.term.prefer, fallback = base_repl_map.term.fallback}

local ignore_repl_map = {}
local post_repl_map = {}
local repls = {}

local function get_repl(filetype, base, extra_opts)
    extra_opts = extra_opts or {}
    filetype = filetype or vim.api.nvim_buf_get_option(0, 'filetype')
    if ignore_repl_map[filetype] then return end
    if not post_repl_map[filetype] then
        vim.notify(string.format("Unable to locate repl for filetype %s", filetype))
        ignore_repl_map[filetype] = 1
        return
    end
    if repls[filetype] then return repls[filetype].term end
    local opts = {
        cmd = post_repl_map[filetype]
    }
    for key, value in pairs(term_map[base]) do
        opts[key] = value
    end
    for key, value in pairs(extra_opts) do
        opts[key] = value
    end
    -- Abusing extra_opts
    if opts.load_file then
        opts.cmd = opts.cmd .. ' ' .. opts.load_file
        opts.load_file = nil
    end
    local term = require("toggleterm.terminal").Terminal:new(opts)
    repls[filetype] = {
        term = term,
        filetype = filetype,
        base = base,
        extra_opts = extra_opts
    }
    return term
end

local function setup_toggleterm()
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
end

local function reset_repl(filetype)
    -- if no filetype is provided, we will reset all of them
    local function reset(term_wrapper)
            vim.notify(string.format("Resetting %s repl", filetype), vim.log.levels.INFO)
            term_wrapper.term:shutdown()
            local base = term_wrapper.base
            local opts = term_wrapper.extra_opts
            opts.hidden = 1
            repls[filetype] = nil
            get_repl(filetype, base, opts)
    end
    if filetype then
        local term_wrapper = repls[filetype]
        if term_wrapper then
            reset(term_wrapper)
        end
    else
        for _, term_wrapper in pairs(repls) do
            reset(term_wrapper)
        end
    end
end

local function setup_cmds()
    vim.api.nvim_create_user_command(
        'CFloatTerm',
        function()
            local term = get_repl('term', 'float')
            if term then term:toggle() end
        end,
        {}
    )
    vim.api.nvim_create_user_command(
        'CSplitTerm',
        function(args)
            local direction = ''
            local term_type = ''
            if args.fargs[1] == 'vertical' then
                direction = 'vert'
                term_type = 'vterm'
            elseif args.fargs[1] == 'horizontal' then
                direction = 'hori'
                term_type = 'hterm'
            else
                vim.notify(string.format("I have no idea what direction %s is...", direction))
                return
            end
            local term = get_repl(term_type, direction)
            if term then term:toggle() end
        end,
        {
            nargs = 1,
            complete = function() return {'vertical', 'horizontal'} end
        }
    )
    vim.api.nvim_create_user_command(
        'CResetTerms',
        function(args)
            local repl = args.fargs[1]
            reset_repl(repl)
        end,
        {
            nargs = '*',
            complete = function()
                local filetypes = {'*'}
                for filetype, _ in pairs(repls) do
                    table.insert(filetypes, filetype)
                end
                return filetypes
            end
        }
    )
    vim.api.nvim_create_user_command(
        'CRepl',
        function(args)
            if #args.fargs > 3 then
                vim.notify("Invalid CRepl Args", vim.log.levels.ERROR)
                return
            end
            local filetype = args.fargs[1] or nil
            local load_file = args.fargs[2] or nil
            if filetype == 'Current Filetype' then filetype = nil end
            local term = get_repl(filetype, 'vert', {load_file = load_file})
            if term then term:toggle() end
        end,
        {
            nargs = '*',
            complete = function()
                local filetypes = {'Current Filetype'}
                for filetype, _ in ipairs(post_repl_map) do
                    table.insert(filetypes, filetype)
                end
                return filetypes
            end
        }
    )
    vim.api.nvim_create_user_command(
        'CReplSendLines',
        function()
            local term_wrapper = get_repl()
            if not term_wrapper then
                -- Nothing to do, there is no active term for the current buffer
                -- Maybe notify?
                vim.notify("No active repl!", vim.log.levels.WARN)
                return
            end
            vim.api.nvim_command(string.format('ToggleTermSendVisualLines %s', term_wrapper.term.id))
        end,
        {
            nargs = '+'
        }
    )
    vim.api.nvim_create_user_command(
        'CReplSendFile',
        function(args)
            local file = args.fargs[1]
        end,
        {
            nargs = 1
        }
    )
    -- vim.api.nvim_create_user_command(
    --     'CFloatTerm',
    --     function()
    --         local term = get_repl('term', 'float')
    --         if term then term:toggle() end
    --     end,
    --     {}
    -- )
end

function M.init()
    if M.__inited then return end
    for lang, repl_details in pairs(base_repl_map) do
        local repl = {}
        if repl_details.prefer and not vim.fn.executable(repl_details.prefer) then
            -- Prefered repl isn't available. Set the fallback
            repl = repl_details.fallback
        else
            repl = repl_details.prefer
        end
        post_repl_map[lang] = repl
    end
    setup_toggleterm()
    setup_cmds()
    M.__inited = true
end

M.init()
