import QtQuick 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NEMeeting 1.0

Rectangle {
    anchors.fill: parent

    property bool createMode: true
    property bool enableAudio: false
    property bool enableVideo: false
    property string password: ''
    property string meetingId: ''
    property string nickname: ''

    color: '#18181F'

    Component.onCompleted: {
        if (createMode) {
            meetingSession.create(meetingId, nickname, enableAudio, enableVideo)
        } else {
            meetingSession.join(meetingId, password, nickname, enableAudio, enableVideo)
        }
    }

    Drawer {
        id: membersDrawer
        edge: Qt.RightEdge
        height: parent.height
        width: parent.width * 0.3 > 360 ? 360 : parent.width * 0.3
        Rectangle {
            anchors.fill: parent
            ColumnLayout {
                anchors.fill: parent
                Label {
                    text: qsTr('Members (%1)').arg(membersList.count)
                    font.pixelSize: 18
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                }
                ListView {
                    id: membersList
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: NEMMembersModel {
                        membersController: membersController
                    }
                    delegate: ItemDelegate {
                        height: 32
                        width: parent.width
                        RowLayout {
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            anchors.verticalCenter: parent.verticalCenter
                            Label {
                                text: model.nickname
                                Layout.fillWidth: true
                            }
                            Image {
                                source: model.audioStatus === NEMAudioController.AUDIO_DEVICE_ENABLED
                                ? 'qrc:/qml/images/members/members-audio-on.svg'
                                : 'qrc:/qml/images/members/members-audio-off.svg'
                                Layout.alignment: Qt.AlignRight
                            }
                            Image {
                                source: model.videoStatus === NEMVideoController.VIDEO_DEVICE_ENABLED
                                ? 'qrc:/qml/images/members/members-video-on.svg'
                                : 'qrc:/qml/images/members/members-video-off.svg'
                                Layout.alignment: Qt.AlignRight
                            }
                        }
                    }
                }
            }
        }
    }

    NEMSession {
        id: meetingSession
        engine: nemEngine
        mine: NEMMine {
            id: mine
            accountId: nemAccount.accountId
        }
        audioController: NEMAudioController {
            id: audioController
        }
        videoController: NEMVideoController {
            id: videoController
        }
        shareController: NEMShareController {
            id: shareController
        }
        membersController: NEMMembersController {
            id: membersController
        }
        onConnected: {
            videoController.setupVideoCanvas(nemAccount.accountId, primary.frameProvider)
        }
        onDisconnected: {
            dialogToast.showDialog(`${errorString} ${errorCode}`)
            loader.setSource(Qt.resolvedUrl('qrc:/qml/FrontPage.qml'))
        }
        onEnded: {
            loader.setSource(Qt.resolvedUrl('qrc:/qml/FrontPage.qml'))
        }
        onError: {
            dialogToast.showDialog(`${errorString} ${errorCode}`)
            loader.setSource(Qt.resolvedUrl('qrc:/qml/FrontPage.qml'))
        }
    }

    ColumnLayout {
        anchors.fill: parent
        Item { Layout.preferredHeight: 1 }
        ListView {
            spacing: 5
            orientation: ListView.Horizontal
            Layout.preferredHeight: parent.height * 0.17
            Layout.preferredWidth: (height * 16 / 9) * count - (count * (5 - 1))
            Layout.alignment: Qt.AlignHCenter
            model: NEMMembersModel {
                membersController: membersController
            }
            delegate: NEMVideoOutput {
                id: videoOutput
                height: parent.height
                width: height * 16 / 9
                Component.onCompleted: {
                    videoController.setupVideoCanvas(model.accountId, videoOutput.frameProvider)
                }
            }
        }
        NEMVideoOutput {
            id: primary
            Layout.fillWidth: true
            Layout.fillHeight: true
            mirrored: true
        }
    }

    ColumnLayout {
        id: toolbar
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        Rectangle {
            radius: 4
            color: '#99222222'
            Layout.preferredHeight: 30
            Layout.preferredWidth: 120
            Layout.alignment: Qt.AlignHCenter
            Label {
                anchors.centerIn: parent
                color: '#ffffff'
                text: prettyId(meetingSession.meetingId)
            }
        }
        RowLayout {
            Button {
                icon.source: 'qrc:/qml/images/meeting-audio-icon.svg'
                icon.color: mine.audioStatus === NEMAudioController.AUDIO_DEVICE_ENABLED ? '#ffffff': '#d81e06'
                onClicked: audioController.muteLocalAudio(mine.audioStatus === NEMAudioController.AUDIO_DEVICE_ENABLED)
            }
            Button {
                icon.source: 'qrc:/qml/images/meeting-video-icon.svg'
                icon.color: mine.videoStatus === NEMVideoController.VIDEO_DEVICE_ENABLED ? '#ffffff': '#d81e06'
                onClicked: videoController.disableLocalVideo(mine.videoStatus === NEMVideoController.VIDEO_DEVICE_ENABLED)
            }
            Button {
                icon.source: 'qrc:/qml/images/meeting-members.svg'
                icon.color: '#ffffff'
                onClicked: membersDrawer.open()
            }
            Button {
                icon.source: 'qrc:/qml/images/meeting-leave.svg'
                icon.color: '#ffffff'
                onClicked: meetingSession.leave(true)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: meetingSession.status !== NEMSession.MEETING_CONNECTED
        BusyIndicator {
            id: busyIndicator
            anchors.centerIn: parent
        }
    }

    HoverHandler {
        onHoveredChanged: {
            toolbar.visible = hovered
        }
    }
}
