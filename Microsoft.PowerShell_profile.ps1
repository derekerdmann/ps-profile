# Modified version of posh-git profile loader, since I'm using Pageant for SSH-Agent
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

    $drive = (get-drive (pwd).Path)
    write-host $drive -n -f $cdrive
    write-host (shorten-path (pwd).Path) -n -f $cloc 

    Write-VcsStatus

    $LASTEXITCODE = $realLASTEXITCODE

    return '> ' 
} 

# Utility for prompt()
function get-drive( [string] $path ) {
    if( $path.StartsWith( $HOME ) ) {
        return "~"
    } elseif( $path.StartsWith( "Microsoft.PowerShell.Core" ) ){
        return "\\"
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

# Fix "not fully-functional" warning in Git. May break HG color?
$env:TERM="msys"

# function for md5 hashes
# doesn't work with relative paths; TODO: fix
function md5sum($file)
{
    try
    {
        $md5 = [System.Security.Cryptography.MD5]::Create()
        $file = [System.IO.File]::OpenRead($file)
        $hash = $md5.ComputeHash($file);
        [System.BitConverter]::ToString($hash).Replace('-', '')
    }
    finally
    {
        if ($md5) { $md5.dispose() }
    }
}
