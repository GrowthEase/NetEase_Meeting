import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia 5.12
import QtQuick.Window 2.14
import Qt5Compat.GraphicalEffects
import NetEase.Meeting.ScreenCaptureSourceModel 1.0
import NetEase.Meeting.MessageBubble 1.0
import "../components"

Popup {
    id: root

    property string randImage: ''
    property int screenIndex: 0
    property int currentSelectType: 0
    property var currentSelectSourceID: undefined

    function initializeCaptureSources() {
        busyIndicator.visible = true;
        Qt.callLater(function() {
            screenListModel.startEnumCaptureSources(320, 192);
        });
    }

    Accessible.name: idDragArea.title
    anchors.centerIn: parent
    bottomInset: 0
    closePolicy: Popup.NoAutoClose
    dim: false
    focus: true
    height: 570
    leftInset: 0
    margins: 0
    modal: false
    padding: 0
    rightInset: 0
    topInset: 0
    width: 800

    background: Rectangle {
        id: backgroundRect
        border.color: "#EBEDF0"
        border.width: 1
        layer.enabled: true
        radius: Qt.platform.os === 'windows' ? 0 : 10

        layer.effect: DropShadow {
            color: "#1917171a"
            height: backgroundRect.height
            horizontalOffset: 0
            radius: 16
            samples: 33
            source: backgroundRect
            verticalOffset: 0
            visible: backgroundRect.visible
            width: backgroundRect.width
            x: backgroundRect.x - 2
            y: backgroundRect.y - 2
        }
    }

    Component.onCompleted: {
        initializeCaptureSources();
    }

    onVisibleChanged: {
        if (visible) {
            initializeCaptureSources();
        }
    }

    ToastManager {
        id: toast
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height
        spacing: 0
        width: parent.width

        DragArea {
            id: idDragArea
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            title: qsTr("Select screen")
            titleFontSize: 18
            windowMode: false

            onCloseClicked: {
                root.close();
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
        }
        GridView {
            id: screenGridView
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: 25
            Layout.preferredHeight: 444
            Layout.preferredWidth: 760
            cacheBuffer: screenListModel.rowCount() * cellHeight
            cellHeight: 135 + 10
            cellWidth: 180 + 10
            clip: true

            ScrollBar.vertical: ScrollBar {
                id: idScrollBar
                width: 7
            }
            delegate: Rectangle {
                height: screenGridView.cellHeight - 10
                width: screenGridView.cellWidth - 10

                Rectangle {
                    Accessible.name: idCellText.text
                    Accessible.role: Accessible.Button
                    anchors.left: parent.left
                    anchors.top: parent.top
                    border.color: screenGridView.currentIndex === model.index || ma.containsMouse ? "#337EFF" : "#E1E3E6"
                    border.width: 1
                    color: "#FFFFFF"
                    height: screenGridView.cellHeight - 10
                    radius: 4
                    visible: -1 !== model.type
                    width: screenGridView.cellWidth - 10

                    Accessible.onPressAction: {
                        if (enabled)
                            ma.clicked(Qt.LeftButton);
                    }
                    Component.onCompleted: {
                        if (model.index === 0) {
                            screenGridView.currentIndex = model.index;
                            screenIndex = model.index;
                            currentSelectType = model.type;
                            currentSelectSourceID = model.id;
                        }
                    }

                    Rectangle {
                        id: idCell
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        color: "#F2F3F5"
                        height: 96
                        width: 160

                        Image {
                            id: idImag
                            anchors.left: parent.left
                            anchors.top: parent.top
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                            height: parent.height
                            mipmap: true
                            source: `data:image/png;base64,${model.thumbnail}`
                            sourceSize.height: height
                            sourceSize.width: width
                            width: parent.width
                        }
                    }
                    Label {
                        id: idCellText
                        ToolTip.text: idCellText.text
                        ToolTip.delay: 1000
                        ToolTip.visible: ma.containsMouse ? idCellText.text.length !== 0 && idCellText.truncated : false
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: idCell.bottom
                        anchors.topMargin: 6
                        color: screenGridView.currentIndex === model.index || ma.containsMouse ? "#337EFF" : "#222222"
                        elide: Text.ElideRight
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        text: model.title
                        width: parent.width - 20
                    }
                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: {
                            currentSelectType = model.type;
                            currentSelectSourceID = model.id;
                            screenGridView.currentIndex = model.index;
                        }
                    }
                }
            }
            model: ScreenCaptureSourceModel {
                id: screenListModel
                onModelReset: {
                    busyIndicator.visible = false;
                    screenGridView.currentIndex = 0;
                }
            }
        }
    }

    Rectangle {
        id: screenFooterBar
        anchors.bottom: parent.bottom
        height: 52
        radius: 10
        width: parent.width

        CustomToolSeparator {
            anchors.top: parent.top
            width: parent.width
        }
        CustomCheckBox {
            id: checkShareAudio
            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter
            checked: shareManager.shareSystemSound
            font.pixelSize: 14
            font.weight: Font.Light
            text: qsTr("Shared computer sound")
            visible: Qt.platform.os === "windows"

            onClicked: {
                shareManager.setShareSystemSound(checkShareAudio.checked);
            }
        }
        CustomButton {
            anchors.centerIn: parent
            height: 36
            highlighted: true
            text: qsTr("Start")
            width: 120

            onClicked: {
                if (whiteboardManager.whiteboardSharing) {
                    toast.show(qsTr("Whiteboard sharing does not currently support screen share"));
                    return;
                }
                if (!shareManager.hasRecordPermission()) {
                    toast.show(qsTr('You have no permission to sharing screen.'));
                    return;
                }
                if (shareManager.shareAccountId.length !== 0) {
                    toast.show(qsTr("Someone is currently sharing a screen"));
                    return;
                }

                if (MessageBubble.visible) {
                    MessageBubble.hide();
                }
                shareManager.clearExcludeShareWindow();
                const screens = Qt.application.screens;
                let screen = mainWindow.screen;
                if (screenGridView.currentIndex <= screens.length - 1) {
                    screen = screens[screenGridView.currentIndex];
                }
                sharedWnd = Qt.createComponent("qrc:/qml/share/SSToolbar.qml").createObject(mainWindow);
                sharedWnd.shareScreen = screen;
                sharedWnd.screen = screen;
                if (Qt.platform.os === 'osx')
                    shareManager.addExcludeShareWindow(MessageBubble);
                console.log(`Start screen capture: source ID: ${currentSelectSourceID}, type: ${currentSelectType}`);
                shareManager.startSharingWithSourceID(currentSelectSourceID, currentSelectType);
                close();
            }
        }
    }

    Rectangle {
        id: busyIndicator
        anchors.fill: parent
        color: "transparent"
        width: parent.width

        BusyIndicator {
            anchors.centerIn: parent
            height: 40
            width: 40
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    Connections {
        target: shareManager
        onScreenAdded: {
            initializeCaptureSources();
        }
        onScreenRemoved: {
            initializeCaptureSources();
        }
    }
}
