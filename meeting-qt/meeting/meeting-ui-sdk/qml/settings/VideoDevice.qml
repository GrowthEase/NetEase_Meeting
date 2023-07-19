import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import QtGraphicalEffects 1.15
import NetEase.Meeting.DeviceModel 1.0
import NetEase.Meeting.MeetingStatus 1.0
import NetEase.Meeting.VideoWindow 1.0
import NetEase.Settings.SettingsStatus 1.0
import NetEase.Meeting.FrameProvider 1.0
import NetEase.Meeting.VideoRender 1.0

import "../components"
import "../utils/dialogManager.js" as DialogManager

Rectangle {
    id: root
    anchors.fill: parent
    anchors.margins: 40
    property bool internalRender: (SettingsManager.enableInternalRender && !(MeetingStatus.MEETING_CONNECTED === meetingManager.getRoomStatus() || MeetingStatus.MEETING_RECONNECTED === meetingManager.getRoomStatus()))
    property bool completed: false
    property bool selectEnable: true

    Component.onCompleted: {
        SettingsManager.setEnableInternalRender(SettingsManager.enableInternalRender)
        //        if (internalRender) {
        //            var point = Window.contentItem.mapFromItem(idVideoRect, 0, 0)
        //            idVideoWindow.setVideoGeometry(point.x, point.y, idVideoRect.width, idVideoRect.height)
        //            idVideoWindow.frontItem = idRowLayout
        //        }

        const currentIndex = deviceManager.currentIndex(DeviceSelector.DeviceType.CaptureType)
        deviceCombobox.currentIndex = currentIndex
        deviceManager.selectDevice(DeviceSelector.DeviceType.CaptureType, currentIndex)
        if (SettingsManager.customRender) {
            videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */videoRender)
        } else {
            videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
        }
        
        completed = true;
        selectEnable = true
    }

    Timer {
        id: clickTimer
        interval: 500
        repeat: false
        onTriggered: {
            selectEnable = true
        }
    }

    ToastManager {
        id: toast
    }

    ColumnLayout {
        width: root.width
        RowLayout {
            id: idRowLayout
            spacing: 40

            Label {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 12
                font.pixelSize: 16
                font.weight: Font.Medium
                text: qsTr("Cameras")
            }

            ColumnLayout {
                spacing: 20
                Rectangle {
                    id: idVideoRect
                    Layout.preferredWidth: 320
                    Layout.preferredHeight: 180
                    color: !internalRender ? "#1f1f1f" : "transparent" // "#1f1f1f" "transparent"

                    Image {
                        //visible: MeetingStatus.DEVICE_ENABLED !== videoManager.localVideoStatus
                        visible: !internalRender
                        anchors.centerIn: parent
                        source: "qrc:/qml/images/settings/camera_empty.png"
                        mipmap: true
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

                ComboBox {
                    id: deviceCombobox
                    textRole: "deviceName"
                    // flat: true
                    Layout.preferredWidth: 320
                    Layout.preferredHeight: 45
                    model: DeviceModel {
                        deviceType: DeviceSelector.DeviceType.CaptureType
                        manager: deviceManager
                    }
                    background: Rectangle {
                        implicitWidth: 320
                        implicitHeight: 45
                        border.color: "#CCCCCC"
                        border.width: 1
                        radius: 2
                    }
                    onActivated: {
                        if (SettingsManager.customRender) {
                            videoManager.stopLocalVideoPreview(/*internalRender ? idVideoWindow : */videoRender);
                        } else {
                            videoManager.stopLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider);
                        }

                        deviceManager.selectDevice(model.deviceType, index)
                        if (SettingsManager.customRender) {
                            videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */videoRender)
                        } else {
                            videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
                        }
                    }
                    onCountChanged: {
                        if (completed) {
                            const currentIndex = deviceManager.currentIndex(model.deviceType)
                            deviceCombobox.currentIndex = currentIndex
                            if (SettingsManager.customRender) {
                                videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */videoRender)
                            } else {
                                videoManager.startLocalVideoPreview(/*internalRender ? idVideoWindow : */frameProvider)
                            }
                        }
                    }
                    Component.onCompleted: {
                    }
                }

                CustomCheckBox {
                    id: checkEnableMirror
                    font.weight: Font.Light
                    text: qsTr("Video Mirror")
                    checked: SettingsManager.mirror
                    onClicked: {
                        SettingsManager.mirror = checkEnableMirror.checked
                    }
                }
            }
        }

        RowLayout {
            spacing: 5
            Layout.topMargin: 15
            Label {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 12
                font.pixelSize: 16
                font.weight: Font.Medium
                text: qsTr("Remote resolution")
            }

            ColumnLayout {
                spacing: 0
                RadioButton {
                    id: autoMode
                    font.weight: Font.Light
                    text: qsTr("Auto Mode")
                    checked: !SettingsManager.remoteVideoResolution
                    enabled: selectEnable
                    onClicked: {
                        selectEnable = false
                        hdMode.checked = false
                        SettingsManager.setRemoteVideoResolution(false)
                        clickTimer.restart()
                    }
                }

                ColumnLayout {
                    spacing: 0
                    RadioButton {
                        id: hdMode
                        font.weight: Font.Light
                        text: qsTr("HD Mode")
                        checked: SettingsManager.remoteVideoResolution
                        enabled: selectEnable
                        onClicked: {
                            selectEnable = false
                            autoMode.checked = false
                            SettingsManager.setRemoteVideoResolution(true)
                            clickTimer.restart()
                        }
                    }
                    Text {
                        Layout.leftMargin: 35
                        Layout.topMargin: -10
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                        text: qsTr("You can enable this option in professional scenarios that have high requirements on picture quality")
                    }
                }
            }
        }

        RowLayout {
            spacing: 5
            Layout.topMargin: 15
            Label {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 12
                font.pixelSize: 16
                font.weight: Font.Medium
                text: qsTr("Local resolution")
            }

            ColumnLayout {
                spacing: 0
                RadioButton {
                    id: id480P
                    font.weight: Font.Light
                    text: qsTr("480P")
                    enabled: selectEnable
                    checked: SettingsStatus.VR_480P === SettingsManager.localVideoResolution
                    onClicked: {
                        selectEnable = false
                        //toast.show(qsTr('The setting takes effect after the video is restarted'))
                        SettingsManager.setLocalVideoResolution(SettingsStatus.VR_480P)
                        clickTimer.restart()
                    }
                }
                RadioButton {
                    id: id720P
                    font.weight: Font.Light
                    text: qsTr("720P")
                    enabled: selectEnable
                    checked: SettingsStatus.VR_720P === SettingsManager.localVideoResolution
                    onClicked: {
                        selectEnable = false
                        //toast.show(qsTr('The setting takes effect after the video is restarted'))
                        SettingsManager.setLocalVideoResolution(SettingsStatus.VR_720P)
                        clickTimer.restart()
                    }
                }
                RadioButton {
                    id: id1080P
                    font.weight: Font.Light
                    text: qsTr("1080P")
                    enabled: selectEnable
                    checked: SettingsStatus.VR_1080P === SettingsManager.localVideoResolution
                    onClicked: {
                        selectEnable = false
                        //toast.show(qsTr('The setting takes effect after the video is restarted'))
                        SettingsManager.setLocalVideoResolution(SettingsStatus.VR_1080P)
                        clickTimer.restart()
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
            selectEnable = true
        }
    }
}
