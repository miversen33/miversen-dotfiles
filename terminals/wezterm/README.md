# Wezterm Abstraction

Note, this documentation is going to be 💩, sorry about that.

This abstraction layer can be used to more easily create status bars. The expense is that you are a bit more restricted on
how you can create them (the abstraction treats the components in the status bar as individual for example, so you can't easily
cascade attributes across components).

How to use? Download the "lib" into your wezterm configuration directory (likely $HOME/.config/wezterm) and include it in your wezterm.lua config
```lua
-- wezterm.lua
local lib = require("lib")
return lib.load()
```

The default configuration used is
```lua
{
    -- Font attributes
    pref_fonts = {'JetBrains Mono'},
    -- font_opts = { weight = 'Bold', style = 'Italic' }
    -- if specified, will apply the options below to the fonts listed in pref_fonts
    -- will only be used if pref_fonts are found
    --
    -- raw = {}
    -- If provided, raw will have its key/value pairs passed _directly_ to wezterm
    -- Anything in raw will override anything provided in the user configuration
    -- or in the default configuration. Consider this a way to directly pass
    -- things that I don't care enough to abstract into wezterm
    --
    -- env_vars = {}
    -- If provided, we will use this to set the global environment of any program
    -- started under us
    --
    tab_bar_appearance = 'Fancy',
    -- Passed directly to wezterm
    --
    tab_bar_location = 'Top',
    -- If provided, sets the tab bar at the top of the window. Alternatively,
    -- this can be 'Bottom' and that will put it at the bottom
    --
    audible_bell = 'Disabled',
    -- Passed directly to wezterm. Fuck Audible bells lol
    --
    cursor_style = 'SteadyBlock',
    -- Passed directly to wezterm
    --
    window_decorations = 'RESIZE',
    -- Passed directly to wezterm
    --
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    },
    -- Passed directly to wezterm
    --
    inactive_pane_hsb = {
        hue = 1,
        saturation = 0.9,
        brightness = 0.9
    },
    -- Passed directly to wezterm
    --
    opacity = {
        window = 1,
        text = 1
    },
    -- The opacity to use for windows and the text on them
    -- for details, refer to wezterm doc for window_background_opacity and
    -- text_background_opacity
    -- Usually documentation is below the item but keys is a bigger boi so
    -- doc is above. Sue me
    -- Keys has can have any of the 3 following keys in it
    --     - leader
    --         - The leader key. Passed raw into wezterm
    --     - maps
    --         - The list of key maps. Passed raw into wezterm
    --     - tables
    --         - The list of key_table maps. Passed raw into wezterm
    -- Note, setting maps or tables in your user config will completely
    -- override the presets. This is because I don't feel like trying
    -- to compare the presets to yours to figure out which to keep or not.
    keys = {
        leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000},
        maps = {
            -- Nasty work around to deal with the fact that CTRL+/ doesn't actually pass through...
            { key = '/', mods = 'CTRL', action=wezterm.action.SendString("\x1f") },
            -- Wezterm Specific Stuff
            -- Sends CTRL+A to the underlying program, since we are using it as the leader
            { key = "a", mods = "LEADER|CTRL", action = wezterm.action.SendString('\x01') },
            -- Splits bois
            { key = "-", mods = "LEADER", action = wezterm.action.SplitPane({
                direction = "Down",
            })},
            { key = "_", mods = "LEADER|SHIFT", action = wezterm.action.SplitPane({
                direction = "Right",
            })},

            -- Navigation!
            -- Jumping between panes
            { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left")},
            { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right")},
            { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down")},
            { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up")},
            -- Make pane big boi
            { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState},
            -- Tabs
            { key = ".", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1)},
            { key = ",", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1)},
            { key = "n", mods = "LEADER|CTRL", action = wezterm.action.SpawnTab('CurrentPaneDomain')},
        }
    },
    -- Once again, doc is above code. Deal with it
    -- First a quick break down on terms here
    -- - status_bar
    --      An array of groups that are compiled and passed through to wezterm
    -- - group
    --      A set of components that should be contained "together"
    -- - component
    --      A function that when called returns a string or nil. This string is the text
    --      content that will be rendered into the group which in turn is rendered into the
    --      status bar. See lib.components for some pre-made components that you can use
    --      NOTE: You can also simply use a string here instead of a function if you
    --      have some static string you want to represent.
    -- - options
    --      A key value entry that specifies an attribute of some kind to apply to the that level and below by default
    --      An example, setting the "background" of a status bar will set the background
    --      for all components in the status bar (unless the component specifies its _own_
    --      background)
    --      Options Apply top down and are can be overriden by applying the same option
    --      at a lower level
    -- - dividers
    --      A divider is broken up into 2 styles. Soft and Hard.
    -- - soft divider
    --      A special divider used to separate individual components within a group. By default
    --      this is 'wezterm.nerdfonts.pl_left_soft_divider' or 'wezterm.nerdfonts.pl_right_soft_divider' (depending on if the status bar is a right or left status bar)
    -- - hard divider
    --      A special divider used to separate individual groups within the status bar.
    --      By default, this is 'wezterm.nerdfonts.pl_left_hard_divider' or 'wezterm.nerdfonts.pl_right_hard_divider' (depending on if the status bar is a right or left status bar)
    -- treated as a "group" of components to use.
    --
    -- The long short, a status bar is an array of groups that can also have optional attributes at any level in the status bar (which apply down as specified in the options definition).
    -- Note: You can have as many items in a group and as many groups as you would like,
    -- up to whatever wezterm will allow. This just provides a (IMO) easier way to create
    -- a "standard" status bar
    -- Valid "options"
    --     - background
    --         Anything that wezterm.color.parse accepts
    --     - foreground
    --         Anything that wezterm.color.parse accepts
    --     - attributes
    --         A table representation of the "Attribute" object
    --         used in wezterm.format
    --         A table that can contain any of the following attributes
    --         - intensity
    --             - Valid options include 'Normal', 'Bold', 'Half'
    --         - underline
    --             - Valid options include 'Single', 'Double', 'Curley', 'Dotted', 'Dashed'
    --         - italic
    --             - Valid options include true, false
    --     - soft_div_icon
    --         The icon to display for soft dividers
    --     - hard_div_icon
    --         The icon to display for hard dividers
    left_status_bar = {
        {
            lib.components.user(),
            background = '#5cf19e',
            foreground = 'BLACK',
            attributes = {
                intensity = 'Bold'
            }
        },
        {
            lib.components.host(),
            background = '#fc669b',
            foreground = 'BLACK',
            attributes = {
                intensity = 'Bold'
            }
        },
        {
            lib.components.workspace()
        },
        soft_div_icon = nerdfonts.pl_left_soft_divider,
        hard_div_icon = nerdfonts.pl_left_hard_divider,
        attributes = {
            intensity = 'Bold',
            italic = true
        },
    },
    right_status_bar = {
        -- This is built left to right
        {
            lib.components.leader(),
            lib.components.spacer(),
            lib.components.caps_indicator(),
            lib.components.battery(),
            lib.components.spacer(),
            soft_div_icon = ''
        },
        {
            lib.components.time(),
            attributes = {
                italic = true
            },
            background = 'WHITE',
            foreground = 'BLACK'
        },
    },
    format_tab = lib.tab_styles.diamond('#37b6ff', 'BLACK'),
    -- If you don't like how I have the "groups" configured,
    -- you can instead provide the following keys, with a valid callback function.
    -- Note, if these are provided, we will ignore whatever is in the "non raw" version
    -- if its in the config.
    -- EG: raw_left_status_bar will supercede left_status_bar (and only left_status_bar).
    -- This callback function will be passed straight to wezterm
    -- raw_left_status_bar = function(),
    -- raw_right_status_bar = function()
    --
    tab_bar_alignment = 'Center'
    -- This can be 'Left', 'Center', or 'Right'
    -- and will align the tab bar to any of those locations
    -- as best it can
}
```

The default configuration is "merged" with a configuration provided by the user on `lib.load`. For example, if you wanted to 
change the default font used, you could pass just that into `lib.load`!

```lua
-- wezterm.lua
local lib = require("lib")
return lib.load({pref_fonts = { 'MesloLGS NF' }})
```

This will change the terminal font to use `MesloLGS NF` instead of the default `JetBrains Mono`, but it will _only_ change this.
Any other "sane" default in the default configuration is still applied. For the most part this applies to anything in the configuration,
with a single notable exception being `keys`.

## Keys

As tracking key mappings are hard, anything that is passed in `keys.maps` or `keys.tables` will simply fully override the existing
`keys.maps` or `keys.tables`. Most other tables can be lazy changed, and the change will only apply to the specific keys provided.

For example, to change just the right padding of the window, you can pass
```lua
{
    window_padding = {
        right = 100 -- whatever padding you want
    }
}
```
This will not affect the other default padding sets for `left`, `top`, and `bottom`.

If you find a bug in this abstraction, or if you have an idea/question, please open an issue! I will likely be moving this to its own
repo as my dotfiles aren't really the place for this but 🤷
