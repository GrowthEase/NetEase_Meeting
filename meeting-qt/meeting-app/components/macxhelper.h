/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef MOUNTFILE_H
#define MOUNTFILE_H

#include <string>
#include <QObject>

class Macxhelper : public QObject
{
    Q_OBJECT
public:
    Macxhelper(const QString& dmgFile, QObject* parent = nullptr);

signals:
    void installFinished();

public slots:
    void installFromDMG();

private:
    QString m_strDmgFile;
};

#endif // MOUNTFILE_H
