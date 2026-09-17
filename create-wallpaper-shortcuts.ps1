$userProfile = [Environment]::GetFolderPath('UserProfile')
$desktop = [Environment]::GetFolderPath('Desktop')
$wallpaperFolder = Join-Path $userProfile 'Pictures\Wallpapers'
$powerShell = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$hiddenLauncher = Join-Path $wallpaperFolder 'run-wallpaper-hidden.vbs'

$shortcuts = @(
    [PSCustomObject]@{
        Name = 'Next Wallpaper'
        Script = Join-Path $wallpaperFolder 'wallpapers.ps1'
        Hidden = $true
        Icon = "$env:WINDIR\System32\imageres.dll,229"
        Description = 'Apply the next unused wallpaper'
    }
    [PSCustomObject]@{
        Name = 'Wallpaper Status'
        Script = Join-Path $wallpaperFolder 'wallpaper-status.ps1'
        Hidden = $false
        Icon = "$env:WINDIR\System32\imageres.dll,144"
        Description = 'Show wallpaper and rotation status'
    }
    [PSCustomObject]@{
        Name = 'Cycle Wallpaper Mode'
        Script = Join-Path $wallpaperFolder 'cycle-wallpaper-mode.ps1'
        Hidden = $true
        Icon = "$env:WINDIR\System32\imageres.dll,145"
        Description = 'Cycle the wallpaper display mode'
    }
    [PSCustomObject]@{
        Name = 'Clear Wallpaper History'
        Script = Join-Path $wallpaperFolder 'clear-wallpaper-history.ps1'
        Hidden = $true
        Icon = "$env:WINDIR\System32\imageres.dll,242"
        Description = 'Clear wallpaper selection history'
    }
    [PSCustomObject]@{
        Name = 'Pause-Resume Wallpapers'
        Script = Join-Path $wallpaperFolder 'pause-wallpapers.ps1'
        Hidden = $true
        Icon = "$env:WINDIR\System32\imageres.dll,282"
        Description = 'Pause or resume wallpaper rotation'
    }
)

$shell = New-Object -ComObject WScript.Shell
foreach ($item in $shortcuts) {
    $shortcutPath = Join-Path $desktop "$($item.Name).lnk"
    $shortcut = $shell.CreateShortcut($shortcutPath)
    if ($item.Hidden) {
        $shortcut.TargetPath = "$env:WINDIR\System32\wscript.exe"
        $shortcut.Arguments = "`"$hiddenLauncher`" `"$($item.Script)`""
    }
    else {
        $shortcut.TargetPath = $powerShell
        $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($item.Script)`""
    }
    $shortcut.WorkingDirectory = $wallpaperFolder
    $shortcut.IconLocation = $item.Icon
    $shortcut.Description = $item.Description
    $shortcut.Save()
}

Write-Output "Created wallpaper shortcuts on $desktop"
