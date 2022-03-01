import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12
import NetEase.Meeting.LiveMembersModel 1.0

import "../components"

Window {
    id: root
    width: 800 + (Qt.platform.os === 'windows' ? 20 : 0)
    height: 588 + (Qt.platform.os === 'windows' ? 20 : 0)
    x: (Screen.width - width) / 2 + Screen.virtualX
    y: (Screen.height - height) / 2 + Screen.virtualY
    color: "#00000000"
    title: qsTr("Live")
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    Material.theme: Material.Light

    DropShadow {
        anchors.fill: mainLayout
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 16
        source: mainLayout
        color: "#3217171A"
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    property string pswd: ""
    property bool isLive: false
    property bool isReJoin: false
    property bool isLiveLayoutChanged: false
    property bool isLiveUserCountChanged: false
    property bool isLiveChatroomChanged: false
    property bool isShareMode: false
    property int oldLayout: 1 //1 : grallay 2: focus
    property int liveMemberCount: 0

    signal liveViewChanged()

    Connections {
        target: root
        onClosing: {
            root.hide()
            close.accepted = false
        }
    }

    Connections {
        target: liveManager
        onLiveStartFinished: {
            console.log("onLiveStartFinished")
            if(success){
                toast.show(qsTr("Live start success"))
                root.isLiveLayoutChanged = false
                root.isLiveChatroomChanged = false
                root.isLiveUserCountChanged = false
            }else{
                toast.show(qsTr("Live start failed,") + errMsg)
            }
        }
    }

    Connections {
        target: liveManager
        onLiveStopFinished: {
            if(success){
                toast.show(qsTr("Live Stop success"))
                root.isLiveLayoutChanged = false
                root.isLiveChatroomChanged = false
                root.isLiveUserCountChanged = false
            }else{
                toast.show(qsTr("Live Stop failed,") + errMsg)
            }
        }
    }

    Connections {
        target: liveManager
        onLiveUpdateFinished:{
            if(success){
                root.isLiveLayoutChanged = false
                root.isLiveChatroomChanged = false
                root.isLiveUserCountChanged = false
                toast.show(qsTr("update success"))
            }else{
                toast.show(qsTr("Update failed,") + errMsg)
            }
        }
    }

    Connections {
        target: membersManager
        onHostAccountIdChangedSignal: {
            console.log("onHostAccountIdChangedSignal")
            if(hostAccountId === authManager.authAccountId && oldhostAccountId !== authManager.authAccountId){
                console.log("liveMemberListModel.updateLiveMembers(liveManager.getLiveUsersList())")

                if(liveMemberListModel.updateLiveMembers(liveManager.getLiveUsersList()) === false){
                    return;
                }

                liveMemberCount = liveMemberListModel.getliveMemberCount()           
                isShareMode = liveMemberListModel.getLiveMemberIsSharing()
                imgPreview.source = getPreviewImageSource()
            }
        }
    }

    Connections {
        target: root
        onLiveViewChanged:{
            imgPreview.source = getPreviewImageSource()

            if(root.isLive){
                let layoutType = galleryRect.check ? 1 : 2
                if(layoutType === liveManager.getLiveLayout()){
                    root.isLiveLayoutChanged = false
                }else{
                    root.isLiveLayoutChanged = true
                }
            }
        }
    }

    Connections {
        target: liveManager
        onLiveStateChanged:{
            root.isLive = isLive
            pswEdit.enabled = !root.isLive

            if(root.isLive){
                btnLive.enabled = true
                if(isJoin){
                    root.isReJoin = true
                }
            }else{
                isLiveLayoutChanged = false
                isLiveUserCountChanged = false
                isLiveChatroomChanged = false

                var currentCount = liveMemberListModel.getliveMemberCount()
                btnLive.enabled = currentCount !== 0
            }

            console.log("onLiveStateChanged")
        }
    }

    Connections {
        target: liveMemberListModel

        onLiveMemberCountChanged: {
            var currentCount = liveMemberListModel.getliveMemberCount()

            console.log("onLiveMemberCountChanged", currentCount)

            if(liveMemberListModel.getLiveMemberIsSharing()) {
                if(!isShareMode){
                    oldLayout = galleryRect.check ? 1 : 2
                }

                galleryRect.check = false
                focusRect.check = false
                isShareMode = true
            } else {
                if(currentCount === 0) {
                    focusRect.check = false
                    galleryRect.check = false
                } else {
                    if (currentCount === 1 && liveMemberCount === 0) {
                        galleryRect.check = true
                    } else if(isShareMode) {
                        galleryRect.check = oldLayout == 1;
                    }

                    focusRect.check= !galleryRect.check
                }

                isShareMode = false
            }

            liveMemberCount = currentCount

            imgPreview.source = getPreviewImageSource()

            if(root.isLive){
                root.isLiveUserCountChanged = true;
            }else{
                btnLive.enabled = currentCount !== 0
            }
        }

        onLiveMemberShareStatusChanged: {
            console.log("onLiveMemberShareStatusChanged")

            if(isSharing && liveMemberListModel.getLiveMemberIsSharing() === false) {
                return
            }

            isShareMode = isSharing
            imgPreview.source = getPreviewImageSource()

            if(isShareMode == false) {
                galleryRect.check = liveManager.getLiveLayout() === 1
                focusRect.check= !galleryRect.check
            }
        }

    }

    ToastManager {
        id: toast
    }

    LiveMembersModel {
        id: liveMemberListModel
    }

    BorderImage{
        id: viewChangedTip
        parent: mainLayout
        anchors.top: mainLayout.top
        anchors.topMargin: 214
        anchors.left: mainLayout.left
        anchors.leftMargin: 596
        width: 179
        height: 90
        visible: root.isLive && (root.isLiveLayoutChanged || root.isLiveUserCountChanged)
        source: "qrc:/qml/images/live/tip_background.png"

        ColumnLayout{
            spacing: 4
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 12

            RowLayout{
                spacing: 6

                Image {
                    source: "qrc:/qml/images/live/warning.png"
                    Layout.preferredWidth:  16
                    Layout.preferredHeight:  16
                }

                Label{
                    color: "#E6352B"
                    font.pixelSize: 14
                    text: qsTr("Live status has changed")
                }

            }

            ColumnLayout {
                spacing: 3

                Layout.leftMargin: 22

                Row {
                    spacing:0
                    Text {
                        text: qsTr("Please click\"")
                        color: "#666666"
                        font.pixelSize: 12
                    }

                    Text {
                        text: qsTr("update")
                        color: "#337EFF"
                        font.pixelSize: 12
                    }

                    Text {
                        text: "\""
                        color: "#666666"
                        font.pixelSize: 12
                    }

                }

                Text {
                    text: qsTr("Refresh the live layout")
                    color: "#666666"
                    font.pixelSize: 12
                }

            }

        }

    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: Qt.platform.os === 'windows' ? 10 : 0
        border.width: 1
        border.color: "#FFFFFF"
        radius: Qt.platform.os === 'windows' ? 0 : 10

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0
            height: parent.height - 52

            DragArea {
                Layout.preferredHeight: 50
                Layout.preferredWidth: parent.width
                title: qsTr("Live")
                onCloseClicked: Window.window.hide()
            }

            Rectangle{
                Layout.preferredWidth: parent.width - (Qt.platform.os === 'windows' ? 36 : 0)
                Layout.preferredHeight: 538 - 52
                Layout.leftMargin: 36
                Layout.topMargin: 10

                Rectangle{
                    id: baseInfo
                    width: parent.width
                    anchors.left: parent.left
                    anchors.top: parent.top
                    height: 144

                    GridLayout{
                        id: infoGrid
                        rows: 1
                        rowSpacing: 16
                        columns: 2
                        columnSpacing: 32

                        Column{
                            id: colLiveTitle
                            spacing: 8

                            Label {
                                id: liveTitle
                                text: qsTr("LiveTitle")
                                font.pixelSize: 16
                                color: "#333333"
                            }

                            CustomTextFieldEx {
                                id: titleEdit
                                enabled: !root.isLive
                                width: 346
                                text: liveManager.getLiveTittle()
                                validator: RegExpValidator { regExp: /\w{1,30}/ }
                                placeholderText: qsTr("Please enter Live subject")
                            }
                        }

                        Column{
                            id: colLiveLink
                            spacing: 8

                            Label {
                                id: liveurl
                                text: qsTr("Live link")
                                font.pixelSize: 16
                                color: "#333333"
                            }

                            RowLayout{
                                spacing: 10
                                CustomTextFieldEx {
                                    id: urledit
                                    enabled: false
                                    cursorPosition: 0
                                    font.pixelSize: 14
                                    color: "#333333"
                                    Layout.preferredWidth: 308
                                    text: qsTr("live link: ") + liveManager.getLiveUrl()
                                }

                                Label {
                                    id: lblCopy
                                    text: qsTr("Copy")
                                    font.pixelSize: 14
                                    color: "#337EFF"
                                    MouseArea {
                                        id: lblCopyBtn
                                        anchors.fill: parent
                                        onClicked: {
                                            clipboard.setText(urledit.text)
                                            toast.show(qsTr('copy success'))
                                        }
                                    }
                                    Accessible.role: Accessible.Button
                                    Accessible.name: lblCopy.text
                                    Accessible.onPressAction: if (enabled) lblCopyBtn.clicked(Qt.LeftButton)
                                }
                            }
                        }

                        RowLayout {
                            id: rowPsw
                            spacing: 20

                            CustomCheckBox{
                                id: pswCheck
                                text: qsTr("Open password")
                                font.pixelSize: 14
                                enabled: !root.isLive

                                onToggled: {
                                    pswEdit.enabled = pswCheck.checked
                                    if (pswCheck.checked) {
                                        pswEdit.text = root.pswd
                                        if (pswEdit.text.trim().length === 0) {
                                            pswEdit.text = ('000000' + Math.floor(Math.random() * 999999)).slice(-6)
                                        }
                                    } else if (!pswEdit.checked) {
                                        root.pswd = pswEdit.text
                                        pswEdit.text = ""
                                    }
                                }

                            }

                            CustomTextFieldEx {
                                id: pswEdit
                                enabled: false
                                Layout.preferredWidth: 218
                                text: liveManager.getLivePassword()
                                validator: RegExpValidator { regExp: /[0-9]{6}/ }
                                Layout.alignment: Qt.AlignVCenter
                                placeholderText: qsTr("Please enter a 6-digit password")
                            }
                        }

                        RowLayout{
                            id: rowChat
                            spacing: 16

                            CustomCheckBox{
                                id: chatRoomEnableCheckBox
                                text: qsTr("Open chatroom")
                                font.pixelSize: 14
                                checkState: liveManager.getLiveChatRoomEnable() ? Qt.Checked : Qt.Unchecked

                                onClicked: {
                                    if(root.isLive ){
                                        root.isLiveChatroomChanged = true;
                                    }
                                }
                            }

                            Label {
                                text: qsTr("After opening, the conference room and the live broadcast room will be visible to each other")
                                font.pixelSize: 12
                                color: "#999999"
                                Layout.alignment: Qt.AlignVCenter
                                wrapMode: Text.WordWrap
                                Layout.preferredWidth: 210
                            }
                        }
                    }

                    RowLayout{
                        id: liveAccess
                        spacing: 16
                        anchors.top: infoGrid.bottom
                        anchors.topMargin: 8
                        anchors.left: infoGrid.left

                        CustomCheckBox{
                            id: liveAccessCheckBox
                            text: qsTr("Only employees of company can watch")
                            font.pixelSize: 14
                            checkState: liveManager.getLiveAccessEnable() ? Qt.Checked : Qt.Unchecked
                            enabled: !root.isLive
                        }

                        Label {
                            text: qsTr("After opening, non-employees cannot watch the live")
                            font.pixelSize: 12
                            color: "#999999"
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                Label {
                    id: liveViewSetting

                    anchors.top: baseInfo.bottom
                    anchors.topMargin: 38
                    anchors.left: baseInfo.left
                    text: qsTr("LiveView setting")
                    font.pixelSize: 16
                    color: "#333333"
                }

                RowLayout{
                    spacing: liveMemberCount === 0 ? 9 : 36
                    anchors.top: liveViewSetting.bottom
                    anchors.topMargin: 16
                    anchors.left: baseInfo.left
                    anchors.leftMargin: 0

                    ColumnLayout{
                        spacing: 8

                        Rectangle{
                            id: memberRect
                            border.color: "#E1E3E6"
                            border.width: 1
                            Layout.preferredWidth: 240
                            Layout.preferredHeight: 192
                            radius: 2

                            ListView{
                                id: memberList
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.top: parent.top
                                anchors.topMargin: 14
                                width: parent.width - 16
                                height: parent.height - 15
                                model:liveMemberListModel
                                clip: true
                                spacing: 8

                                ScrollBar.vertical: ScrollBar {
                                    width: 8
                                    rightPadding: 2
                                }

                                delegate: Rectangle {
                                    height: 20
                                    width: memberList.width - 6
                                    color: "#FFFFFF"

                                    Component.onCompleted: {
                                        if (model.index === 0) {
                                            memberList.currentIndex = model.index
                                        }
                                    }

                                    RowLayout{
                                        spacing: 5
                                        height: 20
                                        anchors.centerIn: parent.Center

                                        CustomButton {
                                            id: btnMemberCheck
                                            Layout.preferredWidth: 16
                                            Layout.preferredHeight: 16
                                            font.pixelSize: 12
                                            borderColor: model.checkState === 1 ? "#337EFF" :"#CCCCCC"
                                            normalBkColor: getNormalTextColor(model.checkState)
                                            normalTextColor: "#FFFFFF"
                                            borderSize: 1
                                            text: model.number === 0 ? "" : model.number

                                            function getNormalTextColor(checkState = 0){
                                                if(checkState === 0){
                                                    return "#FFFFFF"
                                                }else if(checkState === 1){
                                                    return "#337EFF"
                                                }else{
                                                    return "#F2F2F5"
                                                }
                                            }

                                            onClicked: {
                                                liveMemberListModel.setChecked(model.index)
                                            }
                                        }
                                        Label {
                                            text: model.nickname
                                            font.pixelSize: 14
                                            color: "#333333"
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }
                            }

                        }

                        Label {
                            font.pixelSize: 12
                            color: "#999999"
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("After the user turns on the video, it can appear in the list")
                            wrapMode: Text.WordWrap
                            Layout.preferredWidth: memberRect.width + 5
                        }
                    }

                    BorderImage {
                        id: line1
                        source: "qrc:/qml/images/live/line.png"
                        Layout.preferredHeight: 9
                        Layout.preferredWidth: 40
                    }

                    Rectangle {
                        id: rect
                        Layout.preferredWidth: liveMemberCount === 0 ? 212 : 100
                        Layout.preferredHeight: 188
                        ColumnLayout{
                            spacing: 16
                            Layout.fillWidth: true
                            anchors.fill: parent

                            Rectangle{
                                id: galleryRect
                                Layout.alignment: Qt.AlignHCenter
                                property bool check: false
                                visible: liveMemberCount === 0 || !isShareMode
                                width: 100
                                height: 86

                                ColumnLayout{
                                    spacing: 6
                                    BorderImage {
                                        id: name
                                        source:( galleryRect.check && liveMemberCount !== 0 ) ? "qrc:/qml/images/live/gallery_check.png" : "qrc:/qml/images/live/gallery_normal.png"
                                        width: 100
                                        height: 60
                                        Layout.preferredWidth: 100
                                        Layout.preferredHeight: 60
                                    }

                                    Label {
                                        text: qsTr("Gallery view")
                                        color: ( galleryRect.check && liveMemberCount !== 0 ) ? "#337EFF" : "#999999"
                                        font.pixelSize: 12
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }

                                MouseArea{
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton
                                    onPressed: {
                                        if(liveMemberCount === 0) {
                                            return
                                        }

                                        if(!galleryRect.check){
                                            galleryRect.check = true
                                            focusRect.check = false

                                            liveViewChanged()
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                spacing: 12
                                Rectangle{
                                    id: focusRect
                                    property bool check: false
                                    visible: liveMemberCount === 0 || !isShareMode
                                    width: 100
                                    height: 86

                                    ColumnLayout{

                                        spacing: 6
                                        BorderImage {
                                            source: ( focusRect.check && liveMemberCount !== 0 ) ? "qrc:/qml/images/live/focus_check.png" : "qrc:/qml/images/live/focus_normal.png"
                                            width: 100
                                            height: 60
                                            Layout.preferredWidth: 100
                                            Layout.preferredHeight: 60
                                        }

                                        Label {
                                            text: qsTr("Focus view")
                                            color: ( focusRect.check && liveMemberCount !== 0 ) ? "#337EFF" : "#999999"
                                            font.pixelSize: 12
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                    MouseArea{
                                        anchors.fill: parent
                                        acceptedButtons: Qt.LeftButton
                                        onPressed: {
                                            if(liveMemberCount === 0) {
                                                return
                                            }


                                            if(!focusRect.check){
                                                focusRect.check = true
                                                galleryRect.check = false

                                                liveViewChanged()
                                            }
                                        }
                                    }
                                }

                                Rectangle{
                                    id: shareRect
                                    width: 100
                                    height: 86
                                    visible: liveMemberCount === 0 || isShareMode

                                    ColumnLayout{

                                        spacing: 6
                                        BorderImage {
                                            source: (liveMemberCount !== 0 && isShareMode) ? "qrc:/qml/images/live/share_check.png" : "qrc:/qml/images/live/share_normal.png"
                                            width: 100
                                            height: 60
                                            Layout.preferredWidth: 100
                                            Layout.preferredHeight: 60
                                            rotation: 360
                                        }

                                        Label {
                                            text: qsTr("share view")
                                            color: (liveMemberCount !== 0 && isShareMode) ? "#337EFF" : "#999999"
                                            font.pixelSize: 12
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                    MouseArea{
                                        anchors.fill: parent
                                        acceptedButtons: Qt.LeftButton
                                        onPressed: {
                                            if(memberList.count === 0) {
                                                return
                                            }

                                            if(!focusRect.check){
                                                focusRect.check = true
                                                galleryRect.check = false

                                                liveViewChanged()
                                            }
                                        }
                                    }
                                }
                            }

                        }
                    }


                    BorderImage {
                        id: line2
                        source: "qrc:/qml/images/live/line.png"
                        Layout.preferredHeight: 9
                        Layout.preferredWidth: 40
                    }

                    ColumnLayout{
                        id: colPreview

                        spacing: 6

                        BorderImage {
                            id: imgPreview
                            source: "qrc:/qml/images/live/no_preview.png"
                            width: 160
                            height: 96
                            Layout.preferredHeight: 96
                            Layout.preferredWidth: 160
                        }

                        Label{
                            text: qsTr("live preview")
                            color: "#999999"
                            font.pixelSize: 12
                            Layout.alignment: Qt.AlignHCenter
                        }

                    }
                }

            }
        }

        Rectangle {
            id: screenFooterBar
            width: parent.width
            height: 52
            anchors.bottom: col.bottom
            radius: 10
            CustomToolSeparator {
                width: parent.width
                anchors.top: parent.top
            }
            Row{
                anchors.centerIn: parent
                spacing: 10

                CustomButton {
                    id: btnUpdate
                    width: 148
                    height: 36
                    text: qsTr("update")
                    visible: root.isLive
                    normalTextColor: "#FFFFFF"
                    normalBkColor: "#337EFF"
                    borderSize: 0
                    enabled: root.isLiveLayoutChanged || root.isLiveUserCountChanged || root.isLiveChatroomChanged

                    onClicked: {
                        var liveParams = {
                            liveUsers: "",
                            liveTitle: "",
                            liveChatRoomEnable: "",
                            password: "",
                            layoutType: "",
                        };

                        if(liveMemberListModel.getliveMemberCount() === 0){
                            toast.show(qsTr("The number of live broadcast members cannot be null"));
                            return
                        }

                        liveParams.liveUsers = liveMemberListModel.getCheckedUserlist()
                        liveParams.liveChatRoomEnable = chatRoomEnableCheckBox.checkState == Qt.Checked
                        liveParams.layoutType = galleryRect.check ? 1 : 2

                        liveManager.updateLive(liveParams);
                    }
                }

                CustomButton {
                    id: btnLive
                    width: 116
                    height: 36
                    text: root.isLive ? qsTr("Stop") : qsTr("Start")
                    normalBkColor: root.isLive ? "#E6352B" : "#337EFF"
                    normalTextColor: "#FFFFFF"
                    borderSize: 0
                    enabled: false

                    onClicked: {
                        if(root.isLive){
                            liveManager.stopLive()
                        }else{

                            if(titleEdit.text.length === 0){
                                toast.show(qsTr("Live stream subject cannot be empty"))
                                return
                            }

                            if(pswCheck.checkState == Qt.Checked && pswEdit.text === ""){
                                toast.show(qsTr("Please enter a 6-digit password"))
                                return
                            } else if(pswCheck.checkState == Qt.Checked && pswEdit.text.length < 6){
                                toast.show(qsTr("Please enter a 6-digit password"))
                                return
                            }

                            var liveParams = {
                                liveUsers: "",
                                liveTitle: "",
                                liveChatRoomEnable: "",
                                liveAccessEnable: "",
                                password: "",
                                layoutType: "",
                                isEnablePsw: "",
                            };

                            liveParams.liveUsers = liveMemberListModel.getCheckedUserlist()
                            liveParams.liveTitle = titleEdit.text
                            liveParams.liveChatRoomEnable = chatRoomEnableCheckBox.checkState == Qt.Checked
                            liveParams.liveAccessEnable = liveAccessCheckBox.checkState == Qt.Checked

                            if(pswCheck.checkState == Qt.Checked){
                                liveParams.password = pswEdit.text
                            } else{
                                liveParams.password = ""
                            }

                            liveParams.layoutType = galleryRect.check ? 1 : 2

                            liveManager.startLive(liveParams);
                        }
                    }
                }

            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            titleEdit.text = liveManager.getLiveTittle()
            urledit.text = liveManager.getLiveUrl()
            urledit.cursorPosition = 0
            root.isLiveChatroomChanged = false;
            chatRoomEnableCheckBox.checkState = Qt.Unchecked
            if(liveManager.getLiveChatRoomEnable()){
                chatRoomEnableCheckBox.checkState =  Qt.Checked
            }else{
                chatRoomEnableCheckBox.checkState =  Qt.Unchecked
            }

            if(liveManager.getLiveAccessEnable()){
                liveAccessCheckBox.checkState =  Qt.Checked
            }else{
                liveAccessCheckBox.checkState =  Qt.Unchecked
            }

            pswEdit.text = liveManager.getLivePassword()
            if(pswEdit.text.length === 0){
                pswEdit.enabled = false
            }else{
                if(!root.isLive){
                    pswEdit.enabled = true
                }
            }
            pswCheck.checkState = pswEdit.text.length === 0 ? Qt.Unchecked : Qt.Checked

            galleryRect.check = liveManager.getLiveLayout() === 1
            focusRect.check= !galleryRect.check

            if(root.isReJoin){
                root.isReJoin = false
                if(liveMemberListModel.updateLiveMembers(liveManager.getLiveUsersList()) === false){
                    return;
                }

                liveMemberCount = liveMemberListModel.getliveMemberCount()
                imgPreview.source = getPreviewImageSource()
            }

            liveViewChanged()
        }
    }

    function getPreviewImageSource(){

        let memberCount = liveMemberListModel.getliveMemberCount()

        if(memberCount === 0) {
            return "qrc:/qml/images/live/no_preview.png"
        } else if(memberCount === 1) {
            if(isShareMode) {
                return "qrc:/qml/images/live/share_preview_1.png"
            } else {
                return "qrc:/qml/images/live/preview_1.png"
            }

        }

        if(isShareMode) {
            if(memberCount === 2) {
                return "qrc:/qml/images/live/share_preview_2.png"
            } else if(memberCount === 3) {
                return "qrc:/qml/images/live/share_preview_3.png"
            } else if(memberCount === 4) {
                return "qrc:/qml/images/live/share_preview_4.png"
            }

        } else {
            if(galleryRect.check) {
                if(memberCount === 2) {
                    return "qrc:/qml/images/live/gallery_preview_2.png"
                } else if(memberCount === 3) {
                    return "qrc:/qml/images/live/gallery_preview_3.png"
                } else if(memberCount === 4) {
                    return "qrc:/qml/images/live/gallery_preview_4.png"
                }
            } else {
                if(memberCount === 2) {
                    return "qrc:/qml/images/live/Focus_preview_2.png"
                } else if(memberCount === 3) {
                    return "qrc:/qml/images/live/Focus_preview_3.png"
                } else if(memberCount === 4) {
                    return "qrc:/qml/images/live/Focus_preview_4.png"
                }
            }
        }
    }

}
