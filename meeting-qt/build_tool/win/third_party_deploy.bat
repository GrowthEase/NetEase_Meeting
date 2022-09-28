set WORK_DIR=%~dp0..\..\
set TARGET_ARCH=%1
set BUILD_TYPE=%2

cd %WORK_DIR%
set ZIP_PATH=C:\Program Files\7-Zip
path %PATH%;%ZIP_PATH%

set THIRD_PARTY_LIBS_URL=https://yx-web-nosdn.netease.im/package/1664267144062/v3.5.0_third_party_libs.zip?download=v3.5.0_third_party_libs.zip
echo Download third_party_libs ：%THIRD_PARTY_LIBS_URL%
if not exist third_party_libs mkdir third_party_libs
curl %THIRD_PARTY_LIBS_URL% -o third_party_libs.zip 
7z x third_party_libs.zip -r -y
del /f /q third_party_libs.zip

cd third_party_libs
7z x alog\alog_windows.7z -r -y
7z x jsoncpp\jsoncpp.zip -r -y
7z x libyuv\libyuv.zip -r -y

set WORK_DIR=%~dp0..\..\third_party_libs
cd %WORK_DIR%

7z x roomkit\NERoomKit_Windows.zip -r -y
xcopy NERoomKit_Windows\* roomkit /s/e/y

copy %WORK_DIR%\NERoomKit_Windows\libs\%TARGET_ARCH%\%BUILD_TYPE%\bin\*.dll %WORK_DIR%\..\bin /y
if not exist %WORK_DIR%\..\bin\assets mkdir %WORK_DIR%\..\bin\assets
xcopy %WORK_DIR%\NERoomKit_Windows\libs\%TARGET_ARCH%\%BUILD_TYPE%\bin\assets\* %WORK_DIR%\..\bin\assets /s/e/y
if exist NERoomKit_Windows rmdir /s/q NERoomKit_Windows
