/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "more_item_manager.h"
#include <QUuid>
#include "auth_manager.h"
#include "chat_manager.h"
#include "global_manager.h"
#include "meeting/members_manager.h"
#include "meeting/share_manager.h"
#include "meeting_manager.h"

USING_NS_NNEM_SDK_INTERFACE

MoreItemManager::MoreItemManager(QObject* parent)
    : QObject(parent) {
    qmlRegisterUncreatableType<MoreItemEnum>("NetEase.Meeting.MoreItemEnum", 1, 0, "MoreItemEnum", "");

    m_vPresetItems.clear();
    MoreItem itemAudio = {kMicMenuId,
                          QUuid::createUuid().toString(),
                          MoreItemEnum::VisibleAlways,
                          tr("Mute"),
                          "qrc:/qml/images/meeting/footerbar/btn_audio_on_normal.png",
                          tr("Unmte"),
                          "qrc:/qml/images/meeting/footerbar/btn_audio_off_normal.png"};
    m_vPresetItems.push_back(itemAudio);

    MoreItem itemVideo = {kCameraMenuId,
                          QUuid::createUuid().toString(),
                          MoreItemEnum::VisibleAlways,
                          tr("Disable"),
                          "qrc:/qml/images/meeting/footerbar/btn_video_on_normal.png",
                          tr("Enable"),
                          "qrc:/qml/images/meeting/footerbar/btn_video_off_normal.png"};
    m_vPresetItems.push_back(itemVideo);

    MoreItem itemSharing = {kScreenShareMenuId, QUuid::createUuid().toString(), MoreItemEnum::VisibleAlways, tr("Sharing"),
                            "qrc:/qml/images/meeting/footerbar/btn_sharing_normal.png"};
    m_vPresetItems.push_back(itemSharing);

    MoreItem itemWhiteboard = {kWhiteboardMenuId,
                               QUuid::createUuid().toString(),
                               MoreItemEnum::VisibleAlways,
                               tr("open"),
                               "qrc:/qml/images/meeting/footerbar/btn_whiteboard.png",
                               tr("close"),
                               "qrc:/qml/images/meeting/footerbar/stop_whiteboard.png"};

    m_vPresetItems.push_back(itemWhiteboard);

    MoreItem itemMembers = {kParticipantsMenuId, QUuid::createUuid().toString(), MoreItemEnum::VisibleExcludeHost, tr("Members"),
                            "qrc:/qml/images/meeting/footerbar/btn_members_normal.png"};
    m_vPresetItems.push_back(itemMembers);

    MoreItem itemMangeMembers = {kMangeParticipantsMenuId, QUuid::createUuid().toString(), MoreItemEnum::VisibleToHostOnly, tr("Management"),
                                 "qrc:/qml/images/meeting/footerbar/btn_members_normal.png"};
    m_vPresetItems.push_back(itemMangeMembers);

    MoreItem itemView = {kViewMenuId,
                         QUuid::createUuid().toString(),
                         MoreItemEnum::VisibleAlways,
                         tr("View"),
                         "qrc:/qml/images/meeting/footerbar/btn_gallery_view_normal.png",
                         tr("View"),
                         "qrc:/qml/images/meeting/footerbar/btn_focus_view_normal.png"};
    m_vPresetItems.push_back(itemView);

    MoreItem itemChat = {kChatMenuId, QUuid::createUuid().toString(), MoreItemEnum::VisibleAlways, tr("Chat"),
                         "qrc:/qml/images/meeting/footerbar/btn_chat_normal.png"};
    m_vPresetItems.push_back(itemChat);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    MoreItem itemBeauty = {(int)MoreItemEnum::BeautyMenuId, QUuid::createUuid().toString(), MoreItemEnum::VisibleAlways, tr("Beauty"),
                           "qrc:/qml/images/meeting/footerbar/btn_beauty.png"};
    m_itemsPresetMore.push_back(itemBeauty);

    MoreItem itemLive = {(int)MoreItemEnum::LiveMenuId, QUuid::createUuid().toString(), MoreItemEnum::VisibleAlways, tr("Live"),
                         "qrc:/qml/images/meeting/footerbar/btn_live.png"};
    m_itemsPresetMore.push_back(itemLive);

    MoreItem itemInvitation = {kInviteMenuId, QUuid::createUuid().toString(), MoreItemEnum::VisibleAlways, tr("Invitation"),
                               "qrc:/qml/images/meeting/footerbar/btn_invite_normal.png"};
    m_itemsPresetMore.push_back(itemInvitation);

    connect(AuthManager::getInstance(), &AuthManager::isHostAccountChanged, this, [this]() {
        emit micItemVisibleChanged();
        emit cameraItemVisibleChanged();
        emit screenShareItemVisibleChanged();
        emit participantsItemVisibleChanged();
        emit mangeParticipantsItemVisibleChanged();
        emit inviteItemVisibleChanged();
        emit whiteboardItemVisibleChanged();
        emit chatItemVisibleChanged();
        emit viewItemVisibleChanged();

        auto meetingInfo = MeetingManager::getInstance()->getMeetingInfo();
        if (meetingInfo && meetingInfo->getLiveStreamInfo().enable && AuthManager::getInstance()->isHostAccount()) {
            setLiveVisible(true);
        } else {
            setLiveVisible(false);
        }

        emit beginResetItemsMore();
        updateItemsMoreVisible();
        emit endResetItemsMore();
        emit itemCountMoreChanged();
    });

    connect(MeetingManager::getInstance(), &MeetingManager::meetingStatusChanged,
            [this](NEMeeting::Status status, int errorCode, const QString& errorMessage) {
                if (NEMeeting::MEETING_CONNECTED == status || NEMeeting::MEETING_RECONNECTED == status) {
                    auto meetingInfo = MeetingManager::getInstance()->getMeetingInfo();
                    if (meetingInfo && meetingInfo->getLiveStreamInfo().enable && AuthManager::getInstance()->isHostAccount()) {
                        setLiveVisible(true);
                    }
                }
            });

    connect(MembersManager::getInstance(), &MembersManager::countChanged, [this]() {
        if (1 >= MembersManager::getInstance()->count()) {
            modifyItem(kViewMenuId, "", 1);
        }
    });

    connect(ChatManager::getInstance(), &ChatManager::chatRoomOpenChanged, [this]() { emit chatItemVisibleChanged(); });
}

