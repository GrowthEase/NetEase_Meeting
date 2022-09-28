::echo Using NERTC SDK version %NERTC_SDK_VERSION%
echo VS142COMNTOOLS_EX: %VS142COMNTOOLS_EX%

:: delete last artifact
del /f /q %~dp0..\..\*.7z
del /f /q %~dp0..\..\*.zip
del /f /q %~dp0..\..\*.exe
if exist installer rmdir /s/q installer
if exist sign rmdir /s/q sign
if exist release rmdir /s/q release
if exist release_pdb rmdir /s/q release_pdb
if exist setup rmdir /s/q setup

cd %~dp0
set BACKUP_DIR=%1
set IS_USE_API_TEST=%2
set CI_COMMIT_BRANCH=%3
set G2_WINDOWS_DOWNLOAD_URL=%4
set CI_ARTIFACTS_DIR=%5
set CI_BUILD_ID=%6
set CUSTOM_VERSION=%7
set IS_PUBLISH=%8
set TARGET_ARCH=%9

if "%CUSTOM_VERSION%" == "--" (
    set VERSION=3.5.0
) else (
    set VERSION=%CUSTOM_VERSION%
)

set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
set "TIMESTAMP=%TIMESTAMP: =0%"
for /f "delims=" %%i in ('git rev-list HEAD --count') do (set SVN_VER=%%i)
for /f "delims=" %%i in ('git rev-parse --short HEAD') do (set SHORT_COMMIT=%%i)

echo BACKUP_DIR %BACKUP_DIR%
echo IS_USE_API_TEST %IS_USE_API_TEST%
echo CI_COMMIT_BRANCH %CI_COMMIT_BRANCH%
echo G2_WINDOWS_DOWNLOAD_URL %G2_WINDOWS_DOWNLOAD_URL%
echo CI_ARTIFACTS_DIR %CI_ARTIFACTS_DIR%
echo CI_BUILD_ID %CI_BUILD_ID%
echo CUSTOM_VERSION %CUSTOM_VERSION%
echo IS_PUBLISH %IS_PUBLISH%
echo TARGET_ARCH %TARGET_ARCH%

:: Output dir
set WORK_DIR=%~dp0..\..\
set SIGN_DIR=%WORK_DIR%sign\
set OUTPUT_DIR=%WORK_DIR%installer\
set EXPORT_SDK_DIR=%WORK_DIR%nemeeting_sdk_windows\
set UNINSTALL_DIR=%WORK_DIR%setup\Uninstall\
set SETUP_DIR=%WORK_DIR%setup\
set BIN_DIR=%WORK_DIR%release
set PDB_DIR=%WORK_DIR%release_pdb
set ZIP_PATH=C:\Program Files\7-Zip

if "%BACKUP_DIR%" neq "--" (
    plink -batch -ssh -pw admin163 vcloudqa@10.242.100.195 "mkdir -p /Users/vcloudqa/Documents/pack/meeting/%BACKUP_DIR%/v%VERSION%/Windows"
    plink -batch -ssh -pw admin163 vcloudqa@10.242.100.195 "mkdir -p /Users/vcloudqa/Documents/pack/meeting/%BACKUP_DIR%/v%VERSION%/macOS"
    plink -batch -ssh -pw admin163 vcloudqa@10.242.100.195 "mkdir -p /Users/vcloudqa/Documents/pack/kit/meeting/%BACKUP_DIR%/v%VERSION%/Windows-sdk"
    plink -batch -ssh -pw admin163 vcloudqa@10.242.100.195 "mkdir -p /Users/vcloudqa/Documents/pack/kit/meeting/%BACKUP_DIR%/v%VERSION%/macOS-sdk"
)

:: copy 3rd parties
call third_party_deploy.bat %IS_BUILD_ROOMKIT%

set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
set "TIMESTAMP=%TIMESTAMP: =0%"
for /f "delims=" %%i in ('git rev-list HEAD --count') do (set SVN_VER=%%i)
for /f "delims=" %%i in ('git rev-parse --short HEAD') do (set SHORT_COMMIT=%%i)

