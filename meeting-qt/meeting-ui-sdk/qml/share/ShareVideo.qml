import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0

import "../components"
import "../utils/meetingHelpers.js" as MeetingHelpers
import "../"

Window {
    id: shareVideoWindow
    width: 216
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: 'transparent'
    Material.theme: Material.Light

    enum ModelType{
        Model_Min = 0,
        Model_Share,
        Model_All
    }

    property int modelTyle: -1
    property bool nextPage: membersManager.count > 4
    property bool prePage: false
    property bool scrollEnable: true

    function resetPosition() {
        // console.log("11111", screen.virtualX, screen.virtualY, screen.width, screen.height)
        x = screen.virtualX + screen.width - width - 16
        y = screen.virtualY + 16
    }

    onVisibleChanged: {
        if (visible) {
            if (ShareVideo.ModelType.Model_Share === modelTyle) {
                switchModel()
            } else {
                modelTyle = ShareVideo.ModelType.Model_Share
            }
            resetPosition()
        }
    }

    onModelTyleChanged: {
        switchModel()
    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        color: 'transparent' //"#18181F"
        Rectangle {
            id: idTitle
            anchors.top: parent.top
            width: 216
            implicitHeight: 30
            radius: Qt.platform.os === 'windows' ? 0 : 10
            color: "#1D1D27"
            MouseArea {
                property point movePos: '0,0'
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onPressed: {
                    movePos = Qt.point(mouse.x, mouse.y)
                }
                onPositionChanged: {
                    const delta = Qt.point(mouse.x - movePos.x, mouse.y - movePos.y)
                    Window.window.x = Window.window.x + delta.x
                    Window.window.y = Window.window.y + delta.y
                }
            }
            Rectangle {
                visible: Qt.platform.os === 'osx'
                width: parent.width
                height: 10
                anchors.bottom: parent.bottom
                color: "#1D1D27"
            }
            RowLayout {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 12
                ImageButton {
                    id: btnMin
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    normalImage: ShareVideo.ModelType.Model_Min === modelTyle ? 'qrc:/qml/images/meeting/model_min_hover.svg' : 'qrc:/qml/images/meeting/model_min_normal.svg'
                    hoveredImage: 'qrc:/qml/images/meeting/model_min_hover.svg'
                    pushedImage: 'qrc:/qml/images/meeting/model_min_hover.svg'
                    onClicked: modelTyle = ShareVideo.ModelType.Model_Min
                }
                ImageButton {
                    id: btnShare
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    normalImage: ShareVideo.ModelType.Model_Share === modelTyle ? 'qrc:/qml/images/meeting/model_share_hover.svg' : 'qrc:/qml/images/meeting/model_share_normal.svg'
                    hoveredImage: 'qrc:/qml/images/meeting/model_share_hover.svg'
                    pushedImage: 'qrc:/qml/images/meeting/model_share_hover.svg'
                    onClicked: modelTyle = ShareVideo.ModelType.Model_Share
                }
                ImageButton {
                    id: btnAll
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    normalImage: ShareVideo.ModelType.Model_All === modelTyle ? 'qrc:/qml/images/meeting/model_all_hover.svg' : 'qrc:/qml/images/meeting/model_all_normal.svg'
                    hoveredImage: 'qrc:/qml/images/meeting/model_all_hover.svg'
                    pushedImage: 'qrc:/qml/images/meeting/model_all_hover.svg'
                    onClicked: modelTyle = ShareVideo.ModelType.Model_All
                }
            }
        }

        Rectangle {
            id: speaker
            visible: ShareVideo.ModelType.Model_Min === modelTyle
            anchors.top: idTitle.bottom
            width: 216
            implicitHeight: 34
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#33333F"
                }
                GradientStop {
                    position: 1.0
                    color: "#292933"
                }
            }
            RowLayout {
                anchors.centerIn: parent
                spacing: 0
                Image {
                    Layout.leftMargin: 8
                    width: 24
                    height: 24
                    source: "qrc:/qml/images/meeting/microphone.svg"
                }
                ToolSeparator {
                    id: helloline
                    Layout.leftMargin: 0
                    opacity: 0.8
                    contentItem: Rectangle {
                        implicitWidth: 1
                        implicitHeight: 34
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: "#292938"
                            }
                            GradientStop {
                                position: 1.0
                                color: "#1B1B22"
                            }
                        }
                    }
                }

                Label {
                    id: speakerNickname
                    Layout.preferredWidth: 152
                    Layout.rightMargin: 4
                    Layout.leftMargin: 4
                    color: "#FFFFFF"
                    font.pixelSize: 16
                    background: null
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        ListView {
            id: videoList
            visible: ShareVideo.ModelType.Model_Min !== modelTyle
            anchors.top: idTitle.bottom
            width: parent.width
            height: count * 122 + (count > 0 ? (count - 1) * spacing : 0)
            spacing: 2
            orientation: Qt.Vertical
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: ListModel {
                id: multVideoModel
            }
            delegate: VideoDelegate {
                width: 216
                height: 122
                accountId: model.accountId
                nickname: model.nickname
                videoStatus: model.videoStatus
                audioStatus: model.audioStatus
            }

            MouseArea {
                anchors.fill: parent
                id: vidoeMouseArea
                enabled: ShareVideo.ModelType.Model_All === modelTyle
                hoverEnabled: true
                onWheel: {
                    //console.log("555555", currentPage, nextPage, prePage, wheel.angleDelta.y)
                    const angle = wheel.angleDelta.y
                    if (scrollEnable && (nextPage && angle < 0) || (prePage && angle > 0)) {
                        scrollEnable = false
                        goPage(angle / 120)
                    }
                }
            }

            Rectangle {
                id: prePageRect
                visible: prePage && vidoeMouseArea.containsMouse
                anchors.top: videoList.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: 50
                height: 14
                color: Qt.rgba(255, 255, 255, 0.3)
                Image {
                    anchors.centerIn: parent
                    width: 10
                    height: 6
                    source: "qrc:/qml/images/meeting/go_page.svg"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        scrollEnable = false
                        goPage(1)
                    }
                }
            }

            Rectangle {
                id: nextPageRect
                visible: nextPage && vidoeMouseArea.containsMouse
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: 50
                height: 14
                color: Qt.rgba(255, 255, 255, 0.3)
                Image {
                    anchors.centerIn: parent
                    width: 10
                    height: 6
                    source: "qrc:/qml/images/meeting/go_page.svg"
                    rotation: 180
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        scrollEnable = false
                        goPage(-1)
                    }
                }
            }
        }
    }

    Connections {
        target: shareManager
        function onShareAccountIdChanged() {
            if (shareManager.shareAccountId.length === 0) {
                multVideoModel.clear()
                videoList.forceLayout()
            }
        }
    }

    Connections {
        target: audioManager
        function onActiveSpeakerNicknameChanged() {
            if(audioManager.activeSpeakerNickname.length !== 0){
                speakerNickname.text = qsTr("Speaking: ") + audioManager.activeSpeakerNickname
            }
            else{
                speakerNickname.text = ''
            }
        }
    }

    Connections {
        target: membersManager
        function onMembersChanged(primaryMember, secondaryMembers, realPage, realCount) {
            if (ShareVideo.ModelType.Model_Min === modelTyle || !visible) {
                return
            }

            console.info('Members info changed:', JSON.stringify(primaryMember),
                         JSON.stringify(secondaryMembers),
                         realPage,
                         realCount)
            if (currentPage !== realPage) {
                multVideoModel.clear()
                currentPage = realPage;
            }
            MeetingHelpers.arrangeSpeakerLayout(primaryMember, secondaryMembers, realPage, realCount, null, multVideoModel)
            console.info('Secondary members count: ', multVideoModel.count)
            nextPage = currentPage * pageSize < realCount
            prePage = currentPage > 1
            scrollEnable = true
        }

        function onNicknameChanged(accountId, nickname) {
            var rowCount = multVideoModel.count;
            var found = false
            for( var i = 0;i < rowCount;i++ ) {
                var model = multVideoModel.get(i);
                if(model.accountId === accountId){
                    model.nickname = nickname
                    found = true
                }
            }
        }
    }

    function switchModel() {
        switch (modelTyle) {
        case ShareVideo.ModelType.Model_Min:
            height = Qt.binding(function() { return idTitle.height + speaker.height })
            multVideoModel.clear()
            break
        case ShareVideo.ModelType.Model_Share:
            viewMode = MainPanel.ViewMode.ShareMode
            membersManager.isGalleryView = false
            membersManager.isWhiteboardView = false
            currentPage = 1
            pageSize = 1
            membersManager.getMembersPaging(pageSize, currentPage)
            height = Qt.binding(function() { return idTitle.height + videoList.height })
            break
        case ShareVideo.ModelType.Model_All:
            viewMode = MainPanel.ViewMode.ShareMode
            membersManager.isGalleryView = false
            membersManager.isWhiteboardView = false
            currentPage = 1
            pageSize = 4
            membersManager.getMembersPaging(pageSize, currentPage)
            height = Qt.binding(function() { return idTitle.height + videoList.height })
            break
        default:
            console.log("error modelTyle!")
            return idTitle.height
        }
    }

    function goPage(page) {
        currentPage -= page
        if (currentPage <= 0) {
            currentPage = 1
        } else{
            var pages = (0 === membersManager.count % pageSize) ? membersManager.count / pageSize : (membersManager.count / pageSize + 1)
            if (currentPage > pages) {
                currentPage = pages
            }
        }
        membersManager.getMembersPaging(pageSize, currentPage)
    }
}
