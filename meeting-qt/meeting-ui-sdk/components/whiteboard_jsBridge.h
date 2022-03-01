/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEMJSBRIDGE_H
#define NEMJSBRIDGE_H

#include <QObject>

class WhiteboardJsBridge : public QObject {
    Q_OBJECT

public:
    explicit WhiteboardJsBridge(QObject* parent = 0);

    Q_INVOKABLE void NativeFunction(QString toast);

signals:
    void webPageLoadFinished();

    void webLoginIMSucceed();
    void webLoginIMFailed(int errorCode, const QString& errorMessage);

    void webJoinWriteBoardSucceed();
    void webJoinWriteBoardFailed(int errorCode, const QString& errorMessage);

    void webCreateWriteBoardSucceed();
    void webCreateWriteBoardFailed(int errorCode, const QString& errorMessage);

    void webLeaveWriteBoard();

    void webError(int errorCode, const QString& errorMessage, const QString& errorType);
    void webJsError(const QString& errorMessage);
};

#endif  // NEMJSBRIDGE_H
