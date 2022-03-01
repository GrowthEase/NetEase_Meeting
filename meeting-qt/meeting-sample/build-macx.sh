#!/bin/bash

TIMESTAMP=`date +%s`
GIT_COMMIT_COUNT=`git rev-list HEAD --count`
GIT_COMMIT_SHORT_HASH=`git rev-parse --short HEAD`
QT_BUILD_TOOL=/Users/yunxin/Qt/5.15.0/clang_64/bin/

PATH=$PATH:$QT_BUILD_TOOL
SCRIPT_PATH=$(cd "$(dirname "$0")";pwd)

echo ${SCRIPT_PATH}
cd ${SCRIPT_PATH}

qmake -config release meeting-sample.pro -spec macx-clang
make

echo "[Paths]" >bin/NEMeetingSample.app/Contents/Resources/qt.conf
echo "Plugins = Frameworks/NetEaseMeetingClient.app/Contents/PlugIns" >>bin/NEMeetingSample.app/Contents/Resources/qt.conf
echo "Imports = Frameworks/NetEaseMeetingClient.app/Contents/Resources/qml" >>bin/NEMeetingSample.app/Contents/Resources/qt.conf
echo "Qml2Imports = Frameworks/NetEaseMeetingClient.app/Contents/Resources/qml" >>bin/NEMeetingSample.app/Contents/Resources/qt.conf


