========================================================================
                         WALLPAPER ROTATOR
========================================================================

This folder contains a small PowerShell wallpaper rotator for Windows.

It chooses a wallpaper from either the Standard or Ultrawide folder,
depending on the monitor layout, and changes the wallpaper every hour.

The script remembers which files it has already used, so it will not
repeat a wallpaper until the current folder has been used completely.


========================================================================
1. FOLDER SETUP
========================================================================

Keep this folder in the following location:

    %USERPROFILE%\Pictures\Wallpapers

The folder should contain:

    wallpapers.ps1
    run-wallpaper-hidden.vbs
    install-wallpaper-rotator.ps1
    create-wallpaper-shortcuts.ps1
    clear-wallpaper-history.ps1
    cycle-wallpaper-mode.ps1
    pause-wallpapers.ps1
    wallpaper-status.ps1

Put normal monitor wallpapers in:

    Standard

Put ultrawide monitor wallpapers in:

    Ultrawide

The following image types are supported:

    .jpg   .jpeg   .png


========================================================================
2. CREATE THE HOURLY TASK
========================================================================

The easiest setup method is to open PowerShell in this folder and run:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-wallpaper-rotator.ps1

This creates the desktop shortcuts, applies the first wallpaper, and
creates or updates the "Set Wallpaper on Startup" task for the current
user. It uses Windows PowerShell and Task Scheduler already included
with Windows; it does not install an application or require
administrator access.

If PowerShell or user-created scheduled tasks are restricted by your
organisation, use the manual Task Scheduler setup below or ask IT to
approve the scripts and task.

MANUAL TASK SCHEDULER SETUP

The task runs once when you sign in and then once every hour.

  1. Press the Windows key.
  2. Type "Task Scheduler".
  3. Open Task Scheduler.
  4. Select "Create Task..." in the right-hand Actions panel.
  5. On the General tab:

       Name:
           Set Wallpaper on Startup

       Select:
           Run only when user is logged on

  6. On the Triggers tab, click "New...":

       Begin the task:
           At log on

       Specific user:
           Your Windows user account

       Click OK.

  7. Add a second trigger by clicking "New..." again:

       Begin the task:
           On a schedule

       Settings:
           Daily

       Start:
           Choose a time, such as 9:00 AM

       Select:
           Repeat task every: 1 hour
           For a duration of: Indefinitely

       Select:
           Enabled

       Click OK.

  8. On the Actions tab, click "New...".

       Action:
           Start a program

       Program/script:
           wscript.exe

       Add arguments:
           "%USERPROFILE%\Pictures\Wallpapers\run-wallpaper-hidden.vbs"

       Start in:
           %USERPROFILE%\Pictures\Wallpapers

       Click OK.

  9. On the Conditions tab:

       Make sure the task is not restricted to AC power unless that is
       what you want.

 10. On the Settings tab, enable:

       Run task as soon as possible after a scheduled start is missed

 11. Click OK to save the task.


========================================================================
3. TEST THE TASK
========================================================================

In Task Scheduler:

  1. Find "Set Wallpaper on Startup".
  2. Right-click it.
  3. Select "Run".

The desktop should change and the script should finish within a few
seconds.


========================================================================
4. CREATE DESKTOP SHORTCUTS
========================================================================

The shortcut creator makes these desktop shortcuts:

    Next Wallpaper
        Immediately applies the next unused wallpaper.

    Wallpaper Status
        Shows the current wallpaper, display mode, monitor selection,
        image count, and remaining images in the current cycle.

    Cycle Wallpaper Mode
        Keeps the current wallpaper and cycles through:
        Fill, Fit, Stretch, Tile, and Centre.

    Clear Wallpaper History
        Clears the Standard and Ultrawide selection history.

    Pause-Resume Wallpapers
        Toggles scheduled wallpaper rotation without changing Task Scheduler.
        Resuming immediately applies the next unused wallpaper.

To create or update the shortcuts:

  1. Open this folder in File Explorer.
  2. Right-click:

         create-wallpaper-shortcuts.ps1

  3. Select:

         Run with PowerShell

The shortcuts will be created on your desktop. They use built-in
Windows icons and do not require any extra software.

Pause and resume do not modify the Task Scheduler task. While paused,
scheduled runs exit without changing the wallpaper.


========================================================================
5. RESET THE WALLPAPER CYCLE
========================================================================

If you want a wallpaper to become available again immediately:

  1. Double-click the desktop shortcut:

         Clear Wallpaper History

Or right-click and run:

         clear-wallpaper-history.ps1


========================================================================
6. LOGS AND SAVED SETTINGS
========================================================================

The rotator stores its files here:

    %LOCALAPPDATA%\WallpaperRotator

Files in that folder include:

    wallpaper.log
        Records each run and any errors.

    .wallpaper-history-Standard.txt
        Tracks wallpapers used on standard layouts.

    .wallpaper-history-Ultrawide.txt
        Tracks wallpapers used on ultrawide layouts.

    display-mode.txt
        Stores the current display mode.

    paused.txt
        Indicates that scheduled wallpaper rotation is paused.


========================================================================
7. TROUBLESHOOTING
========================================================================

The wallpaper does not change:

  * Run "Next Wallpaper" from the desktop.
  * Check that the Standard or Ultrawide folder contains images.
  * Open:

        %LOCALAPPDATA%\WallpaperRotator\wallpaper.log

  * In Task Scheduler, check the task's Last Run Result.
  * Confirm that the task action points to wallpapers.ps1.

The task does not run every hour:

  * Make sure the hourly trigger is a separate "On a schedule" trigger.
  * Confirm that it says "Repeat task every: 1 hour".
  * Confirm that the duration is "Indefinitely".
  * Make sure the task is Enabled.

The script reports an error:

  * Read wallpaper.log for the exact error.
  * Confirm that this folder has not been moved.
  * Confirm that PowerShell can access the wallpaper folders.


========================================================================
                              END
========================================================================
