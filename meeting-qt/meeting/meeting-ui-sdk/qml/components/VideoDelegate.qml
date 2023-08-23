import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia
import Qt.labs.settings 1.0
import Qt5Compat.GraphicalEffects
import NetEase.Meeting.FrameProvider 1.0

Rectangle {
    id: root
    property string accountId: ""
    property string nickname: ""
    property var videoStatus: 1
    property var audioStatus: 1
    property bool primary: false
    property bool highQuality: false
    property bool sharingStatus: false
    property alias frameProvider: frameProvider

    property int audioVolume: 0
    property int videoWidth: 0
    property int videoHeight: 0
    property int videoFrameRate: 0
    property int videoBitRate: 0
    property var createdAt: 0

    Component.onCompleted: {
        if (accountId.length !== 0)
            videoManager.setupVideoCanvas(accountId, frameProvider, highQuality, frameProvider.uuid);
        console.log(`New video output, accound ID: ${accountId}, nickname: ${nickname}, primary: ${primary}, highQuality: ${highQuality}, videoStatus: ${videoStatus}, audioStatus: ${audioStatus}`)
    }

    Component.onDestruction: {
        if (accountId.length !== 0) {
            if(authManager.authAccountId !== accountId) {
                videoManager.unSubscribeRemoteVideoStream(accountId, frameProvider.uuid)
            }
        }
    }

    onHighQualityChanged: {
        if (accountId.length !== 0) {
            videoManager.subscribeRemoteVideoStream(accountId, highQuality, frameProvider.uuid);
        }
    }

    Rectangle {
        anchors.fill: parent
        color: primary ? "#000000" : "#292933"

        RowLayout {
            anchors.centerIn: parent
            spacing: 30
            Label {
                id: nicknameText
                text: nickname
                color: "#FFFFFF"
                elide: Text.ElideRight
                font.pixelSize: primary ? 48 : 14
                visible: (videoStatus !== 1 && shareManager.shareAccountId !== accountId) || (shareManager.shareAccountId === accountId && !sharingStatus && videoStatus !== 1)
                Layout.maximumWidth: root.width - 20
            }
        }

        Image {
            anchors.centerIn: parent
            width: primary === 1 ? 40 : 25
            height: primary === 1 ? 40 : 25
            visible: videoStatus === 1
            mipmap: true
            source: "qrc:/qml/images/settings/camera_empty.png"
        }
    }

    FrameProvider {
        id: frameProvider
        accountId: root.accountId
        subVideo: sharingStatus
        videoSink: videoContainer.videoSink
        onStreamFpsChanged: {
            labelStreamFps.text = istreamFps.toString()
        }
    }

    VideoOutput {
        id: videoContainer
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
        visible: videoStatus === 1 || (shareManager.shareAccountId === accountId && sharingStatus)
        transform: Rotation {
            origin.x: videoContainer.width / 2
            origin.y: videoContainer.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: (authManager.authAccountId === accountId && SettingsManager.mirror) ? 180 : 0
        }
    }

    Rectangle {
        id: idPhone
        anchors.fill: parent
        visible: membersManager.getPhoneStatus(accountId) && !sharingStatus
        color: primary ? "#000000" : "#292933"
        Rectangle {
            anchors.fill: parent
            color: "#24242C"
            opacity: 0.7
            Label {
                text: nickname
                anchors.centerIn: parent
                visible: primary
                color: "#FFFFFF"
                elide: Text.ElideRight
                font.pixelSize: primary ? 48 : 14
            }
        }
        ColumnLayout {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: primary ? 0 : -10
            spacing: primary ? 35 : 5
            Image {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                // anchors.verticalCenterOffset: primary ? -15 : -10
                Layout.maximumWidth: primary ? 52 : 35
                Layout.maximumHeight: primary ? 52 : 35
                sourceSize: Qt.size(primary ? 52 : 35, primary ? 52 : 35)
                mipmap: true
                source: "qrc:/qml/images/meeting/calling.svg"
            }

            Label {
                text: qsTr("Answering the system call")
                color: "#FFFFFF"
                elide: Text.ElideRight
                font.pixelSize: primary ? 32 : 12
                Layout.maximumWidth: root.width - 20
            }
        }
    }

    Rectangle {
        color: "#88000000"
        height: 21
        width: nicknameRow.width
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        radius: 2

        RowLayout {
            id: nicknameRow
            anchors.leftMargin: 5
            spacing: 3
            anchors.verticalCenter: parent.verticalCenter

            Item { Layout.preferredWidth: 2 }

            Image {
                id: microphoneIcon
                source: audioStatus !== 1 ? "qrc:/qml/images/meeting/footerbar/btn_audio_off_normal.png" : "qrc:/qml/images/meeting/volume/volume_level_1.png"
                mipmap: true
                visible: true
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
            }

            Label {
                id: nicknameSmall
                text: {
                    if(shareManager.shareAccountId === accountId && sharingStatus){
                        return nickname + qsTr(" is screen sharing currently")
                    }
                    else{
                        return nickname
                    }
                }
                color: "#FFFFFF"
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.maximumWidth: root.width - 40
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.preferredWidth: 2 }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 3
        anchors.topMargin: 3
        width: 155
        height: 84
        radius: 2
        color: "#88000000"
        visible: videoManager.displayVideoStats
        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 5
            spacing: 0
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                elide: Qt.ElideRight
                text: accountId; color: "#FFFFFF"; font.pixelSize: 12
            }
            Label {
                horizontalAlignment: Text.AlignLeft
                text: videoWidth.toString() + "x" + videoHeight.toString(); color: "#FFFFFF"; font.pixelSize: 12
            }
            Label {
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                text: videoFrameRate.toString() + " fps"; color: "#FFFFFF"; font.pixelSize: 12
            }
            Label {
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                text: videoBitRate.toString() + " kbps"; color: "#FFFFFF"; font.pixelSize: 12
            }
            Row {
                Layout.fillWidth: true
                spacing: 0
                visible: false
                Label {
                    id: idlabelStreamFps
                    // width: idlabelUid.width
                    horizontalAlignment: Text.AlignRight
                    text: "Stream FPS: "; color: "#FFFFFF"; font.pixelSize: 12
                }
                Label {
                    id: labelStreamFps
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: "0"; color: "#FFFFFF"; font.pixelSize: 12
                }
            }
        }
    }

    Rectangle {
        width: (audioVolume / 100) * parent.width
        height: 4
        radius: 2
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: videoManager.displayVideoStats
        color: "green"
    }

    Rectangle {
        id: speakerBorder
        anchors.fill: parent
        border.width: 4
        border.color: "#59F20C"
        color: "#00000000"
        visible: {
            if(membersManager.isWhiteboardView){
                return false
            }

            if (membersManager.isGalleryView) {
                if (videoManager.focusAccountId === accountId)
                    return true
                if (videoManager.focusAccountId.length === 0 && audioManager.activeSpeaker === accountId)
                    return true;
                return false
            } else {
                return false
            }
        }
    }

    Connections {
        target: videoManager
        onUserVideoStatusChanged: {
            if (changedAccountId === accountId && !sharingStatus){
                videoStatus = deviceStatus
                videoContainer.visible = videoStatus === 1
            }
        }
        onRemoteUserVideoStats: {
            for (let i = 0; i < userStats.length; i++) {
                const stats = userStats[i]
                if (stats.accountId.toString() === accountId && ((!sharingStatus && 1 === stats.layerType) || (sharingStatus && 2 === stats.layerType))) {
                    videoBitRate = stats.bitRate
                    videoFrameRate = stats.frameRate
                    videoWidth = stats.width
                    videoHeight = stats.height
                    break;
                }
            }
        }
        onLocalUserVideoStats: {
            if (authManager.authAccountId === accountId) {
                for (let i = 0; i < userStats.length; i++) {
                    const stats = userStats[i]
                    if ((!sharingStatus && 1 === stats.layerType) || (sharingStatus && 2 === stats.layerType)) {
                        videoBitRate = stats.bitRate
                        videoFrameRate = stats.frameRate
                        videoWidth = stats.width
                        videoHeight = stats.height
                        break;
                    }
                }
            }
        }
    }

    Connections {
        target: audioManager
        onUserAudioStatusChanged: {
            if (changedAccountId === accountId) {
                audioStatus = deviceStatus
                if(audioStatus !== 1) {
                    microphoneIcon.source = "qrc:/qml/images/meeting/footerbar/btn_audio_off_normal.png"
                } else {
                    microphoneIcon.source = "qrc:/qml/images/meeting/volume/volume_level_1.png"
                }
            }
        }
        onRemoteUserAudioStats: {
            for (let i = 0; i < userStats.length; i++) {
                const stats = userStats[i]
                if (stats.accountId === accountId) {
                    audioVolume = stats.volume
                    break;
                }
            }
        }
    }

    Connections {
        target: shareManager
        onShareAccountIdChanged: {
            frameProvider.restart()
            videoContainer.visible = videoStatus === 1 || (shareManager.shareAccountId === accountId && sharingStatus)
        }
    }

    Connections {
        target: membersManager
        function onNicknameChanged(accountId, nickname) {
            if(accountId === root.accountId){
                root.nickname = nickname
            }
        }

        onUserReJoined: {
            if (root.accountId === accountId) {
                videoManager.subscribeRemoteVideoStream(accountId, highQuality, frameProvider.uuid);
                videoManager.setupVideoCanvas(accountId, frameProvider, highQuality, frameProvider.uuid);
            }
        }

        onPhoneStatusChanged: (accountId, open) => {
                                  if (root.accountId === accountId && !sharingStatus) {
                                      idPhone.visible = open
                                  }
                              }
    }

    Connections {
        target: deviceManager
        function onUserAudioVolumeIndication(accountId, level) {
            if(accountId !== root.accountId) {
                return
            }

            if(audioStatus !== 1) {
                return
            }

            microphoneIcon.source = getAudioVolumeSourceImage(level)
        }
    }
}
