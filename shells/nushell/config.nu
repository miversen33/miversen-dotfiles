$env.config = {
    show_banner: false,
    shell_integration: {
        osc133: false
    },
    footer_mode: 20
}

let core_plugins = [
    "query",
    "gstat",
    "inc",
    "polars"
]

let custom_plugins = [
    "https://github.com/yybit/nu_plugin_compress",
    "https://github.com/dead10ck/nu_plugin_dns",
    "https://github.com/PhotonBursted/nu_plugin_vec",
    "https://github.com/ArmoredPony/nu_plugin_hashes",
    "https://github.com/fdncred/nu_plugin_regex",
    "https://github.com/FMotalleb/nu_plugin_port_scan",
]

let custom_programs = [
    
]

$env.NU_PLUGIN_DIRS | each { | plugin_dir | if not ( $plugin_dir | path exists ) { mkdir $plugin_dir }}
if not ($env.BIN_DIR | path exists ) { mkdir $env.BIN_DIR }

let bindir = (which nu | get path | path dirname | get 0)
let custom_plugin_dir = $env.NU_PLUGIN_DIRS.0

$core_plugins | each { | core_plugin |
    mut extension = ""
    if $env.OS == 'windows' {
        $extension = ".exe"
    }
    plugin add $"($bindir)/nu_plugin_($core_plugin)($extension)"
}

if ( which cargo | length ) > 0 {
    $custom_plugins | each {
        | custom_plugin |
            let plugin_name = $custom_plugin | split row "/" | last
            if not ($"($custom_plugin_dir)/bin/($plugin_name)" | path exists) {
                print $"Installing ($plugin_name)..."
                try {
                    cargo install -q --root $"($custom_plugin_dir)" --git $"($custom_plugin)"
                } catch { |err|
                    $"Unable to install ($plugin_name) -- ($err.msg)"
                }
            }
        }
} else {
    # We should complain that cargo isn't available
    print "Cargo is not available. Cannot install custom plugins!"
}

# Convert a timestamp to various epoch formats
# --- Generated with Claude 3.7 Sonnet (reasoning/thinking model)
#
# This function takes a timestamp (or uses the current time) and converts it 
# to seconds, milliseconds, microseconds and nanoseconds since an epoch.
#
# Parameters:
#   timestamp?: string - Optional timestamp in YYYY-MM-DD [HH:MM:SS] format (default: current time)
#   --ad, -a - Use Active Directory/Windows file time epoch (1601-01-01) instead of Unix epoch (1970-01-01)
#
# Examples:
#   > breakdown-timestamp
#   # Returns current time converted to Unix epoch formats
#
#   > breakdown-timestamp "2025-01-01"
#   # Returns the specified date at midnight converted to Unix epoch formats
#
#   > breakdown-timestamp "2025-01-01 14:30:00"
#   # Returns the specified time converted to Unix epoch formats
#
#   > breakdown-timestamp "2025-01-01" -a
#   # Returns the specified date converted to Active Directory epoch formats
def breakdown-timestamp [
    timestamp?: string  # Optional timestamp in YYYY-MM-DD [HH:MM:SS] format
    --ad(-a)           # Flag to use Active Directory/Windows file time
] {
    # Define Unix epoch start date
    let unix_epoch_start = '1970-01-01 00:00:00' | into datetime
    
    # Parse input or use current time
    let parsed_time = if $timestamp == null {
        (date now)
    } else {
        # Check if the timestamp has time component
        let has_time = ($timestamp | str length) > 10 and ($timestamp | str contains ":")
        
        if $has_time {
            # Full datetime provided
            ($timestamp | into datetime)
        } else {
            # Only date provided, default to midnight
            ($timestamp + " 00:00:00" | into datetime)
        }
    }
    
    # Format the input for display
    let input_display = $parsed_time | format date "%Y-%m-%d %H:%M:%S"
    
    # Calculate time difference from Unix epoch in nanoseconds
    let duration_ns = $parsed_time - $unix_epoch_start
    
    # Convert nanoseconds to seconds for the Unix epoch
    let unix_seconds = ($duration_ns / 1000000000) | into int
    
    # AD offset in seconds
    let ad_offset_seconds = 11644473600
    
    if $ad {
        # For AD/Windows file time: 100-nanosecond intervals since 1601-01-01
        let ad_seconds = $unix_seconds + $ad_offset_seconds
        let ad_ms = $ad_seconds * 1000
        let ad_us = $ad_seconds * 1000000
        let ad_ticks = ($ad_seconds | into float) * 10000000
        let ad_ticks_int = $ad_ticks | into int
        
        {
            input: $input_display
            epoch: $ad_seconds 
            mspoch: $ad_ms
            mcpoch: $ad_us
            nspoch: $ad_ticks_int
        }
    } else {
        # Standard Unix epoch calculations
        let unix_ms = $unix_seconds * 1000
        let unix_us = $unix_seconds * 1000000
        let unix_ns = $unix_seconds * 1000000000
        
        {
            input: $input_display
            epoch: $unix_seconds
            mspoch: $unix_ms
            mcpoch: $unix_us
            nspoch: $unix_ns
        }
    }
}

# This needs to be last

source $"($nu.home-path)/.config/nushell/oh-my-posh.nu"
