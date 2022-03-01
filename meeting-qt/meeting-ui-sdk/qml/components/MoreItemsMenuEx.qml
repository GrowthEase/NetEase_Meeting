import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NetEase.Meeting.MoreItemModel 1.0
import NetEase.Meeting.MoreItemEnum 1.0

Popup {
    id: root
    property alias bSharing: listModel.sharing
    height: gridView.height + 8
    width: gridView.width + 8
    padding: 4
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0
    margins: 0
    background: Rectangle {
        radius: 4
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#33333F"
            }
            GradientStop {
                position: 1.0
                color: "#292933"
            }
        }
    }

    function resetItem() {
        listModel.itemManager = null
        gridView.model = null
    }

    MoreItemModel {
        id: listModel
        itemManager: moreItemManager
    }

    GridView {
        id: gridView
        anchors.left: parent.Left
        anchors.top: parent.top
        model: (null === listModel.itemManager) ? null : listModel
        width: count > 3 ? (3 * cellWidth) : (count * cellWidth)
        height: count > 3 ? (Math.ceil(count / 3) * cellHeight) : cellHeight
        cellWidth: 60
        cellHeight: 68
        clip: true
        delegate: Item {
            id: delegate
            width: gridView.cellWidth
            height: gridView.cellHeight
            ImageTipButton {
                anchors.fill: parent
                itemIcon: getItemImage((1 === model.itemCheckedIndex) ? model.itemImage : model.itemImage2)
                itemText: (1 === model.itemCheckedIndex) ? model.itemTitle : model.itemTitle2
                tipNum: (MoreItemEnum.ParticipantsMenuId === model.itemIndex) ? membersManager.count : 0
                //visible: getItemVisibleEx(model) && getItemVisible(imodel.itemVisibility)
                onClicked: {
                    moreItemManager.clickedItem(model.itemGuid)
                    root.close()
                }
            }
        }
    }

    function getItmesCount() {
        return listView.count
    }

    function getItemVisibleEx(model) {
        var show = true
        switch (model.itemIndex) {
        case MoreItemEnum.ScreenShareMenuId:
            show = meetingManager.hideScreenShare
            break
        case MoreItemEnum.ViewMenuId:
            show = meetingManager.hideView
            break
        case MoreItemEnum.InviteMenuId:
            show = !meetingManager.hideInvitation
            break
        case MoreItemEnum.WhiteboardMenuId:
            show = !meetingManager.hideWhiteboard
            break
        }

        return show && model.itemImage.length > 0
    }

    function getItemImage(imagePath) {
        if ('' === imagePath) {
           return ''
        } else if (imagePath.startsWith('qrc:/') || imagePath.startsWith(':/')) {
            return imagePath
        }

        return "image://localImage/" + imagePath
    }

    function getItemVisible(itemVisibility) {
        switch (itemVisibility)
        {
        case MoreItemEnum.VisibleAlways:
            return true
        case MoreItemEnum.VisibleExcludeHost:
            return !authManager.isHostAccount
        case MoreItemEnum.VisibleToHostOnly:
            return authManager.isHostAccount
        default:
            return false
        }
    }
}
