import QtQuick 2.15
import QtQuick.Controls 2.12

Item {
    id: root
    width: 50
    height: 40

    Label {
        anchors.right: parent.right
        color: "#ffffff"
        font.pixelSize: 12
        horizontalAlignment: Qt.AlignRight
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
}
