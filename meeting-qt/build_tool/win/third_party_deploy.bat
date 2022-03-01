set WORK_DIR=%~dp0..\..\
set IS_BUILD_ROOMKIT= %1

cd %WORK_DIR%
set ZIP_PATH=C:\Program Files\7-Zip
path %PATH%;%ZIP_PATH%

set THIRD_PARTY_LIBS_URL=http://yx-web.nos.netease.com/package/1630417431/third_party_libs.zip
echo Download third_party_libs ：%THIRD_PARTY_LIBS_URL%
if not exist third_party_libs mkdir third_party_libs
curl %THIRD_PARTY_LIBS_URL% -o third_party_libs.zip 
7z x third_party_libs.zip -r -y
del /f /q third_party_libs.zip

cd third_party_libs
7z x alog\alog_windows.7z -r -y
7z x glog\glog.zip -r -y
7z x jsoncpp\jsoncpp.zip -r -y
7z x libyuv\libyuv.zip -r -y

set WORK_DIR=%~dp0..\..\third_party_libs
cd %WORK_DIR%

7z x roomkit\NERoomKit_Windows.7z -r -y
xcopy NERoomKit_Windows\* roomkit /s/e/y
copy %WORK_DIR%\NERoomKit_Windows\libs\x86\Release\bin\*.dll %WORK_DIR%\..\bin /y
if not exist %WORK_DIR%\..\bin\assert mkdir %WORK_DIR%\..\bin\assert
copy %WORK_DIR%\NERoomKit_Windows\libs\x86\Release\bin\assert\* %WORK_DIR%\..\bin\assert /y
if exist NERoomKit_Windows rmdir /s/q NERoomKit_Windows