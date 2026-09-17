Add-Type -AssemblyName System.Windows.Forms

Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class WallpaperApi
{
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool SystemParametersInfo(
        uint action,
        uint parameter,
        string imagePath,
        uint updateProfile);
}
'@

$DataFolder = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) "WallpaperRotator"
New-Item -ItemType Directory -Path $DataFolder -Force | Out-Null

$LogFile = Join-Path $DataFolder "wallpaper.log"
$PauseFile = Join-Path $DataFolder "paused.txt"

function Write-Log {
    param([string]$Message)

    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" |
        Out-File -FilePath $LogFile -Append -Encoding utf8
}

Write-Log "========================================"
Write-Log "Script started"

try {

    if (Test-Path $PauseFile) {
        Write-Log "Wallpaper rotation is paused"
        exit 0
    }

    $wallpaperRoot = Join-Path $HOME "Pictures\Wallpapers"

    Write-Log "Wallpaper root: $wallpaperRoot"

    $hasUltraWide = $false

    foreach ($screen in [System.Windows.Forms.Screen]::AllScreens) {

        $width = $screen.Bounds.Width
        $height = $screen.Bounds.Height

        $ratio = $width / $height

        Write-Log "Monitor: ${width}x${height} Ratio=$ratio"

        if ($ratio -ge 2.2) {
            $hasUltraWide = $true
        }
    }

    if ($hasUltraWide) {
        $folder = Join-Path $wallpaperRoot "Ultrawide"
        $folderName = "Ultrawide"
        Write-Log "Using Ultrawide folder"
    }
    else {
        $folder = Join-Path $wallpaperRoot "Standard"
        $folderName = "Standard"
        Write-Log "Using Standard folder"
    }

    if (-not (Test-Path $folder)) {
        throw "Folder not found: $folder"
    }

    $images = Get-ChildItem $folder -File |
        Where-Object {
            $_.Extension -match '^\.(jpg|jpeg|png)$'
        }

    if ($images.Count -eq 0) {
        throw "No wallpapers found in $folder"
    }

    $historyFile = Join-Path $DataFolder ".wallpaper-history-$folderName.txt"
    $legacyHistoryFile = Join-Path $wallpaperRoot ".wallpaper-history-$folderName.txt"
    $history = @()

    if (Test-Path $historyFile) {
        $history = @(Get-Content $historyFile | Where-Object { $_ })
    }
    elseif (Test-Path $legacyHistoryFile) {
        $history = @(Get-Content $legacyHistoryFile | Where-Object { $_ })
        Write-Log "Loaded legacy history from $legacyHistoryFile"
    }

    $availableImages = @(
        $images | Where-Object {
            $history -notcontains $_.FullName
        }
    )

    if ($availableImages.Count -eq 0) {
        $history = @()
        $availableImages = @($images)
        Write-Log "All wallpapers used; starting a new $folderName cycle"
    }

    $wallpaper = $availableImages | Get-Random

    Write-Log "Selected: $($wallpaper.FullName)"

    # Fill style
    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Desktop" `
        -Name WallpaperStyle `
        -Value "10"

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Desktop" `
        -Name TileWallpaper `
        -Value "0"

    # Update wallpaper path
    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Desktop" `
        -Name WallPaper `
        -Value $wallpaper.FullName

    Write-Log "Registry updated"

    if (-not [WallpaperApi]::SystemParametersInfo(20, 0, $wallpaper.FullName, 3)) {
        throw "Windows could not apply wallpaper: $([ComponentModel.Win32Exception]::new([Runtime.InteropServices.Marshal]::GetLastWin32Error()).Message)"
    }

    Write-Log "Wallpaper refresh completed"

    @($history + $wallpaper.FullName) |
        Set-Content -Path $historyFile -Encoding utf8

    Write-Log "Selection history updated"
    Write-Log "SUCCESS"
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}