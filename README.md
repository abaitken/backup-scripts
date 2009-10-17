# Backup Scripts

For the original version see the v1 tag.

## Original Blog post: Simpler version of the 7-Zip backup

I have tested the 7-Zip backup I had constructured that I posted about a while back and I have come to realise that it is a tad bit too complicated. I even went through the process of creating a proxy application to try and get it to be a bit more cleverer but in the end I simplified it down to just 4 parts; the logic, settings and file lists.

**Backup.cmd**

    @ECHO OFF

    ECHO 7-Zip backup script
    ECHO Written by Alex Boyne-Aitken
    ECHO Last update: 07/11/2009
    ECHO.

    ECHO TRACE: Parse arguments: ''%~f1''
    IF EXIST %~f1 GOTO labelBegin

    ECHO.
    ECHO ERROR: Settings file not found!
    GOTO labelWaitEnd

    :labelBegin

    ECHO.
    ECHO TRACE: Reading settings
    FOR /F "eol=# tokens=1,2 delims==" %%i IN (%~f1) DO (
    SET %%i=%%j
    ECHO TRACE: %%i = ''%%j''
    )

    SET varTimeStamp=%DATE:~-4%-%DATE:~3,2%-%DATE:~0,2%-%TIME:~0,2%-%TIME:~3,2%
    SET varTargetBackupSet=%varBackupPath%\%varTimeStamp%-backup.zip

    ECHO.
    ECHO TRACE: Backup set: ''%varTargetBackupSet%''
    ECHO TRACE: Command line: ''"%varPathToSevenZip%\7z" a -t%varArchiveType% "%varTargetBackupSet%" @"%varInclusionsFile%" -xr@"%varExclusionsFile%"''

    ECHO.
    ECHO TRACE: Executing backup
    ::"%varPathToSevenZip%\7z" a -t%varArchiveType% "%varTargetBackupSet%" @"%varInclusionsFile%" -xr@"%varExclusionsFile%"

    IF /I NOT "%varWaitAtEnd%" == "true" GOTO labelEnd

    :labelWaitEnd
    PAUSE
    :labelEnd

**Settings.txt**

    # The path to the where the 7z.exe executable is
    varPathToSevenZip=C:\Program Files\7-Zip

    # The path where to store the backup sets
    varBackupPath=D:\Backups

    # The file path to the inclusions file
    varInclusionsFile=D:\Logaan\Documents\Tools\7ZipBackup\Settings\Inclusions.txt

    # The file path to the exclusions file
    varExclusionsFile=D:\Logaan\Documents\Tools\7ZipBackup\Settings\Exclusions.txt

    # Whether to wait at the end of the backup
    varWaitAtEnd=true

    # Type of backup archive to create
    varArchiveType=zip

**Exclusions.txt**

    *.svn

**Inclusions.txt**

    D:\Logaan\Documents
    D:\Logaan\Favorites
    C:\Users\Logaan\Desktop
    D:\Logaan\Saved Games

**How to use it**

Place the batch file and settings files in a folder somewhere.

Update the setttings file with the correct paths.

Pass the path to the settings file to the backup batch file.

    C:> backup D:\Logaan\Documents\Backup\settings.txt

Or create a scheduled task.
