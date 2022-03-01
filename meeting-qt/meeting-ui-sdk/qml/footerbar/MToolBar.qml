import QtQuick 2.15
import QtQml 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NetEase.Meeting.ToolbarItemModel 1.0
import NetEase.Meeting.MoreItemEnum 1.0
import NetEase.Meeting.GlobalChatManager 1.0

import "../utils/dialogManager.js" as DialogManager
import "../components"
import "../footerbar"
import "../"

Item {
    id: root
    property bool bSSToolbar: false
    property bool bReset: false
    property var btnAudioCtrl: undefined
    property var btnAudioSettings: undefined
    property var btnVideoCtrl: undefined
    property var btnVideoSettings: undefined
    property var btnSharing: undefined
    property var btnWhiteboard: undefined
    property var btnMembersCtrl: undefined
    property var btnSwitchView: undefined
    property var btnChat: undefined
    property var btnMore: undefined
    property var footerItem: undefined
    property var footerItemArr: []

    signal btnAudioCtrlClicked()
    signal btnAudioSettingsClicked()
    signal btnVideoCtrlClicked()
    signal btnVideoSettingsClicked()
    signal btnSharingClicked()
    signal btnInvitationClicked()
    signal btnWhiteboardClicked()
    signal btnMembersCtrlClicked()
    signal btnSwitchViewClicked()
    signal btnChatClicked()
    signal btnMoreClicked()
    signal btnLiveClicked()

    enum DataRole {
        ItemIndex = 256,
        ItemGuid,
        ItemTitle,
        ItemImage,
        ItemTitle2,
        ItemImage2,
        ItemVisibility,
        ItemCheckedIndex
    }

    function resetItem() {
        bReset = true
        idToolbarModel.itemManager = null
        for (let index = 0; index < footerItemArr.length; index++) {
            footerItemArr[index].destroy(0)
        }
        footerItemArr = []
    }

    Component.onCompleted: {
        if (undefined === footerItem) {
            footerItem = Qt.createComponent('qrc:/qml/footerbar/FooterItem.qml')
        }
        idToolbarModel.itemManager = moreItemManager
    }

    implicitHeight: parent.height
    implicitWidth: mainItem.width
    ToolbarItemModel {
        id: idToolbarModel
        onModelReset: {
            if (null !== itemManager && !bReset) {
                layoutBtn()
            }
        }

        onDataChanged: {
            if (null === itemManager || bReset)
                return
            const clickedBtn = footerItemArr[topLeft.row]
            if(undefined !== clickedBtn) {
                clickedBtn.itemText = idToolbarModel.data(topLeft, (1 === idToolbarModel.data(topLeft, MToolBar.DataRole.ItemCheckedIndex)) ? MToolBar.DataRole.ItemTitle : MToolBar.DataRole.ItemTitle2)
                clickedBtn.itemIcon = getItemImage(idToolbarModel.data(topLeft, (1 === idToolbarModel.data(topLeft, MToolBar.DataRole.ItemCheckedIndex)) ? MToolBar.DataRole.ItemImage : MToolBar.DataRole.ItemImage2))
            }
        }
    }

    RowLayout {
        id: mainItem
        implicitHeight: parent.height
        //implicitWidth: childrenRect.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: bSSToolbar ? 10 : 32
    }

    Connections {
        target: moreItemManager
        onMorePresetItemClicked: {
            console.log('onMorePresetItemClicked:', itemIndex)
            switch (itemIndex){
            case MoreItemEnum.ScreenShareMenuId:
                btnSharingClicked()
                break
            case MoreItemEnum.InviteMenuId:
                btnInvitationClicked()
                break
            case MoreItemEnum.ViewMenuId:
                btnSwitchViewClicked()
                break
            case MoreItemEnum.ParticipantsMenuId:
                btnMembersCtrlClicked()
                break
            case MoreItemEnum.LiveMenuId:
                btnLiveClicked()
                break
            case MoreItemEnum.WhiteboardMenuId:
                btnWhiteboardClicked()
                break
            }
        }
    }

    function layoutBtn() {
        if (1 === footerItemArr.length && 0 === moreItemManager.itemCountToolbar) {
            return
        }

        if (undefined === footerItem) {
            footerItem = Qt.createComponent('qrc:/qml/footerbar/FooterItem.qml')
        }
        for (let index = 0; index < footerItemArr.length; index++) {
            footerItemArr[index].destroy(0)
        }
        footerItemArr = []

        if (undefined != btnAudioCtrl)
            btnAudioCtrl = undefined
        if (undefined !== btnAudioSettings)
            btnAudioSettings = undefined
        if (undefined !== btnVideoCtrl)
            btnVideoCtrl = undefined
        if (undefined !== btnVideoSettings)
            btnVideoSettings = undefined
        if (undefined !== btnSharing)
            btnSharing = undefined
        if (undefined !== btnWhiteboard)
            btnWhiteboard = undefined
        if (undefined !== btnMembersCtrl)
            btnMembersCtrl = undefined
        if (undefined !== btnSwitchView)
            btnSwitchView = undefined
        if (undefined !== btnChat)
            btnChat = undefined
        if (undefined !== btnMore)
            btnMore = undefined

        var count = moreItemManager.itemCountToolbar
        var modelIndex = []
        for (let i = 0; i < count; i++) {
            modelIndex[i] = idToolbarModel.index(i, 0)
            var itemIndex = idToolbarModel.data(modelIndex[i], MToolBar.DataRole.ItemIndex)
            if (MoreItemEnum.MicMenuId === itemIndex || MoreItemEnum.CameraMenuId === itemIndex) {
                var rowLayout = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Layouts 1.12; RowLayout { spacing: 0 }', mainItem)
                footerItemArr.push(rowLayout)
                rowLayout.Layout.preferredWidth = 72
                rowLayout.Layout.preferredHeight = 68
                var btn = footerItem.createObject(rowLayout)
                btn.Layout.preferredWidth = 60
                btn.Layout.preferredHeight = 68
                var ctrlBtn = footerItem.createObject(rowLayout)
                ctrlBtn.Layout.preferredWidth = 12
                ctrlBtn.Layout.preferredHeight = 68
                ctrlBtn.imageHieght = 6
                ctrlBtn.imageWidth = 8
                ctrlBtn.imageTopMargin = 5
                ctrlBtn.itemIcon = Qt.binding(function(){ return !bSSToolbar ? 'qrc:/qml/images/meeting/footerbar/btn_show_device_normal.png' : 'qrc:/qml/images/meeting/footerbar/btn_show_device_down_normal.png' })
                if (MoreItemEnum.MicMenuId === itemIndex) {
                    btnAudioCtrl = btn
                    btnAudioCtrl.objectName = 'btnAudioCtrl'
                    btnAudioCtrl.clicked.connect(btnAudioCtrlClicked)
                    btnAudioCtrl.itemText = Qt.binding(function(){ return idToolbarModel.data(modelIndex[i], (audioManager.localAudioStatus === FooterBar.DeviceStatus.DeviceEnabled) ? MToolBar.DataRole.ItemTitle : MToolBar.DataRole.ItemTitle2) })
                    btnAudioCtrl.itemIcon = Qt.binding(function(){ return getItemImage(idToolbarModel.data(modelIndex[i], (audioManager.localAudioStatus === FooterBar.DeviceStatus.DeviceEnabled) ? MToolBar.DataRole.ItemImage : MToolBar.DataRole.ItemImage2)) })
                    btnAudioSettings = ctrlBtn
                    btnAudioSettings.objectName = 'btnAudioSettings'
                    btnAudioSettings.clicked.connect(btnAudioSettingsClicked)
                    rowLayout.visible = Qt.binding(function(){ return moreItemManager.micItemVisible })
                } else {
                    btnVideoCtrl = btn
                    btnVideoCtrl.objectName = 'btnVideoCtrl'
                    btnVideoCtrl.clicked.connect(btnVideoCtrlClicked)
                    btnVideoCtrl.itemText = Qt.binding(function(){ return idToolbarModel.data(modelIndex[i], (videoManager.localVideoStatus === FooterBar.DeviceStatus.DeviceEnabled) ? MToolBar.DataRole.ItemTitle : MToolBar.DataRole.ItemTitle2) })
                    btnVideoCtrl.itemIcon = Qt.binding(function(){ return getItemImage(idToolbarModel.data(modelIndex[i], (videoManager.localVideoStatus === FooterBar.DeviceStatus.DeviceEnabled) ? MToolBar.DataRole.ItemImage : MToolBar.DataRole.ItemImage2)) })
                    btnVideoSettings = ctrlBtn
                    btnVideoSettings.objectName = 'btnVideoSettings'
                    btnVideoSettings.clicked.connect(btnVideoSettingsClicked)
                    rowLayout.visible = Qt.binding(function(){ return moreItemManager.cameraItemVisible })
                }
            } else if (MoreItemEnum.ChatMenuId === itemIndex) {
                btnChat = Qt.createComponent('qrc:/qml/components/ImageTipButton.qml').createObject(mainItem)
                footerItemArr.push(btnChat)
                btnChat.Layout.preferredWidth = 60
                btnChat.Layout.preferredHeight = 68
                btnChat.msgTipNum = Qt.binding(function(){ return GlobalChatManager.chatMsgCount })
                btnChat.objectName = 'btnChat'
                btnChat.clicked.connect(btnChatClicked)
                btnChat.visible = Qt.binding(function(){ return moreItemManager.chatItemVisible })
                btnChat.itemText = idToolbarModel.data(modelIndex[i], MToolBar.DataRole.ItemTitle)
                btnChat.itemIcon = getItemImage(idToolbarModel.data(modelIndex[i], MToolBar.DataRole.ItemImage))
            }
            else {
                var btnTmp = footerItem.createObject(mainItem)
                footerItemArr.push(btnTmp)
                btnTmp.Layout.preferredWidth = 60
                btnTmp.Layout.preferredHeight = 68
                btnTmp.itemText = idToolbarModel.data(modelIndex[i], (1 === idToolbarModel.data(modelIndex[i], MToolBar.DataRole.ItemCheckedIndex)) ? MToolBar.DataRole.ItemTitle : MToolBar.DataRole.ItemTitle2)
                btnTmp.itemIcon = getItemImage(idToolbarModel.data(modelIndex[i], (1 === idToolbarModel.data(modelIndex[i], MToolBar.DataRole.ItemCheckedIndex)) ? MToolBar.DataRole.ItemImage : MToolBar.DataRole.ItemImage2))
                switch (itemIndex) {
                case MoreItemEnum.ScreenShareMenuId:
                    btnSharing = btnTmp
                    btnSharing.objectName = 'btnSharing'
                    btnSharing.clicked.connect(btnSharingClicked)
                    btnSharing.visible = Qt.binding(function(){ return !bSSToolbar && moreItemManager.screenShareItemVisible })
                    break
                case MoreItemEnum.ParticipantsMenuId:
                    var btnTmp2 = btnTmp
                    var tips = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.12; Label { anchors.topMargin: 8; anchors.rightMargin: 10; font.pixelSize: 11; font.bold: true; color: "#FFFFFF" }', btnTmp2)
                    tips.text = Qt.binding(function(){ return membersManager.count })
                    tips.anchors.top = Qt.binding(function(){ return btnTmp2.top })
                    tips.anchors.right = Qt.binding(function(){ return btnTmp2.right })
                    btnTmp2.objectName = 'btnMembersCtrl'
                    btnTmp2.clicked.connect(btnMembersCtrlClicked)
                    btnTmp2.visible = Qt.binding(function(){
                        if (moreItemManager.participantsItemVisible) {
                            btnMembersCtrl = btnTmp2
                            return true
                        } else { return false } })
                    break
                case MoreItemEnum.MangeParticipantsMenuId:
                    var btnTmp3 = btnTmp
                    var tips2 = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.12; Label { anchors.topMargin: 8; anchors.rightMargin: 10; font.pixelSize: 11; font.bold: true; color: "#FFFFFF" }', btnTmp3)
                    tips2.text = Qt.binding(function(){ return membersManager.count })
                    tips2.anchors.top = Qt.binding(function(){ return btnTmp3.top })
                    tips2.anchors.right = Qt.binding(function(){ return btnTmp3.right })
                    btnTmp3.objectName = 'btnMembersCtrl'
                    btnTmp3.clicked.connect(btnMembersCtrlClicked)
                    btnTmp3.visible = Qt.binding(function(){
                        if (moreItemManager.mangeParticipantsItemVisible) {
                            btnMembersCtrl = btnTmp3
                            return true
                        } else { return false } })
                    break
                case MoreItemEnum.WhiteboardMenuId:
                    btnWhiteboard = btnTmp
                    btnWhiteboard.objectName = 'btnWhiteboard'
                    btnWhiteboard.clicked.connect(btnWhiteboardClicked)
                    btnWhiteboard.visible = Qt.binding(function(){ return !shareManager.ownerSharing && moreItemManager.whiteboardItemVisible })
                    btnWhiteboard.itemText = Qt.binding(function(){ return idToolbarModel.data(modelIndex[i], (whiteboardManager.whiteboardSharing && whiteboardManager.whiteboardSharerAccountId === authManager.authAccountId) ? MToolBar.DataRole.ItemTitle2 : MToolBar.DataRole.ItemTitle) })
                    btnWhiteboard.itemIcon = Qt.binding(function(){ return idToolbarModel.data(modelIndex[i], (whiteboardManager.whiteboardSharing && whiteboardManager.whiteboardSharerAccountId === authManager.authAccountId) ? MToolBar.DataRole.ItemImage2 : MToolBar.DataRole.ItemImage) })
                    break
                case MoreItemEnum.InviteMenuId:
                    btnInvitation = btnTmp
                    btnInvitation.objectName = 'btnInvitation'
                    btnInvitation.clicked.connect(btnInvitationClicked)
                    btnInvitation.visible = Qt.binding(function(){ return moreItemManager.inviteItemVisible })
                    break
                case MoreItemEnum.ViewMenuId:
                    btnSwitchView = btnTmp
                    btnSwitchView.objectName = 'btnSwitchView'
                    btnSwitchView.clicked.connect(function() { btnSwitchViewClicked(); moreItemManager.clickedItem(idToolbarModel.data(modelIndex[i], MToolBar.DataRole.ItemGuid)) })
                    btnSwitchView.visible = Qt.binding(function(){ return !bSSToolbar && moreItemManager.viewItemVisible })
                    btnSwitchView.itemText = Qt.binding(function(){ return idToolbarModel.data(modelIndex[i], (1 === idToolbarModel.data(modelIndex[i], MToolBar.DataRole.ItemCheckedIndex)) ? MToolBar.DataRole.ItemTitle : MToolBar.DataRole.ItemTitle2) })
                    btnSwitchView.itemIcon = Qt.binding(function(){ return getItemImage(idToolbarModel.data(modelIndex[i], (1 === idToolbarModel.data(modelIndex[i], MToolBar.DataRole.ItemCheckedIndex)) ? MToolBar.DataRole.ItemImage : MToolBar.DataRole.ItemImage2)) })
                    break
                default:
                    btnTmp.visible = Qt.binding(function(){ return getItemVisible(idToolbarModel.data(modelIndex[i], MToolBar.DataRole.ItemVisibility)) })
                    btnTmp.clicked.connect(function(){ moreItemManager.clickedItem(idToolbarModel.data(modelIndex[i], MToolBar.DataRole.ItemGuid)) })
                    break
                }
            }
        }

        btnMore = footerItem.createObject(mainItem)
        footerItemArr.push(btnMore)
        btnMore.Layout.preferredWidth = 60
        btnMore.Layout.preferredHeight = 68
        btnMore.objectName = 'btnMore'
        btnMore.clicked.connect(btnMoreClicked)
        btnMore.visible = Qt.binding(function(){ if (bSSToolbar && moreItemManager.moreItemInjected) { return false } return !(0 === moreItemManager.itemCountMore || (!bSSToolbar ? false : 0 === moreItemManager.itemCountMore_S()))})
        btnMore.itemIcon = 'qrc:/qml/images/meeting/btn_more_normal.png'
        btnMore.itemText = qsTr('More')
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

