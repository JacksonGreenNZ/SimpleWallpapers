$dataFolder = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) "WallpaperRotator"
$pauseFile = Join-Path $dataFolder "paused.txt"

New-Item -ItemType Directory -Path $dataFolder -Force | Out-Null

if (Test-Path $pauseFile) {
    Remove-Item -Path $pauseFile
    Write-Output "Wallpaper rotation resumed."
    & (Join-Path $PSScriptRoot "wallpapers.ps1")
}
else {
    "Paused at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" |
        Set-Content -Path $pauseFile -Encoding utf8
    Write-Output "Wallpaper rotation paused."
}
