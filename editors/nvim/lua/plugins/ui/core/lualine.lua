local extended_mode_map = {
    dap = "",
    repl = "ﲵ",
    lsp = "",
    test = "ﭧ",
    search = ""
}
local branch_max_width = 40
local branch_min_width = 10

local ANNOYING_ICON_MAP = { devicons = { python = "py" } }
_G.__miversen_devicon_map = ANNOYING_ICON_MAP

local get_buf_filetype = function( buffer )
    return vim.api.nvim_get_option_value( "filetype", { buf = buffer or 0 } )
end

local function get_venv( variable )
    local venv = os.getenv( variable )
    if venv ~= nil and string.find( venv, "/" ) then
        local orig_venv = venv
        for w in orig_venv:gmatch( "([^/]+)" ) do venv = w end
        venv = string.format( "%s", venv )
    end
    return venv
end

-- Function that will attempt to get the current virtual environment in use.
-- Currently supports
-- 
-- Python
--  - virtualenv
local function get_current_venv()
    local ft = vim.api.nvim_get_option_value( "filetype", { buf = 0 } )
    if ft == "python" then
        local venv = get_venv( "VIRTUAL_ENV" )
        if venv then
            -- Check to see if we are in snek lang?
            return venv
        end
    end
    return nil
end

local format_name = function( output )
    -- We removed the exclusion list specifically because there are some 
    -- filetypes we want to see in lualine but we don't want
    -- to maintain separate exclusion lists. So suck it up buttercup
    local output_limit = 40
    if output:len() > output_limit - 3 then
        local new_first = output:len() - (output_limit - 3)
        output = "..." .. output:sub( new_first )
    end
    return output
end

local lualine_opts = {
    options = {
        theme = vim.g.__miversen_lualine_theme or "auto",
        globalstatus = true
    },
    sections = {
        lualine_a = {
            {
                "mode",
                fmt = function( output )
                    return output:len() > 0 and output:sub( 1, 1 ):upper() or ""
                end
            }, {
                function()
                    return
                        extended_mode_map[vim.g.__miversen_extended_mode] or ""
                end
            }, {
                "branch",
                fmt = function( output )
                    local win_width = vim.o.columns
                    local max = branch_max_width
                    if win_width * 0.25 < max then
                        max = math.floor( win_width * 0.25 )
                    end
                    if max < branch_min_width then
                        max = branch_min_width
                    end
                    if max % 2 ~= 0 then max = max + 1 end
                    if output:len() >= max then
                        return output:sub( 1, (max / 2) - 1 ) .. "..." ..
                                   output:sub( -1 * ((max / 2) - 1), -1 )
                    end
                    return output
                end
            }
        },
        lualine_b = {
            { "filename", file_status = false, path = 1, fmt = format_name },
            { "diagnostics", update_in_insert = true }
        },
        lualine_c = {},
        lualine_x = {
            {
                function()
                    local lsps = vim.lsp.get_clients( { bufnr = 0 } )
                    if not lsps or #lsps == 0 then return "" end
                    local names = {}
                    for _, lsp in ipairs( lsps ) do
                        table.insert( names, lsp.name )
                    end
                    return string.format( "%s", table.concat( names, ", " ) )
                end,
                on_click = function()
                    vim.api.nvim_command( "LspInfo" )
                end,
                cond = function()
                    return #vim.lsp.get_clients( { bufnr = 0 } ) > 0
                end,
                color = function()
                    local _, color =
                        require( "nvim-web-devicons" ).get_icon_colors_by_filetype(vim.api.nvim_get_option_value('filetype', { buf = 0})
)
                    return { fg = color }
                end
            }, {
                function()
                    local venv = get_current_venv()
                    local icon =
                        require( "nvim-web-devicons" ).get_icon_by_filetype(
                            vim.api.nvim_get_option_value( "filetype",
                                                           { buf = 0 } ) )
                    if venv then
                        return string.format( "%s %s", icon, venv )
                    else
                        return icon or ""
                    end
                end,
                color = function()
                    local _, color =
                        require( "nvim-web-devicons" ).get_icon_colors_by_filetype(
                            vim.api.nvim_get_option_value( "filetype",
                                                           { buf = 0 } ) )
                    return { fg = color }
                end,
                on_click = function()
                    -- Open Telescope to pick a different virtual env/interpretter/language
                    -- Not sure how we tell the LSP to use that instead though
                end
            }, "progress"
        },
        lualine_y = {},
        lualine_z = {
            "location", {
                function()
                    local starts = vim.fn.line( "v" )
                    local ends = vim.fn.line( "." )
                    local count =
                        starts <= ends and ends - starts + 1 or starts - ends +
                            1
                    return count .. "V"
                end,
                cond = function()
                    return vim.fn.mode():find( "[Vv]" ) ~= nil
                end
            }
        }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
            { "filetype", icon_only = true },
            { "filename", path = 1, fmt = format_name }
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    }
}

---@module "lazy"
---@type LazySpec
return {
    "nvim-lualine/lualine.nvim", -- Neovim status line
    dependencies = { "nvim-tree/nvim-web-devicons", "onsails/lspkind-nvim" },
    lazy = false,
    priority = 999,
    opts = lualine_opts
}
