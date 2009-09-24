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