bool MoreItemManager::initializeMore(const QVector<MoreItem>& items) {
    m_moreItemLiveVisible = false;
    if (m_itemsMore.empty() && items.empty() && m_itemsPresetMore.empty()) {
        return true;
    }

    emit beginResetItemsMore();
    if (m_itemsMore.size() > 0)
        m_itemsMore.clear();
    m_itemsMore.reserve(items.size() + m_itemsPresetMore.size());
    if (m_moreItemInjected) {
        m_itemsMore = items;
        for (auto& it : m_itemsPresetMore) {
            m_itemsMore.insert(m_itemsMore.end(), it);
        }
    } else {
        m_itemsMore = m_itemsPresetMore;
        for (auto& it : items) {
            m_itemsMore.insert(m_itemsMore.end(), it);
        }
    }

    updateItemsMoreVisible();
    emit endResetItemsMore();
    emit itemCountMoreChanged();
    return true;
}

void MoreItemManager::restoreMore() {
    m_moreItemInjected = false;
    m_moreItemLiveVisible = false;
    emit beginResetItemsMore();
    m_itemsMore.clear();
    m_itemsMoreVisible.clear();
    m_itemsMore.reserve(m_itemsPresetMore.size());
    m_itemsMore = m_itemsPresetMore;
    updateItemsMoreVisible();
    emit endResetItemsMore();
    emit itemCountMoreChanged();
}

QVector<MoreItem> MoreItemManager::itemsMore() const {
    return m_itemsMoreVisible;
}

