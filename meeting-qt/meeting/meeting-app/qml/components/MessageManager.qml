import QtQuick 2.15

/**
 * @brief Manager that creates Toasts dynamically
 */
Column {
    /**
     * Private
     */

    id: root

    z: Infinity
    spacing: 5
    anchors.top: parent.top
    anchors.topMargin: 80
    anchors.horizontalCenter: parent.horizontalCenter
    // anchors.centerIn: parent

    property var toastComponent
    property string lastToastText: ""

    Timer {
        id: timer
        interval: 2000
        repeat: false
        running: false
        triggeredOnStart: false
        onTriggered: {
            //do nonthing
        }
    }

    /**
     * @brief Shows a Toast
     *
     * @param {string} text Text to show
     * @param {real} duration Duration to show in milliseconds, defaults to 3000
     */
    function show(text, duration) {
        if(text === lastToastText && timer.running) {
            return
        }

        const toast = toastComponent.createObject(root, { background: "#FFFFFF", textColor: "#333333", margin: 10 })
        toast.selfDestroying = true;
        toast.show(text, duration);

        lastToastText = text
        timer.restart()
    }

    function warning(text, duration) {
        if(text === lastToastText && timer.running) {
            return
        }

        const toast = toastComponent.createObject(root, { background: "#FFFFFF", textColor: "#333333", margin: 10 })
        toast.selfDestroying = true;
        toast.icon = "qrc:/qml/images/public/toast/icon_warning.svg"
        toast.show(text, duration);

        lastToastText = text
        timer.restart()
    }

    function error(text, duration) {
        if(text === lastToastText && timer.running) {
            return
        }

        const toast = toastComponent.createObject(root, { background: "#FFFFFF", textColor: "#333333", margin: 10 })
        toast.selfDestroying = true;
        toast.icon = "qrc:/qml/images/public/toast/icon_error.svg"
        toast.show(text, duration);

        lastToastText = text
        timer.restart()
    }

    function info(text, duration) {
        if(text === lastToastText && timer.running) {
            return
        }

        const toast = toastComponent.createObject(root, { background: "#FFFFFF", textColor: "#333333", margin: 10 })
        toast.selfDestroying = true;
        toast.icon = "qrc:/qml/images/public/toast/icon_info.svg"
        toast.show(text, duration);

        lastToastText = text
        timer.restart()
    }

    Component.onCompleted: {
        toastComponent = Qt.createComponent("Toast.qml")
    }
}
