::echo Using NERTC SDK version %NERTC_SDK_VERSION%
echo VS142COMNTOOLS: %VS142COMNTOOLS%

:: delete last artifact
del /f /q .\*.7z
del /f /q .\*.exe
if exist installer rmdir /s/q installer
if exist sign rmdir /s/q sign
if exist release rmdir /s/q release
if exist release_pdb rmdir /s/q release_pdb

cd %~dp0
set BACKUP_DIR=%1
set IS_USE_API_TEST=%2
set CI_COMMIT_BRANCH=%3
set G2_WINDOWS_DOWNLOAD_URL=%4
set CI_ARTIFACTS_DIR=%5
set CI_BUILD_ID=%6
set IS_BUILD_ROOMKIT=%7
set VERSION=1.20.0
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
set "TIMESTAMP=%TIMESTAMP: =0%"
for /f "delims=" %%i in ('git rev-list HEAD --count') do (set SVN_VER=%%i)
for /f "delims=" %%i in ('git rev-parse --short HEAD') do (set SHORT_COMMIT=%%i)

echo IS_USE_API_TEST %IS_USE_API_TEST%
echo BACKUP_DIR %BACKUP_DIR%
echo CI_COMMIT_BRANCH %CI_COMMIT_BRANCH%
echo IS_BUILD_ROOMKIT %IS_BUILD_ROOMKIT%

:: Tools
set VS_DIR="%VS142COMNTOOLS%..\Tools"
set WINDEPLOY=C:\Qt\5.15.0\msvc2019\bin
set DOWNLOAD_PATH=""

:: Output dir
set WORK_DIR=%~dp0\..\..\
set SIGN_DIR=%WORK_DIR%sign\
set OUTPUT_DIR=%WORK_DIR%installer\
set EXPORT_SDK_DIR=%WORK_DIR%nemeeting_sdk_windows\
set UNINSTALL_DIR=%WORK_DIR%setup\Uninstall\
set SETUP_DIR=%WORK_DIR%setup\
set BIN_DIR=%WORK_DIR%release
set PDB_DIR=%WORK_DIR%release_pdb
set RESFILE=%OUTPUT_DIR%release_%TIMESTAMP%_%SHORT_COMMIT%.7z
set PDBFILE=%OUTPUT_DIR%release_%TIMESTAMP%_%SHORT_COMMIT%_pdb.7z
set SETUPFILE_NAME=NetEaseMeeting_PC_Setup_%TIMESTAMP%_%SHORT_COMMIT%.exe
set SETUPFILE=%OUTPUT_DIR%%SETUPFILE_NAME%
set ZIP_PATH=C:\Program Files\7-Zip
set SDK_ZIP_NAME=NEMeeting_SDK_Windows_v%VERSION%.zip
set EXPORT_SDK_FILE=build_windows_sdk_%TIMESTAMP%_%SHORT_COMMIT%.7z

:: copy 3rd parties
call third_party_deploy.bat %IS_BUILD_ROOMKIT%

:: build ipc
cd meeting-ipc
call build_win32.bat release

:: Update version
%YUNXIN_PYTHON3_PATH%\Python %WORK_DIR%PACKAGE_UPDATE_VERSION.py --version %VERSION%

:: Init enviroment
::call %VS_DIR%\VsDevCmd.bat
::echo VS_DIR %VS_DIR%
path %VS_DIR%;%WINDEPLOY%;%PATH%;%ZIP_PATH%

cd %WORK_DIR%
cd meeting-ui-sdk
qmake meeting-ui-sdk.pro -spec win32-msvc "CONFIG+=qtquickcompiler"
nmake
lupdate meeting-ui-sdk.pro -ts meeting-ui-sdk_zh_CN.ts
lrelease meeting-ui-sdk_zh_CN.ts

cd %WORK_DIR%
cd meeting-app
qmake meeting-app.pro -spec win32-msvc "CONFIG+=qtquickcompiler"
nmake
lupdate meeting-app.pro -ts meeting-app_zh_CN.ts
lrelease meeting-app_zh_CN.ts

