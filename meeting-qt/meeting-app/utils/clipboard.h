/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef CLIPBOARD_H
#define CLIPBOARD_H

#include <QGuiApplication>
#include <QObject>
#include <QClipboard>

class Clipboard : public QObject
{
    Q_OBJECT
public:
    explicit Clipboard(QObject *parent = nullptr);
    Q_INVOKABLE void setText(QString text);
    Q_INVOKABLE QString getText();
private:
    QClipboard *clipboard;
};

#endif // CLIPBOARD_H
