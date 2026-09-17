[CmdletBinding()]
param(
    [switch]$SkipInitialRun
)

$ErrorActionPreference = 'Stop'

$wallpaperRoot = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Pictures\Wallpapers'
$sourceRoot = (Resolve-Path $PSScriptRoot).Path
$expectedRoot = [IO.Path]::GetFullPath($wallpaperRoot).TrimEnd('\')
$resolvedSourceRoot = [IO.Path]::GetFullPath($sourceRoot).TrimEnd('\')
$taskName = 'Set Wallpaper on Startup'
$launcher = Join-Path $wallpaperRoot 'run-wallpaper-hidden.vbs'
$rotator = Join-Path $wallpaperRoot 'wallpapers.ps1'

if ($resolvedSourceRoot -ine $expectedRoot) {
    throw "Extract this release to $wallpaperRoot before running the installer."
}

foreach ($requiredFile in @(
    $rotator,
    $launcher,
    (Join-Path $wallpaperRoot 'create-wallpaper-shortcuts.ps1'),
    (Join-Path $wallpaperRoot 'Standard'),
    (Join-Path $wallpaperRoot 'Ultrawide')
)) {
    if (-not (Test-Path -LiteralPath $requiredFile)) {
        throw "Required release file or folder was not found: $requiredFile"
    }
}

if (-not (Get-Command Register-ScheduledTask -ErrorAction SilentlyContinue)) {
    throw 'The ScheduledTasks PowerShell module is not available on this computer.'
}

Get-ChildItem -LiteralPath $wallpaperRoot -File |
    Where-Object { $_.Extension -in @('.ps1', '.vbs') } |
    Unblock-File

& (Join-Path $wallpaperRoot 'create-wallpaper-shortcuts.ps1')

$powerShell = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$action = New-ScheduledTaskAction `
    -Execute (Join-Path $env:WINDIR 'System32\wscript.exe') `
    -Argument ('"{0}"' -f $launcher) `
    -WorkingDirectory $wallpaperRoot

$logonTrigger = New-ScheduledTaskTrigger -AtLogOn
$hourlyTrigger = New-ScheduledTaskTrigger `
    -Once `
    -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Hours 1) `
    -RepetitionDuration ([TimeSpan]::MaxValue)

$principal = New-ScheduledTaskPrincipal `
    -UserId "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType Interactive `
    -RunLevel Limited

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger @($logonTrigger, $hourlyTrigger) `
    -Principal $principal `
    -Settings $settings `
    -Description 'Changes the Windows wallpaper at logon and every hour.'

if (-not $SkipInitialRun) {
    & $powerShell -NoProfile -ExecutionPolicy Bypass -File $rotator
}

Write-Output "Wallpaper Rotator installed for $env:USERDOMAIN\$env:USERNAME."
Write-Output "Task: $taskName"
Write-Output "Location: $wallpaperRoot"
