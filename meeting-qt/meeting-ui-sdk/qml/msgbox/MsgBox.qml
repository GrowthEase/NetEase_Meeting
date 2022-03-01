import QtQuick 2.15
import QtQuick.Window 2.12

import '../utils/dialogManager.js' as DialogManager

Window {
    id: root
    minimumWidth: 330 + 4
    minimumHeight: 160 + 4
    visible: false
    x: (Screen.width - width) / 2 + Screen.virtualX
    y: (Screen.height - height) / 2 + Screen.virtualY
    title: ''
    color: 'transparent'
    flags: {
        if (Qt.platform.os === 'windows')
            Qt.Popup | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        else
            Qt.Popup | Qt.FramelessWindowHint
    }

    property string titleText: ''
    property string contentText: ''
    property var confirm: undefined
    property var cancel: undefined

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        border.width: Qt.platform.os === 'windows' ? 1 : 0
        border.color: Qt.platform.os === 'windows' ? '#CCCCCC' : '#FFFFFF'
        radius: Qt.platform.os === 'windows' ? 0 : 10
        color: 'transparent'
        visible: root.visible
    }

    Connections {
        target: root
        onVisibleChanged: {
            if (visible) {
                DialogManager.dynamicDialog(titleText, contentText, function () {
                    if (confirm !== undefined) {
                        confirm()
                    }
                    root.hide()
                }, function () {
                    if (cancel !== undefined) {
                        cancel()
                    }
                    root.hide()
                }, root, false)
            }
        }
    }

    function showMsgBox(title, content, confirmFunction, cancelFunction) {
        titleText = title
        contentText = content
        confirm = confirmFunction
        cancel = cancelFunction
        root.show()
    }
}
