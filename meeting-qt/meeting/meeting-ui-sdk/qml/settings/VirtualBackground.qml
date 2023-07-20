import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import NetEase.Meeting.FrameProvider 1.0
import NetEase.Meeting.VideoRender 1.0
import NetEase.Meeting.DeviceModel 1.0
import NetEase.Meeting.VideoWindow 1.0
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.VirtualBackgroundModel 1.0
import NetEase.Settings.SettingsStatus 1.0
import "../components"

Rectangle {
    anchors.fill: parent
    anchors.margins: 40
    anchors.topMargin: 20
    anchors.bottomMargin: 20

    Component.onCompleted: {
        const currentIndex = deviceManager.currentIndex(DeviceSelector.DeviceType.CaptureType)
        deviceManager.selectDevice(DeviceSelector.DeviceType.CaptureType, currentIndex)
        if (SettingsManager.customRender) {
            videoManager.startLocalVideoPreview(videoRender)
        } else {
            videoManager.startLocalVideoPreview(frameProvider)
        }
    }

    ToastManager {
        id: toast
    }

    ColumnLayout {
        spacing: 20
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.right: parent.right
        anchors.rightMargin: 50
        Rectangle {
            id: idVideoRect
            Layout.preferredWidth: 452
            Layout.preferredHeight: 254
            color: "#1f1f1f"

            Image {
                anchors.centerIn: parent
                mipmap: true
                source: "qrc:/qml/images/settings/camera_empty.png"
            }

            VideoRender {
                id: videoRender
                anchors.fill: parent
                visible: {
                            if (!SettingsManager.customRender) {
                                return false
                            }
                            if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                                return videoManager.localVideoStatus === 1
                            }
                            return true
                        }
                accountId: authManager.authAccountId
                transform: Rotation {
                    origin.x: videoRender.width / 2
                    origin.y: videoRender.height / 2
                    axis { x: 0; y: 1; z: 0 }
                    angle: SettingsManager.mirror ? 180 : 0
                }
            }

            FrameProvider {
                id: frameProvider
                accountId: authManager.authAccountId
            }

            VideoOutput {
                id: videoContainer
                anchors.fill: parent
                source: frameProvider
                visible: false
            }

            Rectangle {
                id: idMask
                visible: false
                width: videoContainer.width
                height: videoContainer.height
            }

            OpacityMask {
                id: idRadiusMask
                anchors.fill: parent
                source: videoContainer
                maskSource: idMask
                visible: false
            }

            // 采样逆运算调整
            ShaderEffect {
                id: idFragmentShader
                property string default_frame_shader: "
                                    varying highp vec2 qt_TexCoord0;
                                    uniform sampler2D source;
                                    void main(void)
                                    {
                                        highp vec4 cl = texture2D(source, qt_TexCoord0);
                                        gl_FragColor = cl;
                                    }
                                "
                property string frame_shader: "
                                    varying highp vec2 qt_TexCoord0;
                                    uniform sampler2D source;
                                    void main(void)
                                    {
                                        highp vec4 cl = texture2D(source, qt_TexCoord0);
                                        highp vec3 yuv;
                                        yuv.x = 0.257*cl.r + 0.504*cl.g + 0.098*cl.b;    // 逆运算至 YUV
                                        yuv.y = -0.148*cl.r - 0.291*cl.g + 0.439*cl.b;
                                        yuv.z = 0.439*cl.r - 0.368*cl.g - 0.071*cl.b;
                                        highp vec3 rgb = mat3( %1,       %2,         %3,
                                                            %4,       %5,         %6,
                                                            %7,       %8,         %9) * yuv;    // 新的矩阵计算出 RGB
                                        gl_FragColor = vec4(rgb, cl.a);
                                    }
                                "
                property variant source: ShaderEffectSource { sourceItem: idRadiusMask; hideSource: true }
                anchors.fill: parent
                visible:  {
                            if (SettingsManager.customRender) {
                                return false
                            }
                            if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                                return videoManager.localVideoStatus === 1
                            }
                            return true
                        }
                transform: Rotation {
                    origin.x: idFragmentShader.width / 2
                    origin.y: idFragmentShader.height / 2
                    axis { x: 0; y: 1; z: 0 }
                    angle: SettingsManager.mirror ? 180 : 0
                }
                Component.onCompleted: {
                    idFragmentShader.updateFragmentShader()
                }

                Connections{
                    target: frameProvider
                    onYuv2rgbMatrixChanged:{
                        idFragmentShader.updateFragmentShader()
                    }   
                }
                // fragmentShader 动态更新
                function updateFragmentShader(){
                    // 取颜色系数
                    var adjust_fragment_shader
                    if(frameProvider.yuv2rgbMatrix.length === 9)
                    {
                        adjust_fragment_shader = idFragmentShader.frame_shader
                        for(var index=0; index < 9; index++){
                            adjust_fragment_shader = adjust_fragment_shader.arg(frameProvider.yuv2rgbMatrix[index])
                        }
                        // console.info("VideoOutPut FrameShader:" + adjust_fragment_shader)
                    }
                    else{
                        console.error("yuv2rgbMatrix data invalid. data:" + frameProvider.yuv2rgbMatrix)
                        adjust_fragment_shader = idFragmentShader.default_frame_shader
                    }
                    idFragmentShader.fragmentShader = adjust_fragment_shader
                }
            }
        }

        GridView {
            id: vbGridView
            Layout.preferredWidth: 452
            Layout.preferredHeight: 136
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: 0
            cellWidth: 98 + 15
            cellHeight: 62 + 6
            clip: true
            cacheBuffer: vbListModel.rowCount() * cellHeight
            model: VirtualBackgroundModel {
                id: vbListModel
            }
            delegate: Rectangle {
                width: vbGridView.cellWidth - 10
                height: vbGridView.cellHeight -6
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: vbGridView.cellWidth - 10
                    height: vbGridView.cellHeight -6
                    color: "#FFFFFF"
                    radius: 4
                    border.width: 1
                    border.color: (model.vbCurrentSelected || ma.containsMouse) ? "#337EFF" : "#E1E3E6"

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            if ("qrc:/qml/images/settings/vb/add.svg" === model.vbPath) {
                                fileDialog.open()
                            } else {
                                vbListModel.setSelectedVB(model.vbPath)
                            }
                        }

                        FileDialog {
                            id: fileDialog
                            nameFilters: ["Image files (*.jpg *.png)"]
                            folder: shortcuts.home
                            onAccepted: {
                                console.log("add vb image: " + fileDialog.fileUrl)
                                vbListModel.addVB(fileDialog.fileUrl)
                            }
                        }
                    }

                    Rectangle {
                        id: idCell
                        width: 98
                        height: 62
                        anchors.top: parent.top
                        anchors.topMargin: 6
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 6
                        Image {
                            id: idImag
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: parent.width
                            height: parent.height
                            sourceSize.width: width
                            sourceSize.height: height
                            asynchronous: true
                            mipmap: true
                            fillMode: Image.Stretch // Image.PreserveAspectFit
                            source: getItemImage(model.vbPath)
                        }

                        Image {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            visible: model.vbAllowedDelete && ma.containsMouse
                            width: 16
                            height: 16
                            mipmap: true
                            source: "qrc:/qml/images/settings/vb/delete.svg"
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    vbListModel.removeVB(model.vbPath)
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 0
                            anchors.centerIn: parent
                            visible: "qrc:/qml/images/settings/vb/add.svg" === model.vbPath || model.vbPath.includes("null.jpg")
                            Image {
                                Layout.alignment: Qt.AlignCenter
                                visible: "qrc:/qml/images/settings/vb/add.svg" === model.vbPath
                                mipmap: true
                                width: 12
                                height: 12
                                source: "qrc:/qml/images/settings/vb/add_s.svg"
                            }
                            Label {
                                font.weight: Font.Light
                                font.pointSize: SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage ? 6 : 8
                                text: "qrc:/qml/images/settings/vb/add.svg" === model.vbPath ? qsTr("add local image") : qsTr("nothing")
                            }
                        }
                    }


                    //                    Accessible.role: Accessible.Button
                    //                    Accessible.name: idCellText.text
                    //                    Accessible.onPressAction: if (enabled) ma.clicked(Qt.LeftButton)
                }
            }
            ScrollBar.vertical: ScrollBar {
                id: idScrollBar
                width: 7
            }
        }
    }

    Connections {
        target: rootWindow
        onVisibilityChanged: {
            if (rootWindow.visibility === Window.Hidden) {
                if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                    //videoManager.removeVideoCanvas(authManager.authAccountId, frameProvider)
                } else {
                    if (SettingsManager.customRender) {
                        videoManager.stopLocalVideoPreview(videoRender)
                    } else {
                        videoManager.stopLocalVideoPreview(frameProvider)
                    }
                }
            } else {
                if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                    if (SettingsManager.customRender) {
                        videoManager.setupVideoCanvas(authManager.authAccountId, videoRender, SettingsManager.remoteVideoResolution, videoRender.uuid);
                    } else {
                        videoManager.setupVideoCanvas(authManager.authAccountId, frameProvider, SettingsManager.remoteVideoResolution, frameProvider.uuid);
                    }
                }
            }
        }
    }

    Connections {
        target: SettingsManager
        function onVirtualBackgroundChanged(enabled, msg) {
            if (!enabled) {
                toast.show(msg)
            }
        }
    }

    function getItemImage(imagePath) {
        if ('' === imagePath) {
            return ''
        } else if (imagePath.startsWith('qrc:/') || imagePath.startsWith(':/')) {
            return imagePath
        }

        return "image://localImage/" + imagePath
    }
}