cd %WORK_DIR%
copy meeting-ui-sdk\meeting-ui-sdk_zh_CN.qm bin /y
copy meeting-app\meeting-app_zh_CN.qm bin /y

cd %WORK_DIR%
cd meeting-sample
qmake meeting-sample.pro -spec win32-msvc "CONFIG+=qtquickcompiler"
nmake

cd %WORK_DIR%

rd /s /q %BIN_DIR%
rd /s /q %PDB_DIR%
md %BIN_DIR%
md %PDB_DIR%

:: build uninstall exe
MSBuild %UNINSTALL_DIR%setup_yixin.sln /t:Rebuild /p:Configuration=Release /property:Platform=Win32

set IS_SIGN=false
echo %CI_COMMIT_BRANCH%|find "release/">nul&&set IS_SIGN=true
echo %CI_COMMIT_BRANCH%|find "master">nul&&set IS_SIGN=true
echo %CI_COMMIT_BRANCH%|find "hotfix/">nul&&set IS_SIGN=true

if "%IS_SIGN%" == "true" (
	if not exist %SIGN_DIR% md %SIGN_DIR%
	
	copy %WORK_DIR%bin\NetEaseMeeting.exe %SIGN_DIR%NetEaseMeeting_%TIMESTAMP%.exe
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%NetEaseMeeting_%TIMESTAMP%.exe
	curl %DOWNLOAD_PATH%NetEaseMeeting_%TIMESTAMP%.exe -o %BIN_DIR%\NetEaseMeeting.exe

	copy %WORK_DIR%bin\NetEaseMeetingClient.exe %SIGN_DIR%NetEaseMeetingClient_%TIMESTAMP%.exe
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%NetEaseMeetingClient_%TIMESTAMP%.exe
	curl %DOWNLOAD_PATH%NetEaseMeetingClient_%TIMESTAMP%.exe -o %BIN_DIR%\NetEaseMeetingClient.exe

	copy %WORK_DIR%bin\meeting-native-sdk.dll %SIGN_DIR%meeting-native-sdk_%TIMESTAMP%.dll
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%meeting-native-sdk_%TIMESTAMP%.dll
	curl %DOWNLOAD_PATH%meeting-native-sdk_%TIMESTAMP%.dll -o %BIN_DIR%\meeting-native-sdk.dll

	copy %WORK_DIR%bin\nem_hosting_module.dll %SIGN_DIR%nem_hosting_module_%TIMESTAMP%.dll
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%nem_hosting_module_%TIMESTAMP%.dll
	curl %DOWNLOAD_PATH%nem_hosting_module_%TIMESTAMP%.dll -o %BIN_DIR%\nem_hosting_module.dll

	copy %WORK_DIR%bin\nem_hosting_module_client.dll %SIGN_DIR%nem_hosting_module_client_%TIMESTAMP%.dll
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%nem_hosting_module_client_%TIMESTAMP%.dll
	curl %DOWNLOAD_PATH%nem_hosting_module_client_%TIMESTAMP%.dll -o %BIN_DIR%\nem_hosting_module_client.dll

	copy %WORK_DIR%bin\nertc_sdk.dll %SIGN_DIR%nertc_sdk_%TIMESTAMP%.dll
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%nertc_sdk_%TIMESTAMP%.dll
	curl %DOWNLOAD_PATH%nertc_sdk_%TIMESTAMP%.dll -o %BIN_DIR%\nertc_sdk.dll
    
    copy %WORK_DIR%bin\protoopp.dll %SIGN_DIR%protoopp_%TIMESTAMP%.dll
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%protoopp_%TIMESTAMP%.dll
	curl %DOWNLOAD_PATH%protoopp_%TIMESTAMP%.dll -o %BIN_DIR%\protoopp.dll

	copy %WORK_DIR%bin\nim.dll %SIGN_DIR%nim_%TIMESTAMP%.dll
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%nim_%TIMESTAMP%.dll
	curl %DOWNLOAD_PATH%nim_%TIMESTAMP%.dll -o %BIN_DIR%\nim.dll

	copy %WORK_DIR%bin\nim_sdk_cpp_wrapper_dll.dll %SIGN_DIR%nim_sdk_cpp_wrapper_dll_%TIMESTAMP%.dll
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%nim_sdk_cpp_wrapper_dll_%TIMESTAMP%.dll
	curl %DOWNLOAD_PATH%nim_sdk_cpp_wrapper_dll_%TIMESTAMP%.dll -o %BIN_DIR%\nim_sdk_cpp_wrapper_dll.dll

	copy %WORK_DIR%bin\nim_chatroom.dll %SIGN_DIR%nim_chatroom_%TIMESTAMP%.dll
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%nim_chatroom_%TIMESTAMP%.dll
	curl %DOWNLOAD_PATH%nim_chatroom_%TIMESTAMP%.dll -o %BIN_DIR%\nim_chatroom.dll

	copy %WORK_DIR%bin\nim_chatroom_sdk_cpp_wrapper_dll.dll %SIGN_DIR%nim_chatroom_sdk_cpp_wrapper_dll_%TIMESTAMP%.dll
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%nim_chatroom_sdk_cpp_wrapper_dll_%TIMESTAMP%.dll
	curl %DOWNLOAD_PATH%nim_chatroom_sdk_cpp_wrapper_dll_%TIMESTAMP%.dll -o %BIN_DIR%\nim_chatroom_sdk_cpp_wrapper_dll.dll

	copy %WORK_DIR%bin\SDL2.dll %SIGN_DIR%SDL2_%TIMESTAMP%.dll
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%SDL2_%TIMESTAMP%.dll
	curl %DOWNLOAD_PATH%SDL2_%TIMESTAMP%.dll -o %BIN_DIR%\SDL2.dll

	copy %UNINSTALL_DIR%bin\uninstall.exe %SIGN_DIR%uninstall_%TIMESTAMP%.exe
	%YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SIGN_DIR%uninstall_%TIMESTAMP%.exe
	curl %DOWNLOAD_PATH%uninstall_%TIMESTAMP%.exe -o %BIN_DIR%\uninstall.exe
) else (
	copy %WORK_DIR%bin\NetEaseMeeting.exe %BIN_DIR%
    copy %WORK_DIR%bin\NetEaseMeetingClient.exe %BIN_DIR%
    copy %WORK_DIR%bin\meeting-native-sdk.dll %BIN_DIR%
    copy %WORK_DIR%bin\nem_hosting_module.dll %BIN_DIR%
    copy %WORK_DIR%bin\nem_hosting_module_client.dll %BIN_DIR%
    copy %WORK_DIR%bin\nertc_sdk.dll %BIN_DIR%
    copy %WORK_DIR%bin\protoopp.dll %BIN_DIR%
    copy %WORK_DIR%bin\nim.dll %BIN_DIR%
    copy %WORK_DIR%bin\nim_chatroom.dll %BIN_DIR%
	copy %WORK_DIR%bin\nim_cpp_wrapper.dll %BIN_DIR%
    copy %WORK_DIR%bin\nim_chatroom_cpp_wrapper.dll %BIN_DIR%
    copy %WORK_DIR%bin\SDL2.dll %BIN_DIR%
    copy %WORK_DIR%bin\roomkit.dll %BIN_DIR%
    copy %UNINSTALL_DIR%bin\uninstall.exe %BIN_DIR%
)

