import "../components"
import NetEase.Meeting.LiveMembersModel 1.0
import NetEase.Settings.SettingsStatus 1.0
import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12

Window {
    id: root

    property bool isLive: false
    property bool isLiveChatroomChanged: false
    //property bool isReJoin: false
    property bool isLiveLayoutChanged: false
    property bool isLiveUserCountChanged: false
    property bool isShareMode: false
    property int liveMemberCount: 0
    property int oldLayout: 1 //1 : grallay 2: focus
    property string pswd: ""

    signal liveViewChanged

    function getPreviewImageSource() {
        let memberCount = liveMemberListModel.getliveMemberCount();
        if (memberCount === 0) {
            return "qrc:/qml/images/live/no_preview.png";
        } else if (memberCount === 1) {
            if (isShareMode) {
                return "qrc:/qml/images/live/share_preview_1.png";
            } else {
                return "qrc:/qml/images/live/preview_1.png";
            }
        }
        if (isShareMode) {
            if (memberCount === 2) {
                return "qrc:/qml/images/live/share_preview_2.png";
            } else if (memberCount === 3) {
                return "qrc:/qml/images/live/share_preview_3.png";
            } else if (memberCount === 4) {
                return "qrc:/qml/images/live/share_preview_4.png";
            }
        } else {
            if (galleryRect.check) {
                if (memberCount === 2) {
                    return "qrc:/qml/images/live/gallery_preview_2.png";
                } else if (memberCount === 3) {
                    return "qrc:/qml/images/live/gallery_preview_3.png";
                } else if (memberCount === 4) {
                    return "qrc:/qml/images/live/gallery_preview_4.png";
                }
            } else {
                if (memberCount === 2) {
                    return "qrc:/qml/images/live/Focus_preview_2.png";
                } else if (memberCount === 3) {
                    return "qrc:/qml/images/live/Focus_preview_3.png";
                } else if (memberCount === 4) {
                    return "qrc:/qml/images/live/Focus_preview_4.png";
                }
            }
        }
    }

    Material.theme: Material.Light
    color: "#00000000"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    height: 588 + (Qt.platform.os === 'windows' ? 20 : 0)
    title: qsTr("Live")
    width: 800 + (Qt.platform.os === 'windows' ? 20 : 0)
    x: (Screen.width - width) / 2 + Screen.virtualX
    y: (Screen.height - height) / 2 + Screen.virtualY

    onVisibleChanged: {
        if (visible) {
            titleEdit.text = liveManager.getLiveTittle();
            urledit.text = liveManager.getLiveUrl();
            urledit.cursorPosition = 0;
            root.isLiveChatroomChanged = false;
            chatRoomEnableCheckBox.checkState = Qt.Unchecked;
            if (liveManager.getLiveChatRoomEnable()) {
                chatRoomEnableCheckBox.checkState = Qt.Checked;
            } else {
                chatRoomEnableCheckBox.checkState = Qt.Unchecked;
            }
            if (liveManager.getLiveAccessEnable()) {
                liveAccessCheckBox.checkState = Qt.Checked;
            } else {
                liveAccessCheckBox.checkState = Qt.Unchecked;
            }
            pswEdit.text = liveManager.getLivePassword();
            if (pswEdit.text.length === 0) {
                pswEdit.enabled = false;
            } else {
                if (!root.isLive) {
                    pswEdit.enabled = true;
                }
            }
            pswCheck.checkState = pswEdit.text.length === 0 ? Qt.Unchecked : Qt.Checked;
            galleryRect.check = liveManager.getLiveLayout() === 1;
            focusRect.check = !galleryRect.check;
            if (liveMemberListModel.updateLiveMembers(liveManager.getLiveUsersList()) === false) {
                return;
            }
            liveMemberCount = liveMemberListModel.getliveMemberCount();
            isShareMode = liveMemberListModel.getLiveMemberIsSharing();
            if (!isLive) {
                btnLive.enabled = liveMemberCount !== 0;
            }
            imgPreview.source = getPreviewImageSource();
            liveViewChanged();
        }
    }

    DropShadow {
        anchors.fill: mainLayout
        color: "#3217171A"
        horizontalOffset: 0
        radius: 10
        samples: 16
        source: mainLayout
        verticalOffset: 0
        visible: Qt.platform.os === 'windows'

        Behavior on radius  {
            PropertyAnimation {
                duration: 100
            }
        }
    }
    Connections {
        target: root

        onClosing: {
            root.hide();
            close.accepted = false;
        }
    }
    Connections {
        target: liveManager

        onLiveStartFinished: {
            console.log("onLiveStartFinished");
            if (success) {
                toast.show(qsTr("Live start success"));
                root.isLiveLayoutChanged = false;
                root.isLiveChatroomChanged = false;
                root.isLiveUserCountChanged = false;
            } else {
                toast.show(qsTr("Live start failed,") + errMsg);
            }
        }
        onLiveStopFinished: {
            if (success) {
                toast.show(qsTr("Live Stop success"));
                root.isLiveLayoutChanged = false;
                root.isLiveChatroomChanged = false;
                root.isLiveUserCountChanged = false;
            } else {
                toast.show(qsTr("Live Stop failed,") + errMsg);
            }
        }
        onLiveUpdateFinished: {
            if (success) {
                root.isLiveLayoutChanged = false;
                root.isLiveChatroomChanged = false;
                root.isLiveUserCountChanged = false;
                toast.show(qsTr("update success"));
            } else {
                toast.show(qsTr("Update failed,") + errMsg);
            }
        }
        onLiveStateChanged: {
            root.isLive = state === 2;
            pswEdit.enabled = !root.isLive;
            if (root.isLive) {
                btnLive.enabled = true;
            } else {
                isLiveLayoutChanged = false;
                isLiveUserCountChanged = false;
                isLiveChatroomChanged = false;
                var currentCount = liveMemberListModel.getliveMemberCount();
                btnLive.enabled = currentCount !== 0;
            }
            console.log("onLiveStateChanged state: ", state);
        }
    }
    Connections {
        target: membersManager

        onHostAccountIdChangedSignal: {
            console.log("onHostAccountIdChangedSignal");
            if (hostAccountId === authManager.authAccountId && oldhostAccountId !== authManager.authAccountId) {
                console.log("liveMemberListModel.updateLiveMembers(liveManager.getLiveUsersList())");
                if (liveMemberListModel.updateLiveMembers(liveManager.getLiveUsersList()) === false) {
                    return;
                }
                liveMemberCount = liveMemberListModel.getliveMemberCount();
                isShareMode = liveMemberListModel.getLiveMemberIsSharing();
                imgPreview.source = getPreviewImageSource();
            }
        }
    }
    Connections {
        target: root

        onLiveViewChanged: {
            imgPreview.source = getPreviewImageSource();
            if (root.isLive) {
                let layoutType = galleryRect.check ? 1 : 2;
                if (layoutType === liveManager.getLiveLayout()) {
                    root.isLiveLayoutChanged = false;
                } else {
                    root.isLiveLayoutChanged = true;
                }
            }
        }
    }
    Connections {
        target: liveMemberListModel

        onLiveMemberCountChanged: {
            var currentCount = liveMemberListModel.getliveMemberCount();
            console.log("onLiveMemberCountChanged", currentCount);
            if (liveMemberListModel.getLiveMemberIsSharing()) {
                if (!isShareMode) {
                    oldLayout = galleryRect.check ? 1 : 2;
                }
                galleryRect.check = false;
                focusRect.check = false;
                isShareMode = true;
            } else {
                if (currentCount === 0) {
                    focusRect.check = false;
                    galleryRect.check = false;
                } else {
                    if (currentCount === 1 && liveMemberCount === 0) {
                        galleryRect.check = true;
                    } else if (isShareMode) {
                        galleryRect.check = oldLayout == 1;
                    }
                    focusRect.check = !galleryRect.check;
                }
                isShareMode = false;
            }
            liveMemberCount = currentCount;
            imgPreview.source = getPreviewImageSource();
            if (root.isLive) {
                root.isLiveUserCountChanged = true;
            } else {
                btnLive.enabled = currentCount !== 0;
            }
        }
        onLiveMemberShareStatusChanged: {
            console.log("onLiveMemberShareStatusChanged");
            if (isSharing && liveMemberListModel.getLiveMemberIsSharing() === false) {
                return;
            }
            isShareMode = isSharing;
            imgPreview.source = getPreviewImageSource();
            if (!isShareMode) {
                // #fix YYTX-27734
                galleryRect.check = true;
                focusRect.check = !galleryRect.check;
            }
        }
    }
    ToastManager {
        id: toast
    }
    LiveMembersModel {
        id: liveMemberListModel
    }
    BorderImage {
        id: viewChangedTip
        anchors.left: mainLayout.left
        anchors.leftMargin: {
            if (SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage) {
                return 496;
            } else if (SettingsStatus.UILanguage_en === SettingsManager.uiLanguage) {
                return 575;
            } else {
                return 596;
            }
        }
        anchors.top: mainLayout.top
        anchors.topMargin: SettingsStatus.UILanguage_en === SettingsManager.uiLanguage ? 250 : 214
        height: 90
        parent: mainLayout
        source: "qrc:/qml/images/live/tip_background.png"
        visible: root.isLive && (root.isLiveLayoutChanged || root.isLiveUserCountChanged)
        width: {
            if (SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage) {
                return 293;
            } else if (SettingsStatus.UILanguage_en === SettingsManager.uiLanguage) {
                return 213;
            } else {
                return 179;
            }
        }

        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 12
            spacing: 4

            RowLayout {
                spacing: 6

                Image {
                    Layout.preferredHeight: 16
                    Layout.preferredWidth: 16
                    mipmap: true
                    source: "qrc:/qml/images/live/warning.png"
                }
                Label {
                    color: "#E6352B"
                    font.pixelSize: 14
                    text: qsTr("Live status has changed")
                }
            }
            ColumnLayout {
                Layout.leftMargin: 22
                spacing: 3

                Row {
                    spacing: 0

                    Text {
                        color: "#666666"
                        font.pixelSize: 12
                        text: qsTr("Please click\"")
                    }
                    Text {
                        color: "#337EFF"
                        font.pixelSize: 12
                        text: qsTr("update")
                    }
                    Text {
                        color: "#666666"
                        font.pixelSize: 12
                        text: "\""
                    }
                }
                Text {
                    color: "#666666"
                    font.pixelSize: 12
                    text: qsTr("Refresh the live layout")
                }
            }
        }
    }
    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: Qt.platform.os === 'windows' ? 10 : 0
        border.color: "#FFFFFF"
        border.width: 1
        radius: Qt.platform.os === 'windows' ? 0 : 10

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: 0
            height: parent.height - 52
            spacing: 0

            DragArea {
                Layout.preferredHeight: 50
                Layout.preferredWidth: parent.width
                title: qsTr("Live")

                onCloseClicked: Window.window.hide()
            }
            Rectangle {
                Layout.leftMargin: 36
                Layout.preferredHeight: 538 - 52
                Layout.preferredWidth: parent.width - (Qt.platform.os === 'windows' ? 36 : 0)
                Layout.topMargin: 10

                ColumnLayout {
                    id: baseInfo
                    anchors.left: parent.left
                    anchors.top: parent.top
                    height: 144
                    width: parent.width

                    RowLayout {
                        id: infoGrid
                        spacing: 35
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Column {
                            id: colLiveTitle
                            spacing: 8

                            Label {
                                id: liveTitle
                                color: "#333333"
                                font.pixelSize: 16
                                text: qsTr("LiveTitle")
                            }
                            CustomTextFieldEx {
                                id: titleEdit
                                Accessible.name: placeholderText
                                enabled: !root.isLive
                                placeholderText: qsTr("Please enter Live subject")
                                text: liveManager.getLiveTittle()
                                width: 346

                                validator: RegularExpressionValidator {
                                    regularExpression: /.{1,30}/
                                }
                            }
                        }
                        Column {
                            id: colLiveLink
                            spacing: 8

                            Label {
                                id: liveurl
                                color: "#333333"
                                font.pixelSize: 16
                                text: qsTr("Live link")
                            }
                            RowLayout {
                                spacing: 10

                                CustomTextFieldEx {
                                    id: urledit
                                    Layout.preferredWidth: 308
                                    color: "#333333"
                                    cursorPosition: 0
                                    enabled: false
                                    font.pixelSize: 14
                                    text: qsTr("live link: ") + liveManager.getLiveUrl()
                                }
                                Label {
                                    id: lblCopy
                                    Accessible.name: lblCopy.text
                                    Accessible.role: Accessible.Button
                                    color: "#337EFF"
                                    font.pixelSize: 14
                                    text: qsTr("Copy")

                                    Accessible.onPressAction: if (enabled)
                                        lblCopyBtn.clicked(Qt.LeftButton)

                                    MouseArea {
                                        id: lblCopyBtn
                                        anchors.fill: parent

                                        onClicked: {
                                            clipboard.setText(urledit.text);
                                            toast.show(qsTr('copy success'));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        id: rowPsw
                        spacing: 20

                        CustomCheckBox {
                            id: pswCheck
                            enabled: !root.isLive
                            font.pixelSize: 14
                            text: qsTr("Open password")

                            onToggled: {
                                pswEdit.enabled = pswCheck.checked;
                                if (pswCheck.checked) {
                                    pswEdit.text = root.pswd;
                                    if (pswEdit.text.trim().length === 0) {
                                        pswEdit.text = ('000000' + Math.floor(Math.random() * 999999)).slice(-6);
                                    }
                                } else if (!pswEdit.checked) {
                                    root.pswd = pswEdit.text;
                                    pswEdit.text = "";
                                }
                            }
                        }
                        CustomTextFieldEx {
                            id: pswEdit
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: titleEdit.width - pswCheck.width - rowPsw.spacing
                            enabled: false
                            placeholderText: qsTr("Please enter a 6-digit password")
                            text: liveManager.getLivePassword()

                            validator: RegularExpressionValidator {
                                regularExpression: /[0-9]{6}/
                            }
                        }
                        CustomCheckBox {
                            id: chatRoomEnableCheckBox
                            Layout.leftMargin: 15
                            checkState: liveManager.getLiveChatRoomEnable() ? Qt.Checked : Qt.Unchecked
                            font.pixelSize: 14
                            text: qsTr("Open chatroom")

                            onClicked: {
                                if (root.isLive) {
                                    root.isLiveChatroomChanged = true;
                                }
                            }
                        }
                        Label {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage ? 150 : 210
                            color: "#999999"
                            font.pixelSize: 12
                            text: qsTr("After opening, the conference room and the live broadcast room will be visible to each other")
                            wrapMode: Text.WordWrap
                        }
                    }
                    RowLayout {
                        id: liveAccess
                        spacing: 16

                        CustomCheckBox {
                            id: liveAccessCheckBox
                            checkState: liveManager.getLiveAccessEnable() ? Qt.Checked : Qt.Unchecked
                            enabled: !root.isLive
                            font.pixelSize: 14
                            text: qsTr("Only employees of company can watch")
                        }
                        Label {
                            Layout.alignment: Qt.AlignVCenter
                            color: "#999999"
                            font.pixelSize: 12
                            text: qsTr("After opening, non-employees cannot watch the live")
                        }
                    }
                }
                Label {
                    id: liveViewSetting
                    anchors.left: baseInfo.left
                    anchors.top: baseInfo.bottom
                    anchors.topMargin: 38
                    color: "#333333"
                    font.pixelSize: 16
                    text: qsTr("LiveView setting")
                }
                RowLayout {
                    anchors.left: baseInfo.left
                    anchors.leftMargin: 0
                    anchors.top: liveViewSetting.bottom
                    anchors.topMargin: 16
                    spacing: liveMemberCount === 0 ? 9 : 36

                    // Live view settings
                    ColumnLayout {
                        Layout.preferredHeight: 200
                        spacing: 8

                        Rectangle {
                            id: memberRect
                            Layout.preferredHeight: 192
                            Layout.preferredWidth: 240
                            border.color: "#E1E3E6"
                            border.width: 1
                            radius: 2

                            ListView {
                                id: memberList
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.top: parent.top
                                anchors.topMargin: 14
                                clip: true
                                height: parent.height - 15
                                model: liveMemberListModel
                                spacing: 8
                                width: parent.width - 16

                                ScrollBar.vertical: ScrollBar {
                                    rightPadding: 2
                                    width: 8
                                }
                                delegate: Rectangle {
                                    color: "#FFFFFF"
                                    height: 20
                                    width: memberList.width - 6

                                    Component.onCompleted: {
                                        if (model.index === 0) {
                                            memberList.currentIndex = model.index;
                                        }
                                    }

                                    RowLayout {
                                        anchors.centerIn: parent.Center
                                        height: 20
                                        spacing: 5

                                        CustomButton {
                                            id: btnMemberCheck
                                            function getNormalTextColor(checkState = 0) {
                                                if (checkState === 0) {
                                                    return "#FFFFFF";
                                                } else if (checkState === 1) {
                                                    return "#337EFF";
                                                } else {
                                                    return "#F2F2F5";
                                                }
                                            }

                                            Accessible.name: model.index
                                            Layout.preferredHeight: 16
                                            Layout.preferredWidth: 16
                                            borderColor: model.checkState === 1 ? "#337EFF" : "#CCCCCC"
                                            borderSize: 1
                                            font.pixelSize: 12
                                            normalBkColor: getNormalTextColor(model.checkState)
                                            normalTextColor: "#FFFFFF"
                                            text: model.number === 0 ? "" : model.number

                                            onClicked: {
                                                liveMemberListModel.setChecked(model.index);
                                            }
                                        }
                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            color: "#333333"
                                            font.pixelSize: 14
                                            text: model.nickname
                                        }
                                    }
                                }
                            }
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: memberRect.width + 5
                            color: "#999999"
                            font.pixelSize: 12
                            text: qsTr("After the user turns on the video, it can appear in the list")
                            wrapMode: Text.WordWrap
                        }
                    }
                    // Indicator
                    BorderImage {
                        id: line1
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredHeight: 9
                        Layout.preferredWidth: 40
                        source: "qrc:/qml/images/live/line.png"
                    }
                    // Live layout selector
                    Rectangle {
                        id: rect
                        Layout.preferredHeight: 188
                        Layout.preferredWidth: liveMemberCount === 0 ? 212 : 100

                        ColumnLayout {
                            Layout.fillWidth: true
                            anchors.fill: parent
                            spacing: 16

                            Rectangle {
                                id: galleryRect

                                property bool check: false

                                Layout.alignment: Qt.AlignHCenter
                                height: 86
                                visible: liveMemberCount === 0 || !isShareMode
                                width: 100

                                ColumnLayout {
                                    spacing: 6

                                    BorderImage {
                                        id: name
                                        Layout.preferredHeight: 60
                                        Layout.preferredWidth: 100
                                        height: 60
                                        source: (galleryRect.check && liveMemberCount !== 0) ? "qrc:/qml/images/live/gallery_check.png" : "qrc:/qml/images/live/gallery_normal.png"
                                        width: 100
                                    }
                                    Label {
                                        Layout.alignment: Qt.AlignHCenter
                                        color: (galleryRect.check && liveMemberCount !== 0) ? "#337EFF" : "#999999"
                                        font.pixelSize: 12
                                        text: qsTr("Gallery view")
                                    }
                                }
                                MouseArea {
                                    acceptedButtons: Qt.LeftButton
                                    anchors.fill: parent

                                    onPressed: {
                                        if (liveMemberCount === 0) {
                                            return;
                                        }
                                        if (!galleryRect.check) {
                                            galleryRect.check = true;
                                            focusRect.check = false;
                                            liveViewChanged();
                                        }
                                    }
                                }
                            }
                            RowLayout {
                                spacing: 12

                                Rectangle {
                                    id: focusRect

                                    property bool check: false

                                    height: 86
                                    visible: liveMemberCount === 0 || !isShareMode
                                    width: 100

                                    ColumnLayout {
                                        spacing: 6

                                        BorderImage {
                                            Layout.preferredHeight: 60
                                            Layout.preferredWidth: 100
                                            height: 60
                                            source: (focusRect.check && liveMemberCount !== 0) ? "qrc:/qml/images/live/focus_check.png" : "qrc:/qml/images/live/focus_normal.png"
                                            width: 100
                                        }
                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            color: (focusRect.check && liveMemberCount !== 0) ? "#337EFF" : "#999999"
                                            font.pixelSize: 12
                                            text: qsTr("Focus view")
                                        }
                                    }
                                    MouseArea {
                                        acceptedButtons: Qt.LeftButton
                                        anchors.fill: parent

                                        onPressed: {
                                            if (liveMemberCount === 0) {
                                                return;
                                            }
                                            if (!focusRect.check) {
                                                focusRect.check = true;
                                                galleryRect.check = false;
                                                liveViewChanged();
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    id: shareRect
                                    height: 86
                                    visible: liveMemberCount === 0 || isShareMode
                                    width: 100

                                    ColumnLayout {
                                        spacing: 6

                                        BorderImage {
                                            Layout.preferredHeight: 60
                                            Layout.preferredWidth: 100
                                            height: 60
                                            rotation: 360
                                            source: (liveMemberCount !== 0 && isShareMode) ? "qrc:/qml/images/live/share_check.png" : "qrc:/qml/images/live/share_normal.png"
                                            width: 100
                                        }
                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            color: (liveMemberCount !== 0 && isShareMode) ? "#337EFF" : "#999999"
                                            font.pixelSize: 12
                                            text: qsTr("Shared view")
                                        }
                                    }
                                    MouseArea {
                                        acceptedButtons: Qt.LeftButton
                                        anchors.fill: parent

                                        onPressed: {
                                            if (memberList.count === 0) {
                                                return;
                                            }
                                            if (!focusRect.check) {
                                                focusRect.check = true;
                                                galleryRect.check = false;
                                                liveViewChanged();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // Indicator
                    BorderImage {
                        id: line2
                        Layout.preferredHeight: 9
                        Layout.preferredWidth: 40
                        source: "qrc:/qml/images/live/line.png"
                    }
                    // Live preview
                    ColumnLayout {
                        id: colPreview
                        spacing: 6

                        BorderImage {
                            id: imgPreview
                            Layout.preferredHeight: 96
                            Layout.preferredWidth: 160
                            height: 96
                            source: "qrc:/qml/images/live/no_preview.png"
                            width: 160

                            Label {
                                anchors.centerIn: parent
                                color: "#999999"
                                font.pixelSize: 12
                                text: qsTr("Select Live from the left")
                                visible: imgPreview.source == Qt.resolvedUrl("qrc:/qml/images/live/no_preview.png")
                                wrapMode: Text.WordWrap
                            }
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            color: "#999999"
                            font.pixelSize: 12
                            text: qsTr("live preview")
                        }
                    }
                }
            }
        }
        Rectangle {
            id: screenFooterBar
            anchors.bottom: col.bottom
            height: 52
            radius: 10
            width: parent.width

            CustomToolSeparator {
                anchors.top: parent.top
                width: parent.width
            }
            Row {
                anchors.centerIn: parent
                spacing: 10

                CustomButton {
                    id: btnUpdate
                    borderSize: 0
                    enabled: root.isLiveLayoutChanged || root.isLiveUserCountChanged || root.isLiveChatroomChanged
                    height: 36
                    normalBkColor: "#337EFF"
                    normalTextColor: "#FFFFFF"
                    text: qsTr("update")
                    visible: root.isLive
                    width: 148

                    onClicked: {
                        var liveParams = {
                            "liveUsers": "",
                            "liveTitle": "",
                            "liveChatRoomEnable": "",
                            "password": "",
                            "layoutType": ""
                        };
                        if (liveMemberListModel.getliveMemberCount() === 0) {
                            toast.show(qsTr("The number of live broadcast members cannot be null"));
                            return;
                        }
                        liveParams.liveUsers = liveMemberListModel.getCheckedUserlist();
                        liveParams.liveChatRoomEnable = chatRoomEnableCheckBox.checkState == Qt.Checked;
                        liveParams.layoutType = galleryRect.check ? 1 : 2;
                        liveManager.updateLive(liveParams);
                    }
                }
                CustomButton {
                    id: btnLive
                    borderSize: 0
                    enabled: false
                    height: 36
                    normalBkColor: root.isLive ? "#E6352B" : "#337EFF"
                    normalTextColor: "#FFFFFF"
                    text: root.isLive ? qsTr("Stop") : qsTr("Start")
                    width: 116

                    onClicked: {
                        if (root.isLive) {
                            liveManager.stopLive();
                        } else {
                            if (titleEdit.text.length === 0) {
                                toast.show(qsTr("Live stream subject cannot be empty"));
                                return;
                            }
                            if (pswCheck.checkState == Qt.Checked && pswEdit.text === "") {
                                toast.show(qsTr("Please enter a 6-digit password"));
                                return;
                            } else if (pswCheck.checkState == Qt.Checked && pswEdit.text.length < 6) {
                                toast.show(qsTr("Please enter a 6-digit password"));
                                return;
                            }
                            var liveParams = {
                                "liveUsers": "",
                                "liveTitle": "",
                                "liveChatRoomEnable": "",
                                "liveAccessEnable": "",
                                "password": "",
                                "layoutType": "",
                                "isEnablePsw": ""
                            };
                            liveParams.liveUsers = liveMemberListModel.getCheckedUserlist();
                            liveParams.liveTitle = titleEdit.text;
                            liveParams.liveChatRoomEnable = chatRoomEnableCheckBox.checkState == Qt.Checked;
                            liveParams.liveAccessEnable = liveAccessCheckBox.checkState == Qt.Checked;
                            if (pswCheck.checkState == Qt.Checked) {
                                liveParams.password = pswEdit.text;
                            } else {
                                liveParams.password = "";
                            }
                            liveParams.layoutType = galleryRect.check ? 1 : 2;
                            liveManager.startLive(liveParams);
                        }
                    }
                }
            }
        }
    }
}
