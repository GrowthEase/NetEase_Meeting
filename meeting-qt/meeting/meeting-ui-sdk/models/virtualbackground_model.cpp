// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "virtualbackground_model.h"
#include "manager/global_manager.h"
#include "manager/settings_manager.h"

VirtualBackgroundModel::VirtualBackgroundModel(QObject* parent)
    : QAbstractListModel(parent) {}

VirtualBackgroundModel::~VirtualBackgroundModel() {}

int VirtualBackgroundModel::rowCount(const QModelIndex& parent) const {
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid())
        return 0;

    return SettingsManager::getInstance()->getVirtualBackgroundList().size();
}

QVariant VirtualBackgroundModel::data(const QModelIndex& index, int role) const {
    auto indexTmp = index.row();
    auto vectVB = SettingsManager::getInstance()->getVirtualBackgroundList();
    if (!index.isValid() || indexTmp >= vectVB.size() || indexTmp < 0)
        return QVariant();

    switch (role) {
        case kVBPath:
            return QVariant(vectVB.at(indexTmp).strPath);
        case kVBAllowedDelete:
            return QVariant(vectVB.at(indexTmp).bAllowedDelete);
        case kVBCurrentSelected:
            return QVariant(vectVB.at(indexTmp).bCurrentSelected);
        default:
            break;
    }

    return QVariant();
}

QHash<int, QByteArray> VirtualBackgroundModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[kVBPath] = "vbPath";
    names[kVBAllowedDelete] = "vbAllowedDelete";
    names[kVBCurrentSelected] = "vbCurrentSelected";

    return names;
}

const std::vector<VirtualBackgroundModel::VBProperty>& VirtualBackgroundModel::virtualBackgroundList() const {
    return SettingsManager::getInstance()->getVirtualBackgroundList();
}

void VirtualBackgroundModel::addVB(const QString& filePathUrl) {
    QString newFilePath;
    QString filePath = QUrl(filePathUrl).toLocalFile();
    QFile file(filePath);
    if (file.exists(filePath)) {
        QString vbPath = SettingsManager::getInstance()->getVirtualBackgroundPath();
        YXLOG(Error) << "vbPath. filePath: " << vbPath.toStdString() << YXLOGEnd;
        newFilePath = vbPath + QString::number(QDateTime::currentDateTimeUtc().toTime_t()) + "_+_+_" + QFileInfo(filePath).fileName();
        if (!file.copy(newFilePath)) {
            YXLOG(Error) << "addVB, copyFile error. filePath: " << filePath.toStdString() << ", error: " << file.errorString().toStdString()
                         << ", newFilePath: " << newFilePath.toStdString() << YXLOGEnd;
            SettingsManager::getInstance()->virtualBackgroundChanged(false, tr("add failed"));
            return;
        }
    }
    int indexUnSelected = -1;
    auto& vectVB = SettingsManager::getInstance()->getVirtualBackgroundList();
    for (int i = 0; i < (int)vectVB.size(); i++) {
        if (vectVB[i].bCurrentSelected) {
            indexUnSelected = i;
            vectVB[i].bCurrentSelected = false;
            break;
        }
    }

    if (indexUnSelected >= 0) {
        QModelIndex modelIndex = createIndex(indexUnSelected, 0);
        emit dataChanged(modelIndex, modelIndex, QVector<int>{kVBCurrentSelected});
    }

    if (vectVB.empty()) {
        return;
    }

    int indexSelected = vectVB.size() - 1;
    emit beginInsertRows(QModelIndex(), indexSelected, indexSelected);
    vectVB.insert(vectVB.begin() + indexSelected, VBProperty{newFilePath, true, true});
    emit endInsertRows();

    auto rtc = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (rtc) {
        if (indexSelected > 0) {
            NERoomVirtualBackgroundSource source;
            source.sourceType = kNEBackgroundImage;
            source.path = newFilePath.toStdString();
            rtc->enableVirtualBackground(true, source);
            SettingsManager::getInstance()->setVirtualBackground(indexSelected);
        }
    }
}

void VirtualBackgroundModel::removeVB(const QString& filePath) {
    QFile file(filePath);
    if (!file.remove()) {
        YXLOG(Error) << "removeVB, removeFile error. filePath: " << filePath.toStdString() << ", error: " << file.errorString().toStdString()
                     << YXLOGEnd;
        return;
    }

    auto& vectVB = SettingsManager::getInstance()->getVirtualBackgroundList();
    auto itFind = std::find_if(vectVB.begin(), vectVB.end(), [filePath](const auto& it) { return it.strPath == filePath; });
    if (vectVB.end() != itFind) {
        bool bCurrentSelected = itFind->bCurrentSelected;
        int index = std::distance(vectVB.begin(), itFind);
        emit beginRemoveRows(QModelIndex(), index, index);
        vectVB.erase(itFind);
        emit endRemoveRows();
        if (!vectVB.empty() && bCurrentSelected) {
            vectVB.begin()->bCurrentSelected = true;
            QModelIndex modelIndex = createIndex(0, 0);
            emit dataChanged(modelIndex, modelIndex, QVector<int>{kVBCurrentSelected});

            auto rtc = GlobalManager::getInstance()->getPreviewRoomRtcController();
            if (rtc) {
                rtc->enableVirtualBackground(false, NERoomVirtualBackgroundSource{});
            }
        }
        if (bCurrentSelected) {
            SettingsManager::getInstance()->setVirtualBackground(0);
        }
    }
}

void VirtualBackgroundModel::setSelectedVB(const QString& filePath) {
    int indexSelected = -1;
    int indexUnSelected = -1;
    auto& vectVB = SettingsManager::getInstance()->getVirtualBackgroundList();
    for (int i = 0; i < (int)vectVB.size(); i++) {
        if (vectVB[i].strPath == filePath) {
            indexSelected = i;
            vectVB[i].bCurrentSelected = true;
        } else if (vectVB[i].bCurrentSelected) {
            indexUnSelected = i;
            vectVB[i].bCurrentSelected = false;
        }
    }

    if (indexSelected < 0 && indexUnSelected < 0) {
        return;
    }

    QModelIndex modelIndex = createIndex(indexSelected, 0);
    emit dataChanged(modelIndex, modelIndex, QVector<int>{kVBCurrentSelected});

    QModelIndex modelIndex2 = createIndex(indexUnSelected, 0);
    emit dataChanged(modelIndex2, modelIndex2, QVector<int>{kVBCurrentSelected});

    auto rtc = GlobalManager::getInstance()->getPreviewRoomRtcController();
    if (rtc) {
        if (indexSelected > 0) {
            NERoomVirtualBackgroundSource source;
            source.sourceType = kNEBackgroundImage;
            source.path = vectVB.at(indexSelected).strPath.toStdString();
            rtc->enableVirtualBackground(true, source);
        } else {
            rtc->enableVirtualBackground(false, NERoomVirtualBackgroundSource{});
        }
    }
    SettingsManager::getInstance()->setVirtualBackground(indexSelected);
}
