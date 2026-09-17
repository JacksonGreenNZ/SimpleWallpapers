$dataFolder = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) "WallpaperRotator"
New-Item -ItemType Directory -Path $dataFolder -Force | Out-Null

Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class WallpaperModeApi
{
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool SystemParametersInfo(
        uint action,
        uint parameter,
        string imagePath,
        uint updateProfile);
}
'@

$modeFile = Join-Path $dataFolder "display-mode.txt"
$modes = @(
    [PSCustomObject]@{ Name = "Fill"; Style = "10"; Tile = "0" }
    [PSCustomObject]@{ Name = "Fit"; Style = "6"; Tile = "0" }
    [PSCustomObject]@{ Name = "Stretch"; Style = "2"; Tile = "0" }
    [PSCustomObject]@{ Name = "Tile"; Style = "0"; Tile = "1" }
    [PSCustomObject]@{ Name = "Centre"; Style = "0"; Tile = "0" }
)

$currentMode = if (Test-Path $modeFile) {
    Get-Content $modeFile -Raw
}
else {
    "Fill"
}

$currentIndex = 0
for ($index = 0; $index -lt $modes.Count; $index++) {
    if ($modes[$index].Name -eq $currentMode.Trim()) {
        $currentIndex = $index
        break
    }
}

$nextMode = $modes[($currentIndex + 1) % $modes.Count]

Set-ItemProperty `
    -Path "HKCU:\Control Panel\Desktop" `
    -Name WallpaperStyle `
    -Value $nextMode.Style

Set-ItemProperty `
    -Path "HKCU:\Control Panel\Desktop" `
    -Name TileWallpaper `
    -Value $nextMode.Tile

$currentWallpaper = (Get-ItemProperty -Path "HKCU:\Control Panel\Desktop").WallPaper
if (-not [WallpaperModeApi]::SystemParametersInfo(20, 0, $currentWallpaper, 3)) {
    throw "Windows could not apply wallpaper mode: $([ComponentModel.Win32Exception]::new([Runtime.InteropServices.Marshal]::GetLastWin32Error()).Message)"
}

Set-Content -Path $modeFile -Value $nextMode.Name -Encoding utf8
Write-Output "Wallpaper mode: $($nextMode.Name)"
