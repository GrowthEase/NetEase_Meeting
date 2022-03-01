@echo off
@echo backup and clear backup

set BACKUP_DIR=%1
set BUILD_ID=%2
set BACKUP_EXE_FILE=%3
set BACKUP_SDK_FILE=%4
set BACKUP_PDB_FILE=%5
set BACKUP_BUILD_DIR=%BACKUP_DIR%\%BUILD_ID%
@echo BACKUP_BUILD_DIR: %BACKUP_BUILD_DIR%
@echo BACKUP_EXE_FILE: %BACKUP_EXE_FILE%
@echo BACKUP_SDK_FILE: %BACKUP_SDK_FILE%
@echo BACKUP_PDB_FILE: %BACKUP_PDB_FILE%
if not exist %BACKUP_BUILD_DIR% mkdir %BACKUP_BUILD_DIR%
copy %BACKUP_EXE_FILE% "%BACKUP_BUILD_DIR%"
copy %BACKUP_SDK_FILE% "%BACKUP_BUILD_DIR%"
copy %BACKUP_PDB_FILE% "%BACKUP_BUILD_DIR%"
forfiles /p %BACKUP_DIR% /s /m *.* /d -5 /c "cmd /c del /q @path"
for /f "delims=" %%a in ('dir /ad /b /s %BACKUP_DIR%\^|sort /r') do (
   rd "%%a">nul 2>nul &&echo empty dir "%%a" delsuc!
)
exit(0)