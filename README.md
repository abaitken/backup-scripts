# Backup Scripts

## Original Blog post: Using 7-zip and batch files to perform backups automatically

First, a little history:

Since the days when I started using XP I had gotten used to the control that NT Backup provided to allow me to backup my files.

About a year ago I moved to Vista and was unhappy with the “All or nothing” approach that the bundled backup software provided. I was also using OneCare at the time and it followed a similar policy.

Since moving to BitDefender I was much happier with the backup software it provided yet the fact that I was not using a well known backup format rubbed me.

So, using this article: http://www.wilshireone.com/article/115/easy-backups-with-7-zip as a guide, I engineered my own backup mechnism using 7-zip.

Now heres the fun. My backup schedule consists of a weekly incremental backup and one monthly full backup. My files are not so important that I need frequent backups, this schedule suits me down to the ground.

My solution consists of 7 parts:

 - **Backup.cmd**, this is the main script that executes the command
 - **Backupset.txt**, a list of files and folders that I wish to backup
 - **CurrentSet.txt**, a path to the current backup file. Used by incremental backups to update
 - **FullBackup.cmd**, the script to run a full backup
 - **FullBackupSettings.ini**, the settings used by a full backup
 - **IncrementalBackup.cmd**, the script to run an incremental backup
 - **IncrementalBackupSettings.ini**, the settings used by the incremental backup

Now you could remove the separate scripts for the full and incremental backup, the reason I created separate scripts was that I don”t have to change the arguments in the task scheduler. Instead it is all controlled through those scripts.

**Backup.cmd**

    @echo off

    echo TRACE: Start

    IF EXIST %1 GOTO Begin

    echo Settings file does not exist
    GOTO End

    :Begin

    echo TRACE: Read settings
    for /f "eol=# tokens=1,2 delims==" %%i in (%1) do SET %%i=%%j

    IF "%varBackupType%"=="full" GOTO CreateNewSet

    echo TRACE: Load existing set
    for /F %%i in (CurrentSet.txt) do set varTargetBackupSet=%%i

    IF EXIST "%varTargetBackupSet%" GOTO Execute

    echo Backup set does not exist!
    GOTO End

    :CreateNewSet
    echo TRACE: Create new set

    set varTargetBackupSet=%varBackupLocation%\%DATE:~-4%-%DATE:~3,2%-%DATE:~0,2%-%TIME:~0,2%-%TIME:~3,2%-backup.%varFormat%
    echo %varTargetBackupSet% &gt; CurrentSet.txt

    :Execute
    echo TRACE: Execute backup
    "%var7zipPath%\7z" %varMode% -t%varFormat% "%varTargetBackupSet%" @"%varFileList%"

    :End
    echo TRACE: Finished
    pause

The backup script loads the settings passed as argument 1, does some checking, then calls 7-zip to begin backing up. The settings files define how the files are added and where to etc.

**BackupSet.txt**

    D:\Guild Wars\Screens
    D:\Logaan\Documents
    D:\Logaan\Favorites
    C:\Users\Logaan\Desktop
    D:\Logaan\Saved Games
    C:\Users\Logaan\AppData\Local\2DBoy
    C:\Users\Logaan\AppData\Local\Ascaron Entertainment
    C:\Users\Logaan\AppData\Local\id Software
    C:\Users\Logaan\AppData\Local\Ironclad Games
    C:\Users\Logaan\AppData\Local\Rockstar Games
    C:\Users\Logaan\AppData\Roaming\EditPlus 3
    C:\Users\Logaan\AppData\Roaming\FileZilla
    C:\Users\Logaan\AppData\Roaming\Free Download Manager
    C:\Users\Logaan\AppData\Roaming\Xfire

This is the list file passed to 7-zip. The only downside is that you cannot list the same folder or file name twice in this file. The work around would be to invoke multiple backup scripts and then add the duplicate folders and nested zips.

**CurrentSet.txt**

    D:\2009-04-05-17-16-backup.zip

This contains the backup file created in the last full backup. Incremental backups then read it in and use it to update files.

**FullBackup.cmd**

    @echo off
    Backup D:\Logaan\Documents\Tools\7ZipBackup\FullBackupSettings.ini

Simples, it just calls the main backup script with the correct settings.

**FullBackupSettings.ini**

    # File path to the 7-zip executables
    var7zipPath=C:\Program Files\7-Zip

    # Backup format
    varFormat=zip

    # Target location for the backup
    varBackupLocation=D:

    # List file
    varFileList=D:\Logaan\Documents\Tools\7ZipBackup\BackupSet.txt

    # Mode
    varMode=a

    # Type
    varBackupType=full

The settings file is read in and used in the main backup script. Note the mode and backup type, this is what separates the two types of backup.

**IncrementalBackup.cmd**

    @echo off
    Backup D:\Logaan\Documents\Tools\7ZipBackup\IncrementalBackupSettings.ini

Similar to the full version, except its providing the increment backup settings

**IncrementalBackupSettings.ini**

    # File path to the 7-zip executables
    var7zipPath=C:\Program Files\7-Zip

    # Backup format
    varFormat=zip

    # Target location for the backup
    varBackupLocation=D:

    # List file
    varFileList=D:\Logaan\Documents\Tools\7ZipBackup\BackupSet.txt

    # Mode
    varMode=u

    # Type
    varBackupType=incremental

Similar to the full settings, but with the zip mode set to update and its backup type defined as incremental.

Once that has all been put in place, all I do is create two tasks in the windows task scheduler.

You could go one step further and have the script copy the backups to another disk, I just do this myself when I feel like.


**Update**

After a little testing I found a flaw in the technique that I was using. Essentially what is happening is that new files are being added to the old archive and any deleted files were being left. I want to keep any files that I deleted but I do not want them muddying up the actual latest image.

Instead, what I did was use the -u switch to stop updates to the base archive being made and adding new files to a new archive, which makes it incremental in its true sense.

**Backup.cmd**

    @echo off

    echo TRACE: Start

    IF EXIST %1 GOTO Begin

    echo Settings file does not exist
    GOTO End

    :Begin

    echo TRACE: Read settings
    for /f "eol=# tokens=1,2 delims==" %%i in (%1) do SET %%i=%%j

    set varNewBackupSet=%varBackupLocation%\%DATE:~-4%-%DATE:~3,2%-%DATE:~0,2%-%TIME:~0,2%-%TIME:~3,2%-backup.%varFormat%

    IF "%varBackupType%"=="full" GOTO CreateNewSet

    echo TRACE: Load existing set
    for /F %%i in (CurrentSet.txt) do set varOldBackupSet=%%i

    IF EXIST "%varOldBackupSet%" GOTO ExecuteIncremental

    echo Backup set does not exist!
    GOTO End

    :CreateNewSet
    echo TRACE: Create new set
    echo %varNewBackupSet% > CurrentSet.txt

    :ExecuteFull
    echo TRACE: Execute Full backup
    "%var7zipPath%\7z" a -t%varFormat% "%varNewBackupSet%" @"%varFileList%"
    GOTO End

    :ExecuteIncremental
    echo TRACE: Execute Incremental backup
    "%var7zipPath%\7z" u -u- -u!"%varNewBackupSet%" -t%varFormat% "%varOldBackupSet%" @"%varFileList%"

    :End
    echo TRACE: Finished
    pause

In fact, I have gone one step further and I have built a command line tool that wraps 7-zip and provides a nicer mechanism for configuring the backups. It then executes 7-zip. Once I have tested it a little I will post the source code.