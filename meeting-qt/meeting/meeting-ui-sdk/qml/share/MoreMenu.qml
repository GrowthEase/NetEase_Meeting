import QtQuick
import QtQuick.Window 2.12
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material 2.12

import '../components'

Window {
    id: moreMenuWnd
    property alias menu: moreItemsMenu
    width: moreItemsMenu.width
    height: moreItemsMenu.height
    flags: {
        if (Qt.platform.os === 'windows')
            return Qt.SubWindow | Qt.FramelessWindowHint
        else
            return Qt.Tool | Qt.FramelessWindowHint
    }

    color: 'transparent'
    Material.theme: Material.Light

    onVisibleChanged: {
        if (visible)
            moreItemsMenu.open()
    }

    onActiveChanged: {
        if (!active)
            moreItemsMenu.close()
    }

    onActiveFocusItemChanged: {
        if (!activeFocusItem)
            moreItemsMenu.close()
    }

    MoreItemsMenuEx {
        id: moreItemsMenu
        bSharing: true
        onClosed: {
            moreMenuWnd.hide()
        }
    }
}
