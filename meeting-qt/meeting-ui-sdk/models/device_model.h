/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef DEVICEMODEL_H
#define DEVICEMODEL_H

#include <QAbstractListModel>
#include "manager/device_manager.h"

class DeviceModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit DeviceModel(QObject *parent = nullptr);

    Q_PROPERTY(int deviceType READ deviceType WRITE setDeviceType)
    Q_PROPERTY(DeviceManager* manager READ manager WRITE setManager NOTIFY managerChanged)

    enum {
        kDeviceTypeDefault,
        kDeviceTypePlayout,
        kDeviceTypeRecord,
        kDeviceTypeCapture
    };

    enum {
        kDeviceName = Qt::UserRole,
        kDevicePath,
        kDeviceSelected,
        kDeviceDefault,
        kDeviceUnavailable
    };

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    // Get data
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    // Add data:
    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;

    // Remove data:
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;

    // Get role names
    virtual QHash<int, QByteArray> roleNames() const override;

    int deviceType() const;
    void setDeviceType(int deviceType);

    DeviceManager *manager() const;
    void setManager(DeviceManager *manager);

signals:
    void managerChanged();

private:
    int m_deviceType = kDeviceTypeDefault;
    DeviceManager *m_manager = nullptr;

};

#endif // DEVICEMODEL_H
