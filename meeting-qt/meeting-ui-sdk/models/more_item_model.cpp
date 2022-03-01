/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#include "more_item_model.h"

MoreItemModel::MoreItemModel(QObject* parent)
    : QAbstractListModel(parent) {}

MoreItemModel::~MoreItemModel() {
    if (m_itemManager)
        m_itemManager->disconnect(this);
}

int MoreItemModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid() || !m_itemManager)
        return 0;

    QVector<MoreItem> items = m_itemManager->itemsMore();
    if (m_bSharing) {
        int index = items.indexOf(MoreItem(kScreenShareMenuId));
        if (-1 != index) {
            items.remove(index);
        }
        index = items.indexOf(MoreItem(kViewMenuId));
        if (-1 != index) {
            items.remove(index);
        }
        index = items.indexOf(MoreItem((int)MoreItemEnum::BeautyMenuId));
        if (-1 != index) {
            items.remove(index);
        }
    }
    return items.size() >= 0 ? items.size() : 0;
}

QVariant MoreItemModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || !m_itemManager)
        return QVariant();

    QVector<MoreItem> items = m_itemManager->itemsMore();
    if (m_bSharing) {
        int index = items.indexOf(MoreItem(kScreenShareMenuId));
        if (-1 != index) {
            items.remove(index);
        }
        index = items.indexOf(MoreItem(kViewMenuId));
        if (-1 != index) {
            items.remove(index);
        }
        index = items.indexOf(MoreItem((int)MoreItemEnum::BeautyMenuId));
        if (-1 != index) {
            items.remove(index);
        }
    }
    if (index.row() > (items.size() - 1))
        return QVariant();

    auto item = items.at(index.row());

    switch (role) {
        case kItemIndex:
            return QVariant(item.itemIndex);
        case kItemGuid:
            return QVariant(item.itemGuid);
        case kItemTitle:
            return QVariant(item.itemTitle);
        case kItemImage:
            return QVariant(item.itemImagePath);
        case kItemTitle2:
            return QVariant(item.itemTitle2);
        case kItemImage2:
            return QVariant(item.itemImagePath2);
        case kItemVisibility:
            return QVariant(item.itemVisibility);
        case kItemCheckedIndex:
            return QVariant(item.itemCheckedIndex);
        default:
            break;
    }

    return QVariant();
}

QHash<int, QByteArray> MoreItemModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[kItemIndex] = "itemIndex";
    names[kItemGuid] = "itemGuid";
    names[kItemTitle] = "itemTitle";
    names[kItemImage] = "itemImage";
    names[kItemTitle2] = "itemTitle2";
    names[kItemImage2] = "itemImage2";
    names[kItemVisibility] = "itemVisibility";
    names[kItemCheckedIndex] = "itemCheckedIndex";
    return names;
}

bool MoreItemModel::sharing() const {
    return m_bSharing;
}

void MoreItemModel::setSharing(bool sharing) {
    if (sharing != m_bSharing) {
        m_bSharing = sharing;
        emit sharingChanged();
    }
}

MoreItemManager* MoreItemModel::itemManager() const {
    return m_itemManager;
}

void MoreItemModel::setItemManager(MoreItemManager* itemManager) {
    if (itemManager == m_itemManager) {
        return;
    }

    if (m_itemManager) {
        m_itemManager->disconnect(this);
    }

    m_itemManager = itemManager;
    if (m_itemManager) {
        beginResetModel();
        connect(m_itemManager, &MoreItemManager::beginResetItemsMore, this, &MoreItemModel::onBeginResetItemsMore);
        connect(m_itemManager, &MoreItemManager::endResetItemsMore, this, &MoreItemModel::onEndResetItemsMore);
        connect(m_itemManager, &MoreItemManager::itemMoreDataChanged, this, &MoreItemModel::onItemMoreDataChanged);
        endResetModel();
    }
}

