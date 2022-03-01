import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
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
