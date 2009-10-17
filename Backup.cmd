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