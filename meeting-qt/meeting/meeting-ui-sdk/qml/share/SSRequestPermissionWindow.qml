import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material 2.12

import '../components'

Window {
    id: requestPerssionWnd
    width: permission.width
    height: permission.height
    flags: {
        if (Qt.platform.os === 'windows')
            return Qt.SubWindow | Qt.FramelessWindowHint
        else
            return Qt.Tool | Qt.FramelessWindowHint
    }

    color: 'transparent'
    Material.theme: Material.Light

    property var titleText: qsTr('Permission')
    property var contentText: ""
    signal sigOpenSetting


    onContentTextChanged: {
        permission.contentText = contentText
        titleText.titleText = titleText
    }

    onVisibleChanged: {
        if (visible)
            permission.open()
    }

    onActiveChanged: {
        if (!active)
            permission.close()
    }

    onActiveFocusItemChanged: {
        if (!activeFocusItem)
            permission.close()
    }

    SSRequestPermission {
        id: permission

        onSigOpenSetting: {
            requestPerssionWnd.sigOpenSetting()
        }

        onClosed: {
            requestPerssionWnd.hide()
        }
    }
}