:BuildStart
set TARGET_ARCH_TMP=''
if "%TARGET_ARCH%" == "All" (
    set TARGET_ARCH_TMP=x86
) else (
    set TARGET_ARCH_TMP=%TARGET_ARCH%
)

if "%TARGET_ARCH_TMP%" == "x64" (
    set RESFILE=%OUTPUT_DIR%release_%TIMESTAMP%_%SHORT_COMMIT%_%TARGET_ARCH_TMP%.zip
    set PDBFILE=%WORK_DIR%build_PC_Setup_%TIMESTAMP%_%SHORT_COMMIT%_pdb_%TARGET_ARCH_TMP%.zip
    set SETUPFILE_NAME=NetEaseMeeting_PC_Setup_%TIMESTAMP%_%SHORT_COMMIT%_%TARGET_ARCH_TMP%.exe
    set SDK_ZIP_NAME=NEMeeting_SDK_Windows_v%VERSION%_%TARGET_ARCH_TMP%.zip
    set EXPORT_SDK_FILE=build_windows_sdk_%TIMESTAMP%_%SHORT_COMMIT%_%TARGET_ARCH_TMP%.zip
) else (
    set RESFILE=%OUTPUT_DIR%release_%TIMESTAMP%_%SHORT_COMMIT%.zip
    set PDBFILE=%WORK_DIR%build_PC_Setup_%TIMESTAMP%_%SHORT_COMMIT%_pdb.zip
    set SETUPFILE_NAME=NetEaseMeeting_PC_Setup_%TIMESTAMP%_%SHORT_COMMIT%.exe
    set SDK_ZIP_NAME=NEMeeting_SDK_Windows_v%VERSION%.zip
    set EXPORT_SDK_FILE=build_windows_sdk_%TIMESTAMP%_%SHORT_COMMIT%.zip
)
set SETUPFILE=%OUTPUT_DIR%%SETUPFILE_NAME%

cd %WORK_DIR%

:: Tools
:: build ipc
cd meeting-ipc
if "%TARGET_ARCH_TMP%" == "x64" (
    call "%VS142COMNTOOLS_EX%vcvars64.bat"
    set WINDEPLOY=C:\Qt\5.15.0_64\5.15.0\msvc2019_64\bin
    start build_win32.bat release x64
    
) else (
    call "%VS142COMNTOOLS_EX%vcvars32.bat"
    set WINDEPLOY=C:\Qt\5.15.0\msvc2019\bin
    start build_win32.bat release Win32
)

:: Update version
%YUNXIN_PYTHON3_PATH%\Python %WORK_DIR%PACKAGE_UPDATE_VERSION.py --version %VERSION%

:: Init enviroment
path %WINDEPLOY%;%PATH%;%ZIP_PATH%

if not exist third_party_libs\roomkit mkdir third_party_libs\roomkit
cd %WORK_DIR%..\roomkit
python ./build.py --build_type=Release -nc -arch=%TARGET_ARCH_TMP%
xcopy install\* %WORK_DIR%third_party_libs\roomkit\ /s/e/y
cd %WORK_DIR%
copy third_party_libs\roomkit\libs\%TARGET_ARCH_TMP%\Release\bin\*.dll %WORK_DIR%bin /y
if not exist %WORK_DIR%bin\assets mkdir %WORK_DIR%bin\assets
xcopy third_party_libs\roomkit\libs\%TARGET_ARCH_TMP%\Release\bin\assets\* %WORK_DIR%bin\assets\ /s/e/y

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
MSBuild %UNINSTALL_DIR%setup_yixin.sln /t:Rebuild /m /p:Configuration=Release /property:Platform=Win32

