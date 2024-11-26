$env.HOME = $"($nu.home-path)"
$env.BIN_DIR = (which nu | get path | get 0 | path dirname)
$env.DOTFILES = $"($nu.home-path)/git/miversen-dotfiles"
if ( sys host | get name ) == 'Windows' {
    $env.OS = "windows"
} else if ( sys host | get name ) =~ 'Linux' {
    $env.OS = "linux"
} else {
    $env.OS = "mac"
}

if not ( $"($nu.home-path)/.config/nushell/" | path exists ) { mkdir $"($nu.home-path)/.config/nushell" }
oh-my-posh init nu --config $"($nu.home-path)/git/miversen-dotfiles/shells/oh-my-posh.toml" --print | save $"($nu.home-path)/.config/nushell/oh-my-posh.nu" --force
