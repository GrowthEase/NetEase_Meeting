# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.
#rm -rf output_mac
cmake -H./. -Boutput_mac -G"Xcode"
cmake --build output_mac --config Release