set IS_SIGN=false
echo %CI_COMMIT_BRANCH%|find "release/">nul&&set IS_SIGN=true
echo %CI_COMMIT_BRANCH%|find "master">nul&&set IS_SIGN=true
echo %CI_COMMIT_BRANCH%|find "hotfix/">nul&&set IS_SIGN=true

cd %~dp0
del /f /q response.txt
curl -X POST http://fcy-auth.nie.netease.com/api/v2/tokens -Hcontent-type:application/json -d{\"user\":\"dengjiajia\",\"key\":\"b6f6a5f66cd3446dacb598f0699e0ca1\"} -o response.txt
for /f %%i in (response.txt) do (set TOKEN_STRING=%%i)
del /f /q response.txt
::echo TOKEN_STRING=%TOKEN_STRING%
set "TOKEN=%TOKEN_STRING% | jq-win64.exe .token"
echo %TOKEN% > response.txt
for /f %%i in (response.txt) do (set TOKEN=%%i)
del /f /q response.txt
::echo TOKEN=%TOKEN%
if "%IS_SIGN%" == "true" (
    if not exist %SIGN_DIR% md %SIGN_DIR%
    %~dp0ssigncode.2.2.exe --token %TOKEN%
    
    copy %WORK_DIR%bin\NetEaseMeeting.exe %SIGN_DIR%NetEaseMeeting_%TIMESTAMP%.exe
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SIGN_DIR%NetEaseMeeting_%TIMESTAMP%.exe
    copy %SIGN_DIR%NetEaseMeeting_%TIMESTAMP%.exe %BIN_DIR%\NetEaseMeeting.exe /y

    copy %WORK_DIR%bin\NetEaseMeetingClient.exe %SIGN_DIR%NetEaseMeetingClient_%TIMESTAMP%.exe
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SIGN_DIR%NetEaseMeetingClient_%TIMESTAMP%.exe
    copy %SIGN_DIR%NetEaseMeetingClient_%TIMESTAMP%.exe %BIN_DIR%\NetEaseMeetingClient.exe /y

    copy %WORK_DIR%bin\roomkit.dll %SIGN_DIR%roomkit_%TIMESTAMP%.dll
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SIGN_DIR%roomkit_%TIMESTAMP%.dll
    copy %SIGN_DIR%roomkit_%TIMESTAMP%.dll %BIN_DIR%\roomkit.dll /y

    copy %WORK_DIR%bin\nem_hosting_module.dll %SIGN_DIR%nem_hosting_module_%TIMESTAMP%.dll
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SIGN_DIR%nem_hosting_module_%TIMESTAMP%.dll
    copy %SIGN_DIR%nem_hosting_module_%TIMESTAMP%.dll %BIN_DIR%\nem_hosting_module.dll /y

    copy %WORK_DIR%bin\nem_hosting_module_client.dll %SIGN_DIR%nem_hosting_module_client_%TIMESTAMP%.dll
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SIGN_DIR%nem_hosting_module_client_%TIMESTAMP%.dll
    copy %SIGN_DIR%nem_hosting_module_client_%TIMESTAMP%.dll %BIN_DIR%\nem_hosting_module_client.dll /y

    copy %WORK_DIR%bin\nertc_sdk.dll %SIGN_DIR%nertc_sdk_%TIMESTAMP%.dll
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SIGN_DIR%nertc_sdk_%TIMESTAMP%.dll
    copy %SIGN_DIR%nertc_sdk_%TIMESTAMP%.dll %BIN_DIR%\nertc_sdk.dll /y
    
    copy %WORK_DIR%bin\protoopp.dll %SIGN_DIR%protoopp_%TIMESTAMP%.dll
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SIGN_DIR%protoopp_%TIMESTAMP%.dll
    copy %SIGN_DIR%protoopp_%TIMESTAMP%.dll %BIN_DIR%\protoopp.dll /y

    copy %WORK_DIR%bin\nim_cpp_wrapper.dll %SIGN_DIR%nim_cpp_wrapper_%TIMESTAMP%.dll
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SIGN_DIR%nim_cpp_wrapper_%TIMESTAMP%.dll
    copy %SIGN_DIR%nim_cpp_wrapper_%TIMESTAMP%.dll %BIN_DIR%\nim_cpp_wrapper.dll /y

    copy %WORK_DIR%bin\nim_chatroom_cpp_wrapper.dll %SIGN_DIR%nim_chatroom_cpp_wrapper_%TIMESTAMP%.dll
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SIGN_DIR%nim_chatroom_cpp_wrapper_%TIMESTAMP%.dll
    copy %SIGN_DIR%nim_chatroom_cpp_wrapper_%TIMESTAMP%.dll %BIN_DIR%\nim_chatroom_cpp_wrapper.dll /y

    copy %WORK_DIR%bin\SDL2.dll %SIGN_DIR%SDL2_%TIMESTAMP%.dll
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SIGN_DIR%SDL2_%TIMESTAMP%.dll
    copy %SIGN_DIR%SDL2_%TIMESTAMP%.dll %BIN_DIR%\SDL2.dll /y

    copy %UNINSTALL_DIR%bin\uninstall.exe %SIGN_DIR%uninstall_%TIMESTAMP%.exe
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SIGN_DIR%uninstall_%TIMESTAMP%.exe
    copy %SIGN_DIR%uninstall_%TIMESTAMP%.exe %BIN_DIR%\uninstall.exe /y
) else (
    copy %WORK_DIR%bin\NetEaseMeeting.exe %BIN_DIR%
    copy %WORK_DIR%bin\NetEaseMeetingClient.exe %BIN_DIR%
    copy %WORK_DIR%bin\nem_hosting_module.dll %BIN_DIR%
    copy %WORK_DIR%bin\nem_hosting_module_client.dll %BIN_DIR%
    copy %WORK_DIR%bin\nertc_sdk.dll %BIN_DIR%
    copy %WORK_DIR%bin\protoopp.dll %BIN_DIR%
    copy %WORK_DIR%bin\nim_cpp_wrapper.dll %BIN_DIR%
    copy %WORK_DIR%bin\nim_chatroom_cpp_wrapper.dll %BIN_DIR%
    copy %WORK_DIR%bin\SDL2.dll %BIN_DIR%
    copy %WORK_DIR%bin\roomkit.dll %BIN_DIR%
    copy %UNINSTALL_DIR%bin\uninstall.exe %BIN_DIR%
)

