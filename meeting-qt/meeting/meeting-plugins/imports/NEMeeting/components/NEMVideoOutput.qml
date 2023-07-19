import QtQuick 2.0
import QtMultimedia 5.14
import NEMeeting 1.0

Rectangle {
    id: root

    property bool mirrored: false
    property alias frameProvider: frameProvider

    color: '#000000'

    VideoOutput {
        anchors.fill: parent
        source: frameProvider
        transform: Rotation {
            origin.x: root.width / 2
            origin.y: root.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: mirrored ? 180 : 0
        }
    }

    NEMFrameProvider {
        id: frameProvider
    }
}
