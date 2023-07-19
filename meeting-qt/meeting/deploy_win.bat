cd %~dp0

if exist alog rmdir /s/q alog
if exist glog rmdir /s/q glog
if exist jsoncpp rmdir /s/q jsoncpp
if exist libyuv rmdir /s/q libyuv

call .\build_tool\win\third_party_deploy.bat ""

cd %~dp0

if exist alog rmdir /s/q alog
if exist glog rmdir /s/q glog
if exist jsoncpp rmdir /s/q jsoncpp
if exist libyuv rmdir /s/q libyuv
if exist nebase rmdir /s/q nebase

call .\meeting-ipc\build_win32.bat debug Win32
cd %~dp0
