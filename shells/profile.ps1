# To use this, you can use the following code snippet (maybe setup an installer?)
# $profile_script="$HOME\git\miversen-dotfiles\shells\profile.ps1"
# if ( Test-Path($profile_script) ){
#     .$profile_script
#     $my_domains = "my_domain.com"
#     $my_nameservers = "my_nameserver.com"
#     function Wrapped-Dev-Env{
#         Param($mount_opt, $port_opt)
#         Dev-Env $mount_opt $port_opt $my_domains $my_nameservers
#     }
#     Set-Alias -Name dev_env -Value Wrapped-Dev-Env
#     # usage: 
#     #     dev_env path_to_mount ports_to_share
#     # example
#     #     # just open a new dev environment
#     #     dev_env
#     #     # open a new dev environment and share the current directory with it
#     #     dev_env .
#     #     # open a new dev environment and share a specific file with it
#     #     dev_env some_file.txt
#     #     # open a new dev environment and open a specific port
#     #     dev_env 8000
#     #     # open a new dev environment and map a specific port to it
#     #     dev_env 8000:8000
#     #     # open a new dev environment and share a port range with it
#     #     dev_env 8000-8005
#     #     # open a new dev environment and share a directory _and_ map a port
#     #     dev_env some_project 8000
# }
# Note, none of the parameters are required but they do
# have to be provided in the order they are listed.
function Dev-Env
{
    # Losely based on the dev_env function found in https://github.com/miversen33/miversen-dotfiles/blob/master/shells/.shellrc
    Param($mount_opt, $port_opt, $domains_opt, $nameservers_opt)
    if ( ($null -eq $port_opt ) -and ($mount_opt -match "[0-9,:]") ){
        $port_opt=$mount_opt
        $mount_opt=$null
    }
    if ( -not (docker image ls --filter 'reference=miversen33/dev_env' --format '{{.Repository}}')){
        $response = Read-Host "dev_env image not found. Would you like me to create it? [y/N] "
        $response = $response.ToUpper()
        if ( $response -notmatch "[YES]" ){
            return
        }
        $_pwd=Get-Location
        cd $env:TEMP
        $build_url = "https://raw.githubusercontent.com/miversen33/miversen-dotfiles/master/docker/Dockerfile"
        $entrypoint_url = "https://raw.githubusercontent.com/miversen33/miversen-dotfiles/master/docker/entrypoint.sh"
        curl -Lso entrypoint.sh $entrypoint_url
        curl -Lso Dockerfile $build_url
        Write-Host "Fetching latest dockerfile of dev_env image"
        docker build -t miversen33/dev_env:latest .
        cd $_pwd
    }
    $port_arg = ""
    if ( $port_opt -ne $null){
        if ( $port_opt -is [System.Array] ){
            # Can't use join here because it appends the string instead of prepending it
            foreach ( $port in $port_opt ){
                $port_arg += "--expose $port "
            }
        }
        elseif ( $port_opt -match '^[0-9]+$' ){
            $port_arg = "--expose $port_opt "
        }
        elseif ( $port_opt -match ":" ){
            $port_arg = $port_opt -replace '([0-9:]+)', '--publish $1'
        }
        $port_arg = "$port_arg --publish-all=true"
    }
    $mount_arg = ""
    if ( $mount_opt -ne $null ){
        $source = Get-Item $mount_opt
        $destination = "/workspace"
        if ( $source -is [System.IO.FileInfo] ){
            $base_name = $source.BaseName
            $extension = $source.Extension
            $destination = "/workspace/$base_name$extension"
        }
        $source = $source.FullName
        $mount_arg = "--mount type=bind,source=$source,destination=$destination"
    }
    $mount_arg = "$mount_arg --mount type=volume,source=dev_env_home,destination=/home/miversen -v //var/run/docker.sock:/var/run/docker.sock"
    if ( Test-Path "$HOME\.ssh\id_rsa.pub" ){
        $mount_arg = "$mount_arg --mount type=bind,source=$HOME\.ssh\id_rsa.pub,destination=/tmp/id_rsa.pub"
    }
    if ( Test-Path "$HOME\.ssh\id_rsa" ){
        $mount_arg = "$mount_arg --mount type=bind,source=$HOME\.ssh\id_rsa,destination=/tmp/id_rsa"
    }
    if ( Test-Path "$HOME\.ssh\config" ){
        $mount_arg = "$mount_arg --mount type=bind,source=$HOME\.ssh\config,destination=/tmp/ssh_config"
    }
    if ( $port_arg -notmatch '^\s*$' ){
        Write-Host "Exposing $port_opt on container"
    }
    $domains_opt_arg = ""
    if ( $domains_opt -ne $null ){
        $domains_opt_arg = "--domain " + ($domains_opt -join ",")
    }
    $nameservers_opt_arg = ""
    if ( $nameservers_opt -ne $null ){
        $nameservers_opt_arg = "--nameservers " + ($nameservers_opt -join ",")
    }
    $cmd = "docker run --label dev_env --rm -it $port_arg $mount_arg miversen33/dev_env:latest $domains_opt_arg $nameservers_opt_arg"
    Write-Host $cmd
    Invoke-Expression $cmd
}