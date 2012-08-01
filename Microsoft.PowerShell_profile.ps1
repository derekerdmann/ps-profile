﻿# Modified version of posh-git profile loader, since I'm using Pageant for SSH-Agent
Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
Import-Module posh-git
Import-Module posh-hg

Pop-Location

# Used as a grep replacement
Import-Module find-string

# Allows installing more modules easily
Import-Module PsGet

# It's like wget
Import-Module PsUrl



function prompt { 

    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    $cdrive = [ConsoleColor]::DarkCyan 
    $chost = [ConsoleColor]::Green 
    $cloc = [ConsoleColor]::White 

    write-host (get-drive (pwd).Path) -n -f $cdrive
    write-host (shorten-path (pwd).Path) -n -f $cloc 

    Write-VcsStatus

    $LASTEXITCODE = $realLASTEXITCODE

    return '> ' 
} 

# Utility for prompt()
function get-drive( [string] $path ) {
    if( $path.StartsWith( $HOME ) ) {
        return "~"
    } else {
        return $path.split( "\" )[0]
    }
}

function shorten-path([string] $path) { 
    $loc = $path.Replace($HOME, '~') 

    # remove prefix for UNC paths 
    $loc = $loc -replace '^[^:]+::', '' 

    $drive = get-drive (pwd).Path
    $loc = $loc.TrimStart( $drive )

    # make path shorter like tabs in Vim, 
    # handle paths starting with \\ and . correctly 
    return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2') 
}

# Load posh-git example profile
#. 'K:\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

# Fix "not fully-functional" warning in Git. May break HG color?
$env:TERM="msys"
