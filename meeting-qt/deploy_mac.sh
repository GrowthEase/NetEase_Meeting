#!/usr/bin/env bash
# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

cd -P $(dirname "${BASH_SOURCE[0]}")

cd ./build_tool/mac
chmod +x third_party_deploy.sh
./third_party_deploy.sh ""

cd ../../meeting-ipc
./build_macx.sh

cd ..
rm -rf build