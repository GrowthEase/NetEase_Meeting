/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef MOREITEMMANAGER_H
#define MOREITEMMANAGER_H

#include <QObject>
#include "ipc_handlers/hosting_module_client.h"

class MoreItemEnum : public QObject {
    Q_GADGET
public:
    explicit MoreItemEnum() {}
    enum Status {
        MicMenuId = kMicMenuId,
        CameraMenuId = kCameraMenuId,
        ScreenShareMenuId = kScreenShareMenuId,
        ParticipantsMenuId = kParticipantsMenuId,
        MangeParticipantsMenuId = kMangeParticipantsMenuId,
        InviteMenuId = kInviteMenuId,
        ChatMenuId = kChatMenuId,
        ViewMenuId = kViewMenuId,
        WhiteboardMenuId = kWhiteboardMenuId,

        BeautyMenuId = 50,  // 预置的更多按钮
        LiveMenuId = 51,    // 预置的更多按钮
    };
    Q_ENUM(Status)

    enum Visibility {
        VisibleAlways = 0,       // 始终可见
        VisibleExcludeHost = 1,  // 主持人不可见
        VisibleToHostOnly = 2,   // 仅主持人可见
    };
    Q_ENUM(Visibility)
};

typedef struct tagMoreItem {
    tagMoreItem() {}
    tagMoreItem(const QString& itemGuidTmp)
        : itemGuid(itemGuidTmp) {}
    tagMoreItem(int itemIndexTmp, const QString& itemGuidTmp = QString())
        : itemIndex(itemIndexTmp)
        , itemGuid(itemGuidTmp) {}
    tagMoreItem(int itemIndexTmp,
                const QString& itemGuidTmp,
                MoreItemEnum::Visibility itemVisibilityTmp,
                const QString& itemTitleTmp,
                const QString& itemImagePathTmp,
                const QString& itemTitle2Tmp = QString(),
                const QString& itemImagePath2Tmp = QString(),
                int itemCheckedIndexTmp = 1)
        : itemIndex(itemIndexTmp)
        , itemGuid(itemGuidTmp)
        , itemTitle(itemTitleTmp)
        , itemImagePath(itemImagePathTmp)
        , itemTitle2(itemTitle2Tmp)
        , itemImagePath2(itemImagePath2Tmp)
        , itemVisibility(itemVisibilityTmp)
        , itemCheckedIndex(itemCheckedIndexTmp) {}
    int itemIndex = -1;
    QString itemGuid;
    QString itemTitle;
    QString itemImagePath;
    QString itemTitle2;
    QString itemImagePath2;
    MoreItemEnum::Visibility itemVisibility = MoreItemEnum::VisibleAlways;
    int itemCheckedIndex = 1;  // 菜单项当前的状态（即对应当前显示的名称），默认为1，1是itemTitle， 2是itemTitle2

    bool operator==(const tagMoreItem& item) const { return item.itemGuid == itemGuid || item.itemIndex == itemIndex; }
} MoreItem;

class MoreItemManager : public QObject {
    Q_OBJECT
private:
    explicit MoreItemManager(QObject* parent = nullptr);
    Q_PROPERTY(int itemCountMore READ itemCountMore NOTIFY itemCountMoreChanged)
    Q_PROPERTY(int itemCountToolbar READ itemCountToolbar NOTIFY itemCountToolbarChanged)
    Q_PROPERTY(bool micItemVisible READ micItemVisible NOTIFY micItemVisibleChanged)
    Q_PROPERTY(bool cameraItemVisible READ cameraItemVisible NOTIFY cameraItemVisibleChanged)
    Q_PROPERTY(bool screenShareItemVisible READ screenShareItemVisible NOTIFY screenShareItemVisibleChanged)
    Q_PROPERTY(bool participantsItemVisible READ participantsItemVisible NOTIFY participantsItemVisibleChanged)
    Q_PROPERTY(bool mangeParticipantsItemVisible READ mangeParticipantsItemVisible NOTIFY mangeParticipantsItemVisibleChanged)
    Q_PROPERTY(bool inviteItemVisible READ inviteItemVisible NOTIFY inviteItemVisibleChanged)
    Q_PROPERTY(bool whiteboardItemVisible READ whiteboardItemVisible NOTIFY whiteboardItemVisibleChanged)
    Q_PROPERTY(bool chatItemVisible READ chatItemVisible NOTIFY chatItemVisibleChanged)
    Q_PROPERTY(bool viewItemVisible READ viewItemVisible NOTIFY viewItemVisibleChanged)
    Q_PROPERTY(bool moreItemInjected READ moreItemInjected WRITE setMoreItemInjected NOTIFY moreItemInjectedChanged)

public:
    SINGLETONG(MoreItemManager)
    MoreItemEnum::Visibility switchVisibility(nem_sdk_interface::NEMenuVisibility);
    nem_sdk_interface::NEMenuVisibility switchVisibility(MoreItemEnum::Visibility);
    QString strPathToPath(const std::string& strPath) const;

    void modifyItem(int itemId, const QString& itemGuid, int itemCheckedIndex);

    bool initializeMore(const QVector<MoreItem>& items);
    void restoreMore();
    int itemCountMore() const;
    QVector<MoreItem> itemsMore() const;

    bool initializeToolbar(const QVector<MoreItem>& items);
    void restoreToolbar();
    int itemCountToolbar() const;
    QVector<MoreItem> itemsToolbar() const;

    void getPresetItems(const std::vector<int>& vItemId, std::vector<MoreItem>& vItems);

    void setMoreItemInjected(bool moreItemInjected);

    Q_INVOKABLE void clickedItem(const QString& itemGuid);
    Q_INVOKABLE int itemCountMore_S() const;
    Q_INVOKABLE void setBeautyVisible(bool visible);
    Q_INVOKABLE void setLiveVisible(bool visible);

    bool micItemVisible() const;
    bool cameraItemVisible() const;
    bool screenShareItemVisible() const;
    bool participantsItemVisible() const;
    bool mangeParticipantsItemVisible() const;
    bool inviteItemVisible() const;
    bool whiteboardItemVisible() const;
    bool chatItemVisible() const;
    bool viewItemVisible() const;

    bool moreItemInjected() const;

signals:
    void beginResetItemsMore();
    void endResetItemsMore();
    void itemCountMoreChanged();

    void beginResetItemsToolbar();
    void endResetItemsToolbar();
    void itemCountToolbarChanged();

    void itemMoreDataChanged(int index);
    void itemToolbarDataChanged(int index);

    void micItemVisibleChanged();
    void cameraItemVisibleChanged();
    void screenShareItemVisibleChanged();
    void participantsItemVisibleChanged();
    void mangeParticipantsItemVisibleChanged();
    void inviteItemVisibleChanged();
    void whiteboardItemVisibleChanged();
    void chatItemVisibleChanged();
    void viewItemVisibleChanged();

    void morePresetItemClicked(int itemIndex);
    void moreItemInjectedChanged();

private:
    bool findItem(int itemIndex, MoreItem& item) const;
    bool getItemVisible(MoreItemEnum::Visibility visibility) const;
    void updateItemsMoreVisible();

private:
    QVector<MoreItem> m_itemsMore;
    QVector<MoreItem> m_itemsMoreVisible;
    QVector<MoreItem> m_itemsPresetMore;

    QVector<MoreItem> m_itemsToolbar;
    std::vector<MoreItem> m_vPresetItems;
    bool m_moreItemInjected = false;
    bool m_moreItemBeautyVisible = false;
    bool m_moreItemLiveVisible = false;
};

#endif  // MOREITEMMANAGER_H
