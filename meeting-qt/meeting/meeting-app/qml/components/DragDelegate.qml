import QtQuick 2.15
import QtQuick.Window 2.2

Item {
    property int enableSize: 4
    property bool isPressed: false
    property point customPoint

    Item {
        id: leftTop
        width: enableSize
        height: enableSize
        anchors.left: parent.left
        anchors.top: parent.top
        z: 1000
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeFDiagCursor
            onPressed: press(mouse)
            onEntered: enter(1)
            onReleased: release()
            onPositionChanged: positionChange(mouse, -1, -1)
        }
    }

    Item {
        id: top
        height: enableSize
        anchors.left: leftTop.right
        anchors.right: rightTop.left
        anchors.top: parent.top
        z: 1000
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeVerCursor
            onPressed: press(mouse)
            onEntered: enter(2)
            onReleased: release()
            onMouseYChanged: positionChange(Qt.point(customPoint.x, mouseY), 1, -1)
        }
    }

    Item {
        id: rightTop
        width: enableSize
        height: enableSize
        anchors.right: parent.right
        anchors.top: parent.top
        z: 1000
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeBDiagCursor
            onPressed: press(mouse)
            onEntered: enter(3)
            onReleased: release()
            onPositionChanged: positionChange(mouse, 1, -1)
        }
    }

    Item {
        id: left
        width: enableSize
        anchors.left: parent.left
        anchors.top: leftTop.bottom
        anchors.bottom: leftBottom.top
        z: 1000
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeHorCursor
            onPressed: press(mouse)
            onEntered: enter(4)
            onReleased: release()
            onMouseXChanged: positionChange(Qt.point(mouseX, customPoint.y), -1, 1)
        }
    }

    Item {
        id: right
        width: enableSize
        anchors.right: parent.right
        anchors.top: rightTop.bottom
        anchors.bottom: rightBottom.top
        z: 1000
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeHorCursor
            onPressed: press(mouse)
            onEntered: enter(6)
            onReleased: release()
            onMouseXChanged: positionChange(Qt.point(mouseX, customPoint.y), 1, 1)
        }
    }

    Item {
        id: leftBottom
        width: enableSize
        height: enableSize
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        z: 1000
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeBDiagCursor
            onPressed: press(mouse)
            onEntered: enter(7)
            onReleased: release()
            onPositionChanged: positionChange(mouse, -1, 1)
        }
    }

    Item {
        id: bottom
        height: enableSize
        anchors.left: leftBottom.right
        anchors.right: rightBottom.left
        anchors.bottom: parent.bottom
        z: 1000
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeVerCursor
            onPressed: press(mouse)
            onEntered: enter(8)
            onReleased: release()
            onMouseYChanged: positionChange(Qt.point(customPoint.x, mouseY), 1, 1)
        }
    }

    Item {
        id:rightBottom
        width: enableSize
        height: enableSize
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        z: 1000
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeFDiagCursor
            onPressed: press(mouse)
            onEntered: enter(9)
            onReleased: release()
            onPositionChanged: positionChange(mouse,1,1)
        }
    }

    function enter(direct) {
        // Resize.setMyCursor(direct)
    }

    function press(mouse) {
        isPressed = true
        customPoint = Qt.point(mouse.x, mouse.y)
    }

    function release() {
        isPressed = false
        //customPoint = undefined
    }

    function positionChange(newPosition, directX, directY) {
        if (!isPressed) return

        const delta = Qt.point(newPosition.x-customPoint.x, newPosition.y-customPoint.y)
        let tmpW,tmpH

        if (directX >= 0)
            tmpW = Window.window.width + delta.x
        else
            tmpW = Window.window.width - delta.x

        if (directY >= 0)
            tmpH = Window.window.height + delta.y
        else
            tmpH = Window.window.height - delta.y

        if (tmpW < Window.window.minimumWidth) {
            if (directX < 0)
                Window.window.x += (Window.window.width - Window.window.minimumWidth)
            Window.window.width = Window.window.minimumWidth
        } else {
            Window.window.width = tmpW
            if (directX < 0)
                Window.window.x += delta.x
        }

        if (tmpH < Window.window.minimumHeight) {
            if (directY < 0)
                Window.window.y += (Window.window.height - Window.window.minimumHeight)
            Window.window.height = Window.window.minimumHeight
        } else {
            Window.window.height = tmpH
            if (directY < 0)
                Window.window.y += delta.y
        }
    }
}
