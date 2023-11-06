pragma Singleton
import QtQuick
import QtQuick.Window 2.12
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material 2.12
import "../components"

Window {
    id: rootWindow

    property int beautyIndex: -1

    signal visibleStatus(bool isVisible)

    function displayPage(pageIndex) {
        initializeListMode(false);
        loader.setSource(Qt.resolvedUrl(optionModel.get(pageIndex).page));
        optionList.currentIndex = pageIndex;
        rootWindow.show();
        rootWindow.raise();
    }
    function hideWindow() {
        loader.setSource(Qt.resolvedUrl(optionModel.get(0).page));
        optionList.currentIndex = 0;
        hideRoot.start();
    }
    function initializeListMode(firstTime) {
        optionModel.clear();
        optionModel.append({
                "optionName": qsTr("General"),
                "iconActive": "qrc:/qml/images/settings/general_active.svg",
                "iconNormal": "qrc:/qml/images/settings/general_normal.svg",
                "page": "qrc:/qml/settings/MeetingSettings.qml"
            });
        optionModel.append({
                "optionName": qsTr("Videos"),
                "iconActive": "qrc:/qml/images/settings/video_active.svg",
                "iconNormal": "qrc:/qml/images/settings/video_normal.svg",
                "page": "qrc:/qml/settings/VideoDevice.qml"
            });
        optionModel.append({
                "optionName": qsTr("Audios"),
                "iconActive": "qrc:/qml/images/settings/microphone_active.svg",
                "iconNormal": "qrc:/qml/images/settings/microphone_normal.svg",
                "page": "qrc:/qml/settings/AudioDevice.qml"
            });
        if (authManager.isSupportBeauty && SettingsManager.getEnableBeauty()) {
            optionModel.append({
                    "optionName": qsTr("Beauty"),
                    "iconActive": "qrc:/qml/images/settings/beauty_active.svg",
                    "iconNormal": "qrc:/qml/images/settings/beauty_normal.svg",
                    "page": "qrc:/qml/settings/Beauty.qml"
                });
            beautyIndex = optionModel.count - 1;
        }
        if (SettingsManager.showVirtualBackground) {
            optionModel.append({
                    "optionName": qsTr("VirtualBackground"),
                    "iconActive": "qrc:/qml/images/settings/virtaulbackground_active.svg",
                    "iconNormal": "qrc:/qml/images/settings/virtaulbackground_normal.svg",
                    "page": "qrc:/qml/settings/VirtualBackground.qml"
                });
        }
        if (firstTime) {
            loader.setSource(Qt.resolvedUrl(optionModel.get(0).page));
            optionList.currentIndex = 0;
        }
    }

    Material.theme: Material.Light
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    height: 500 + 20
    title: qsTr("Settings")
    width: 800 + 20 // include shadow size

    Component.onCompleted: {
        initializeListMode(true);
    }
    onVisibleChanged: {
        visibleStatus(visible);
    }

    Timer {
        id: hideRoot
        interval: 200
        repeat: false

        onTriggered: rootWindow.hide()
    }
    Connections {
        target: rootWindow

        onClosing: {
            rootWindow.hide();
            close.accepted = false;
        }
    }
    Connections {
        target: moreItemManager

        onMorePresetItemClicked: {
            if (itemIndex === 50 && authManager.isSupportBeauty && beautyIndex !== -1) {
                displayPage(3);
            }
        }
    }
    Connections {
        target: authManager

        onLogin: {
            console.log(`Recevied login signal, auth status: ${authStatus}, beautyIndex: ${beautyIndex}`)
            if (beautyIndex === -1 && authStatus === 2 && authManager.isSupportBeauty) {
                optionModel.append({
                        "optionName": qsTr("Beauty"),
                        "iconActive": "qrc:/qml/images/settings/beauty_active.svg",
                        "iconNormal": "qrc:/qml/images/settings/beauty_normal.svg",
                        "page": "qrc:/qml/settings/Beauty.qml"
                    });
                beautyIndex = optionModel.count - 1;
            }
        }
        onLogout: {
            if (beautyIndex !== -1) {
                optionModel.remove(beautyIndex);
                beautyIndex = -1;
                optionList.currentIndex = 0;
            }
        }
    }
    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        border.color: '#FFFFFF'
        border.width: 1
        radius: Qt.platform.os === 'windows' ? 0 : 10

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 1
            spacing: 0

            DragArea {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                onlyCloseClickedSignal: true
                title: qsTr("Settings")

                onCloseClicked: {
                    hideWindow();
                }
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                radius: 10

                ListModel {
                    id: optionModel
                }
                ListView {
                    id: optionList
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.top: parent.top
                    model: optionModel
                    width: 175

                    delegate: ItemDelegate {
                        height: 50
                        width: optionList.width

                        background: Rectangle {
                            anchors.fill: parent
                            color: optionList.currentIndex === model.index ? "#F2F3F5" : "#FFFFFF"
                        }

                        onClicked: {
                            if (optionList.currentIndex === model.index) {
                                return;
                            }
                            optionList.currentIndex = model.index;
                            loader.setSource(Qt.resolvedUrl(model.page));
                        }

                        RowLayout {
                            anchors.left: parent.left
                            anchors.leftMargin: 18
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Image {
                                id: icon
                                mipmap: true
                                source: optionList.currentIndex === model.index ? model.iconActive : model.iconNormal
                            }
                            Label {
                                color: optionList.currentIndex === model.index ? "#337EFF" : "#666666"
                                text: model.optionName
                            }
                        }
                    }
                }
                ToolSeparator {
                    id: separator
                    anchors.bottom: parent.bottom
                    anchors.left: optionList.right
                    anchors.top: parent.top
                    leftInset: 0
                    leftPadding: 0
                    rightInset: 0
                    rightPadding: 0

                    contentItem: Rectangle {
                        color: "#EBEDF0"
                        implicitWidth: 1
                    }
                }
                Flickable {
                    id: idFlickable
                    anchors.bottom: parent.bottom
                    anchors.left: separator.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    clip: true

                    ScrollBar.vertical: ScrollBar {
                        id: vsb
                        visible: loader.source == 'qrc:/qml/settings/AudioDevice.qml' || loader.source == 'qrc:/qml/settings/VideoDevice.qml'
                        width: 5
                    }

                    Loader {
                        id: loader
                        anchors.fill: parent

                        onLoaded: {
                            console.log("pageLoader:", source);
                            vsb.position = 0;
                            if (source == 'qrc:/qml/settings/AudioDevice.qml' || source == 'qrc:/qml/settings/VideoDevice.qml') {
                                idFlickable.contentHeight = loader.item.childrenRect.height + 70;
                            } else {
                                idFlickable.contentHeight = 400;
                            }
                        }
                    }
                }
            }
        }
    }
    DropShadow {
        anchors.fill: mainLayout
        color: "#3217171A"
        horizontalOffset: 0
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
}
