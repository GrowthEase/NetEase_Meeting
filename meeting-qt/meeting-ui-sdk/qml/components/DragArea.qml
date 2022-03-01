import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Item {
    property string title: ''
    property int titleFontSize: 16
    property bool minVisible: false
    property bool maxVisible: false
    property bool closeVisible: true
    property bool closeIsHide: true
    property bool windowMode: true

    signal closeClicked()

    function close() {
        if (Qt.platform.os === 'osx') {
            macCloseButton.clicked()
        } else {
            idCloseButton.clicked()
        }
    }

    function macMinimized() {
        flags = Qt.Window | Qt.WindowFullscreenButtonHint | Qt.CustomizeWindowHint | Qt.WindowMinimizeButtonHint
        visibility = Window.Minimized
    }

    MouseArea {
        property int lastWindowWidth: 0
        property int lastWindowHeight: 0
        property point movePos: '0,0'

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        enabled: windowMode
        onPressed: {
            movePos = Qt.point(mouse.x, mouse.y)
            lastWindowWidth = Window.window.width
            lastWindowHeight = Window.window.height
        }
        onPositionChanged: {
            const delta = Qt.point(mouse.x - movePos.x, mouse.y - movePos.y)
            if (Window.window.visibility !== Window.Maximized && Window.window.visibility !== Window.FullScreen) {
                Window.window.x = Window.window.x + delta.x
                Window.window.y = Window.window.y + delta.y
                Window.window.width = lastWindowWidth
                Window.window.height = lastWindowHeight
            }
        }
    }

    RowLayout {
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 13
        visible: Qt.platform.os === 'osx'
        ImageButton {
            id: macCloseButton
            visible: closeVisible
            Layout.preferredHeight: 12
            Layout.preferredWidth: 12
            normalImage: 'qrc:/qml/images/public/caption/btn_close_normal.png'
            hoveredImage: 'qrc:/qml/images/public/caption/btn_close_hovered.png'
            pushedImage: 'qrc:/qml/images/public/caption/btn_close_pushed.png'
            onClicked: {
                closeClicked()
                if (!windowMode) {
                    return
                }
                if (closeIsHide) {
                    Window.window.hide()
                    close.accepted = false
                }else {
                    Window.window.close()
                }
            }
        }
        ImageButton {
            id: macMinButton
            visible: minVisible
            Layout.preferredHeight: 12
            Layout.preferredWidth: 12
            normalImage: 'qrc:/qml/images/public/caption/btn_min_normal.png'
            hoveredImage: 'qrc:/qml/images/public/caption/btn_min_hovered.png'
            pushedImage: 'qrc:/qml/images/public/caption/btn_min_pushed.png'
            onClicked: {
                macMinimized()
            }
        }
        ImageButton {
            id: macMaxButton
            visible: maxVisible
            Layout.preferredHeight: 12
            Layout.preferredWidth: 12
            normalImage: 'qrc:/qml/images/public/caption/btn_max_normal.png'
            hoveredImage: 'qrc:/qml/images/public/caption/btn_max_hovered.png'
            pushedImage: 'qrc:/qml/images/public/caption/btn_max_pushed.png'
            onClicked: {
                Window.window.showMaximized()
            }
        }
    }

    Label {
        text: title
        color: "#2B2B2B"
        font.pixelSize: titleFontSize
        anchors.centerIn: parent
    }

    ToolButton {
        id: idCloseButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 5
        visible: Qt.platform.os === 'windows'
        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/qml/images/public/icons/close_gray.svg"
        }
        onClicked: {
            closeClicked()
            if (!windowMode) {
                return
            }
            if (closeIsHide) {
                Window.window.hide()
                close.accepted = false
            } else {
                Window.window.close()
            }
        }
    }

    CustomToolSeparator {
        width: parent.width
        anchors.bottom: parent.bottom
    }
}
