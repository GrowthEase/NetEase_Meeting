cd %~dp0

if exist alog rmdir /s/q alog
if exist jsoncpp rmdir /s/q jsoncpp
if exist libyuv rmdir /s/q libyuv

call .\build_tool\win\third_party_deploy.bat x64 Debug

cd %~dp0

if exist alog rmdir /s/q alog
if exist jsoncpp rmdir /s/q jsoncpp
if exist libyuv rmdir /s/q libyuv

call .\meeting-ipc\build_win32.bat debug x64
cd %~dp0
