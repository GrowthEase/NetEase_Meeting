import QtQuick 2.15
import QtQuick.Controls 2.12

Item {
    id: root
    property int frameCounter: 0
    property int fps: 0;

    width: 50
    height: 40

    Item {
        id: idRotation
        NumberAnimation on rotation {
            from:0
            to: 360
            duration: 800
            loops: -1
        }
        onRotationChanged: frameCounter++;
    }

    Label {
        id: fpsText
        anchors.right: parent.right
        anchors.verticalCenter: root.verticalCenter
        anchors.verticalCenterOffset: -10
        color: "#ffffff"
        font.pixelSize: 12
        text: root.fps + " fps"
    }

    Label {
        anchors.right: parent.right
        anchors.top: fpsText.bottom
        color: "#ffffff"
        font.pixelSize: 12
        text: {
            if (GraphicsInfo.api === GraphicsInfo.Software) {
                width = 70;
                return "Software";
            }
            else if (GraphicsInfo.api === GraphicsInfo.OpenGL) {
                width = 50;
                return "OpenGL";
            }
            else if (GraphicsInfo.api === GraphicsInfo.Direct3D12) {
                width = 90;
                return "Direct3D12";
            }
            else if (GraphicsInfo.api === GraphicsInfo.OpenVG) {
                width = 50;
                return "OpenVG";
            }
            else if (GraphicsInfo.api === GraphicsInfo.OpenGLRhi) {
                return "OpenGL on QRhi";
                width = 120;
            }
            else if (GraphicsInfo.api === GraphicsInfo.Direct3D11Rhi) {
                width = 120;
                return "D3D11 on QRhi";
            }
            else if (GraphicsInfo.api === GraphicsInfo.VulkanRhi) {
                width = 120;
                return "Vulkan on QRhi";
            }
            else if (GraphicsInfo.api === GraphicsInfo.MetalRhi) {
                width = 120;
                return "Metal on QRhi";
            }
            else if (GraphicsInfo.api === GraphicsInfo.NullRhi) {
                width = 120;
                return "Null on QRhi";
            }
            else {
                width = 100;
                return "Unknown API";
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: root.visible
        onTriggered: {
            fps = frameCounter/2;
            frameCounter = 0;
        }
    }
}
