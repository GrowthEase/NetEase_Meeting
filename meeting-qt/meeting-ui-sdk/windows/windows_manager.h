/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef WINDOWSMANAGER_H
#define WINDOWSMANAGER_H

#include <QObject>

class WindowsManager : public QObject
{
    Q_OBJECT
public:
    explicit WindowsManager(QObject *parent = nullptr);

signals:

private:
};

#endif // WINDOWSMANAGER_H