void MoreItemManager::updateItemsMoreVisible() {
    m_itemsMoreVisible.clear();
    for (auto& it : m_itemsMore) {
        qInfo() << "it.itemTitle:" << it.itemTitle;
        bool bVisible = false;
        switch (it.itemIndex) {
            case kInviteMenuId:
                bVisible = inviteItemVisible();
                break;
            case kViewMenuId:
                bVisible = viewItemVisible();
                break;
            case kScreenShareMenuId:
                bVisible = screenShareItemVisible();
                break;
            case kParticipantsMenuId:
                bVisible = participantsItemVisible();
                break;
            case kWhiteboardMenuId:
                bVisible = whiteboardItemVisible();
                break;
            case (int)MoreItemEnum::BeautyMenuId:
                bVisible = m_moreItemBeautyVisible;
                break;
            case (int)MoreItemEnum::LiveMenuId:
                bVisible = m_moreItemLiveVisible;
                break;
            default:
                bVisible = getItemVisible(it.itemVisibility);
        }

        if (bVisible) {
            m_itemsMoreVisible.append(it);
        }
    }
}

void MoreItemManager::setBeautyVisible(bool visible) {
    if (visible != m_moreItemBeautyVisible) {
        m_moreItemBeautyVisible = visible;
        emit beginResetItemsMore();
        updateItemsMoreVisible();
        emit endResetItemsMore();
        emit itemCountMoreChanged();
    }
}

void MoreItemManager::setLiveVisible(bool visible) {
    if (visible != m_moreItemLiveVisible) {
        m_moreItemLiveVisible = visible;
        emit beginResetItemsMore();
        updateItemsMoreVisible();
        emit endResetItemsMore();
        emit itemCountMoreChanged();
    }
}

int MoreItemManager::itemCountMore() const {
    return m_itemsMoreVisible.size();
}

int MoreItemManager::itemCountMore_S() const {
    QVector<MoreItem> items = m_itemsMoreVisible;
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

    return items.size() >= 0 ? items.size() : 0;
}

bool MoreItemManager::initializeToolbar(const QVector<MoreItem>& items) {
    if (m_itemsToolbar.empty() && items.empty()) {
        return true;
    }

    emit beginResetItemsToolbar();
    if (m_itemsToolbar.size() > 0)
        m_itemsToolbar.clear();
    m_itemsToolbar.reserve(items.size());
    m_itemsToolbar = items;
    emit endResetItemsToolbar();
    emit itemCountToolbarChanged();
    return true;
}

QVector<MoreItem> MoreItemManager::itemsToolbar() const {
    return m_itemsToolbar;
}

void MoreItemManager::restoreToolbar() {
    emit beginResetItemsToolbar();
    QVector<MoreItem> items(m_vPresetItems.begin(), m_vPresetItems.end());
    m_itemsToolbar.swap(items);
    emit endResetItemsToolbar();
    emit itemCountToolbarChanged();
}

int MoreItemManager::itemCountToolbar() const {
    return m_itemsToolbar.size();
}

