#!/bin/bash
echo start build

rm -rf ../../bin/*.app
rm -rf ../../bin/*.framework
rm -rf ../../build_macos*.zip
rm -rf ./build_macos_*
rm -rf ../../*.dmg

BACKUP_DIR=$1
IS_USE_API_TEST=$2
CI_COMMIT_BRANCH=$3
G2_MACOS_DOWNLOAD_URL=$4
VERSION=1.20.0
TIMESTAMP=`date +%s`
GIT_COMMIT_COUNT=`git rev-list HEAD --count`
GIT_COMMIT_SHORT_HASH=`git rev-parse --short HEAD`
MAC_OS_VERSION=${VERSION}
QT_BUILD_TOOL=/Users/yunxin/Qt/5.15.0/clang_64/bin/
PACKAGE_FULL_NAME=meeting_macOS_${TIMESTAMP}_${GIT_COMMIT_SHORT_HASH}_online.dmg
SDK_ZIP_NAME=NEMeeting_SDK_macOS_v${VERSION}.zip
EXPORT_SDK_FILE=build_macos_sdk_${TIMESTAMP}_${GIT_COMMIT_SHORT_HASH}.zip
EXPORT_SDK_DIR_NAME=build_macos_sdk_${TIMESTAMP}_${GIT_COMMIT_SHORT_HASH}

PATH=$PATH:$QT_BUILD_TOOL

# copy 3rd parties
chmod +x third_party_deploy.sh
./third_party_deploy.sh

# build ipc
cd ../../meeting-ipc
cmake -H./. -Boutput_mac -G"Xcode"
cmake --build output_mac --config Release

cd ..
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString "${MAC_OS_VERSION} ./meeting-app/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString "${MAC_OS_VERSION} ./meeting-ui-sdk/Info.plist

rm -rf ./bin/NetEaseMeetingClient.app
rm -rf ./bin/NeteaseMeeting.app
rm -rf ./bin/网易会议.app
rm -rf ./third_party/OpenGL
rm -rf ./third_party/FaceUnity-SDK

python3 ./PACKAGE_UPDATE_VERSION.py --version ${VERSION}

cd meeting-ui-sdk
qmake -config release meeting-ui-sdk.pro -spec macx-clang
make
lupdate ./meeting-ui-sdk.pro -ts meeting-ui-sdk_zh_CN.ts
lrelease ./meeting-ui-sdk_zh_CN.ts
cp ./meeting-ui-sdk_zh_CN.qm ../bin/NetEaseMeetingClient.app/Contents/Resources/meeting-ui-sdk_zh_Hans_CN.qm
cd ..

cd bin
macdeployqt NetEaseMeetingClient.app -qmldir=../meeting-ui-sdk/qml
cd ..

cd meeting-app
qmake -config release meeting-app.pro -spec macx-clang
make
lupdate ./meeting-app.pro -ts meeting-app_zh_CN.ts
lrelease ./meeting-app_zh_CN.ts
cp ./meeting-app_zh_CN.qm ../bin/NetEaseMeeting.app/Contents/Resources/meeting-app_zh_Hans_CN.qm
cp ../bin/feedback.png ../bin/NetEaseMeeting.app/Contents/Resources/feedback.png
cd ..

cd bin
# macdeployqt NetEaseMeeting.app -qmldir=../meeting-app/qml
echo "[Paths]" >NetEaseMeeting.app/Contents/Resources/qt.conf
echo "Plugins = Frameworks/NetEaseMeetingClient.app/Contents/PlugIns" >>NetEaseMeeting.app/Contents/Resources/qt.conf
echo "Imports = Frameworks/NetEaseMeetingClient.app/Contents/Resources/qml" >>NetEaseMeeting.app/Contents/Resources/qt.conf
echo "Qml2Imports = Frameworks/NetEaseMeetingClient.app/Contents/Resources/qml" >>NetEaseMeeting.app/Contents/Resources/qt.conf
# codesign
mv ./NetEaseMeeting.app 网易会议.app
appdmg NetEaseMeeting.json ${PACKAGE_FULL_NAME}
cp ${PACKAGE_FULL_NAME} ..
cd ..

if [[ "${CI_COMMIT_BRANCH}" == "master" ]] || [[ "${CI_COMMIT_BRANCH}" =~ "release" ]] || [[ "${CI_COMMIT_BRANCH}" =~ "hotfix" ]]; then
    chmod +x ./build_tool/mac/build-notarized-macx.sh
    ../build_tool/mac/build-notarized-macx.sh ./bin/${PACKAGE_FULL_NAME}
fi

if [ "${BACKUP_DIR}" != "--" ]; then
echo "upload-artifacts"
fi

mkdir ${EXPORT_SDK_DIR_NAME}
cp -R ./meeting-ipc/output_mac/nem_hosting_module/Release/*.framework ./${EXPORT_SDK_DIR_NAME}
cp -R ./bin/NetEaseMeetingClient.app ./${EXPORT_SDK_DIR_NAME}

./meeting-sample/build-macx.sh
cp -R meeting-sample/bin/NEMeetingSample.app ${EXPORT_SDK_DIR_NAME}
#codesign
${EXPORT_SDK_DIR_NAME}/NEMeetingSample.app --deep

cd ${EXPORT_SDK_DIR_NAME}
zip -ry ${SDK_ZIP_NAME} nem_hosting_module.framework NetEaseMeetingClient.app
rm -rf nem_hosting_module.framework
rm -rf NetEaseMeetingClient.app
cd ..

zip -ry ${EXPORT_SDK_FILE} ${EXPORT_SDK_DIR_NAME}/*

if [ "${BACKUP_DIR}" != "--" ]; then
echo "upload-artifacts"
fi

rm -rf nim_sdk_macos
rm -rf FaceUnity-SDK
rm -rf glog
rm -rf jsoncpp
rm -rf libyuv
rm -rf ${EXPORT_SDK_DIR_NAME}
rm -rf bin


