// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_mine.h"

NEMMine::NEMMine(QObject* parent)
    : QObject(parent) {}

void NEMMine::userAudioStatusChanged(const QString& accountId, NEMAudioController::AudioDeviceStatus status) {
    if (accountId == m_accountId) {
        setAudioStatus(status);
    }
}

void NEMMine::userVideoStatusChanged(const QString& accountId, NEMVideoController::VideoDeviceStatus status) {
    if (accountId == m_accountId) {
        setVideoStatus(status);
    }
}

void NEMMine::sharingStatusChanged(const QString& accountId, bool sharing, bool /*paused*/) {
    setSharing(m_accountId == accountId && sharing);
}

bool NEMMine::sharing() const {
    return m_sharing;
}

void NEMMine::setSharing(bool sharing) {
    if (m_sharing != sharing) {
        m_sharing = sharing;
        Q_EMIT sharingChanged();
    }
}

QString NEMMine::accountId() const {
    return m_accountId;
}

void NEMMine::setAccountId(const QString& accountId) {
    if (m_accountId != accountId) {
        m_accountId = accountId;
        Q_EMIT accountIdChanged();
    }
}

NEMVideoController::VideoDeviceStatus NEMMine::videoStatus() const {
    return m_videoStatus;
}

void NEMMine::setVideoStatus(const NEMVideoController::VideoDeviceStatus& videoStatus) {
    if (m_videoStatus != videoStatus) {
        m_videoStatus = videoStatus;
        Q_EMIT videoStatusChanged();
    }
}

NEMAudioController::AudioDeviceStatus NEMMine::audioStatus() const {
    return m_audioStatus;
}

void NEMMine::setAudioStatus(const NEMAudioController::AudioDeviceStatus& audioStatus) {
    if (m_audioStatus != audioStatus) {
        m_audioStatus = audioStatus;
        Q_EMIT audioStatusChanged();
    }
}