void MoreItemManager::clickedItem(const QString& itemGuid) {
    auto* client = NEMeetingSDKIPCClient::getInstance();
    auto* meetingService = dynamic_cast<NEMeetingServiceIPCClient*>(client->getMeetingService());
    if (!meetingService) {
        return;
    }

    MoreItem item(itemGuid);
    int index = m_itemsToolbar.indexOf(item);
    if (-1 != index) {
        item = m_itemsToolbar.at(index);
        if (!item.itemTitle2.isEmpty() && !item.itemImagePath2.isEmpty()) {
            if (kViewMenuId == item.itemIndex) {
                if (MembersManager::getInstance()->count() < 2) {
                } else {
                    modifyItem(item.itemIndex, item.itemGuid, 1 == item.itemCheckedIndex ? 2 : 1);
                }
                return;
            }
        }
        int index2 = m_itemsMoreVisible.indexOf(item);
        if (-1 != index2) {
            item = m_itemsMoreVisible.at(index2);
            if (!item.itemTitle2.isEmpty() && !item.itemImagePath2.isEmpty()) {
                if (kViewMenuId == item.itemIndex && (MembersManager::getInstance()->count() < 2)) {
                } else {
                    modifyItem(item.itemIndex, item.itemGuid, 1 == item.itemCheckedIndex ? 2 : 1);
                }
            }
            return;
        }
    } else {
        index = m_itemsMoreVisible.indexOf(item);
        if (-1 != index) {
            item = m_itemsMoreVisible.at(index);
            MoreItem iteTmp(item.itemIndex);
            if (m_vPresetItems.end() != std::find(m_vPresetItems.begin(), m_vPresetItems.end(), iteTmp)) {
                emit morePresetItemClicked(item.itemIndex);
                if (!item.itemTitle2.isEmpty() && !item.itemImagePath2.isEmpty()) {
                    if (kViewMenuId == item.itemIndex && (MembersManager::getInstance()->count() < 2)) {
                    } else {
                        modifyItem(item.itemIndex, item.itemGuid, 1 == item.itemCheckedIndex ? 2 : 1);
                    }
                }
                return;
            } else if (m_itemsPresetMore.end() != std::find(m_itemsPresetMore.begin(), m_itemsPresetMore.end(), iteTmp)) {
                emit morePresetItemClicked(item.itemIndex);
                if (!item.itemTitle2.isEmpty() && !item.itemImagePath2.isEmpty()) {
                    modifyItem(item.itemIndex, item.itemGuid, 1 == item.itemCheckedIndex ? 2 : 1);
                }
                return;
            }
        }
    }

    if (-1 == index) {
        return;
    }

    QByteArray byteGuid = item.itemGuid.toUtf8();
    QByteArray byteTitle = item.itemTitle.toUtf8();
    QByteArray byteImagePath = item.itemImagePath.toUtf8();
    QByteArray byteTitle2 = item.itemTitle2.toUtf8();
    QByteArray byteImagePath2 = item.itemImagePath2.toUtf8();

    NEMeetingMenuItem nem_item;
    nem_item.itemId = item.itemIndex;
    nem_item.itemGuid = byteGuid.data();
    nem_item.itemTitle = byteTitle.data();
    nem_item.itemImage = byteImagePath.data();
    nem_item.itemTitle2 = byteTitle2.data();
    nem_item.itemImage2 = byteImagePath2.data();
    nem_item.itemVisibility = switchVisibility(item.itemVisibility);
    nem_item.itemCheckedIndex = item.itemCheckedIndex;
    meetingService->onInjectedMenuItemClick(nem_item);
}

bool MoreItemManager::micItemVisible() const {
    MoreItem item;
    if (findItem(kMicMenuId, item)) {
        return getItemVisible(item.itemVisibility);
    }

    return false;
}

bool MoreItemManager::cameraItemVisible() const {
    MoreItem item;
    if (findItem(kCameraMenuId, item)) {
        return getItemVisible(item.itemVisibility);
    }

    return false;
}

bool MoreItemManager::screenShareItemVisible() const {
    MoreItem item;
    if (findItem(kScreenShareMenuId, item)) {
        return MeetingManager::getInstance()->hideScreenShare() && getItemVisible(item.itemVisibility);
    }

    return false;
}

bool MoreItemManager::participantsItemVisible() const {
    MoreItem item;
    if (findItem(kParticipantsMenuId, item)) {
        return getItemVisible(item.itemVisibility);
    }

    return false;
}

bool MoreItemManager::mangeParticipantsItemVisible() const {
    MoreItem item;
    if (findItem(kMangeParticipantsMenuId, item)) {
        return getItemVisible(item.itemVisibility);
    }

    return false;
}

bool MoreItemManager::inviteItemVisible() const {
    MoreItem item;
    if (findItem(kInviteMenuId, item)) {
        return !MeetingManager::getInstance()->hideInvitation() && getItemVisible(item.itemVisibility);
    }

    return false;
}

bool MoreItemManager::whiteboardItemVisible() const {
    MoreItem item;
    if (findItem(kWhiteboardMenuId, item)) {
        auto congigSvr = GlobalManager::getInstance()->getGlobalConfig();
        if (congigSvr != nullptr) {
            return !MeetingManager::getInstance()->hideWhiteboard() && getItemVisible(item.itemVisibility) && congigSvr->isWhiteboardSupported();
        }
    }

    return false;
}

bool MoreItemManager::chatItemVisible() const {
    MoreItem item;
    if (findItem(kChatMenuId, item)) {
        return (0 != GlobalManager::getInstance()->getGlobalConfig()->isChatSupported()) && !MeetingManager::getInstance()->hideChatroom() &&
               getItemVisible(item.itemVisibility);
    }

    return false;
}

bool MoreItemManager::viewItemVisible() const {
    MoreItem item;
    if (findItem(kViewMenuId, item)) {
        return MeetingManager::getInstance()->hideView() && getItemVisible(item.itemVisibility);
    }

    return false;
}

