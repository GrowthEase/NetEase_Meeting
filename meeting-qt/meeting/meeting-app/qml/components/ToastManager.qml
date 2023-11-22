import QtQuick

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
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 95
    anchors.horizontalCenter: parent.horizontalCenter
    // anchors.centerIn: parent

    property var toastComponent
    property string lastToastText: ""

    Timer {
        id: timer;
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
    function show(text, duration){
        if(text === lastToastText && timer.running) {
            return
        }

        if (toastComponent !== undefined) {
            const toast = toastComponent.createObject(root, { background: "#771E1E1E", textColor: "#FFFFFF", margin: 8 })
            toast.selfDestroying = true;
            toast.show(text, duration);
            lastToastText = text
            timer.restart()
        }
    }

    Component.onCompleted: {
        toastComponent = Qt.createComponent("Toast.qml")
    }
}
