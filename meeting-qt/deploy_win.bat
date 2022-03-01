cd %~dp0
if exist nim_sdk rmdir /s/q nim_sdk
if exist nertc_sdk rmdir /s/q nertc_sdk
if exist nertc_demos rmdir /s/q nertc_demos
if exist NERtc_windows_SDK rmdir /s/q NERtc_windows_SDK
if exist OpenGL rmdir /s/q OpenGL
if exist FaceUnity-SDK rmdir /s/q FaceUnity-SDK
if exist glog rmdir /s/q glog
if exist jsoncpp rmdir /s/q jsoncpp
if exist libyuv rmdir /s/q libyuv
if exist nebase rmdir /s/q nebase

call .\build_tool\win\third_party_deploy.bat ""
cd %~dp0
xcopy .\third_party_libs\roomkit\libs\x86\Debug\bin\* .\bin /s/e/y

if exist nim_sdk rmdir /s/q nim_sdk
if exist nertc_sdk rmdir /s/q nertc_sdk
if exist nertc_demos rmdir /s/q nertc_demos
if exist NERtc_windows_SDK rmdir /s/q NERtc_windows_SDK
if exist OpenGL rmdir /s/q OpenGL
if exist FaceUnity-SDK rmdir /s/q FaceUnity-SDK
if exist glog rmdir /s/q glog
if exist jsoncpp rmdir /s/q jsoncpp
if exist libyuv rmdir /s/q libyuv
if exist nebase rmdir /s/q nebase

call .\meeting-ipc\build_win32.bat debug
cd %~dp0
