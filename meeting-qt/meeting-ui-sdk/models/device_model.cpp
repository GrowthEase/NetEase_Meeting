/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "device_model.h"
#include <QDebug>

DeviceModel::DeviceModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int DeviceModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid() || !m_manager)
        return 0;

    QVector<DEVICE_INFO> devices;

    if (m_deviceType == kDeviceTypePlayout) {
        devices = m_manager->getPlayoutDevices();
    } else if (m_deviceType == kDeviceTypeRecord) {
        devices = m_manager->getRecordDevices();
    } else if (m_deviceType == kDeviceTypeCapture) {
        devices = m_manager->getCaptureDevices();
    } else {
        return 0;
    }

    return devices.size();
}

QVariant DeviceModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !m_manager)
        return QVariant();

    QVector<DEVICE_INFO> devices;
    if (m_deviceType == kDeviceTypePlayout) {
        devices = m_manager->getPlayoutDevices();
    } else if (m_deviceType == kDeviceTypeRecord) {
        devices = m_manager->getRecordDevices();
    } else if (m_deviceType == kDeviceTypeCapture) {
        devices = m_manager->getCaptureDevices();
    } else {
        return QVariant();
    }

    if (index.row() > devices.size() - 1)
        return QVariant();

    auto device = devices.at(index.row());

    switch (role) {
    case kDeviceName:
        return QVariant(device.deviceName);
    case kDevicePath:
        return QVariant(device.devicePath);
    case kDeviceDefault:
        return QVariant(device.defaultDevice);
    case kDeviceSelected:
        return QVariant(device.selectedDevice);
    case kDeviceUnavailable:
        return QVariant(device.unavailable);
    }

    return QVariant();
}

bool DeviceModel::insertRows(int row, int count, const QModelIndex &parent)
{
    beginInsertRows(parent, row, row + count - 1);
    // FIXME: Implement me!
    endInsertRows();

    return true;
}

bool DeviceModel::removeRows(int row, int count, const QModelIndex &parent)
{
    beginRemoveRows(parent, row, row + count - 1);
    // FIXME: Implement me!
    endRemoveRows();

    return true;
}

QHash<int, QByteArray> DeviceModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[kDeviceName] = "deviceName";
    names[kDevicePath] = "devicePath";
    names[kDeviceSelected] = "deviceSelected";
    names[kDeviceDefault] = "deviceDefault";
    names[kDeviceUnavailable] = "unavailable";
    return names;
}

int DeviceModel::deviceType() const
{
    return m_deviceType;
}

void DeviceModel::setDeviceType(int deviceType)
{
    m_deviceType = deviceType;
}

DeviceManager *DeviceModel::manager() const
{
    return m_manager;
}

void DeviceModel::setManager(DeviceManager *deviceManager)
{
    beginResetModel();

    if (m_manager)
        m_manager->disconnect(this);

    m_manager = deviceManager;

    if (m_manager) {
        connect(m_manager, &DeviceManager::preDeviceListReset, this, [=](DeviceType deviceType) {
            if (deviceType != m_deviceType)
                return;
            beginResetModel();
        });
        connect(m_manager, &DeviceManager::postDeviceListReset, this, [=](DeviceType deviceType) {
            if (deviceType != m_deviceType)
                return;
            endResetModel();
        });
    }

    endResetModel();
}
