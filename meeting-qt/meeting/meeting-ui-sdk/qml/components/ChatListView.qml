import QtQuick 2.15
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12
import NetEase.Meeting.GlobalChatManager 1.0
import NetEase.Meeting.MessageModel 1.0
import NetEase.Meeting.MessageModelEnum 1.0

import "../components"

Rectangle {
    property MessageModel messageModel
    property alias  msglistView : msglistView
    property int    maxMsgUintWidth: 302
    property int    avatarSize: 24
    property alias  verScrollBar :verScrollBar
    property var    listBarPos: 0.0
    id:root
    width: parent.width
    height:parent.height
    color: "#00000000"

    Component.onCompleted: {
        messageModel.clearMessage()
        msglistView.positionViewAtEnd()
    }

    Component.onDestruction:{
        messageModel.clearMessage()
    }

    function getShowedNickname(name){ 
           return name.substring(0,1)
    }

    function getFileImageSource(ext) {
        if(ext === "mp3" || ext === "aac" || ext === "wav" || ext === "pcm") {
            return "qrc:/qml/images/chatroom/file/audio.svg"
        } else if(ext === "flv" || ext === "mov" || ext === "mp4") {
            return "qrc:/qml/images/chatroom/file/video.svg"
        } else if(ext === "doc" || ext === "docx") {
            return "qrc:/qml/images/chatroom/file/doc.svg"
        } else if(ext === "xls" || ext === "xlsx") {
            return "qrc:/qml/images/chatroom/file/excel.svg"
        } else if(ext === "ppt" || ext === "pptx") {
            return "qrc:/qml/images/chatroom/file/ppt.svg"
        } else if(ext === "pdf") {
            return "qrc:/qml/images/chatroom/file/pdf.svg"
        } else if(ext === "txt") {
            return "qrc:/qml/images/chatroom/file/text.svg"
        } else if(ext === "zip" || ext === "7z" || ext === "biz" || ext === "tar") {
            return "qrc:/qml/images/chatroom/file/rar.svg"
        } else if(ext === "jpg" || ext === "png" || ext === "jpeg" || ext === "bmp"){
            return "qrc:/qml/images/chatroom/file/image.svg"
        } else {
            return "qrc:/qml/images/chatroom/file/unknow.svg"
        }
    }

    function getFileSize(fileSize) {
        if(fileSize < 1024 * 1024) {
            return (fileSize / 1024).toFixed(2) + " KB"
        } else if(fileSize < 1024 * 1024 * 1024 && fileSize >= 1024 * 1024) {
            return (fileSize / (1024 * 1024)).toFixed(2) + " MB"
        }
        return ""
    }

    onHeightChanged: {
        verScrollBar.setPosition(listBarPos)
    }

    FileDialog {
        id: dialog_save
        property var uuid: ""
        property var fileUrl: ""
        property var fileName: ""
        property var oldFilePath: ""
        property var imageType: false
        currentFile: "file:///" + fileName
        title: qsTr("Save as")
        fileMode:FileDialog.SaveFile
        onAccepted: {
            var filePath = dialog_save.file.toString()

            if(Qt.platform.os === 'osx') {
                filePath = filePath.replace("file://", "")
            } else {
                filePath = filePath.replace("file:///", "")
            }

            if(imageType) {
                chatManager.saveImageAs(uuid, oldFilePath, filePath)
            } else {
                chatManager.saveFileAs(uuid, fileUrl, filePath)
            }
        }
    }

    Rectangle {
        id:listviewlayout
        anchors.fill: parent
        ListView {
            property bool msgTimeTip : false
            property bool appendByme : false
            id: msglistView
            anchors.fill: parent
            anchors.bottomMargin: 15
            anchors.leftMargin: 5
            header: Rectangle { height: 20 }
            clip: true
            displayMarginBeginning: 40
            displayMarginEnd: 40
            verticalLayoutDirection:ListView.TopToBottom
            spacing: 6

            model: messageModel
            delegate: Rectangle {
                anchors.rightMargin: 5
                anchors.leftMargin: 5
                width: listviewlayout.width - 10
                height: msgUintLayout.height

                ColumnLayout {
                    id:msgUintLayout
                    width: parent.width
                    spacing:0
                    visible: model.type === MessageModelEnum.IMAGE ? (image.status == Image.Ready) : true //图片消息由于加载图片存在耗时，加载完成后再显示消息
                    Rectangle {
                        id:timetiper
                        Layout.fillWidth: true
                        Layout.preferredWidth: msgTip.width + 24
                        Layout.preferredHeight: msgTip.implicitHeight + 8
                        Layout.alignment: Qt.Horizontal
                        visible: model.type === MessageModelEnum.TIME
                        color: "transparent"
                        border.color:"transparent"
                        Label {
                            id: msgTip
                            color: "#999999"
                            text: qsTr(model.text)
                            font.pixelSize:12
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Rectangle {
                        id: userInfo
                        Layout.preferredHeight: 32
                        Layout.fillWidth: true

                        Avatar {
                            id: avatarLeft
                            height: avatarSize
                            width: height
                            visible: !model.sendFlag && model.type !== MessageModelEnum.TIME
                            nickname:  qsTr(getShowedNickname(model.nickname))
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            id: leftnickname
                            visible: avatarLeft.visible
                            font.pixelSize:12
                            color: "#333333"
                            anchors.top: parent.top
                            anchors.topMargin: 4
                            anchors.leftMargin: 5
                            anchors.left: avatarLeft.right
                            text: qsTr(model.nickname)
                        }

                        Label {
                            id: rightnickname
                            visible: model.sendFlag
                            font.pixelSize: 12
                            color: "#333333"
                            anchors.top: parent.top
                            anchors.topMargin: 4
                            text: qsTr(model.nickname)
                            anchors.right: avatarRight.left
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                        }

                        Avatar {
                            id: avatarRight
                            height: avatarSize
                            width: height
                            visible: model.sendFlag && model.type !== MessageModelEnum.TIME
                            nickname:  qsTr(getShowedNickname(model.nickname))
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: model.sendFlag ? parent.right : undefined
                        }
                    }

                    Rectangle{
                        id: fileRec
                        Layout.leftMargin: (!model.sendFlag && model.fileStatus !== MessageModelEnum.FAILED) ? avatarLeft.width + 3 : 0
                        Layout.rightMargin: model.sendFlag ? avatarRight.width + 3 : 0
                        Layout.topMargin: 0
                        Layout.alignment: model.sendFlag ? Qt.AlignRight : Qt.AlignLeft
                        Layout.preferredWidth: row.width
                        Layout.preferredHeight: row.height
                        RowLayout {
                            id: row
                            anchors.right: model.sendFlag ? parent.right : undefined
                            anchors.left: model.sendFlag ? undefined : parent.left
                            anchors.leftMargin: (error.visible && !model.sendFlag) ? 6 : 0
                            spacing: 4
                            Image {
                                id: error
                                source: "qrc:/qml/images/chatroom/error.svg"
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                mipmap: true
                                visible: model.fileStatus === MessageModelEnum.FAILED

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if(model.sendFlag) {
                                            if(!chatManager.isFileExists(model.filePath)){
                                                operator.show(qsTr("file not exist"))
                                                return
                                            }
                                            chatManager.resendFileMsg(model.type, model.filePath, model.uuid)
                                        } else {
                                            chatManager.saveFile(model.uuid, model.fileUrl, model.fileName)
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: fileMessageinfo
                                visible: model.type === 2
                                Layout.preferredWidth: 250
                                Layout.preferredHeight: 96
                                Layout.alignment: model.sendFlag ? Qt.AlignRight : Qt.AlignLeft
                                border.width: 1
                                border.color: "#dee0e2"
                                radius: 8

                                ColumnLayout {
                                    spacing: 0
                                    RowLayout {
                                        spacing: 14
                                        Layout.leftMargin: 14
                                        Layout.rightMargin: 14
                                        Layout.preferredHeight: 55
                                        Layout.alignment: Qt.AlignVCenter
                                        Image {
                                            id: fileImage
                                            Layout.alignment: Qt.AlignVCenter
                                            source: getFileImageSource(model.fileExt)
                                            mipmap: true
                                            Layout.preferredHeight: 32
                                            Layout.preferredWidth: 32
                                        }

                                        ColumnLayout {
                                            spacing: model.fileStatus === MessageModelEnum.START ? 12 : 4
                                            Layout.rightMargin: 14
                                            Label {
                                                text: model.fileName
                                                elide: Qt.ElideMiddle
                                                Layout.preferredWidth: 178
                                            }
                                            Label {
                                                text: getFileSize(model.fileSize)
                                                visible: model.fileStatus !== 1
                                                color: "#999999"
                                                font.pixelSize: 10
                                            }

                                            ProgressBar {
                                                id: progress
                                                visible: model.fileStatus === MessageModelEnum.START
                                                value: model.progress
                                                Layout.preferredWidth: 178
                                                Layout.preferredHeight: 4
                                                background: Rectangle {
                                                    radius: 2
                                                    color: "#e5e5e5"
                                                }
                                                contentItem: Item {
                                                    implicitWidth: progress.background.implicitWidth
                                                    implicitHeight: progress.background.implicitHeight

                                                    Rectangle {
                                                        radius: 2
                                                        width: progress.visualPosition * parent.width
                                                        height: parent.height
                                                        color: "#337eff"
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
                                        spacing: 24
                                        Layout.leftMargin: 14
                                        Layout.preferredHeight: 40
                                        visible: true
                                        Label {
                                            visible: model.sendFlag === false && (model.fileStatus === MessageModelEnum.IDLE || model.fileStatus === MessageModelEnum.FAILED)
                                            text: model.fileStatus === MessageModelEnum.IDLE ? qsTr("download") : qsTr("download again")
                                            font.pixelSize: 14
                                            color: "#337EFF"
                                            Layout.alignment: Qt.AlignVCenter
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    var path = ""
                                                    if(model.fileStatus === MessageModelEnum.FAILED) {
                                                        path = model.filePath
                                                    }
                                                    chatManager.saveFile(model.uuid, model.fileUrl, model.fileName, path)
                                                }
                                            }
                                        }

                                        Label {
                                            visible: model.sendFlag === false && model.fileStatus === MessageModelEnum.START
                                            text: qsTr("cancel download")
                                            font.pixelSize: 14
                                            color: "#337EFF"
                                            Layout.alignment: Qt.AlignVCenter
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    chatManager.stopDownloadFile(model.uuid)
                                                }
                                            }
                                        }

                                        Label {
                                            visible: model.sendFlag === true && model.fileStatus === MessageModelEnum.START
                                            text: qsTr("cancel upload")
                                            font.pixelSize: 14
                                            color: "#337EFF"
                                            Layout.alignment: Qt.AlignVCenter
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    chatManager.stopFileMsg(model.uuid);
                                                }
                                            }
                                        }

                                        Label {
                                            visible: (model.sendFlag === true && model.fileStatus !== MessageModelEnum.START) ||
                                                     (model.sendFlag === false && model.fileStatus === MessageModelEnum.SUCCESS)
                                            text: qsTr("open file")
                                            font.pixelSize: 14
                                            color: "#337EFF"
                                            Layout.alignment: Qt.AlignVCenter
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if(chatManager.isFileExists(model.filePath)) {
                                                        if(!Qt.openUrlExternally("file:///" + model.filePath)) {
                                                            operator.show(qsTr("file open failed"))
                                                        }
                                                        return
                                                    }

                                                    if(model.sendFlag) {
                                                        operator.show(qsTr("file not exist"))
                                                    } else {
                                                        operator.show(qsTr("file not exist, please download again"))
                                                        chatManager.updateFileStatus(model.uuid, MessageModelEnum.IDLE)
                                                    }
                                                }
                                            }
                                        }

                                        Label {
                                            visible: (model.sendFlag === true && model.fileStatus !== MessageModelEnum.START) ||
                                                     (model.sendFlag === false && model.fileStatus === MessageModelEnum.SUCCESS)
                                            text: qsTr("open dir")
                                            font.pixelSize: 14
                                            color: "#337EFF"
                                            Layout.alignment: Qt.AlignVCenter
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if(chatManager.isFileExists(model.filePath)) {
                                                        chatManager.showFileInFolder(model.filePath)
                                                        return
                                                    }

                                                    if(chatManager.isDirExists(model.fileDir)) {
                                                        Qt.openUrlExternally("file:///" + model.fileDir)
                                                        return
                                                    }

                                                    if(model.sendFlag) {
                                                        operator.show(qsTr("file not exist"))
                                                    } else {
                                                        operator.show(qsTr("file not exist, please download again"))
                                                        chatManager.updateFileStatus(model.uuid, MessageModelEnum.IDLE)
                                                    }
                                                }
                                            }
                                        }

                                        Label {
                                            visible: model.sendFlag === false &&
                                                     (model.fileStatus === MessageModelEnum.IDLE)
                                            text: qsTr("save as")
                                            font.pixelSize: 14
                                            color: "#337EFF"
                                            Layout.alignment: Qt.AlignVCenter
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    dialog_save.imageType = false
                                                    dialog_save.uuid = model.uuid
                                                    dialog_save.fileUrl = model.fileUrl
                                                    dialog_save.fileName = model.fileName
                                                    dialog_save.open()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: imageMessageinfo
                                visible: model.type === MessageModelEnum.IMAGE
                                Layout.preferredWidth: (model.imageWidth > root.width / 2) ? root.width / 2 : model.imageWidth
                                Layout.preferredHeight: imageMessageinfo.width * (model.imageHeight / model.imageWidth)
                                Layout.alignment: model.sendFlag ? Qt.AlignRight : Qt.AlignLeft
                                radius: 8
                                color: "transparent"

                                Image {
                                    id: image
                                    visible: model.type === MessageModelEnum.IMAGE
                                    smooth: false
                                    Component.onCompleted: {
                                        if (model.type === MessageModelEnum.IMAGE) {
                                            image.source = "file:///" + model.filePath
                                        }
                                    }

                                    sourceSize.width: parent.width
                                    sourceSize.height: parent.height
                                    asynchronous: true
                                    mipmap: true
                                    clip: true
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectCrop

                                    RingProgressbar {
                                        id: imageUploadProgressbar
                                        visible:  model.sendFlag && model.type === MessageModelEnum.IMAGE &&
                                                  image.status == Image.Ready && model.fileStatus === MessageModelEnum.START
                                        anchors.centerIn: parent
                                        percent:  {
                                            return model.progress
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                        onDoubleClicked: {
                                            Qt.openUrlExternally("file:///" + model.filePath)
                                        }

                                        onClicked: {
                                            if (mouse.button == Qt.RightButton) { // right menu
                                                const point = parent.mapToItem(imageMessageinfo, mouse.x, mouse.y)
                                                var delta = imageMessageinfo.width - point.x + 30;

                                                if(delta > imageMenu.width){
                                                    imageMenu.x = mouse.x
                                                    imageMenu.y = mouse.y
                                                }
                                                else{
                                                    imageMenu.x = mouse.x - imageMenu.width
                                                    imageMenu.y = mouse.y
                                                }

                                                imageMenu.open()
                                            }
                                        }
                                    }
                                }

                                Menu {
                                    id: imageMenu
                                    implicitWidth:80
                                    implicitHeight: 50

                                    Connections{
                                        target: msglistView
                                        onCountChanged: {
                                           if(imageMenu.visible === true){
                                               imageMenu.close()
                                           }
                                        }
                                    }

                                    MenuItem{
                                        id: saveItem
                                        width: parent.width
                                        height: visible ? 32 : 0

                                        Label {
                                            text: qsTr("Save as")
                                            color: saveItem.hovered ? "#337EFF" : "#333333"
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: saveItem.hovered ? "#F2F3F5" : "#FFFFFF"
                                        }
                                        onClicked: {
                                            dialog_save.imageType = true
                                            dialog_save.oldFilePath = model.filePath
                                            dialog_save.uuid = model.uuid
                                            dialog_save.fileName = model.fileName
                                            dialog_save.open()
                                        }
                                    }
                                }
                            }


                        }
                    }

                    Rectangle {
                        id: textMessageInfo
                        visible: model.type === MessageModelEnum.TEXT
                        Layout.leftMargin: avatarLeft.width + 3
                        Layout.rightMargin: avatarRight.width + 3
                        Layout.topMargin: -7
                        Layout.preferredWidth: Math.min(messageText.implicitWidth+24, maxMsgUintWidth)
                        Layout.preferredHeight: messageText.implicitHeight
                        Layout.alignment: model.sendFlag ? Qt.AlignRight : Qt.AlignLeft
                        radius: 8
                        color: model.sendFlag ? "#CCE1FF" : "#F2F3F5"
                        border.color: "white"

//                        Label {
//                            id: messageText
//                            text: model.text
//                            visible: model.type === MessageModelEnum.TEXT
//                            font.pixelSize:14
//                            anchors.fill: parent
//                            anchors.margins: 12
//                            anchors.topMargin: 10
//                            anchors.bottomMargin: 10
//                            wrapMode: Label.Wrap
//                            color: "#222222"
//                        }

                        TextArea {
                                id: messageText
                                visible: model.type === MessageModelEnum.TEXT
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                anchors.topMargin: 2
                                anchors.bottomMargin: 0
                                verticalAlignment: TextArea.AlignVCenter
                                readOnly: true
                                color: "#222222"
                                font.pixelSize: 14
                                wrapMode: Text.Wrap
                                background: Rectangle {
                                    height: 0
                                }
                                selectByMouse: true
                                selectByKeyboard: true
                                text: model.text
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.RightButton
                            onClicked: {
                                if (mouse.button == Qt.RightButton) { // right menu
                                    const point = parent.mapToItem(textMessageInfo, mouse.x, mouse.y)
                                    var delta = textMessageInfo.width - point.x + 30;

                                    if(delta > contentMenu.width){
                                        contentMenu.x = mouse.x
                                        contentMenu.y = mouse.y
                                    }
                                    else{
                                        contentMenu.x = mouse.x - contentMenu.width
                                        contentMenu.y = mouse.y
                                    }
                                    if (messageText.selectedText === "") {
                                        messageText.selectAll()
                                    }
                                    contentMenu.focus = false
                                    contentMenu.open()
                                }
                            }
                        }

                        Menu {
                            id: contentMenu
                            implicitWidth:80
                            implicitHeight: 50
                            Connections{
                                target: msglistView
                                onCountChanged: {
                                   if(contentMenu.visible === true){
                                       contentMenu.close()
                                   }
                                }
                            }

                            MenuItem{
                                id: copyItem
                                width: parent.width
                                height: visible ? 32 : 0
                                hoverEnabled: false
                                Label {
                                    id: copyText
                                    text: qsTr("Copy")
                                    color: ma.containsMouse ? "#337EFF" : "#333333"
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                background: Rectangle {
                                    anchors.fill: parent
                                    color: ma.containsMouse ? "#F2F3F5" : "#FFFFFF"
                                }
                                Accessible.role: Accessible.Button
                                Accessible.name: copyText.text
                                Accessible.onPressAction: if (enabled) clicked(Qt.LeftButton)
                            }
                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onClicked: {
                                    messageText.copy()
                                    contentMenu.close()
                                }
                            }
                        }
                    }

                }
            }

            ScrollBar.vertical: ScrollBar {
                id: verScrollBar
                width: 5
                onPositionChanged: {
                    listBarPos = verScrollBar.position
                    if (msglistView.atYEnd){
                        listBarPos = 1.0
                    }
                }
            }

        }
    }

}







