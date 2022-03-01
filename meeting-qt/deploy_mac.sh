#!/usr/bin/env bash
cd -P $(dirname "${BASH_SOURCE[0]}")

cd ./build_tool/mac
chmod +x third_party_deploy.sh
./third_party_deploy.sh ""

cd ../../meeting-ipc
chmod +x build_macx.sh
./build_macx.sh

cd ..
rm -rf build