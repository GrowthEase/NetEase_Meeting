import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia
import Qt.labs.settings 1.0
import Qt5Compat.GraphicalEffects
import NetEase.Meeting.FrameProvider 1.0
import NetEase.Members.Status 1.0

Rectangle {
    id: root

    property string accountId: ""
    property var audioStatus: 1
    property int audioVolume: 0
    property var createdAt: 0
    property alias frameProvider: frameProvider
    property bool highQuality: false
    property string nickname: ""
    property bool primary: false
    property bool sharingStatus: false
    property int videoBitRate: 0
    property int videoFrameRate: 0
    property int videoHeight: 0
    property var videoStatus: 1
    property int videoWidth: 0

    Component.onCompleted: {
        if (accountId.length !== 0)
            videoManager.setupVideoCanvas(accountId, frameProvider, highQuality, frameProvider.uuid);
        console.log(`New video output, accound ID: ${accountId}, nickname: ${nickname}, primary: ${primary}, highQuality: ${highQuality}, videoStatus: ${videoStatus}, audioStatus: ${audioStatus}, createdAt: ${createdAt}`);
    }
    Component.onDestruction: {
        if (accountId.length !== 0) {
            if (authManager.authAccountId !== accountId) {
                console.log(`Video output destory, accound ID: ${accountId}, nickname: ${nickname}, primary: ${primary}, highQuality: ${highQuality}, videoStatus: ${videoStatus}, audioStatus: ${audioStatus}, createdAt: ${createdAt}`);
                videoManager.unSubscribeRemoteVideoStream(accountId, highQuality, frameProvider.uuid);
            }
        }
    }
    // onHighQualityChanged: {
    //     if (accountId.length !== 0) {
    //         videoManager.subscribeRemoteVideoStream(accountId, highQuality, frameProvider.uuid);
    //     }
    // }

    Rectangle {
        anchors.fill: parent
        color: primary ? "#000000" : "#292933"

        RowLayout {
            anchors.centerIn: parent
            spacing: 30

            Label {
                id: nicknameText
                Layout.maximumWidth: root.width - 20
                color: "#FFFFFF"
                elide: Text.ElideRight
                font.pixelSize: primary ? 48 : 14
                text: nickname
                visible: (videoStatus !== 1 && shareManager.shareAccountId !== accountId) || (shareManager.shareAccountId === accountId && !sharingStatus && videoStatus !== 1)
            }
        }
        Image {
            anchors.centerIn: parent
            height: primary === 1 ? 40 : 25
            mipmap: true
            source: "qrc:/qml/images/settings/camera_empty.png"
            visible: videoStatus === 1
            width: primary === 1 ? 40 : 25
        }
    }
    FrameProvider {
        id: frameProvider
        accountId: root.accountId
        subVideo: sharingStatus
        videoSink: videoContainer.videoSink

        onStreamFpsChanged: {
            labelStreamFps.text = istreamFps.toString();
        }
    }
    VideoOutput {
        id: videoContainer
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
        visible: videoStatus === 1 || (shareManager.shareAccountId === accountId && sharingStatus)

        transform: Rotation {
            angle: (authManager.authAccountId === accountId && SettingsManager.mirror) ? 180 : 0
            origin.x: videoContainer.width / 2
            origin.y: videoContainer.height / 2

            axis {
                x: 0
                y: 1
                z: 0
            }
        }
    }
    Rectangle {
        id: idPhone
        anchors.fill: parent
        color: primary ? "#000000" : "#292933"
        visible: membersManager.getPhoneStatus(accountId) && !sharingStatus

        Rectangle {
            anchors.fill: parent
            color: "#24242C"
            opacity: 0.7

            Label {
                anchors.centerIn: parent
                color: "#FFFFFF"
                elide: Text.ElideRight
                font.pixelSize: primary ? 48 : 14
                text: nickname
                visible: primary
            }
        }
        ColumnLayout {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: primary ? 0 : -10
            spacing: primary ? 35 : 5

            Image {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.maximumHeight: primary ? 52 : 35
                // anchors.verticalCenterOffset: primary ? -15 : -10
                Layout.maximumWidth: primary ? 52 : 35
                mipmap: true
                source: "qrc:/qml/images/meeting/calling.svg"
                sourceSize: Qt.size(primary ? 52 : 35, primary ? 52 : 35)
            }
            Label {
                Layout.maximumWidth: root.width - 20
                color: "#FFFFFF"
                elide: Text.ElideRight
                font.pixelSize: primary ? 32 : 12
                text: qsTr("Answering the system call")
            }
        }
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        color: "#88000000"
        height: 21
        radius: 2
        width: nicknameRow.width

        RowLayout {
            id: nicknameRow
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Item {
                Layout.preferredWidth: 2
            }
            Image {
                id: microphoneIcon
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: 14
                Layout.preferredWidth: 14
                mipmap: true
                source: audioStatus !== 1 ? "qrc:/qml/images/meeting/footerbar/btn_audio_off_normal.png" : "qrc:/qml/images/meeting/volume/volume_level_1.png"
                visible: true
            }
            Label {
                id: nicknameSmall
                Layout.alignment: Qt.AlignVCenter
                Layout.maximumWidth: root.width - 40
                color: "#FFFFFF"
                elide: Text.ElideRight
                font.pixelSize: 12
                text: {
                    if (shareManager.shareAccountId === accountId && sharingStatus) {
                        return nickname + qsTr(" is screen sharing currently");
                    } else {
                        return nickname;
                    }
                }
            }
            Item {
                Layout.preferredWidth: 2
            }
        }
    }
    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 3
        anchors.top: parent.top
        anchors.topMargin: 3
        color: "#88000000"
        height: 84
        radius: 2
        visible: videoManager.displayVideoStats
        width: 155

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 5
            spacing: 0

            Label {
                Layout.fillWidth: true
                color: "#FFFFFF"
                elide: Qt.ElideRight
                font.pixelSize: 12
                horizontalAlignment: Text.AlignLeft
                text: accountId
            }
            Label {
                color: "#FFFFFF"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignLeft
                text: videoWidth.toString() + "x" + videoHeight.toString() + (highQuality || authManager.authAccountId === accountId ? " - High Quality" : " - Low Quality")
            }
            Label {
                color: "#FFFFFF"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignLeft
                text: videoFrameRate.toString() + " fps"
                verticalAlignment: Text.AlignVCenter
            }
            Label {
                color: "#FFFFFF"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignLeft
                text: videoBitRate.toString() + " kbps"
                verticalAlignment: Text.AlignVCenter
            }
            Row {
                Layout.fillWidth: true
                spacing: 0
                visible: false

                Label {
                    id: idlabelStreamFps
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    // width: idlabelUid.width
                    horizontalAlignment: Text.AlignRight
                    text: "Stream FPS: "
                }
                Label {
                    id: labelStreamFps
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    text: "0"
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: "green"
        height: 4
        radius: 2
        visible: videoManager.displayVideoStats
        width: (audioVolume / 100) * parent.width
    }
    Rectangle {
        id: speakerBorder
        anchors.fill: parent
        border.color: "#59F20C"
        border.width: 4
        color: "#00000000"
        visible: {
            if (membersManager.viewMode !== MembersStatus.VIEW_MODE_GALLERY) {
                return false;
            }
            if (membersManager.isGalleryView) {
                if (videoManager.focusAccountId === accountId)
                    return true;
                if (videoManager.focusAccountId.length === 0 && audioManager.activeSpeaker === accountId)
                    return true;
                return false;
            } else {
                return false;
            }
        }
    }
    Connections {
        target: videoManager

        onLocalUserVideoStats: {
            if (authManager.authAccountId === accountId) {
                for (let i = 0; i < userStats.length; i++) {
                    const stats = userStats[i];
                    if ((!sharingStatus && 1 === stats.layerType) || (sharingStatus && 2 === stats.layerType)) {
                        videoBitRate = stats.bitRate;
                        videoFrameRate = stats.frameRate;
                        videoWidth = stats.width;
                        videoHeight = stats.height;
                        break;
                    }
                }
            }
        }
        onRemoteUserVideoStats: {
            for (let i = 0; i < userStats.length; i++) {
                const stats = userStats[i];
                if (stats.accountId.toString() === accountId && ((!sharingStatus && 1 === stats.layerType) || (sharingStatus && 2 === stats.layerType))) {
                    videoBitRate = stats.bitRate;
                    videoFrameRate = stats.frameRate;
                    videoWidth = stats.width;
                    videoHeight = stats.height;
                    break;
                }
            }
        }
        onUserVideoStatusChanged: {
            if (changedAccountId === accountId && !sharingStatus) {
                videoStatus = deviceStatus;
                videoContainer.visible = videoStatus === 1;
            }
        }
    }
    Connections {
        target: audioManager

        onRemoteUserAudioStats: {
            for (let i = 0; i < userStats.length; i++) {
                const stats = userStats[i];
                if (stats.accountId === accountId) {
                    audioVolume = stats.volume;
                    break;
                }
            }
        }
        onUserAudioStatusChanged: {
            if (changedAccountId === accountId) {
                audioStatus = deviceStatus;
                if (audioStatus !== 1) {
                    microphoneIcon.source = "qrc:/qml/images/meeting/footerbar/btn_audio_off_normal.png";
                } else {
                    microphoneIcon.source = "qrc:/qml/images/meeting/volume/volume_level_1.png";
                }
            }
        }
    }
    Connections {
        target: shareManager

        onShareAccountIdChanged: {
            frameProvider.restart();
            videoContainer.visible = videoStatus === 1 || (shareManager.shareAccountId === accountId && sharingStatus);
        }
    }
    Connections {
        function onNicknameChanged(accountId, nickname) {
            if (accountId === root.accountId) {
                root.nickname = nickname;
            }
        }

        target: membersManager

        onPhoneStatusChanged: (accountId, open) => {
            if (root.accountId === accountId && !sharingStatus) {
                idPhone.visible = open;
            }
        }
        onUserReJoined: {
            if (root.accountId === accountId) {
                videoManager.subscribeRemoteVideoStream(accountId, highQuality, frameProvider.uuid);
                videoManager.setupVideoCanvas(accountId, frameProvider, highQuality, frameProvider.uuid);
            }
        }
    }
    Connections {
        function onUserAudioVolumeIndication(accountId, level) {
            if (accountId !== root.accountId) {
                return;
            }
            if (audioStatus !== 1) {
                return;
            }
            microphoneIcon.source = getAudioVolumeSourceImage(level);
        }

        target: deviceManager
    }
}
