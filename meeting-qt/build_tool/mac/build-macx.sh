#!/bin/bash
# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.
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
CUSTOM_VERSION=$5
IS_PUBLISH=$6

echo BACKUP_DIR "${BACKUP_DIR}"
echo IS_USE_API_TEST "${IS_USE_API_TEST}"
echo CI_COMMIT_BRANCH "${CI_COMMIT_BRANCH}"
echo G2_MACOS_DOWNLOAD_URL "${G2_MACOS_DOWNLOAD_URL}"
echo CUSTOM_VERSION "${CUSTOM_VERSION}"
echo IS_PUBLISH "${IS_PUBLISH}"

VERSION=3.5.0

if [ "${CUSTOM_VERSION}" != "--" ]; then
    VERSION=${CUSTOM_VERSION}
fi

TIMESTAMP=`date +%s`
GIT_COMMIT_COUNT=`git rev-list HEAD --count`
GIT_COMMIT_SHORT_HASH=`git rev-parse --short HEAD`
MAC_OS_VERSION=${VERSION}
QT_BUILD_TOOL=/Users/yunxin/Qt/5.15.0/clang_64/bin/
PACKAGE_FULL_NAME=meeting_macOS_${TIMESTAMP}_${GIT_COMMIT_SHORT_HASH}_online.dmg
SDK_ZIP_NAME=NEMeetingKit_macOS_v${VERSION}.zip
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

mkdir ./third_party_libs/roomkit
cd ../roomkit
python3 ./build.py --build_type=Release
cp -R install/* ../meeting/third_party_libs/roomkit/
cd ../meeting

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
security unlock-keychain -p yunxin163 login.keychain
codesign --entitlements=NetEaseMeeting.entitlements --timestamp --options=runtime -f -s "06C66D0DDF51A99C6A5C0F65BF9B2ABB5FD409B4" -v ./NetEaseMeeting.app --deep
codesign --entitlements=NetEaseMeeting.entitlements --timestamp --options=runtime -f -s "06C66D0DDF51A99C6A5C0F65BF9B2ABB5FD409B4" -v ./NetEaseMeetingClient.app --deep
mv ./NetEaseMeeting.app 网易会议.app
appdmg NetEaseMeeting.json ${PACKAGE_FULL_NAME}

cd ..
if [[ "${CI_COMMIT_BRANCH}" == "master" ]] || [[ "${CI_COMMIT_BRANCH}" =~ "release" ]] || [[ "${CI_COMMIT_BRANCH}" =~ "hotfix" ]]; then
    chmod +x ./build_tool/mac/build-notarized-macx.sh
    ./build_tool/mac/build-notarized-macx.sh ./bin/${PACKAGE_FULL_NAME}
fi

mv -f ./bin/${PACKAGE_FULL_NAME} ./

if [ "${BACKUP_DIR}" != "--" ]; then
echo "upload-artifacts"
chmod +x ./build_tool/mac/scp.exp
sh ./build_tool/mac/upload-artifacts.sh ./${PACKAGE_FULL_NAME} "meeting" "${BACKUP_DIR}/v${VERSION}/macOS"

sh ./build_tool/mac/notify.sh --platform "macOS" --env "online" --version "${VERSION}" \
      --downloadurl "http://10.242.100.195/meeting/${BACKUP_DIR}/v${VERSION}/macOS/${PACKAGE_FULL_NAME}" \
      --gitbranch "${CI_COMMIT_BRANCH}" \
      --artifacts_type "APP" \
      --artifacts_path ./${PACKAGE_FULL_NAME}
fi

mkdir ${EXPORT_SDK_DIR_NAME}
cp -R ./meeting-ipc/output_mac/nem_hosting_module/Release/*.framework ./${EXPORT_SDK_DIR_NAME}
cp -R ./bin/NetEaseMeetingClient.app ./${EXPORT_SDK_DIR_NAME}

chmod +x ./meeting-sample/build-macx.sh
./meeting-sample/build-macx.sh
cp -R meeting-sample/bin/NEMeetingSample.app ${EXPORT_SDK_DIR_NAME}
codesign --entitlements=bin/NetEaseMeeting.entitlements --timestamp --options=runtime -f -s "06C66D0DDF51A99C6A5C0F65BF9B2ABB5FD409B4" -v ${EXPORT_SDK_DIR_NAME}/NEMeetingSample.app --deep

cd ${EXPORT_SDK_DIR_NAME}
zip -ry ${SDK_ZIP_NAME} nem_hosting_module.framework NetEaseMeetingClient.app
rm -rf nem_hosting_module.framework
rm -rf NetEaseMeetingClient.app
cd ..

zip -ry ${EXPORT_SDK_FILE} ${EXPORT_SDK_DIR_NAME}/*

if [ "${BACKUP_DIR}" != "--" ]; then
echo "upload-artifacts"
chmod +x ./build_tool/mac/scp.exp
sh ./build_tool/mac/upload-artifacts.sh ${EXPORT_SDK_FILE} "kit/meeting" "${BACKUP_DIR}/v${VERSION}/macos-sdk"

sh ./build_tool/mac/notify.sh --platform "macOS" --env "online" --version "${VERSION}" \
      --downloadurl "http://10.242.100.195/kit/meeting/${BACKUP_DIR}/v${VERSION}/macos-sdk/${EXPORT_SDK_FILE}" \
      --gitbranch "${CI_COMMIT_BRANCH}" \
      --artifacts_type "SDK" \
      --artifacts_path ${EXPORT_SDK_FILE}
fi

if [ "${IS_PUBLISH}" == "true" ]; then
    echo "admin publish"
    chmod +x ./build_tool/common/admin_upload/upload.sh
    sh ./build_tool/common/admin_upload/upload.sh wangjianzhong mac "" meeting "dmg demo" "" ${VERSION} ${PACKAGE_FULL_NAME}
    cd ${EXPORT_SDK_DIR_NAME}
    sh ../build_tool/common/admin_upload/upload.sh wangjianzhong mac "" meeting "sdk" "" ${VERSION} ${SDK_ZIP_NAME}
    cd ..
fi

rm -rf nim_sdk_macos
rm -rf FaceUnity-SDK
rm -rf glog
rm -rf jsoncpp
rm -rf libyuv
rm -rf ${EXPORT_SDK_DIR_NAME}
rm -rf bin