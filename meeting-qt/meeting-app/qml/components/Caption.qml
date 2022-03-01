import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    property alias  avatar      : avatar
    property alias  schedule    : schedule
    property point  movePos     : "0,0"
    property var    timestamp   : 0
    property bool   isDoubleClicked: false
    property bool   verified    : false
    property var    popupProfile: undefined
    property int    lastWindowWidth: 0
    property int    lastWindowHeight: 0

    signal close()
    signal avatarClicked()
    signal scheduleClicked()

    id: caption
    z: 999

    Component.onCompleted: {
    }

    function updateSize(width, height){
        lastWindowWidth = width
        lastWindowHeight = height
        mainWindow.width = lastWindowWidth
        mainWindow.height = lastWindowHeight
    }

    MouseArea {
        anchors.fill: parent
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
                if (mainWindow.visibility !== Window.Maximized) {
                    mainWindow.x = mainWindow.x + delta.x
                    mainWindow.y = mainWindow.y + delta.y
                    mainWindow.width = lastWindowWidth
                    mainWindow.height = lastWindowHeight
                }
            }
        }
    }

    Image {
        id: logo
        width: 107
        height: 29
        visible: Qt.platform.os === 'windows'
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/qml/images/public/caption/logo.png"
    }

    RowLayout {
        spacing: 8
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 16
        anchors.topMargin: 16
        visible: Qt.platform.os === 'osx'

        ImageButton {
            id: macCloseButton
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            normalImage: 'qrc:/qml/images/public/caption/btn_close_normal.png'
            hoveredImage: 'qrc:/qml/images/public/caption/btn_close_hovered.png'
            pushedImage: 'qrc:/qml/images/public/caption/btn_close_pushed.png'
            onClicked: {
                closeWindow()
            }
        }
        ImageButton {
            id: macMinButton
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            normalImage: 'qrc:/qml/images/public/caption/btn_min_normal.png'
            hoveredImage: 'qrc:/qml/images/public/caption/btn_min_hovered.png'
            pushedImage: 'qrc:/qml/images/public/caption/btn_min_pushed.png'
            onClicked: {
                macMinimized()
            }
        }
        ImageButton {
            id: macMaxButton
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            normalImage: 'qrc:/qml/images/public/caption/btn_max_normal.png'
            hoveredImage: 'qrc:/qml/images/public/caption/btn_max_hovered.png'
            pushedImage: 'qrc:/qml/images/public/caption/btn_max_pushed.png'
            visible: pageLoader.source == "qrc:/qml/MeetingPage.qml" && Qt.platform.os === 'osx'
            onClicked: {
                mainWindow.showFullScreen()
            }
        }
    }

    CustomButton {
        id: schedule
        anchors.right: avatar.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        visible: false
        width: 110
        height: 32
        highlighted: true
        text: qsTr("Schedule")
        display: AbstractButton.TextBesideIcon
        onClicked: {
            scheduleClicked()
        }
    }

    Avatar {
        id: avatar
        anchors.right: Qt.platform.os === 'windows' ? minButton.left : parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        nickname: authManager.appUserNick
        visible: nickname !== '' && pageLoader.source == 'qrc:/qml/FrontPage.qml'
        onVisibleChanged: {
            if (!visible) {
                if (popupProfile !== undefined) {
                    popupProfile.close()
                }
            }
        }
        onClick: {
            avatarClicked()
        }
    }

    ImageButton {
        id: minButton
        width: 24
        height: 24
        anchors.right: pageLoader.source == "qrc:/qml/MeetingPage.qml" ? maxButton.left : closeButton.left
        anchors.rightMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        visible: Qt.platform.os === 'windows'

        normalImage: 'qrc:/qml/images/public/caption/btn_wnd_white_min_normal.png'
        hoveredImage: 'qrc:/qml/images/public/caption/btn_wnd_white_min_hovered.png'
        pushedImage: 'qrc:/qml/images/public/caption/btn_wnd_white_min_pushed.png'

        onClicked: {
            mainWindow.showMinimized()
        }
    }

    ImageButton {
        id: maxButton
        width: 24
        height: 24
        anchors.right: closeButton.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        visible: pageLoader.source === "qrc:/qml/MeetingPage.qml" && Qt.platform.os === 'windows'

        normalImage: mainWindow.visibility === Window.Maximized
                    ? "qrc:/qml/images/public/caption/btn_wnd_white_restore_normal.png"
                    : "qrc:/qml/images/public/caption/btn_wnd_white_max_normal.png"
        hoveredImage: mainWindow.visibility === Window.Maximized
                    ? "qrc:/qml/images/public/caption/btn_wnd_white_restore_hovered.png"
                    : "qrc:/qml/images/public/caption/btn_wnd_white_max_hovered.png"
        pushedImage: mainWindow.visibility === Window.Maximized
                    ? "qrc:/qml/images/public/caption/btn_wnd_white_restore_pushed.png"
                    : "qrc:/qml/images/public/caption/btn_wnd_white_max_pushed.png"

        onClicked: {
            if (mainWindow.visibility === Window.Maximized) {
                mainWindow.showNormal()
            } else {
                mainWindow.showMaximized()
            }
        }
    }

    ImageButton {
        id: closeButton
        width: 24
        height: 24
        anchors.right: parent.right
        anchors.rightMargin: 13
        anchors.verticalCenter: parent.verticalCenter
        visible: Qt.platform.os === 'windows'

        normalImage: 'qrc:/qml/images/public/caption/btn_wnd_white_close_normal.png'
        hoveredImage: 'qrc:/qml/images/public/caption/btn_wnd_white_close_hovered.png'
        pushedImage: 'qrc:/qml/images/public/caption/btn_wnd_white_close_pushed.png'

        onClicked: {
            closeWindow()
        }
    }

    function printf(num) {
        if (num < 10) {
            return "0" + num.toString()
        }
        return num.toString()
    }

    function closeWindow() {
        mainWindow.close()
    }
}
