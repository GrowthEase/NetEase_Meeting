cd %~dp0
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
set "TIMESTAMP=%TIMESTAMP: =0%"
for /f "delims=" %%i in ('git rev-list HEAD --count') do (set SVN_VER=%%i)
for /f "delims=" %%i in ('git rev-parse --short HEAD') do (set SHORT_COMMIT=%%i)

:: Tools
set VS_DIR="%VS142COMNTOOLS%..\Tools"
set WINDEPLOY=D:\Qt\Qt5.15.0\5.15.0\msvc2019\bin

:: Init enviroment
call %VS_DIR%\VsDevCmd.bat
path %VS_DIR%;%WINDEPLOY%;%PATH%;

qmake meeting-sample.pro -spec win32-msvc "CONFIG+=qtquickcompiler"
nmake

copy .\bin\NEMeetingSample.exe ..\nemeeting_sdk_windows /y