copy %WORK_DIR%bin\feedback.png %BIN_DIR%
copy %WORK_DIR%bin\libssl-1_1.dll %BIN_DIR%
copy %WORK_DIR%bin\meeting-ui-sdk_zh_CN.qm %BIN_DIR%
copy %WORK_DIR%bin\meeting-app_zh_CN.qm %BIN_DIR%
copy %WORK_DIR%bin\nim_tools_http.dll %BIN_DIR%
copy %WORK_DIR%bin\libcrypto-1_1.dll %BIN_DIR%
copy %WORK_DIR%bin\vc_redist.x86.exe %BIN_DIR%
copy %WORK_DIR%bin\vld.dll %BIN_DIR%
copy %WORK_DIR%bin\rain.mp3 %BIN_DIR%

if not exist %BIN_DIR%\assert mkdir %BIN_DIR%\assert
echo copy assert %WORK_DIR%bin\assert 
echo copy assert %BIN_DIR%\assert
copy %WORK_DIR%bin\assert\*.* %BIN_DIR%\assert\

if not exist %BIN_DIR%\config mkdir %BIN_DIR%\config
copy %WORK_DIR%bin\config\*.* %BIN_DIR%\config\

copy %WORK_DIR%bin\CNamaSDK.dll %BIN_DIR%
copy %WORK_DIR%bin\fuai.dll %BIN_DIR%
copy %WORK_DIR%bin\opengl32.dll %BIN_DIR%
copy %WORK_DIR%bin\glfw3.dll %BIN_DIR%
copy %WORK_DIR%bin\gl3w.dll %BIN_DIR%
copy %WORK_DIR%bin\uninstall.exe %BIN_DIR%
copy %WORK_DIR%bin\nim_audio.dll %BIN_DIR%
copy %WORK_DIR%bin\nim_audio_hook.dll %BIN_DIR%nrtc.dll
copy %WORK_DIR%bin\nrtc.dll %BIN_DIR%
copy %WORK_DIR%bin\nrtc_audio_process.dll %BIN_DIR%
copy %WORK_DIR%bin\h_available.dll %BIN_DIR%
copy %WORK_DIR%bin\msvcp120.dll %BIN_DIR%
copy %WORK_DIR%bin\msvcr120.dll %BIN_DIR%

