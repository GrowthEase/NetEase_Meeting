import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import QtQuick.Window 2.14
import QtGraphicalEffects 1.0
import NetEase.Meeting.ScreenModel 1.0
import NetEase.Meeting.MessageBubble 1.0

import "../components"

Popup {
    id: root
    anchors.centerIn: parent
    width: 800
    height: 570
    padding: 0
    bottomInset: 0
    leftInset: 0
    topInset: 0
    rightInset: 0
    margins: 0
    modal: true
    dim: false
    background: Rectangle {
        id: backgroundRect
        radius: Qt.platform.os === 'windows' ? 0 : 10
        border.width: 1
        border.color: "#EBEDF0"
        layer.enabled: true
        layer.effect: DropShadow {
            width: backgroundRect.width
            height: backgroundRect.height
            x: backgroundRect.x - 2
            y: backgroundRect.y - 2
            visible: backgroundRect.visible
            source: backgroundRect
            horizontalOffset: 0
            verticalOffset: 0
            radius: 16
            samples: 33
            color: "#1917171a"
        }
    }

    property int screenIndex: 0
    property string randImage: ''

    ToastManager {
        id: toast
    }

    Timer {
        id: idImageTimer
        repeat: false
        running: false
        interval: 100
        onTriggered: {
            randImage = '_' + ('000000' + Math.floor(Math.random() * 999999)).slice(-6)
            //idImageTimer.start()
        }
    }

    ColumnLayout {
        spacing: 0
        height: parent.height
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter

        DragArea {
            title: qsTr("Select screen")
            windowMode: false
            titleFontSize: 18
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            onCloseClicked: {
                root.close()
            }
        }

        Item {
            Layout.preferredHeight: 20
            Layout.fillWidth: true
        }

        GridView {
            id: screenGridView
            Layout.preferredHeight: 444
            Layout.preferredWidth: 760
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: 25
            cellWidth: 180 + 10
            cellHeight: 135 + 10
            clip: true
            cacheBuffer: screenListModel.rowCount() * cellHeight
            model: ScreenModel {
                id: screenListModel
                onModelReset: {
                    screenIndex = 0
                    screenGridView.currentIndex = screenIndex
                }
            }
            delegate: Rectangle {
                width: screenGridView.cellWidth - 10
                height: screenGridView.cellHeight -10
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: screenGridView.cellWidth - 10
                    height: screenGridView.cellHeight -10
                    color: "#FFFFFF"
                    radius: 4
                    border.width: 1
                    border.color: screenGridView.currentIndex === model.index || ma.containsMouse ? "#337EFF" : "#E1E3E6"
                    Component.onCompleted: {
                        if (model.index === 0) {
                            screenGridView.currentIndex = model.index
                            screenIndex = model.index
                        }
                    }
                    visible: -1 !== model.screenType

                    Rectangle {
                        id: idCell
                        width: 160
                        height: 96
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        color: "#F2F3F5"
                        Image {
                            id: idImag
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: parent.width
                            height: parent.height
                            asynchronous: true
                            fillMode: model.screenAppWinMinimized ? Image.Pad : Image.PreserveAspectFit
                            source: {
                                if (0 === model.screenType) {
                                    return "image://shareScreen/" + model.index + randImage
                                } else if (1 === model.screenType) {
                                    return "image://shareApp/" + model.screenAppWinId + randImage
                                }
                                return ""
                            }
                        }
                    }
                    Label {
                        id: idCellText
                        anchors.top: idCell.bottom
                        anchors.topMargin: 6
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: screenGridView.currentIndex === model.index || ma.containsMouse ? "#337EFF" : "#222222"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        text: {
                            if (0 === model.screenType) {
                                return qsTr("Screen") + (model.index + 1).toString()
                            } else if (1 === model.screenType) {
                                return model.screenName.toString()
                            }
                            return ""
                        }
                        ToolTip.text: idCellText.text
                        ToolTip.visible: ma.containsMouse ? idCellText.text.length !== 0 && idCellText.truncated : false
                        //                        MouseArea {
                        //                            id: maLabel
                        //                            anchors.fill: idCellText
                        //                            hoverEnabled: true
                        //                        }
                    }
                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            screenGridView.currentIndex = model.index
                            if (0 === model.screenType) {
                                screenIndex = model.index
                            } else if (1 === model.screenType) {
                                screenIndex = model.screenAppWinId
                            }
                        }
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: idCellText.text
                    Accessible.onPressAction: if (enabled) ma.clicked(Qt.LeftButton)
                }
            }
            ScrollBar.vertical: ScrollBar {
                id: idScrollBar
                width: 7
            }
        }
    }

    Rectangle {
        id: screenFooterBar
        width: parent.width
        height: 52
        anchors.bottom: parent.bottom
        radius: 10
        CustomToolSeparator {
            width: parent.width
            anchors.top: parent.top
        }
        CustomCheckBox {
            id: checkShareAudio
            visible: Qt.platform.os === "windows"
            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            font.weight: Font.Light
            text: qsTr("Shared computer sound")
            checked: shareManager.shareSystemSound
            onClicked: {
                shareManager.setShareSystemSound(checkShareAudio.checked);
            }
        }
        CustomCheckBox {
            id: checkSmooth
            anchors.left: Qt.platform.os === "windows" ? checkShareAudio.right : parent.left
            anchors.leftMargin: Qt.platform.os === "windows" ? 10 : 25
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            font.weight: Font.Light
            text: qsTr("Smooth priority")
            checked: shareManager.smoothPriority
            onClicked: {
                shareManager.setSmoothPriority(checkSmooth.checked);
            }
        }
        CustomButton {
            anchors.centerIn: parent
            width: 120
            height: 36
            highlighted: true
            text: qsTr("Start")
            onClicked: {
                if(whiteboardManager.whiteboardSharing){
                    toast.show(qsTr("Whiteboard sharing does not currently support screen share"))
                    return;
                }

                if (!shareManager.hasRecordPermission()) {
                    toast.show(qsTr('You have no permission to sharing screen.'))
                    return;
                }

                if (shareManager.shareAccountId.length !== 0) {
                    toast.show(qsTr("Someone is currently sharing a screen"))
                } else {
                    if (MessageBubble.visible){
                        MessageBubble.hide();
                    }

                    if (sharedWnd !== undefined){
                        sharedWnd.destroy()
                        sharedWnd = undefined
                    }
                    shareManager.clearShareWindow()
                    const screens = Qt.application.screens;
                    var screen = mainWindow.screen
                    if (shareSelector.screenIndex <= screens.length - 1)
                    {
                        screen = screens[shareSelector.screenIndex]
                    }
                    sharedWnd = Qt.createComponent("qrc:/qml/share/SSToolbar.qml").createObject(mainWindow)
                    sharedWnd.shareScreen = screen
                    sharedWnd.screen = screen

                    console.log("screenIndex: ", shareSelector.screenIndex)
                    if (shareSelector.screenIndex <= screens.length - 1)
                    {
                        close();
                        shareManager.startScreenSharing(shareSelector.screenIndex)
                    } else{
                        if (!screenListModel.windowExist(shareSelector.screenIndex)) {
                            toast.show(qsTr('The share failed because the window was closed'))
                            Qt.callLater(function(){
                                screenListModel.startEnumTopWindow()
                                //randImage = '_' + ('000000' + Math.floor(Math.random() * 999999)).slice(-6)
                            })
                            return;
                        }
                        close();
                        shareManager.startAppSharing(shareSelector.screenIndex)
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(function(){
                screenListModel.startEnumTopWindow()
                //randImage = '_' + ('000000' + Math.floor(Math.random() * 999999)).slice(-6)
            })

            //idImageTimer.start()
        }
        else {
            //idImageTimer.stop()
            //randImage = '_' + ('000000' + Math.floor(Math.random() * 999999)).slice(-6)
        }
    }
}
