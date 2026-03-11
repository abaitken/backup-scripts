@echo off
goto :main

:fn_parseline
set "LINE=%1"
echo LINE=[%LINE%]
    
if "%LINE%"=="" goto :eof
if "%LINE:~0,1%"=="#" goto :eof
if "%LINE:~1,1%" NEQ "%DRIVE%" goto :eof

if "%LINE:~0,1%"=="-" echo %LINE:~1%>>"%EXCLUDE%"
if "%LINE:~0,1%"=="+" echo %LINE:~1%>>"%INCLUDE%"

goto :eof

:fn_backup
SET DRIVE=%1
SET DEST=%2

echo Backing up %DRIVE% to %DEST% ...

set "INCLUDE=tmp_include_list.txt"
set "EXCLUDE=tmp_exclude_list.txt"

if exist "%INCLUDE%" del "%INCLUDE%"
if exist "%EXCLUDE%" del "%EXCLUDE%"

for /f "usebackq delims=" %%A in ("sync-filelist.txt") do call :fn_parseline %%A

if not exist "%INCLUDE%" echo.> "%INCLUDE%"
if not exist "%EXCLUDE%" echo.> "%EXCLUDE%"

echo Include for %DRIVE%:
type "%INCLUDE%"
echo Exclude for %DRIVE%:
type "%EXCLUDE%"
::/L 
::robocopy "%DRIVE%:\\" "%DEST%" /E /IF @%INCLUDE% /XD @%EXCLUDE% /R:1 /W:1 /COPY:DAT /DCOPY:T /MT /ETA
for /f "tokens=* delims= eol=#" %%i in (%INCLUDE%) do (
echo ***************************
echo "%%i" to "%DEST%\%%~nxi"
echo ***************************
robocopy "%%i" "%DEST%\%%~nxi" /XF @%EXCLUDE% /R:1 /W:1 /E /MT /COPY:DAT /DCOPY:T /ETA
)

goto :eof

:main
setlocal
cd /D %~dp0

::call :fn_backup C \\nasserver.lan\Backups\%COMPUTERNAME%\C
call :fn_backup D \\nasserver.lan\Backups\%COMPUTERNAME%\D

endlocal
