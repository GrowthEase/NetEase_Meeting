import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NetEase.Meeting.DeviceModel 1.0
import NetEase.Meeting.Settings 1.0

Popup {
    id: root
    height: deviceContainer.height + 10
    width: globalWidth
    padding: 5
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

    signal selectedDevice

    enum DeviceSelectorMode {
        DefaultMode,
        AudioMode,
        VideoMode
    }

    enum DeviceType {
        DefaultType,
        PlayoutType,
        RecordType,
        CaptureType
    }

    property int globalWidth: 350
    property int insetWidth: 340
    property int selectorMode: DeviceSelector.DeviceSelectorMode.AudioMode

    Component.onCompleted: {
        repeaterModel.clear()
        if (selectorMode === DeviceSelector.DeviceSelectorMode.AudioMode) {
            repeaterModel.append({ deviceType: DeviceSelector.DeviceType.PlayoutType })
            repeaterModel.append({ deviceType: DeviceSelector.DeviceType.RecordType })
        } else if (selectorMode === DeviceSelector.DeviceSelectorMode.VideoMode) {
            repeaterModel.append({ deviceType: DeviceSelector.DeviceType.CaptureType })
        }
    }

    Rectangle {
        id: deviceContainer
        height: childrenRect.height
        width: insetWidth
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

        ListModel {
            id: repeaterModel
        }

        ColumnLayout {
            spacing: 0
            Repeater {
                model: repeaterModel
                Layout.preferredHeight: childrenRect.height
                Layout.preferredWidth: childrenRect.width
                delegate: ColumnLayout {
                    Label {
                        Layout.preferredWidth: deviceListView.width
                        Layout.preferredHeight: 32
                        Layout.leftMargin: 10
                        verticalAlignment: Text.AlignVCenter
                        color: "#FFFFFF"
                        text: {
                            switch (model.deviceType) {
                            case DeviceSelector.DeviceType.PlayoutType:
                                return qsTr("Speakers")
                            case DeviceSelector.DeviceType.RecordType:
                                return qsTr("Microphones")
                            case DeviceSelector.DeviceType.CaptureType:
                                return qsTr("Videos")
                            }
                        }
                    }
                    ListView {
                        id: deviceListView
                        Layout.preferredWidth: insetWidth
                        Layout.preferredHeight: deviceListView.count * 32
                        model: DeviceModel {
                            id: listModel
                            deviceType: model.deviceType
                            manager: deviceManager
                        }
                        delegate: ItemDelegate {
                            id: delegate
                            width: insetWidth
                            height: 32
                            background: Rectangle {
                                anchors.fill: parent
                                color: hovered ? "#0000000" : "#00000000"
                            }
                            RowLayout {
                                width: parent.width
                                anchors.verticalCenter: parent.verticalCenter
                                clip: true
                                spacing: 0
                                Label {
                                    id: deviceName
                                    clip: true
                                    color: "#FFFFFF"
                                    opacity: .8
                                    text: model.deviceName
                                    elide: Text.ElideRight
                                    font.pixelSize: 14
                                    Layout.preferredWidth: parent.width * .85
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                    Layout.leftMargin: 18
                                }
                            }
                            Image {
                                id: selectedIcon
                                height: 12
                                width: 12
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                visible: model.deviceSelected
                                source: "qrc:/qml/images/public/icons/right_white.svg"
                            }
                            onClicked: {
                                if (shareManager.shareAccountId === authManager.authAccountId)
                                    root.close()
                                deviceManager.selectDevice(listModel.deviceType, model.index)
                            }
                        }
                    }
                    CustomToolSeparator {
                        opacity: .1
                        Layout.preferredWidth: insetWidth
                        visible: shareManager.shareAccountId !== authManager.authAccountId
                    }
                }
            }
            ItemDelegate {
                Layout.preferredWidth: insetWidth
                Layout.preferredHeight: 32
                Layout.topMargin: 5
                visible: shareManager.shareAccountId !== authManager.authAccountId
                background: Rectangle {
                    anchors.fill: parent
                    color: parent.hovered ? "#000000" : "#00000000"
                }
                Label {
                    font.pixelSize: 14
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: {
                        if (selectorMode === DeviceSelector.DeviceSelectorMode.AudioMode) {
                            return qsTr("Audio Settings")
                        } else if (selectorMode === DeviceSelector.DeviceSelectorMode.VideoMode) {
                            return qsTr("Video Settings")
                        }
                        return qsTr('Settings')
                    }
                }
                onClicked: {
                    if (selectorMode === DeviceSelector.DeviceSelectorMode.AudioMode)
                        SettingsWnd.displayPage(2)
                    else
                        SettingsWnd.displayPage(1)

                    root.close()
                }
            }
            Item { height: 8 }
        }
    }

    function setDeviceSelectorMode(mode) {
        repeaterModel.clear()
        selectorMode = mode
        if (selectorMode === DeviceSelector.DeviceSelectorMode.AudioMode) {
            repeaterModel.append({ deviceType: DeviceSelector.DeviceType.PlayoutType })
            repeaterModel.append({ deviceType: DeviceSelector.DeviceType.RecordType })
        } else if (selectorMode === DeviceSelector.DeviceSelectorMode.VideoMode) {
            repeaterModel.append({ deviceType: DeviceSelector.DeviceType.CaptureType })
        }
    }
}
