import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: root
    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: "#292933"
        }
        GradientStop {
            position: 1.0
            color: "#212129"
        }
    }

    property point  movePos     : "0,0"
    property var    timestamp   : 0
    property bool   verified    : false
    property var    popupProfile: undefined
    property bool   isDoubleClicked: false
    property int    lastWindowWidth: 0
    property int    lastWindowHeight: 0

    signal close()

    Component.onCompleted: {
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: 2
        acceptedButtons: Qt.LeftButton
        onPressed: {
            movePos = Qt.point(mouse.x, mouse.y)
            isDoubleClicked = false
            lastWindowWidth = mainWindow.width
            lastWindowHeight = mainWindow.height
        }
        onPositionChanged: {
            if (!isDoubleClicked) {
                const delta = Qt.point(mouse.x - movePos.x, mouse.y - movePos.y)
                if (Window.window.visibility !== Window.Maximized) {
                    Window.window.x = Window.window.x + delta.x
                    Window.window.y = Window.window.y + delta.y
                    Window.window.width = lastWindowWidth
                    Window.window.height = lastWindowHeight
                }
            }
        }
        onExited: {
        }
        onDoubleClicked: {
            isDoubleClicked = true
            if (mainWindow.visibility === Window.Maximized) {
                mainWindow.showNormal()
                mainWindow.flags = Qt.Window | Qt.FramelessWindowHint
            } else {           
                mainWindow.flags = Qt.Window | Qt.WindowFullscreenButtonHint | Qt.CustomizeWindowHint | Qt.WindowMinimizeButtonHint
                mainWindow.visibility = Window.Maximized
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
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            normalImage: 'qrc:/qml/images/public/caption/btn_close_normal.png'
            hoveredImage: 'qrc:/qml/images/public/caption/btn_close_hovered.png'
            pushedImage: 'qrc:/qml/images/public/caption/btn_close_pushed.png'
            onClicked: {
                close()
            }
        }
        ImageButton {
            id: macMinButton
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            normalImage: mainWindow.visibility !== Window.FullScreen
                        ? 'qrc:/qml/images/public/caption/btn_min_normal.png'
                        : 'qrc:/qml/images/public/caption/btn_min_prohibit.png'
            hoveredImage: mainWindow.visibility !== Window.FullScreen
                        ? 'qrc:/qml/images/public/caption/btn_min_hovered.png'
                        : 'qrc:/qml/images/public/caption/btn_min_prohibit.png'
            pushedImage: mainWindow.visibility !== Window.FullScreen
                        ? 'qrc:/qml/images/public/caption/btn_min_pushed.png'
                        : 'qrc:/qml/images/public/caption/btn_min_prohibit.png'
            onClicked: {
                if(mainWindow.visibility !== Window.FullScreen)
                    macMinimized()
            }
        }
        ImageButton {
            id: macMaxButton
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            normalImage: 'qrc:/qml/images/public/caption/btn_max_normal.png'
            hoveredImage: mainWindow.visibility === Window.FullScreen
                          ? 'qrc:/qml/images/public/caption/btn_max_shrink.png'
                          : 'qrc:/qml/images/public/caption/btn_max_hovered.png'

            pushedImage: mainWindow.visibility === Window.FullScreen
                         ? 'qrc:/qml/images/public/caption/btn_max_shrink.png'
                         : 'qrc:/qml/images/public/caption/btn_max_hovered.png'
            onClicked: {
                if (mainWindow.visibility === Window.FullScreen){
                    mainWindow.showNormal()
                }
                else{
                    mainWindow.showFullScreen()
                }
            }
        }
    }

    Label {
        id: captionTitle
        text: Qt.application.displayName
        font.pixelSize: 14
        color: "#FFFFFF"
        anchors.centerIn: parent
    }

    ImageButton {
        id: minButton
        width: 24
        height: 24
        visible: Qt.platform.os === 'windows'
        anchors.right: maxButton.left
        anchors.rightMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        normalImage: 'qrc:/qml/images/public/button/btn_wnd_white_min_normal.png'
        hoveredImage: 'qrc:/qml/images/public/button/btn_wnd_white_min_hovered.png'
        pushedImage: 'qrc:/qml/images/public/button/btn_wnd_white_min_pushed.png'
        onClicked: {
            mainWindow.showMinimized()
        }
    }

    ImageButton {
        id: maxButton
        width: 24
        height: 24
        visible: Qt.platform.os === 'windows'
        anchors.right: closeButton.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        normalImage: mainWindow.visibility === Window.Maximized || mainWindow.visibility === Window.FullScreen
                     ? "qrc:/qml/images/public/button/btn_wnd_white_restore_normal.png"
                     : "qrc:/qml/images/public/button/btn_wnd_white_max_normal.png"
        hoveredImage: mainWindow.visibility === Window.Maximized || mainWindow.visibility === Window.FullScreen
                      ? "qrc:/qml/images/public/button/btn_wnd_white_restore_hovered.png"
                      : "qrc:/qml/images/public/button/btn_wnd_white_max_hovered.png"
        pushedImage: mainWindow.visibility === Window.Maximized || mainWindow.visibility === Window.FullScreen
                     ? "qrc:/qml/images/public/button/btn_wnd_white_restore_pushed.png"
                     : "qrc:/qml/images/public/button/btn_wnd_white_max_pushed.png"
        onClicked: {
            if (mainWindow.visibility === Window.Maximized) {
                mainWindow.showNormal()
                flags = Qt.Window | Qt.FramelessWindowHint

            } else {
                flags = Qt.Window | Qt.WindowFullscreenButtonHint | Qt.CustomizeWindowHint | Qt.WindowMinimizeButtonHint
                visibility = Window.Maximized
            }
        }
    }

    ImageButton {
        id: closeButton
        width: 24
        height: 24
        visible: Qt.platform.os === 'windows'
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        normalImage: 'qrc:/qml/images/public/button/btn_wnd_white_close_normal.png'
        hoveredImage: 'qrc:/qml/images/public/button/btn_wnd_white_close_hovered.png'
        pushedImage: 'qrc:/qml/images/public/button/btn_wnd_white_close_pushed.png'
        onClicked: close()
    }

    function printf(num) {
        if (num < 10) {
            return "0" + num.toString()
        }
        return num.toString()
    }

    function macMinimized() {
        flags = Qt.Window | Qt.WindowFullscreenButtonHint | Qt.CustomizeWindowHint | Qt.WindowMinimizeButtonHint
        visibility = Window.Minimized
    }
}
