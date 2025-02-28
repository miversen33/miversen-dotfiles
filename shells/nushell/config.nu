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

# This needs to be last

source $"($nu.home-path)/.config/nushell/oh-my-posh.nu"
