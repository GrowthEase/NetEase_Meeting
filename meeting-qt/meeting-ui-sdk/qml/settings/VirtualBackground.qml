import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import QtQuick.Dialogs 1.3
import NetEase.Meeting.FrameProvider 1.0
import NetEase.Meeting.DeviceModel 1.0
import NetEase.Meeting.VideoWindow 1.0
import NetEase.Meeting.VirtualBackgroundModel 1.0

import "../components"

Rectangle {
    anchors.fill: parent
    anchors.margins: 40
    anchors.topMargin: 20
    anchors.bottomMargin: 20

    Component.onCompleted: {
        const currentIndex = deviceManager.currentIndex(DeviceSelector.DeviceType.CaptureType)
        deviceManager.selectDevice(DeviceSelector.DeviceType.CaptureType, currentIndex)
        videoManager.startLocalVideoPreview(frameProvider)
    }

    FrameProvider {
        id: frameProvider
        accountId: authManager.authAccountId
    }

    ToastManager {
        id: toast
    }

    ColumnLayout {
        spacing: 20
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.right: parent.right
        anchors.rightMargin: 50
        Rectangle {
            id: idVideoRect
            Layout.preferredWidth: 452
            Layout.preferredHeight: 254
            color: "#1f1f1f"

            Image {
                anchors.centerIn: parent
                mipmap: true
                source: "qrc:/qml/images/settings/camera_empty.png"
            }

            VideoOutput {
                anchors.fill: parent
                source: frameProvider
            }
        }

        GridView {
            id: vbGridView
            Layout.preferredWidth: 452
            Layout.preferredHeight: 136
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: 0
            cellWidth: 98 + 15
            cellHeight: 62 + 6
            clip: true
            cacheBuffer: vbListModel.rowCount() * cellHeight
            model: VirtualBackgroundModel {
                id: vbListModel
            }
            delegate: Rectangle {
                width: vbGridView.cellWidth - 10
                height: vbGridView.cellHeight -6
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: vbGridView.cellWidth - 10
                    height: vbGridView.cellHeight -6
                    color: "#FFFFFF"
                    radius: 4
                    border.width: 1
                    border.color: (model.vbCurrentSelected || ma.containsMouse) ? "#337EFF" : "#E1E3E6"

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            if ("qrc:/qml/images/settings/vb/add.svg" === model.vbPath) {
                                fileDialog.open()
                            } else {
                                vbListModel.setSelectedVB(model.vbPath)
                            }
                        }

                        FileDialog {
                            id: fileDialog
                            nameFilters: ["Image files (*.jpg *.png)"]
                            folder: shortcuts.home
                            onAccepted: {
                                console.log("add vb image: " + fileDialog.fileUrl)
                                vbListModel.addVB(fileDialog.fileUrl)
                            }
                        }
                    }

                    Rectangle {
                        id: idCell
                        width: 98
                        height: 62
                        anchors.top: parent.top
                        anchors.topMargin: 6
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 6
                        Image {
                            id: idImag
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: parent.width
                            height: parent.height
                            asynchronous: true
                            mipmap: true
                            fillMode: Image.Stretch // Image.PreserveAspectFit
                            source: getItemImage(model.vbPath)
                        }

                        Image {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            visible: model.vbAllowedDelete && ma.containsMouse
                            width: 16
                            height: 16
                            mipmap: true
                            source: "qrc:/qml/images/settings/vb/delete.svg"
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    vbListModel.removeVB(model.vbPath)
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 0
                            anchors.centerIn: parent
                            visible: "qrc:/qml/images/settings/vb/add.svg" === model.vbPath || model.vbPath.includes("null.jpg")
                            Image {
                                Layout.alignment: Qt.AlignCenter
                                visible: "qrc:/qml/images/settings/vb/add.svg" === model.vbPath
                                mipmap: true
                                width: 12
                                height: 12
                                source: "qrc:/qml/images/settings/vb/add_s.svg"
                            }
                            Label {
                                font.weight: Font.Light
                                font.pointSize: 8
                                text: "qrc:/qml/images/settings/vb/add.svg" === model.vbPath ? qsTr("add local image") : qsTr("nothing")
                            }
                        }
                    }


                    //                    Accessible.role: Accessible.Button
                    //                    Accessible.name: idCellText.text
                    //                    Accessible.onPressAction: if (enabled) ma.clicked(Qt.LeftButton)
                }
            }
            ScrollBar.vertical: ScrollBar {
                id: idScrollBar
                width: 7
            }
        }
    }

    Connections {
        target: rootWindow
        onVisibilityChanged: {
            if (rootWindow.visibility === Window.Hidden) {
                if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                    //videoManager.removeVideoCanvas(authManager.authAccountId, frameProvider)
                } else {
                    videoManager.stopLocalVideoPreview(frameProvider)
                }
            } else {
                if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                    videoManager.setupVideoCanvas(authManager.authAccountId, frameProvider, SettingsManager.remoteVideoResolution, frameProvider.uuid);
                }
            }
        }
    }

    Connections {
        target: SettingsManager
        function onVirtualBackgroundChanged(enabled, msg) {
            if (!enabled) {
                toast.show(msg)
            }
        }
    }

    function getItemImage(imagePath) {
        if ('' === imagePath) {
            return ''
        } else if (imagePath.startsWith('qrc:/') || imagePath.startsWith(':/')) {
            return imagePath
        }

        return "image://localImage/" + imagePath
    }
}
