import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import NetEase.Meeting.FrameProvider 1.0
import Qt.labs.settings 1.0

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

    Component.onCompleted: {
        if (accountId.length !== 0)
            videoManager.setupVideoCanvas(accountId, frameProvider, highQuality);
    }

    Component.onDestruction: {
        if (accountId.length !== 0)
            videoManager.removeVideoCanvas(accountId, frameProvider)
    }

    Rectangle {
        anchors.fill: parent
        color: primary ? "#000000" : "#292933"

        RowLayout {
            anchors.centerIn: parent
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
            source: "qrc:/qml/images/settings/camera_empty.png"
        }
    }

    FrameProvider {
        id: frameProvider
        accountId: root.accountId
        subVideo: sharingStatus
        onStreamFpsChanged: {
            labelStreamFps.text = istreamFps.toString()
        }
    }

    VideoOutput {
        id: videoContainer
        anchors.fill: parent
        source: frameProvider
        fillMode: VideoOutput.PreserveAspectFit
        visible: videoStatus === 1 || (shareManager.shareAccountId === accountId && sharingStatus)
        transform: Rotation {
            origin.x: root.width / 2
            origin.y: root.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: authManager.authAccountId === accountId ? 180 : 0
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
                source: "qrc:/qml/images/public/icons/voice_off.png"
                visible: audioStatus !== 1
                Layout.alignment: Qt.AlignVCenter
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

    ColumnLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 3
        anchors.topMargin: 3
        spacing: 0
        visible: videoManager.displayVideoStats
        Label {
            id: labelUid
            text: accountId; color: "#FFFFFF"; font.pixelSize: 12
        }
        Label {
            id: labelPix
            text: videoWidth.toString() + "x" + videoHeight.toString(); color: "#FFFFFF"; font.pixelSize: 12
        }
        Label {
            id: labelBitRate
            text: videoBitRate.toString(); color: "#FFFFFF"; font.pixelSize: 12
        }
        Label {
            id: labelFrameRate
            text: videoFrameRate.toString(); color: "#FFFFFF"; font.pixelSize: 12
        }
        Label {
            id: labelStreamFps
            text: "0"; color: "#FFFFFF"; font.pixelSize: 12
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
            if (changedAccountId === accountId && !sharingStatus)
            {
                videoStatus = deviceStatus
                frameProvider.restart()
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
            if (changedAccountId === accountId)
                audioStatus = deviceStatus
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
    }
}

