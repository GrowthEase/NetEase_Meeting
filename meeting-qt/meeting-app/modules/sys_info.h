/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef SYSINFO_H
#define SYSINFO_H

#include <QObject>

class SysInfo : public QObject
{
    Q_OBJECT
public:
    explicit SysInfo(QObject *parent = nullptr);

    static QString GetSystemManufacturer();
    static QString GetSystemProductName();

private:
    static QString ReadBisoValueFromReg(const QString& key);
};

#endif // SYSINFO_H