cd %BIN_DIR%
windeployqt NetEaseMeetingClient.exe --qmldir %WORK_DIR%meeting-ui-sdk\qml

@echo Make output dir
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

@echo Zip release
if exist %RESFILE% del /f /q %RESFILE%
7z a -t7z %RESFILE% %BIN_DIR% -mx=9 -m0=LZMA2 >nul

copy /Y %RESFILE% %SETUP_DIR%src\setup\release.7z
MSBuild %SETUP_DIR%setup_yixin.sln /t:Rebuild /p:Configuration=Release /property:Platform=Win32
if "%IS_SIGN%" == "true"  (
    move %SETUP_DIR%bin\nimsetup.exe %SETUP_DIR%bin\nimsetup_%TIMESTAMP%.exe
    %YUNXIN_PYTHON2_PATH%python %~dp0\winsign_client_api.py -f %SETUP_DIR%bin\nimsetup_%TIMESTAMP%.exe
    curl %DOWNLOAD_PATH%nimsetup_%TIMESTAMP%.exe -o %SETUPFILE%
) else (
    copy %SETUP_DIR%bin\nimsetup.exe %SETUPFILE% /y
)

cd %WORK_DIR%
copy %SETUPFILE% %WORK_DIR% /y
if "%BACKUP_DIR%" neq "--"  (
)

@echo Export SDK
if not exist %EXPORT_SDK_DIR% mkdir %EXPORT_SDK_DIR%
if not exist %EXPORT_SDK_DIR%\bin mkdir %EXPORT_SDK_DIR%\bin
if not exist %EXPORT_SDK_DIR%\lib mkdir %EXPORT_SDK_DIR%\lib
if not exist %EXPORT_SDK_DIR%\include mkdir %EXPORT_SDK_DIR%\include

xcopy %BIN_DIR% %EXPORT_SDK_DIR%\bin /s
copy %WORK_DIR%meeting-sample\bin\NEMeetingSample.exe %EXPORT_SDK_DIR% /y
copy %WORK_DIR%meeting-ipc\nem_sdk_interface\*.h %EXPORT_SDK_DIR%\include /y
del /f /q %EXPORT_SDK_DIR%\include\sdk_introduction.h
copy %WORK_DIR%meeting-ipc\output\nem_hosting_module\Release\nem_hosting_module.lib %EXPORT_SDK_DIR%\lib /y
if exist %EXPORT_SDK_DIR%\bin\NetEaseMeeting.exe del /f /q %EXPORT_SDK_DIR%\bin\NetEaseMeeting.exe
if exist %EXPORT_SDK_DIR%\bin\meeting-app_zh_CN.qm del /f /q %EXPORT_SDK_DIR%\bin\meeting-app_zh_CN.qm