copy %WORK_DIR%bin\feedback.png %BIN_DIR%
copy %WORK_DIR%bin\meeting-ui-sdk_zh_CN.qm %BIN_DIR%
copy %WORK_DIR%bin\meeting-app_zh_CN.qm %BIN_DIR%
copy %WORK_DIR%bin\vc_redist.%TARGET_ARCH_TMP%.exe %BIN_DIR%
copy %WORK_DIR%bin\vld.dll %BIN_DIR%
copy %WORK_DIR%bin\rain.mp3 %BIN_DIR%
copy %WORK_DIR%bin\libfreetype-6.dll %BIN_DIR%
copy %WORK_DIR%bin\libjpeg-9.dll %BIN_DIR%
copy %WORK_DIR%bin\libpng16-16.dll %BIN_DIR%
copy %WORK_DIR%bin\libwebp-7.dll %BIN_DIR%
copy %WORK_DIR%bin\libtiff-5.dll %BIN_DIR%
copy %WORK_DIR%bin\SDL2_image.dll %BIN_DIR%
copy %WORK_DIR%bin\SDL2_ttf.dll %BIN_DIR%
copy %WORK_DIR%bin\zlib1.dll %BIN_DIR%
if "%TARGET_ARCH_TMP%" == "x64" (
    copy %WORK_DIR%bin\libssl-1_1-x64.dll %BIN_DIR%
    copy %WORK_DIR%bin\libcrypto-1_1-x64.dll %BIN_DIR%
    
) else (
    copy %WORK_DIR%bin\libssl-1_1.dll %BIN_DIR%
    copy %WORK_DIR%bin\libcrypto-1_1.dll %BIN_DIR%
)

