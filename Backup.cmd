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
