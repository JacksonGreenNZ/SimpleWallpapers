Add-Type -AssemblyName System.Windows.Forms

$dataFolder = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) "WallpaperRotator"
$wallpaperRoot = Join-Path ([Environment]::GetFolderPath('UserProfile')) "Pictures\Wallpapers"
$modeFile = Join-Path $dataFolder "display-mode.txt"
$pauseFile = Join-Path $dataFolder "paused.txt"

$wallpaperSettings = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop"
$currentWallpaper = $wallpaperSettings.WallPaper
$displayMode = if (Test-Path $modeFile) {
    (Get-Content $modeFile -Raw).Trim()
}
else {
    "Unknown"
}
$rotationStatus = if (Test-Path $pauseFile) { "Paused" } else { "Running" }

$hasUltraWide = $false
foreach ($screen in [System.Windows.Forms.Screen]::AllScreens) {
    $ratio = $screen.Bounds.Width / $screen.Bounds.Height
    if ($ratio -ge 2.2) {
        $hasUltraWide = $true
    }
}

$folderName = if ($hasUltraWide) { "Ultrawide" } else { "Standard" }
$folder = Join-Path $wallpaperRoot $folderName
$historyFile = Join-Path $dataFolder ".wallpaper-history-$folderName.txt"
$images = @(
    Get-ChildItem $folder -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -match '^\.(jpg|jpeg|png)$' }
)
$history = if (Test-Path $historyFile) {
    @(Get-Content $historyFile | Where-Object { $_ })
}
else {
    @()
}
$remaining = @(
    $images | Where-Object { $history -notcontains $_.FullName }
)

Write-Output "Wallpaper status"
Write-Output "----------------"
Write-Output "Current wallpaper: $currentWallpaper"
Write-Output "Display mode:      $displayMode"
Write-Output "Rotation status:   $rotationStatus"
Write-Output "Monitor selection: $folderName"
Write-Output "Wallpaper folder:  $folder"
Write-Output "Images in folder:  $($images.Count)"
Write-Output "Unused this cycle: $($remaining.Count)"
Write-Output "History file:      $historyFile"
Write-Output ""
Read-Host "Press Enter to close"
