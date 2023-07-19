// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_devices_model.h"

NEMDevicesModel::NEMDevicesModel(QObject* parent)
    : QAbstractListModel(parent) {}

int NEMDevicesModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid() || !m_deviceController || m_deviceType == NEMDevices::DEVICE_TYPE_UNKNOWN)
        return 0;
    return m_deviceController->getDevices(m_deviceType).size();
}

QVariant NEMDevicesModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || !m_deviceController || m_deviceType == NEMDevices::DEVICE_TYPE_UNKNOWN)
        return QVariant();

    const auto device = m_deviceController->getDevices(m_deviceType).at(index.row());

    switch (role) {
        case DeviceName:
            return QVariant(device.deviceName);
        case DevicePath:
            return QVariant(device.devicePath);
        case DeviceProperty:
            return QVariant(device.unavailable);
    }

    return QVariant();
}

QHash<int, QByteArray> NEMDevicesModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[DeviceName] = "deviceName";
    names[DevicePath] = "deviceId";
    names[DeviceProperty] = "unavailable";
    return names;
}

NEMDevices* NEMDevicesModel::deviceController() const {
    return m_deviceController;
}

void NEMDevicesModel::setDeviceController(NEMDevices* deviceController) {
    if (m_deviceController != deviceController) {
        m_deviceController = deviceController;
        Q_EMIT deviceControllerChanged();
    }
}

NEMDevices::DeviceType NEMDevicesModel::deviceType() const {
    return m_deviceType;
}

void NEMDevicesModel::setDeviceType(const NEMDevices::DeviceType& deviceType) {
    if (m_deviceType != deviceType) {
        beginResetModel();
        m_deviceType = deviceType;
        endResetModel();
        Q_EMIT deviceTypeChanged();
    }
}