if not exist %BIN_DIR%\image\vb mkdir %BIN_DIR%\image\vb
copy %WORK_DIR%bin\image\vb %BIN_DIR%\image\vb

if not exist %BIN_DIR%\assets mkdir %BIN_DIR%\assets
echo copy assets %WORK_DIR%bin\assets 
echo copy assets %BIN_DIR%\assets
xcopy %WORK_DIR%bin\assets\* %BIN_DIR%\assets\ /s/e/y

if not exist %BIN_DIR%\config mkdir %BIN_DIR%\config
copy %WORK_DIR%bin\config\*.* %BIN_DIR%\config\

copy %WORK_DIR%bin\CNamaSDK.dll %BIN_DIR%
copy %WORK_DIR%bin\fuai.dll %BIN_DIR%
copy %WORK_DIR%bin\opengl32.dll %BIN_DIR%
copy %WORK_DIR%bin\glfw3.dll %BIN_DIR%
copy %WORK_DIR%bin\gl3w.dll %BIN_DIR%
copy %WORK_DIR%bin\uninstall.exe %BIN_DIR%
copy %WORK_DIR%bin\nim.dll %BIN_DIR%
copy %WORK_DIR%bin\nim_chatroom.dll %BIN_DIR%
copy %WORK_DIR%bin\nim_audio.dll %BIN_DIR%
copy %WORK_DIR%bin\nim_audio_hook.dll %BIN_DIR%
copy %WORK_DIR%bin\nim_tools_http.dll %BIN_DIR%
copy %WORK_DIR%bin\nrtc.dll %BIN_DIR%
copy %WORK_DIR%bin\nrtc_audio_process.dll %BIN_DIR%
copy %WORK_DIR%bin\h_available.dll %BIN_DIR%
copy %WORK_DIR%bin\msvcp120.dll %BIN_DIR%
copy %WORK_DIR%bin\msvcr120.dll %BIN_DIR%

cd %BIN_DIR%
windeployqt NetEaseMeeting.exe --qmldir %WORK_DIR%meeting-app\qml
windeployqt NetEaseMeetingClient.exe --qmldir %WORK_DIR%meeting-ui-sdk\qml

@echo Make output dir
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

@echo Zip release
if exist %RESFILE% del /f /q %RESFILE%
7z a -t7z %RESFILE% %BIN_DIR% -mx=9 -m0=LZMA2 >nul

copy /Y %RESFILE% %SETUP_DIR%src\setup\release.7z
echo #pragma once> %SETUP_DIR%target_def.h
if "%TARGET_ARCH_TMP%" == "x64" (
    echo #define PRODUCT_EXE_X64>> %SETUP_DIR%target_def.h
)
MSBuild %SETUP_DIR%setup_yixin.sln /t:Rebuild /m /p:Configuration=Release /property:Platform=Win32
if "%IS_SIGN%" == "true"  (
    move %SETUP_DIR%bin\nimsetup.exe %SETUP_DIR%bin\nimsetup_%TIMESTAMP%.exe
    %~dp0ssigncode.2.2.exe -c -t sha256 -f %SETUP_DIR%bin\nimsetup_%TIMESTAMP%.exe
    copy %SETUP_DIR%bin\nimsetup_%TIMESTAMP%.exe %SETUPFILE% /y
) else (
    copy %SETUP_DIR%bin\nimsetup.exe %SETUPFILE% /y
)

