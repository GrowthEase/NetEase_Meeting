import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12

Window {
    id: rootWindow

    property alias title: idDragArea.title
    property alias idLoader: idLoader
    property alias idMessage: idMessage
    property alias minVisible : idDragArea.minVisible
    property alias maxVisible : idDragArea.maxVisible
    property alias closeVisible : idDragArea.closeVisible
    property alias closeIsHide : idDragArea.closeIsHide
    property  int customWidth: 100
    property  int customHeight: 100
    readonly property int customRadius: 10

    signal closeBtnClicked()
    function close() {
        idDragArea.close()
    }

    width: 100
    height: 100
    color: "#00000000"

    Material.theme: Material.Light
    flags: Qt.Window | Qt.FramelessWindowHint  | Qt.WindowStaysOnTopHint

    onCustomWidthChanged: {
        width = Qt.platform.os === 'windows' ? customWidth + 20 : customWidth
    }

    onCustomHeightChanged : {
        height = Qt.platform.os === 'windows' ? customHeight + 20 : customHeight
    }

    DropShadow {
        anchors.fill: mainLayout
        horizontalOffset: 0
        verticalOffset: 0
        radius: customRadius
        samples: 16
        source: mainLayout
        color: "#3217171A"
        spread: 0
        visible: Qt.platform.os === 'windows'
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }

    MessageManager {
        id: idMessage
    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: Qt.platform.os === 'windows' ? 10 : 0
        border.width: 1
        border.color: '#FFFFFF'
        radius: Qt.platform.os === 'windows' ? 0 : customRadius

        ColumnLayout {
            spacing: 0
            anchors.fill: parent
            anchors.margins: 1
            DragArea {
                id: idDragArea
                Layout.preferredHeight: 50
                Layout.fillWidth: true
                onCloseClicked: {
                    closeBtnClicked()
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                radius: Qt.platform.os === 'windows' ? 0 : customRadius
                Loader {
                    id: idLoader
                    anchors.fill: parent
                    onLoaded: {
                        if (Qt.platform.os === 'osx') {
                            findBottomItem(idLoader.item)
                        }
                    }

                    onWidthChanged: {
                        if (Qt.platform.os === 'osx') {
                            findBottomItem(idLoader.item)
                        }
                    }

                    onHeightChanged: {
                        if (Qt.platform.os === 'osx') {
                            findBottomItem(idLoader.item)
                        }
                    }
                }
            }
        }
    }

    function findBottomItem (item) {
        if (undefined === item || null === item || !item.hasOwnProperty('radius'))
            return

        const point1 = mainLayout.mapFromItem(item, item.x, item.height)
        const point2 = mainLayout.mapFromItem(item, item.width, item.height)
        if ((point1.x <= customRadius && point1.y >= (mainLayout.height - customRadius)) ||
                (point2.x >= (mainLayout.width - customRadius) && point2.y >= (mainLayout.height - customRadius))) {
            item.radius = customRadius
        }

        var itemList = item.children;
        for (let  i = 0; i < itemList.length; i++) {
            findBottomItem(itemList[i])
        }
    }
}
