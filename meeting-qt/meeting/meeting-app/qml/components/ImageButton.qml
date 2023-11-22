import QtQuick

Item {
    id: root
    property string normalImage: ""
    property string hoveredImage: ""
    property string pushedImage: ""
    signal clicked()
    Image {
        id: img
        source: normalImage
        anchors.fill: parent
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPressed: {
            img.source = pushedImage
        }
        onReleased: {
            img.source = normalImage
            if (containsMouse) {
                root.clicked()
            }
        }
        onEntered: {
            img.source = hoveredImage
        }
        onExited: {
            img.source = normalImage
        }
        onClicked: {
            root.clicked()
        }
    }
}
