// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEMJSBRIDGE_H
#define NEMJSBRIDGE_H

#include <QObject>

class URSJsBridge : public QObject {
    Q_OBJECT

public:
    explicit URSJsBridge(QObject* parent = 0);

    Q_INVOKABLE void NativeFunction(QString response);
    Q_INVOKABLE QJsonObject getHttpRawHeader();
    Q_INVOKABLE void onRenderFinished();
    Q_INVOKABLE void onLoginClicked();
    Q_INVOKABLE void onError();
signals:
    void ursLoginFinished(QJsonObject object);
    void ursRenderFinished();
    void ursLoginClicked();
    void ursLoginError();
};

#endif  // NEMJSBRIDGE_H
