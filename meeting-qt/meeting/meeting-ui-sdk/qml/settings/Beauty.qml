import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import QtGraphicalEffects 1.15
import NetEase.Meeting.FrameProvider 1.0
import NetEase.Meeting.VideoRender 1.0
import NetEase.Meeting.DeviceModel 1.0
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.VideoWindow 1.0

import "../components"

Rectangle {
    anchors.fill: parent
    anchors.margins: 40
    property bool internalRender: (SettingsManager.enableInternalRender
                                   && !(MeetingStatus.MEETING_CONNECTED === meetingManager.getRoomStatus()
                                        || MeetingStatus.MEETING_RECONNECTED === meetingManager.getRoomStatus()))

    Component.onCompleted: {
        SettingsManager.setEnableInternalRender(SettingsManager.enableInternalRender)
        SettingsManager.initFaceBeautyLevel()
        beautyValue.value = SettingsManager.faceBeautyLevel
        const currentIndex = deviceManager.currentIndex(
                               DeviceSelector.DeviceType.CaptureType)
        deviceManager.selectDevice(DeviceSelector.DeviceType.CaptureType,
                                   currentIndex)
        if (SettingsManager.customRender) {
            videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */videoRender)
        } else {
            videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
        }
    }

    Component.onDestruction: {
        SettingsManager.saveFaceBeautyLevel()
    }

    RowLayout {
        id: idRowLayout
        spacing: 40
        Label {
            id: beautyLabel
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 12
            font.pixelSize: 16
            font.weight: Font.Medium
            text: qsTr("Beauty level")
        }

        ColumnLayout {
            spacing: 20
            CustomSlider {
                id: beautyValue
                showValue: true
                Layout.preferredWidth: 320
                Layout.topMargin: beautyLabel.height / 2
                from: 0
                to: 10
                stepSize: 1
                onValueChanged: {
                    SettingsManager.setFaceBeautyLevel(value)
                }
                Accessible.name: beautyLabel.text
            }


            Rectangle {
                id: idVideoRect
                Layout.preferredWidth: 320
                Layout.preferredHeight: 180
                color: !internalRender ? "#1f1f1f" : "transparent"

                Image {
                    //visible: MeetingStatus.DEVICE_ENABLED !== videoManager.localVideoStatus
                    visible: !internalRender
                    anchors.centerIn: parent
                    mipmap: true
                    source: "qrc:/qml/images/settings/camera_empty.png"
                }

                VideoRender {
                    id: videoRender
                    anchors.fill: parent
                    visible: {
                            if (!SettingsManager.customRender || internalRender) {
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
                            if (SettingsManager.customRender || internalRender) {
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
        }
    }

    //    VideoWindow{
    //        id: idVideoWindow
    //        anchors.fill: parent
    //        visible: internalRender && parent.visible
    //        //fillColor: "#1f1f1f"
    //    }
    Connections {
        target: rootWindow
        onVisibilityChanged: {
            if (rootWindow.visibility === Window.Hidden) {
                SettingsManager.setFaceBeautyLevel(beautyValue.value)
                SettingsManager.saveFaceBeautyLevel()
                if (MeetingStatus.MEETING_CONNECTED === meetingManager.roomStatus || MeetingStatus.MEETING_RECONNECTED === meetingManager.roomStatus) {
                    //videoManager.removeVideoCanvas(authManager.authAccountId, frameProvider)
                } else {
                    if (SettingsManager.customRender) {
                        videoManager.stopLocalVideoPreview(/*internalRender ? idVideoWindow : */videoRender)
                    } else {
                        videoManager.stopLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
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
}
