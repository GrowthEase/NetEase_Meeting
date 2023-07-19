// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_MODELS_NEM_DEVICES_MODEL_H_
#define MEETING_PLUGINS_MODELS_NEM_DEVICES_MODEL_H_

#include <QAbstractListModel>
#include "components/devices/nem_devices.h"

class NEMDevicesModel : public QAbstractListModel {
    Q_OBJECT

public:
    explicit NEMDevicesModel(QObject* parent = nullptr);

    enum { DeviceName, DevicePath, DeviceProperty };

    Q_PROPERTY(NEMDevices* deviceController READ deviceController WRITE setDeviceController NOTIFY deviceControllerChanged)
    Q_PROPERTY(NEMDevices::DeviceType deviceType READ deviceType WRITE setDeviceType NOTIFY deviceTypeChanged)

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    NEMDevices* deviceController() const;
    void setDeviceController(NEMDevices* deviceController);

    NEMDevices::DeviceType deviceType() const;
    void setDeviceType(const NEMDevices::DeviceType& deviceType);

Q_SIGNALS:
    void deviceControllerChanged();
    void deviceTypeChanged();

private:
    NEMDevices* m_deviceController = nullptr;
    NEMDevices::DeviceType m_deviceType = NEMDevices::DEVICE_TYPE_UNKNOWN;
};

#endif  // MEETING_PLUGINS_MODELS_NEM_DEVICES_MODEL_H_
