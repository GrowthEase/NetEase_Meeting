/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef MOREITEMMODEL_H
#define MOREITEMMODEL_H

#include <QAbstractListModel>
#include <QQuickImageProvider>
#include "manager/more_item_manager.h"

class MoreItemModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit MoreItemModel(QObject *parent = nullptr);
    ~MoreItemModel();

    Q_PROPERTY(MoreItemManager* itemManager READ itemManager WRITE setItemManager NOTIFY itemManagerChanged)
    Q_PROPERTY(bool sharing READ sharing WRITE setSharing NOTIFY sharingChanged)

    enum {
        kItemIndex = Qt::UserRole,
        kItemGuid,
        kItemTitle,
        kItemImage,
        kItemTitle2,
        kItemImage2,
        kItemVisibility,
        kItemCheckedIndex,
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    MoreItemManager *itemManager() const;
    void setItemManager(MoreItemManager *itemManager);

    bool sharing() const;
    void setSharing(bool sharing);

signals:
    void itemManagerChanged();
    void sharingChanged();

private slots:
    void onBeginResetItemsMore();
    void onEndResetItemsMore();
    void onItemMoreDataChanged(int index);

private:
    MoreItemManager* m_itemManager = nullptr;
    bool m_bSharing = false;
};

/////////////////////////////////////////////////////////////////////
class ToolbarItemModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit ToolbarItemModel(QObject *parent = nullptr);
    ~ToolbarItemModel();

    Q_PROPERTY(MoreItemManager* itemManager READ itemManager WRITE setItemManager NOTIFY itemManagerChanged)

    enum {
        kItemIndex = Qt::UserRole,
        kItemGuid,
        kItemTitle,
        kItemImage,
        kItemTitle2,
        kItemImage2,
        kItemVisibility,
        kItemCheckedIndex,
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    MoreItemManager *itemManager() const;
    void setItemManager(MoreItemManager *itemManager);

signals:
    void itemManagerChanged();

private slots:
    void onBeginResetItemsToolbar();
    void onEndResetItemsToolbar();
    void onItemToolbarDataChanged(int index);

private:
    MoreItemManager* m_itemManager = nullptr;
};

class localImageProvider : public QQuickImageProvider
{
public:
    localImageProvider();
    virtual QPixmap requestPixmap(const QString& filePath, QSize* size, const QSize& requestedSize) override;
};
#endif // MOREITEMMODEL_H
