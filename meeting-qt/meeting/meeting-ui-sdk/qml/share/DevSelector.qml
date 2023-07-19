import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12

import '../components'

Window {
    id: deviceSelectorWnd
    width: selector.width
    height: selector.height
    flags: {
        if (Qt.platform.os === 'windows')
            return Qt.SubWindow | Qt.FramelessWindowHint
        else
            return Qt.Tool | Qt.FramelessWindowHint
    }

    color: 'transparent'
    Material.theme: Material.Light

    property int mode: DeviceSelector.DeviceSelectorMode.DefaultMode

    onVisibleChanged: {
        if (visible)
            selector.open()
    }

    onModeChanged: {
        selector.setDeviceSelectorMode(mode)
    }

    onActiveChanged: {
        if (!active)
            selector.close()
    }

    onActiveFocusItemChanged: {
        if (!activeFocusItem)
            selector.close()
    }

    DeviceSelector {
        id: selector
        selectorMode: mode
        onClosed: {
            deviceSelectorWnd.hide()
        }
    }
}