cd %WORK_DIR%
copy %SETUPFILE% %WORK_DIR% /y
if "%BACKUP_DIR%" neq "--" (
    echo y | pscp -p -v -P 22 -pw admin163 %SETUPFILE% vcloudqa@10.242.100.195:/Users/vcloudqa/Documents/pack/meeting/%BACKUP_DIR%/v%VERSION%/Windows
    call .\build_tool\win\notify.bat "windows" "online" "%VERSION%" "http://10.242.100.195/meeting/%BACKUP_DIR%/v%VERSION%/Windows/%SETUPFILE_NAME%" "%CI_COMMIT_BRANCH%" "APP" %SETUPFILE%
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
if exist %EXPORT_SDK_DIR%\bin\UnInstall.exe del /f /q %EXPORT_SDK_DIR%\bin\UnInstall.exe

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
7z a %EXPORT_SDK_FILE% %EXPORT_SDK_DIR%\%SDK_ZIP_NAME% %EXPORT_SDK_DIR%\api_test.xml %EXPORT_SDK_DIR%\NEMeetingSample.exe
if "%BACKUP_DIR%" neq "--" (
    echo y | pscp -p -v -P 22 -pw admin163 %EXPORT_SDK_FILE% vcloudqa@10.242.100.195:/Users/vcloudqa/Documents/pack/kit/meeting/%BACKUP_DIR%/v%VERSION%/Windows-sdk
    call .\build_tool\win\notify.bat "windows" "online" "%VERSION%" "http://10.242.100.195/kit/meeting/%BACKUP_DIR%/v%VERSION%/Windows-sdk/%EXPORT_SDK_FILE%" "%CI_COMMIT_BRANCH%" "SDK" %EXPORT_SDK_FILE%
)

@echo Zip release pdb

copy %WORK_DIR%bin\*.pdb %PDB_DIR%
copy %WORK_DIR%third_party_libs\roomkit\libs\%TARGET_ARCH_TMP%\Release\pdb\*.pdb %PDB_DIR%

if exist %PDBFILE% del /f /q %PDBFILE%
7z a %PDBFILE% %PDB_DIR%
if "%BACKUP_DIR%" neq "--" (
    echo y | pscp -p -v -P 22 -pw admin163 %PDBFILE% vcloudqa@10.242.100.195:/Users/vcloudqa/Documents/pack/meeting/%BACKUP_DIR%/v%VERSION%/Windows
)

::@echo backup
::cd %~dp0
::start backup.bat %CI_ARTIFACTS_DIR% %CI_BUILD_ID% %SETUPFILE% %WORK_DIR%%EXPORT_SDK_FILE% %PDBFILE%
cd %~dp0
if "%IS_SIGN%" == "true" (
    call upsomefile.bat "%PDB_DIR%" "NetEaseMeeting" "v%VERSION%_%TIMESTAMP%_%SHORT_COMMIT%_online"
) else (
    call upsomefile.bat "%PDB_DIR%" "NetEaseMeeting" "v%VERSION%_%TIMESTAMP%_%SHORT_COMMIT%"
)

if "%IS_PUBLISH%" == "true" (
    @echo admin publish
    cd %WORK_DIR%
    call cmd /c "sh %WORK_DIR%build_tool\common\admin_upload\upload.sh wangjianzhong pc "" meeting "exe demo" "" %VERSION% %SETUPFILE_NAME%"
    cd %EXPORT_SDK_DIR%
    call cmd /c "sh %WORK_DIR%build_tool\common\admin_upload\upload.sh wangjianzhong pc "" meeting "sdk" "" %VERSION% %SDK_ZIP_NAME%"
)

cd %WORK_DIR%
@echo clear 
if exist %RESFILE% del /f /q %RESFILE%
if exist sign rmdir /s/q sign
if exist release rmdir /s/q release
if exist release_pdb rmdir /s/q release_pdb
if exist %EXPORT_SDK_DIR% rmdir /s/q %EXPORT_SDK_DIR%

if "%TARGET_ARCH%" == "All" (
    set TARGET_ARCH=x64
    cd bin && git clean -dfx
    cd ../meeting-app && git clean -dfx
    cd ../meeting-ui-sdk && git clean -dfx
    cd ../meeting-sample && git clean -dfx
    goto BuildStart
)

cd %WORK_DIR%
if exist third_party_libs rmdir /s/q third_party_libs

