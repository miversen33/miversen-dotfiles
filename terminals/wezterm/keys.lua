local wezterm = require( "wezterm" )
local action = wezterm.action

local leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- Consider a key chord for QuickSelect

local keys = {
    -- Toggle Leader
    {
        key = "b",
        mods = "CTRL",
        action = wezterm.action.EmitEvent( "toggle-leader" )
    },
    -- Nasty work around to deal with the fact that CTRL+/ doesn't actually pass through...
    { key = "/", mods = "CTRL", action = wezterm.action.SendString( "\x1f" ) },
    -- Sends CTRL+A to the underlying program, since we are using it as the leader
    {
        key = "a",
        mods = "LEADER|CTRL",
        action = wezterm.action.SendString( "\x01" )
    }, -- Splits bois
    {
        key = "-",
        mods = "LEADER",
        action = wezterm.action.SplitPane( { direction = "Down" } )
    }, {
        key = "_",
        mods = "LEADER|SHIFT",
        action = wezterm.action.SplitPane( { direction = "Right" } )
    }, -- Navigation
    {
        key = "n",
        mods = "LEADER|CTRL",
        action = wezterm.action.SpawnTab( "CurrentPaneDomain",
                                          { cwd = wezterm.home_dir } )
    }, -- Navigation!
    -- Jumping between panes
    {
        key = "h",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection( "Left" )
    }, {
        key = "l",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection( "Right" )
    }, {
        key = "j",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection( "Down" )
    }, {
        key = "k",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection( "Up" )
    }, -- Panes
    -- Make pane big boi
    { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
    {
        key = "q",
        mods = "LEADER",
        action = wezterm.action.CloseCurrentPane( { confirm = true } )
    }, -- Tabs
    {
        key = ".",
        mods = "LEADER",
        action = wezterm.action.ActivateTabRelative( 1 )
    },
    {
        key = ",",
        mods = "LEADER",
        action = wezterm.action.ActivateTabRelative( -1 )
    }, -- Workspace
    { key = "c", mods = "LEADER", action = wezterm.action.SwitchToWorkspace },
    { key = "c", mods = "CTRL|LEADER", action = wezterm.action.SwitchToWorkspace },
    {
        key = "$",
        mods = "LEADER|SHIFT",
        action = action.PromptInputLine( {
            description = wezterm.format( {
                { Attribute = { Intensity = "Bold" } },
                { Foreground = { AnsiColor = "Fuchsia" } },
                { Text = "Enter name for new workspace" }
            } ),
            action = wezterm.action_callback(
                function( window, pane, line )
                    if line then
                        wezterm.mux.rename_workspace( wezterm.mux
                                                          .get_active_workspace(),
                                                      line )
                    end
                end ),
            prompt = "> ",
            initial_value = wezterm.mux.get_active_workspace()
        } )
    }, {
        key = "s",
        mods = "LEADER",
        action = wezterm.action_callback(
            function( window, pane )
                local workspaces = {}
                -- local current_workspace = wezterm.mux.get_active_workspace()
                for _, workspace in ipairs( wezterm.mux.get_workspace_names() ) do
                    table.insert( workspaces, { label = workspace } )
                end
                window:perform_action( action.InputSelector( {
                    action = wezterm.action_callback(
                        function( window, pane, id, label )
                            if not id and not label then
                                return
                            end
                            window:perform_action(
                                action.SwitchToWorkspace( { name = label } ),
                                pane )
                        end ),
                    title = "Workspace Selector",
                    choices = workspaces
                } ), pane )
            end )
    }
}

return { leader = leader, mappings = keys }