bool MoreItemManager::findItem(int itemIndex, MoreItem& item) const {
    MoreItem itemTmp(itemIndex);
    int index = m_itemsToolbar.indexOf(itemTmp);
    if (-1 != index) {
        item = m_itemsToolbar.at(index);
        return true;
    }

    index = m_itemsMore.indexOf(itemTmp);
    if (-1 != index) {
        item = m_itemsMore.at(index);
        return true;
    }

    return false;
}

bool MoreItemManager::getItemVisible(MoreItemEnum::Visibility visibility) const {
    switch (visibility) {
        case MoreItemEnum::VisibleAlways:
            return true;
        case MoreItemEnum::VisibleExcludeHost:
            return !AuthManager::getInstance()->isHostAccount();
        case MoreItemEnum::VisibleToHostOnly:
            return AuthManager::getInstance()->isHostAccount();
        default:
            break;
    }

    return false;
}

void MoreItemManager::modifyItem(int itemId, const QString& itemGuid, int itemCheckedIndex) {
    MoreItem item(itemId, itemGuid);
    int index = m_itemsMoreVisible.indexOf(item);
    if (-1 != index) {
        auto& it = m_itemsMoreVisible[index];
        if (itemCheckedIndex != it.itemCheckedIndex) {
            it.itemCheckedIndex = itemCheckedIndex;
            emit itemMoreDataChanged(index);
        }
    }

    index = m_itemsToolbar.indexOf(item);
    if (-1 != index) {
        auto& it = m_itemsToolbar[index];
        if (itemCheckedIndex != it.itemCheckedIndex) {
            it.itemCheckedIndex = itemCheckedIndex;
            emit itemToolbarDataChanged(index);
        }
    }
}

void MoreItemManager::getPresetItems(const std::vector<int>& vItemId, std::vector<MoreItem>& vItems) {
    vItems.clear();
    if (vItemId.empty()) {
        vItems.assign(m_vPresetItems.begin(), m_vPresetItems.end());
    } else {
        for (auto& it : vItemId) {
            auto it2 = std::find_if(m_vPresetItems.begin(), m_vPresetItems.end(), [it](const auto& item) { return it == item.itemIndex; });
            if (m_vPresetItems.end() != it2) {
                vItems.push_back(*it2);
            }
        }
    }
}

MoreItemEnum::Visibility MoreItemManager::switchVisibility(nem_sdk_interface::NEMenuVisibility visibility) {
    switch (visibility) {
        case nem_sdk_interface::VISIBLE_ALWAYS:
            return MoreItemEnum::VisibleAlways;
        case nem_sdk_interface::VISIBLE_EXCLUDE_HOST:
            return MoreItemEnum::VisibleExcludeHost;
        case nem_sdk_interface::VISIBLE_TO_HOST_ONLY:
            return MoreItemEnum::VisibleToHostOnly;
        default:
            return MoreItemEnum::VisibleAlways;
    }
}

nem_sdk_interface::NEMenuVisibility MoreItemManager::switchVisibility(MoreItemEnum::Visibility visibility) {
    switch (visibility) {
        case MoreItemEnum::VisibleAlways:
            return nem_sdk_interface::VISIBLE_ALWAYS;
        case MoreItemEnum::VisibleExcludeHost:
            return nem_sdk_interface::VISIBLE_EXCLUDE_HOST;
        case MoreItemEnum::VisibleToHostOnly:
            return nem_sdk_interface::VISIBLE_TO_HOST_ONLY;
        default:
            return nem_sdk_interface::VISIBLE_ALWAYS;
    }
}

QString MoreItemManager::strPathToPath(const std::string& strPath) const {
    QString strTmp = QString::fromStdString(strPath);
#ifdef Q_OS_WIN
    strTmp.replace("\\", "/");
#endif
    return strTmp;
}

bool MoreItemManager::moreItemInjected() const {
    return m_moreItemInjected;
}

void MoreItemManager::setMoreItemInjected(bool moreItemInjected) {
    if (moreItemInjected != m_moreItemInjected) {
        m_moreItemInjected = moreItemInjected;
        emit moreItemInjectedChanged();
    }
}
