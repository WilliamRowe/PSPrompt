function prompt {
    <#
    .SYNOPSIS
        Override the default prompt function
    .DESCRIPTION
        This function is called every time the console prompt is displayed
    
    .EXAMPLE
      000000.10 Sec : 0000104.9 ms : 000104921 μs
      [10:54:58] will@myComputer:.\Repos\ > 
    #>

    # Gather if current user is an admin, adjust prompt color accordingly.
    $isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin){
        $cColor = 'Red'; $uColor = 'DarkRed'; $aColor = 'DarkYellow'
    } else {
        $cColor = 'Green'; $uColor = 'DarkGreen'; $aColor = 'DarkMagenta'
    }

    # Get the current location, format the path, and adjust color based on path, local or remote.
    $currentLocation = $(get-location)
    $lColor = 'darkGray'
    switch ($currentLocation) {
        {$_.path.startswith('Microsoft.PowerShell.Core\FileSystem::')} { # remote filesystem
            $location = $_.path.replace('Microsoft.PowerShell.Core\FileSystem::', '')
            $lColor = 'Yellow'
            break
        };
        default { $location = $currentLocation };
    }
    $currentDir = Split-Path -Path $location -Leaf

    # Define nested prompt indicator, e.g. when using wait-debugger 
    $nestedPromptIndicator = '>' * ($NestedPromptLevel + 1)

    # Calculate the runtime of the last command
    $lastCommand = Get-History -Count 1
    [TimeSpan]$runtime = 0
    if ($lastCommand) { [TimeSpan]$runtime = $lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime }

    #
    #  Display Prompt
    #
    # Set the console title to the current location
    $Host.UI.RawUI.WindowTitle = $location

    # New line
    Write-Host ""
    
    # Show last command runtimes
    if ($runtime.Hours -gt 0)
    {
        Write-Host "$("{0:00.0000000} Hr" -f $runtime.TotalHours)" -ForegroundColor DarkRed -NoNewline
        Write-Host " : " -ForegroundColor Gray -NoNewline
        Write-Host "$("{0:00.000000} Min" -f $runtime.TotalMinutes)" -ForegroundColor DarkYellow -NoNewline
        Write-Host " : " -ForegroundColor Gray -NoNewline
        Write-Host "$("{0:000000.00} Sec" -f $runtime.TotalSeconds) " -ForegroundColor DarkBlue
    }
    elseif ($runtime.Minutes -gt 0)
    {
        Write-Host "$("{0:00.000000} Min" -f $runtime.TotalMinutes)" -ForegroundColor DarkYellow -NoNewline
        Write-Host " : " -ForegroundColor Gray -NoNewline
        Write-Host "$("{0:000000.00} Sec" -f $runtime.TotalSeconds)" -ForegroundColor DarkBlue -NoNewline
        Write-Host " : " -ForegroundColor Gray -NoNewline
        Write-Host "$("{0:0000000.0} ms" -f $runtime.TotalMilliseconds) " -ForegroundColor DarkGray
    }
    else
    {
        Write-Host "$("{0:000000.00} Sec" -f $runtime.TotalSeconds)" -ForegroundColor DarkBlue -NoNewline
        Write-Host " : " -ForegroundColor Gray -NoNewline
        Write-Host "$("{0:0000000.0} ms" -f $runtime.TotalMilliseconds)" -ForegroundColor DarkGray -NoNewline
        Write-Host " : " -ForegroundColor Gray -NoNewline
        Write-Host "$("{0:000000000} μs" -f $runtime.TotalMicroseconds) " -ForegroundColor Black
    }

    # Display main prompt with colors = ' username@computername : current directory >'
    Write-Host "[$(get-date -f 'HH:mm:ss')] " -ForegroundColor $aColor -NoNewline
    Write-Host "$($env:USERNAME.ToLower())" -ForegroundColor $uColor -NoNewLine
    Write-Host "@" -ForegroundColor $aColor -NoNewLine
    Write-Host "$($env:COMPUTERNAME.ToLower())" -ForegroundColor $cColor -NoNewLine
    Write-Host ":" -ForegroundColor White -NoNewline

    # Handle location display when at drive root or nested directory
    if ($currentDir -like "*:*") {
        Write-Host " $currentDir" -ForegroundColor $lColor -NoNewLine
    } else {
        Write-Host ".\$currentDir\" -ForegroundColor $lColor -NoNewLine
    }
    Write-Host " $nestedPromptIndicator" -ForegroundColor $aColor -NoNewLine

    return " "
}
