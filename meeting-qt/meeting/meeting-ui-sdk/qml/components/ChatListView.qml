import QtQuick
import Qt.labs.platform 1.1
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material
import NetEase.Meeting.GlobalChatManager 1.0
import NetEase.Meeting.MessageModel 1.0
import NetEase.Meeting.MessageModelEnum 1.0
import "../components"

Rectangle {
    id: root

    property int avatarSize: 24
    property var listBarPos: 0.0
    property int maxMsgUintWidth: 302
    property MessageModel messageModel
    property alias msglistView: msglistView
    property alias verScrollBar: verScrollBar

    function getFileImageSource(ext) {
        if (ext === "mp3" || ext === "aac" || ext === "wav" || ext === "pcm") {
            return "qrc:/qml/images/chatroom/file/audio.svg";
        } else if (ext === "flv" || ext === "mov" || ext === "mp4") {
            return "qrc:/qml/images/chatroom/file/video.svg";
        } else if (ext === "doc" || ext === "docx") {
            return "qrc:/qml/images/chatroom/file/doc.svg";
        } else if (ext === "xls" || ext === "xlsx") {
            return "qrc:/qml/images/chatroom/file/excel.svg";
        } else if (ext === "ppt" || ext === "pptx") {
            return "qrc:/qml/images/chatroom/file/ppt.svg";
        } else if (ext === "pdf") {
            return "qrc:/qml/images/chatroom/file/pdf.svg";
        } else if (ext === "txt") {
            return "qrc:/qml/images/chatroom/file/text.svg";
        } else if (ext === "zip" || ext === "7z" || ext === "biz" || ext === "tar") {
            return "qrc:/qml/images/chatroom/file/rar.svg";
        } else if (ext === "jpg" || ext === "png" || ext === "jpeg" || ext === "bmp") {
            return "qrc:/qml/images/chatroom/file/image.svg";
        } else {
            return "qrc:/qml/images/chatroom/file/unknow.svg";
        }
    }
    function getFileSize(fileSize) {
        if (fileSize < 1024 * 1024) {
            return (fileSize / 1024).toFixed(2) + " KB";
        } else if (fileSize < 1024 * 1024 * 1024 && fileSize >= 1024 * 1024) {
            return (fileSize / (1024 * 1024)).toFixed(2) + " MB";
        }
        return "";
    }
    function getShowedNickname(name) {
        return name.substring(0, 1);
    }

    color: "#00000000"
    height: parent.height
    width: parent.width

    Component.onCompleted: {
        messageModel.clearMessage();
        msglistView.positionViewAtEnd();
    }
    Component.onDestruction: {
        messageModel.clearMessage();
    }
    onHeightChanged: {
        verScrollBar.setPosition(listBarPos);
    }

    FileDialog {
        id: dialog_save

        property var fileName: ""
        property var fileUrl: ""
        property var imageType: false
        property var oldFilePath: ""
        property var uuid: ""

        currentFile: "file:" + fileName
        fileMode: FileDialog.SaveFile
        title: qsTr("Save as")

        onAccepted: {
            var filePath = dialog_save.file.toString();
            if (Qt.platform.os === 'osx') {
                filePath = filePath.replace("file://", "");
            } else {
                filePath = filePath.replace("file:///", "");
            }
            if (imageType) {
                chatManager.saveImageAs(uuid, oldFilePath, filePath);
            } else {
                chatManager.saveFileAs(uuid, fileUrl, filePath);
            }
        }
    }
    Rectangle {
        id: listviewlayout

        anchors.fill: parent

        ListView {
            id: msglistView

            property bool appendByme: false
            property bool msgTimeTip: false

            anchors.bottomMargin: 15
            anchors.fill: parent
            anchors.leftMargin: 10
            clip: true
            displayMarginBeginning: 40
            displayMarginEnd: 40
            model: messageModel
            spacing: 6
            verticalLayoutDirection: ListView.TopToBottom

            ScrollBar.vertical: ScrollBar {
                id: verScrollBar

                width: 5

                onPositionChanged: {
                    listBarPos = verScrollBar.position;
                    if (msglistView.atYEnd) {
                        listBarPos = 1.0;
                    }
                }
            }
            delegate: Rectangle {
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                height: msgUintLayout.height
                width: listviewlayout.width - 20

                ColumnLayout {
                    id: msgUintLayout

                    spacing: 0
                    visible: model.type === MessageModelEnum.IMAGE ? (image.status == Image.Ready) : true // 图片消息由于加载图片存在耗时，加载完成后再显示消息
                    width: parent.width

                    Rectangle {
                        id: timetiper

                        Layout.alignment: Qt.Horizontal
                        Layout.fillWidth: true
                        Layout.preferredHeight: msgTip.implicitHeight + 8
                        Layout.preferredWidth: msgTip.width + 24
                        border.color: "transparent"
                        color: "transparent"
                        visible: model.type === MessageModelEnum.TIME

                        Label {
                            id: msgTip

                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#999999"
                            font.pixelSize: 12
                            text: qsTr(model.text)
                        }
                    }
                    Rectangle {
                        id: userInfo

                        Layout.fillWidth: true
                        Layout.preferredHeight: 32

                        Avatar {
                            id: avatarLeft

                            anchors.verticalCenter: parent.verticalCenter
                            height: avatarSize
                            nickname: qsTr(getShowedNickname(model.nickname))
                            visible: !model.sendFlag && model.type !== MessageModelEnum.TIME
                            width: height
                        }
                        Label {
                            id: leftnickname

                            anchors.left: avatarLeft.right
                            anchors.leftMargin: 5
                            anchors.top: parent.top
                            anchors.topMargin: 4
                            color: "#333333"
                            font.pixelSize: 12
                            text: qsTr(model.nickname)
                            visible: avatarLeft.visible
                        }
                        Label {
                            id: rightnickname

                            anchors.leftMargin: 5
                            anchors.right: avatarRight.left
                            anchors.rightMargin: 5
                            anchors.top: parent.top
                            anchors.topMargin: 4
                            color: "#333333"
                            font.pixelSize: 12
                            text: qsTr(model.nickname)
                            visible: model.sendFlag
                        }
                        Avatar {
                            id: avatarRight

                            anchors.right: model.sendFlag ? parent.right : undefined
                            anchors.verticalCenter: parent.verticalCenter
                            height: avatarSize
                            nickname: qsTr(getShowedNickname(model.nickname))
                            visible: model.sendFlag && model.type !== MessageModelEnum.TIME
                            width: height
                        }
                    }
                    Rectangle {
                        id: fileRec

                        Layout.alignment: model.sendFlag ? Qt.AlignRight : Qt.AlignLeft
                        Layout.leftMargin: (!model.sendFlag && model.fileStatus !== MessageModelEnum.FAILED) ? avatarLeft.width + 3 : 0
                        Layout.preferredHeight: row.height
                        Layout.preferredWidth: row.width
                        Layout.rightMargin: model.sendFlag ? avatarRight.width + 3 : 0
                        Layout.topMargin: 0

                        RowLayout {
                            id: row

                            anchors.left: model.sendFlag ? undefined : parent.left
                            anchors.leftMargin: (error.visible && !model.sendFlag) ? 6 : 0
                            anchors.right: model.sendFlag ? parent.right : undefined
                            spacing: 4

                            Image {
                                id: error

                                Layout.preferredHeight: 16
                                Layout.preferredWidth: 16
                                mipmap: true
                                source: "qrc:/qml/images/chatroom/error.svg"
                                visible: model.fileStatus === MessageModelEnum.FAILED

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: {
                                        if (model.sendFlag) {
                                            if (!chatManager.isFileExists(model.filePath)) {
                                                operator.show(qsTr("file not exist"));
                                                return;
                                            }
                                            chatManager.resendFileMsg(model.type, model.filePath, model.uuid);
                                        } else {
                                            chatManager.saveFile(model.uuid, model.fileUrl, model.fileName);
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                id: fileMessageinfo

                                Layout.alignment: model.sendFlag ? Qt.AlignRight : Qt.AlignLeft
                                Layout.preferredHeight: 96
                                Layout.preferredWidth: 250
                                border.color: "#dee0e2"
                                border.width: 1
                                radius: 8
                                visible: model.type === 2

                                ColumnLayout {
                                    spacing: 0

                                    RowLayout {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.leftMargin: 14
                                        Layout.preferredHeight: 55
                                        Layout.rightMargin: 14
                                        spacing: 14

                                        Image {
                                            id: fileImage

                                            Layout.alignment: Qt.AlignVCenter
                                            Layout.preferredHeight: 32
                                            Layout.preferredWidth: 32
                                            mipmap: true
                                            source: getFileImageSource(model.fileExt)
                                        }
                                        ColumnLayout {
                                            Layout.rightMargin: 14
                                            spacing: model.fileStatus === MessageModelEnum.START ? 12 : 4

                                            Label {
                                                Layout.preferredWidth: 178
                                                color: "#333333"
                                                elide: Qt.ElideMiddle
                                                font.pixelSize: 14
                                                text: model.fileName
                                            }
                                            Label {
                                                color: "#999999"
                                                font.pixelSize: 10
                                                text: getFileSize(model.fileSize)
                                                visible: model.fileStatus !== 1
                                            }
                                            ProgressBar {
                                                id: progress

                                                Layout.preferredHeight: 4
                                                Layout.preferredWidth: 178
                                                value: model.progress
                                                visible: model.fileStatus === MessageModelEnum.START

                                                background: Rectangle {
                                                    color: "#e5e5e5"
                                                    radius: 2
                                                }
                                                contentItem: Item {
                                                    implicitHeight: progress.background.implicitHeight
                                                    implicitWidth: progress.background.implicitWidth

                                                    Rectangle {
                                                        color: "#337eff"
                                                        height: parent.height
                                                        radius: 2
                                                        width: progress.visualPosition * parent.width
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    Rectangle {
                                        Layout.preferredHeight: 1
                                        Layout.preferredWidth: fileMessageinfo.width
                                        color: "#dee0ef"
                                        visible: true
                                    }
                                    RowLayout {
                                        Layout.leftMargin: 14
                                        Layout.preferredHeight: 40
                                        spacing: 24
                                        visible: true

                                        Label {
                                            Layout.alignment: Qt.AlignVCenter
                                            color: "#337EFF"
                                            font.pixelSize: 14
                                            text: model.fileStatus === MessageModelEnum.IDLE ? qsTr("download") : qsTr("download again")
                                            visible: model.sendFlag === false && (model.fileStatus === MessageModelEnum.IDLE || model.fileStatus === MessageModelEnum.FAILED)

                                            MouseArea {
                                                anchors.fill: parent

                                                onClicked: {
                                                    var path = "";
                                                    if (model.fileStatus === MessageModelEnum.FAILED) {
                                                        path = model.filePath;
                                                    }
                                                    chatManager.saveFile(model.uuid, model.fileUrl, model.fileName, path);
                                                }
                                            }
                                        }
                                        Label {
                                            Layout.alignment: Qt.AlignVCenter
                                            color: "#337EFF"
                                            font.pixelSize: 14
                                            text: qsTr("cancel download")
                                            visible: model.sendFlag === false && model.fileStatus === MessageModelEnum.START

                                            MouseArea {
                                                anchors.fill: parent

                                                onClicked: {
                                                    chatManager.stopDownloadFile(model.uuid);
                                                }
                                            }
                                        }
                                        Label {
                                            Layout.alignment: Qt.AlignVCenter
                                            color: "#337EFF"
                                            font.pixelSize: 14
                                            text: qsTr("cancel upload")
                                            visible: model.sendFlag === true && model.fileStatus === MessageModelEnum.START

                                            MouseArea {
                                                anchors.fill: parent

                                                onClicked: {
                                                    chatManager.stopFileMsg(model.uuid);
                                                }
                                            }
                                        }
                                        Label {
                                            Layout.alignment: Qt.AlignVCenter
                                            color: "#337EFF"
                                            font.pixelSize: 14
                                            text: qsTr("open file")
                                            visible: (model.sendFlag === true && model.fileStatus !== MessageModelEnum.START) || (model.sendFlag === false && model.fileStatus === MessageModelEnum.SUCCESS)

                                            MouseArea {
                                                anchors.fill: parent

                                                onClicked: {
                                                    if (chatManager.isFileExists(model.filePath)) {
                                                        if (!Qt.openUrlExternally("file:" + model.filePath)) {
                                                            operator.show(qsTr("file open failed"));
                                                        }
                                                        return;
                                                    }
                                                    if (model.sendFlag) {
                                                        operator.show(qsTr("file not exist"));
                                                    } else {
                                                        operator.show(qsTr("file not exist, please download again"));
                                                        chatManager.updateFileStatus(model.uuid, MessageModelEnum.IDLE);
                                                    }
                                                }
                                            }
                                        }
                                        Label {
                                            Layout.alignment: Qt.AlignVCenter
                                            color: "#337EFF"
                                            font.pixelSize: 14
                                            text: qsTr("open dir")
                                            visible: (model.sendFlag === true && model.fileStatus !== MessageModelEnum.START) || (model.sendFlag === false && model.fileStatus === MessageModelEnum.SUCCESS)

                                            MouseArea {
                                                anchors.fill: parent

                                                onClicked: {
                                                    if (chatManager.isFileExists(model.filePath)) {
                                                        chatManager.showFileInFolder(model.filePath);
                                                        return;
                                                    }
                                                    if (chatManager.isDirExists(model.fileDir)) {
                                                        Qt.openUrlExternally("file:" + model.fileDir);
                                                        return;
                                                    }
                                                    if (model.sendFlag) {
                                                        operator.show(qsTr("file not exist"));
                                                    } else {
                                                        operator.show(qsTr("file not exist, please download again"));
                                                        chatManager.updateFileStatus(model.uuid, MessageModelEnum.IDLE);
                                                    }
                                                }
                                            }
                                        }
                                        Label {
                                            Layout.alignment: Qt.AlignVCenter
                                            color: "#337EFF"
                                            font.pixelSize: 14
                                            text: qsTr("save as")
                                            visible: model.sendFlag === false && (model.fileStatus === MessageModelEnum.IDLE)

                                            MouseArea {
                                                anchors.fill: parent

                                                onClicked: {
                                                    dialog_save.imageType = false;
                                                    dialog_save.uuid = model.uuid;
                                                    dialog_save.fileUrl = model.fileUrl;
                                                    dialog_save.fileName = model.fileName;
                                                    dialog_save.open();
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                id: imageMessageinfo

                                Layout.alignment: model.sendFlag ? Qt.AlignRight : Qt.AlignLeft
                                Layout.preferredHeight: imageMessageinfo.width * (model.imageHeight / model.imageWidth)
                                Layout.preferredWidth: (model.imageWidth > root.width / 2) ? root.width / 2 : model.imageWidth
                                color: "transparent"
                                radius: 8
                                visible: model.type === MessageModelEnum.IMAGE

                                Image {
                                    id: image

                                    anchors.fill: parent
                                    asynchronous: true
                                    clip: true
                                    fillMode: Image.PreserveAspectCrop
                                    mipmap: true
                                    smooth: false
                                    sourceSize.height: parent.height
                                    sourceSize.width: parent.width
                                    visible: model.type === MessageModelEnum.IMAGE

                                    Component.onCompleted: {
                                        if (model.type === MessageModelEnum.IMAGE) {
                                            image.source = "file:" + model.filePath;
                                        }
                                    }
                                    onStatusChanged: {
                                        if (image.status == Image.Ready && model.index == msglistView.count - 1) {
                                            Qt.callLater(() => {
                                                    if (!msglistView.atYEnd)
                                                        msglistView.positionViewAtEnd();
                                                });
                                        }
                                    }

                                    RingProgressbar {
                                        id: imageUploadProgressbar

                                        anchors.centerIn: parent
                                        percent: {
                                            return model.progress;
                                        }
                                        visible: model.sendFlag && model.type === MessageModelEnum.IMAGE && image.status == Image.Ready && model.fileStatus === MessageModelEnum.START
                                    }
                                    MouseArea {
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                        anchors.fill: parent

                                        onClicked: {
                                            if (mouse.button == Qt.RightButton) {
                                                // right menu
                                                const point = parent.mapToItem(imageMessageinfo, mouse.x, mouse.y);
                                                var delta = imageMessageinfo.width - point.x + 30;
                                                if (delta > imageMenu.width) {
                                                    imageMenu.x = mouse.x;
                                                    imageMenu.y = mouse.y;
                                                } else {
                                                    imageMenu.x = mouse.x - imageMenu.width;
                                                    imageMenu.y = mouse.y;
                                                }
                                                imageMenu.open();
                                            }
                                        }
                                        onDoubleClicked: {
                                            if (mouse.button !== Qt.LeftButton)
                                                return;
                                            Qt.openUrlExternally("file:" + model.filePath);
                                        }
                                    }
                                }
                                Menu {
                                    id: imageMenu

                                    implicitHeight: 50
                                    implicitWidth: 80

                                    Connections {
                                        target: msglistView

                                        onCountChanged: {
                                            if (imageMenu.visible === true) {
                                                imageMenu.close();
                                            }
                                        }
                                    }
                                    MenuItem {
                                        id: saveItem

                                        height: visible ? 32 : 0
                                        width: parent.width

                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: saveItem.hovered ? "#F2F3F5" : "#FFFFFF"
                                        }

                                        onClicked: {
                                            dialog_save.imageType = true;
                                            dialog_save.oldFilePath = model.filePath;
                                            dialog_save.uuid = model.uuid;
                                            dialog_save.fileName = model.fileName;
                                            dialog_save.open();
                                        }

                                        Label {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: saveItem.hovered ? "#337EFF" : "#333333"
                                            text: qsTr("Save as")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: textMessageInfo

                        Layout.alignment: model.sendFlag ? Qt.AlignRight : Qt.AlignLeft
                        Layout.leftMargin: avatarLeft.width + 3
                        Layout.preferredHeight: messageText.implicitHeight + 20
                        Layout.preferredWidth: Math.min(messageText.implicitWidth + 8, maxMsgUintWidth)
                        Layout.rightMargin: avatarRight.width + 3
                        border.color: "white"
                        color: model.sendFlag ? "#CCE1FF" : "#F2F3F5"
                        radius: 8
                        visible: model.type === MessageModelEnum.TEXT

                        TextArea {
                            id: messageText

                            anchors.bottomMargin: 0
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            background: null
                            bottomPadding: 0
                            color: "#222222"
                            font.pixelSize: 14
                            leftPadding: 12
                            readOnly: true
                            rightPadding: 12
                            selectByKeyboard: true
                            selectByMouse: true
                            text: model.text
                            topPadding: 0
                            verticalAlignment: TextArea.AlignVCenter
                            visible: model.type === MessageModelEnum.TEXT
                            wrapMode: Text.Wrap
                        }
                        MouseArea {
                            acceptedButtons: Qt.RightButton
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                if (mouse.button == Qt.RightButton) {
                                    // right menu
                                    const point = parent.mapToItem(textMessageInfo, mouse.x, mouse.y);
                                    var delta = textMessageInfo.width - point.x + 30;
                                    if (delta > contentMenu.width) {
                                        contentMenu.x = mouse.x;
                                        contentMenu.y = mouse.y;
                                    } else {
                                        contentMenu.x = mouse.x - contentMenu.width;
                                        contentMenu.y = mouse.y;
                                    }
                                    if (messageText.selectedText === "") {
                                        messageText.selectAll();
                                    }
                                    contentMenu.focus = false;
                                    contentMenu.open();
                                }
                            }
                        }
                        Menu {
                            id: contentMenu

                            implicitHeight: 50
                            implicitWidth: 80

                            Connections {
                                target: msglistView

                                onCountChanged: {
                                    if (contentMenu.visible === true) {
                                        contentMenu.close();
                                    }
                                }
                            }
                            MenuItem {
                                id: copyItem

                                Accessible.name: copyText.text
                                Accessible.role: Accessible.Button
                                height: visible ? 32 : 0
                                hoverEnabled: false
                                width: parent.width

                                background: Rectangle {
                                    anchors.fill: parent
                                    color: ma.containsMouse ? "#F2F3F5" : "#FFFFFF"
                                }

                                Accessible.onPressAction: if (enabled)
                                    clicked(Qt.LeftButton)

                                Label {
                                    id: copyText

                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: ma.containsMouse ? "#337EFF" : "#333333"
                                    text: qsTr("Copy")
                                }
                            }
                            MouseArea {
                                id: ma

                                acceptedButtons: Qt.LeftButton
                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    messageText.copy();
                                    contentMenu.close();
                                }
                            }
                        }
                    }
                }
            }
            header: Rectangle {
                height: 20
            }
        }
    }
}
