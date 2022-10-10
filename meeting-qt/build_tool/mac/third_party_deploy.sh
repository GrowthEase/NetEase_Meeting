#!/usr/bin/env bash

cd ../../

THIRD_PARTY_LIBS_URL=https://yx-web-nosdn.netease.im/package/1664267144062/v3.5.0_third_party_libs.zip?download=v3.5.0_third_party_libs.zip
echo Download third_party_libs ：${THIRD_PARTY_LIBS_URL}
rm -rf ./third_party_libs
mkdir ./third_party_libs
curl ${THIRD_PARTY_LIBS_URL} -o third_party_libs.zip
unzip -o third_party_libs.zip
rm -rf third_party_libs.zip

cd third_party_libs
unzip -o alog/alog_macos.zip
unzip -o jsoncpp/jsoncpp.zip
unzip -o libyuv/libyuv.zip
unzip -o roomkit/NERoomKit_macOS.zip
cp -R NERoomKit_macOS/* roomkit/
rm -rf NERoomKit_macOS
rm -rf __MACOSX
