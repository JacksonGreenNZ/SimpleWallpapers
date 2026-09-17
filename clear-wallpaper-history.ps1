$userProfile = [Environment]::GetFolderPath('UserProfile')
$dataFolder = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) "WallpaperRotator"
$wallpaperFolder = Join-Path $userProfile "Pictures\Wallpapers"

$historyFiles = @(
    (Join-Path $dataFolder ".wallpaper-history-Standard.txt")
    (Join-Path $dataFolder ".wallpaper-history-Ultrawide.txt")
    (Join-Path $wallpaperFolder ".wallpaper-history-Standard.txt")
    (Join-Path $wallpaperFolder ".wallpaper-history-Ultrawide.txt")
)

$clearedFiles = 0
foreach ($historyFile in $historyFiles) {
    if (Test-Path $historyFile) {
        Remove-Item -LiteralPath $historyFile -Force -ErrorAction Stop
        $clearedFiles++
    }
}

Write-Output "Cleared $clearedFiles wallpaper history file(s)."
