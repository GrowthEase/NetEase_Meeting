// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_NEMEETING_PLUGIN_H_
#define MEETING_PLUGINS_NEMEETING_PLUGIN_H_

#include <QQmlExtensionPlugin>

class NEMeetingPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char* uri) override;
};

#endif  // MEETING_PLUGINS_NEMEETING_PLUGIN_H_
