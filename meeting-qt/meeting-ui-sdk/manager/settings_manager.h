/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include "client_setting_service.h"

class SettingsManager : public QObject {
    Q_OBJECT
public:
    explicit SettingsManager(QObject* parent = nullptr);

    SINGLETONG(SettingsManager);

    Q_PROPERTY(bool enableAudioAfterJoin READ enableAudioAfterJoin WRITE setEnableAudioAfterJoin NOTIFY enableAudioAfterJoinChanged)
    Q_PROPERTY(bool enableVideoAfterJoin READ enableVideoAfterJoin WRITE setEnableVideoAfterJoin NOTIFY enableVideoAfterJoinChanged)

    Q_PROPERTY(bool enableFaceBeauty READ enableFaceBeauty WRITE setEnableFaceBeauty NOTIFY enableFaceBeautyChanged)
    Q_PROPERTY(int faceBeautyLevel READ faceBeautyLevel WRITE setFaceBeautyLevel NOTIFY faceBeautyLevelChanged)

    Q_PROPERTY(bool enableInternalRender READ enableInternalRender WRITE setEnableInternalRender NOTIFY enableInternalRenderChanged)
    Q_PROPERTY(bool mainWindowVisible READ mainWindowVisible WRITE setMainWindowVisible NOTIFY mainWindowVisibleChanged)

    Q_INVOKABLE bool enableAudioAfterJoin() const;
    Q_INVOKABLE void setEnableAudioAfterJoin(bool enableAudioAfterJoin);

    Q_INVOKABLE bool enableVideoAfterJoin() const;
    Q_INVOKABLE void setEnableVideoAfterJoin(bool enableVideoAfterJoin);

    Q_INVOKABLE bool enableFaceBeautyPreview(bool enable);

    Q_INVOKABLE int faceBeautyLevel() const;
    Q_INVOKABLE void setFaceBeautyLevel(int level);

    Q_INVOKABLE bool setEnableFaceBeauty(bool enable);
    Q_INVOKABLE bool enableFaceBeauty() const;

    Q_INVOKABLE void saveFaceBeautyLevel() const;
    Q_INVOKABLE void initFaceBeautyLevel();

    Q_INVOKABLE bool enableInternalRender() const;
    Q_INVOKABLE void setEnableInternalRender(bool enableInternalRender);

    Q_INVOKABLE bool mainWindowVisible() const;
    Q_INVOKABLE void setMainWindowVisible(bool mainWindowVisible);

    bool useInternalRender() const;

signals:
    void enableAudioAfterJoinChanged();
    void enableVideoAfterJoinChanged();
    void enableFaceBeautyChanged();
    void faceBeautyLevelChanged();
    void enableInternalRenderChanged();
    void mainWindowVisibleChanged();

private:
    bool m_enableAudioAfterJoin = false;
    bool m_enableVideoAfterJoin = false;
    bool m_enableFaceBeautyAfterJoin = false;
    int m_FaceBeautyLevel = -1;
    bool m_enableInternalRender = false;
    bool m_mainWindowVisible = false;
};

#endif  // SETTINGSMANAGER_H