void MoreItemModel::onBeginResetItemsMore() {
    emit beginResetModel();
}

void MoreItemModel::onEndResetItemsMore() {
    emit endResetModel();
}

void MoreItemModel::onItemMoreDataChanged(int index) {
    QModelIndex modelIndex = createIndex(index, 0);
    QVector<int> roles = {kItemCheckedIndex};
    emit dataChanged(modelIndex, modelIndex, roles);
}

/////////////////////////////////////////////////////////////////////
ToolbarItemModel::ToolbarItemModel(QObject* parent)
    : QAbstractListModel(parent) {}

ToolbarItemModel::~ToolbarItemModel() {
    if (m_itemManager)
        m_itemManager->disconnect(this);
}

int ToolbarItemModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid() || !m_itemManager)
        return 0;

    return m_itemManager->itemsToolbar().size();
}

QVariant ToolbarItemModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || !m_itemManager)
        return QVariant();

    if (index.row() > m_itemManager->itemsToolbar().size() - 1)
        return QVariant();

    auto item = m_itemManager->itemsToolbar().at(index.row());

    switch (role) {
        case kItemIndex:
            return QVariant(item.itemIndex);
        case kItemGuid:
            return QVariant(item.itemGuid);
        case kItemTitle:
            return QVariant(item.itemTitle);
        case kItemImage:
            return QVariant(item.itemImagePath);
        case kItemTitle2:
            return QVariant(item.itemTitle2);
        case kItemImage2:
            return QVariant(item.itemImagePath2);
        case kItemVisibility:
            return QVariant(item.itemVisibility);
        case kItemCheckedIndex:
            return QVariant(item.itemCheckedIndex);
        default:
            break;
    }

    return QVariant();
}

QHash<int, QByteArray> ToolbarItemModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[kItemIndex] = "itemIndex";
    names[kItemGuid] = "itemGuid";
    names[kItemTitle] = "itemTitle";
    names[kItemImage] = "itemImage";
    names[kItemTitle2] = "itemTitle2";
    names[kItemImage2] = "itemImage2";
    names[kItemVisibility] = "itemVisibility";
    names[kItemCheckedIndex] = "itemCheckedIndex";
    return names;
}

MoreItemManager* ToolbarItemModel::itemManager() const {
    return m_itemManager;
}

void ToolbarItemModel::setItemManager(MoreItemManager* itemManager) {
    if (itemManager == m_itemManager) {
        return;
    }
    if (m_itemManager) {
        m_itemManager->disconnect(this);
    }

    m_itemManager = itemManager;
    if (m_itemManager) {
        beginResetModel();
        connect(m_itemManager, &MoreItemManager::beginResetItemsToolbar, this, &ToolbarItemModel::onBeginResetItemsToolbar);
        connect(m_itemManager, &MoreItemManager::endResetItemsToolbar, this, &ToolbarItemModel::onEndResetItemsToolbar);
        connect(m_itemManager, &MoreItemManager::itemToolbarDataChanged, this, &ToolbarItemModel::onItemToolbarDataChanged);
        endResetModel();
    }
}

void ToolbarItemModel::onBeginResetItemsToolbar() {
    emit beginResetModel();
}

void ToolbarItemModel::onEndResetItemsToolbar() {
    emit endResetModel();
}

void ToolbarItemModel::onItemToolbarDataChanged(int index) {
    QModelIndex modelIndex = createIndex(index, 0);
    QVector<int> roles = {kItemCheckedIndex};
    emit dataChanged(modelIndex, modelIndex, roles);
}

localImageProvider::localImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap) {}

QPixmap localImageProvider::requestPixmap(const QString& filePath, QSize* size, const QSize& requestedSize) {
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)

    QPixmap pixmap(filePath);
    if (pixmap.isNull()) {
        YXLOG(Info) << "file load failed, filepath: " << filePath.toStdString() << YXLOGEnd;
    }

    return pixmap;
}
