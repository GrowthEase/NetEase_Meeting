import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

/**
* @brief An Android-like timed message text in a box that selfdestroys when finished if desired
*/
Rectangle {

    /**
    * Public
    */

    /**
    * @brief Shows this Toast
    *
    * @param {string} text Text to show
    * @param {real} duration Duration to show in milliseconds, defaults to 3000
    */
    function show(text, duration) {
        theText.text = text;
        if(typeof duration !== "undefined") {
            if(duration >= 2*fadeTime)
                time = duration;
            else
                time = 2*fadeTime;
        }
        else
            time = defaultTime;
        anim.start();
    }

    property bool selfDestroying: false ///< Whether this Toast will selfdestroy when it is finished
    property var background: "#333333"
    property var textColor: "#FFFFFF"
    property var icon: ""

    /**
    * Private
    */

    id: root

    property real time: defaultTime
    readonly property real defaultTime: 3000
    readonly property real fadeTime: 300

    property var margin: 4

    width: rect.width
    height: rect.height
    radius: margin

    anchors.horizontalCenter: parent.horizontalCenter

    opacity: 0
    color: background

    Rectangle {
        id: rect
        width: content.width + 2 * margin + 8
        height: content.height + 2 * margin
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        radius: margin / 2
        color: background

        RowLayout {
            id: content
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Image {
                source: icon
                sourceSize.width: 14
                sourceSize.height: 14
                visible: icon.length > 0
            }

            Label {
                id: theText
                text: ""
                color: textColor
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    SequentialAnimation on opacity {
        id: anim
        running: false

        NumberAnimation {
            to: 1
            duration: fadeTime
        }
        PauseAnimation {
            duration: time - 2*fadeTime
        }
        NumberAnimation {
            to: 0
            duration: fadeTime
        }
        onRunningChanged: {
            if(!running && selfDestroying)
                root.destroy();
        }
    }

    DropShadow {
        anchors.fill: rect
        horizontalOffset: 1
        verticalOffset: 1
        radius: 8
        samples: 17
        source: rect
        color: "#661E1E1E"
        Behavior on radius { PropertyAnimation { duration: 100 } }
    }
}
