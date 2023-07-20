pragma Singleton

import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12

import "../components"

Window {
    id: rootWindow
    width: 800 + 20 // include shadow size
    height: 500 + 20
    color: "transparent"
    Material.theme: Material.Light
    title: qsTr("Settings")
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    property int beautyIndex: -1
    signal visibleStatus(bool isVisible)

    onVisibleChanged: {
        visibleStatus(visible)
    }

    function hideWindow() {
        loader.setSource(Qt.resolvedUrl(optionModel.get(0).page))
        optionList.currentIndex = 0
        hideRoot.start()
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
            rootWindow.hide()
            close.accepted = false
        }
    }

    Connections{
        target: moreItemManager
        onMorePresetItemClicked:{
            if(itemIndex === 50 && authManager.isSupportBeauty && beautyIndex !== -1){
                displayPage(3)
            }
        }
    }

    Connections {
        target: authManager
        onLogout:{
            if(beautyIndex !== -1){
                optionModel.remove(beautyIndex)
                beautyIndex = -1
                optionList.currentIndex = 0
            }
        }
        onLogin:{
            if(beautyIndex== -1 && authStatus == 2 && authManager.isSupportBeauty){
                optionModel.append({
                                       optionName: qsTr("Beauty"),
                                       iconActive: "qrc:/qml/images/settings/beauty_active.svg",
                                       iconNormal: "qrc:/qml/images/settings/beauty_normal.svg",
                                       page: "qrc:/qml/settings/Beauty.qml",
                                   })
                beautyIndex = optionModel.count - 1
            }
        }
    }

    Component.onCompleted: {
        initializeListMode(true)
    }

    function initializeListMode (firstTime) {
        optionModel.clear()
        optionModel.append({
                               optionName: qsTr("General"),
                               iconActive: "qrc:/qml/images/settings/general_active.svg",
                               iconNormal: "qrc:/qml/images/settings/general_normal.svg",
                               page: "qrc:/qml/settings/MeetingSettings.qml",
                           })
        optionModel.append({
                               optionName: qsTr("Videos"),
                               iconActive: "qrc:/qml/images/settings/video_active.svg",
                               iconNormal: "qrc:/qml/images/settings/video_normal.svg",
                               page: "qrc:/qml/settings/VideoDevice.qml",
                           })
        optionModel.append({
                               optionName: qsTr("Audios"),
                               iconActive: "qrc:/qml/images/settings/microphone_active.svg",
                               iconNormal: "qrc:/qml/images/settings/microphone_normal.svg",
                               page: "qrc:/qml/settings/AudioDevice.qml",
                           })
        if(authManager.isSupportBeauty && SettingsManager.getEnableBeauty()){
            optionModel.append({
                                   optionName: qsTr("Beauty"),
                                   iconActive: "qrc:/qml/images/settings/beauty_active.svg",
                                   iconNormal: "qrc:/qml/images/settings/beauty_normal.svg",
                                   page: "qrc:/qml/settings/Beauty.qml",
                               })
            beautyIndex = optionModel.count - 1
        }
        if (SettingsManager.showVirtualBackground) {
            optionModel.append({
                                   optionName: qsTr("VirtualBackground"),
                                   iconActive: "qrc:/qml/images/settings/virtaulbackground_active.svg",
                                   iconNormal: "qrc:/qml/images/settings/virtaulbackground_normal.svg",
                                   page: "qrc:/qml/settings/VirtualBackground.qml",
                               })
        }

        if (firstTime) {
            loader.setSource(Qt.resolvedUrl(optionModel.get(0).page))
            optionList.currentIndex = 0
        }
    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        border.width: 1
        border.color: '#FFFFFF'
        radius: Qt.platform.os === 'windows' ? 0 : 10

        ColumnLayout {
            spacing: 0
            anchors.fill: parent
            anchors.margins: 1

            DragArea {
                Layout.preferredHeight: 52
                Layout.fillWidth: true
                title: qsTr("Settings")
                onlyCloseClickedSignal: true
                onCloseClicked: { hideWindow() }
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
                    width: 175
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    model: optionModel
                    delegate: ItemDelegate {
                        height: 50
                        width: optionList.width
                        RowLayout {
                            spacing: 8
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 18
                            Image {
                                id: icon
                                mipmap: true
                                source: optionList.currentIndex === model.index ? model.iconActive : model.iconNormal
                            }
                            Label {
                                text: model.optionName
                                color: optionList.currentIndex === model.index ? "#337EFF" : "#666666"
                            }
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: optionList.currentIndex === model.index ? "#F2F3F5" : "#FFFFFF"
                        }
                        onClicked: {
                            if (optionList.currentIndex === model.index) {
                                return
                            }
                            optionList.currentIndex = model.index
                            loader.setSource(Qt.resolvedUrl(model.page))
                        }
                    }
                }

                ToolSeparator {
                    id: separator
                    anchors.top: parent.top
                    anchors.left: optionList.right
                    anchors.bottom: parent.bottom
                    leftPadding: 0
                    rightPadding: 0
                    leftInset: 0
                    rightInset: 0
                    contentItem: Rectangle {
                        implicitWidth: 1
                        color: "#EBEDF0"
                    }
                }

                Flickable {
                    id: idFlickable
                    clip: true
                    anchors.left: separator.right
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    ScrollBar.vertical: ScrollBar {
                        id: vsb
                        visible: loader.source == 'qrc:/qml/settings/AudioDevice.qml' || loader.source == 'qrc:/qml/settings/VideoDevice.qml'
                        width: 5
                    }
                    Loader {
                        id: loader
                        anchors.fill: parent
                        onLoaded: {
                            console.log("pageLoader:", source)
                            vsb.position = 0
                            if (source == 'qrc:/qml/settings/AudioDevice.qml' || source == 'qrc:/qml/settings/VideoDevice.qml') {
                                idFlickable.contentHeight = loader.item.childrenRect.height + 70
                            } else {
                                idFlickable.contentHeight = 400
                            }
                        }
                    }
                }
            }
        }
    }

    DropShadow {
        anchors.fill: mainLayout
        horizontalOffset: 0
        verticalOffset: 0
        samples: 16
        source: mainLayout
        color: "#3217171A"
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    function displayPage(pageIndex) {
        initializeListMode(false)
        loader.setSource(Qt.resolvedUrl(optionModel.get(pageIndex).page))
        optionList.currentIndex = pageIndex
        rootWindow.show()
        rootWindow.raise()
    }
}