cd %EXPORT_SDK_DIR%
7z a %SDK_ZIP_NAME% .\bin .\include .\lib

@echo IS_USE_API_TEST %IS_USE_API_TEST%
if "%IS_USE_API_TEST%" == "true" (	
	cd %WORK_DIR%third_party\meeting-sdk-desktop-tests
	qmake meeting-sdk-desktop-tests.pro -spec win32-msvc "CONFIG+=qtquickcompiler"
	nmake
    call %EXPORT_SDK_DIR%bin\meeting-sdk-desktop-tests.exe "xml" "%EXPORT_SDK_DIR%\api_test.xml"
	cd %WORK_DIR%
)

if exist %EXPORT_SDK_DIR%\bin rmdir /s/q %EXPORT_SDK_DIR%\bin
if exist %EXPORT_SDK_DIR%\lib rmdir /s/q %EXPORT_SDK_DIR%\lib
if exist %EXPORT_SDK_DIR%\include rmdir /s/q %EXPORT_SDK_DIR%\include

cd %WORK_DIR%
7z a -t7z %EXPORT_SDK_FILE% %EXPORT_SDK_DIR%\%SDK_ZIP_NAME% %EXPORT_SDK_DIR%\api_test.xml %EXPORT_SDK_DIR%\NEMeetingSample.exe  -mx=9 -m0=LZMA2 >nul
if "%BACKUP_DIR%" neq "--"  (
)

@echo Zip release pdb

copy %WORK_DIR%bin\*.pdb %PDB_DIR%
copy %WORK_DIR%NERtc_windows_SDK\dll\x86\nertc_sdk.pdb %PDB_DIR%
copy %WORK_DIR%NERtc_windows_SDK\dll\x86\protoopp.pdb %PDB_DIR%
copy %WORK_DIR%nim_sdk\bin\nim.pdb %PDB_DIR%
copy %WORK_DIR%nim_sdk\bin\nim_chatroom.pdb %PDB_DIR%
copy %WORK_DIR%nim_sdk\bin\nim_sdk_cpp_wrapper_dll.pdb %PDB_DIR%

if exist %PDBFILE% del /f /q %PDBFILE%
7z a -t7z %PDBFILE% %PDB_DIR% -mx=9 -m0=LZMA2 >nul
if "%BACKUP_DIR%" neq "--"  (
)

@echo backup
cd %~dp0
start backup.bat %CI_ARTIFACTS_DIR% %CI_BUILD_ID% %SETUPFILE% %WORK_DIR%%EXPORT_SDK_FILE% %PDBFILE%

cd %WORK_DIR%

@echo clear 
if exist %RESFILE% del /f /q %RESFILE%
if exist nim_sdk rmdir /s/q nim_sdk
if exist nertc_sdk rmdir /s/q nertc_sdk
if exist nertc_demos rmdir /s/q nertc_demos
if exist OpenGL rmdir /s/q OpenGL
if exist FaceUnity-SDK rmdir /s/q FaceUnity-SDK
if exist NERtc_windows_SDK rmdir /s/q NERtc_windows_SDK
if exist glog rmdir /s/q glog
if exist jsoncpp rmdir /s/q jsoncpp
if exist libyuv rmdir /s/q libyuv
if exist nebase rmdir /s/q nebase
if exist sign rmdir /s/q sign
if exist release rmdir /s/q release
if exist release_pdb rmdir /s/q release_pdb
if exist %ARTIFACTS_DIR% rmdir /s/q %ARTIFACTS_DIR%
if exist third_party_libs rmdir /s/q third_party_libs
if exist %EXPORT_SDK_DIR% rmdir /s/q %EXPORT_SDK_DIR%

