import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import Qt5Compat.GraphicalEffects
import NetEase.Settings.SettingsStatus 1.0
import "../components"
import "../utils/meetingHelpers.js" as MeetingHelpers
import "../"

Window {
    id: shareVideoWindow

    property bool nextPage: membersManager.count > 4
    property bool prePage: false
    property bool scrollEnable: true

    function goPage(page) {
        currentPage -= page;
        if (currentPage <= 0) {
            currentPage = 1;
        } else {
            var pages = (0 === membersManager.count % pageSize) ? membersManager.count / pageSize : (membersManager.count / pageSize + 1);
            if (currentPage > pages) {
                currentPage = pages;
            }
        }
        membersManager.getMembersPaging(pageSize, currentPage);
    }
    function resetPosition() {
        // console.log("11111", screen.virtualX, screen.virtualY, screen.width, screen.height)
        x = screen.virtualX + screen.width - width - 16;
        y = screen.virtualY + 16;
    }
    function switchModel() {
        switch (SettingsManager.sidebarViewMode) {
        case SettingsStatus.VM_MIN:
            height = Qt.binding(function () {
                    return idTitle.height + speaker.height;
                });
            multVideoModel.clear();
            break;
        case SettingsStatus.VM_SINGLE:
            viewMode = MainPanel.ViewMode.ShareMode;
            membersManager.isGalleryView = false;
            membersManager.isWhiteboardView = false;
            currentPage = 1;
            pageSize = 1;
            membersManager.getMembersPaging(pageSize, currentPage);
            height = Qt.binding(function () {
                    return idTitle.height + videoList.height;
                });
            break;
        case SettingsStatus.VM_MULTIPLE:
            viewMode = MainPanel.ViewMode.ShareMode;
            membersManager.isGalleryView = false;
            membersManager.isWhiteboardView = false;
            currentPage = 1;
            pageSize = 4;
            membersManager.getMembersPaging(pageSize, currentPage);
            height = Qt.binding(function () {
                    return idTitle.height + videoList.height;
                });
            break;
        default:
            return idTitle.height;
        }
    }

    Material.theme: Material.Light
    color: 'transparent'
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    width: 216

    onVisibleChanged: {
        if (visible) {
            switchModel();
        }
    }

    Rectangle {
        id: mainLayout
        anchors.fill: parent
        color: 'transparent' //"#18181F"

        Rectangle {
            id: idTitle
            anchors.top: parent.top
            color: "#1D1D27"
            implicitHeight: 30
            radius: Qt.platform.os === 'windows' ? 0 : 10
            width: 216

            MouseArea {
                property point movePos: '0,0'

                acceptedButtons: Qt.LeftButton
                anchors.fill: parent

                onPositionChanged: {
                    const delta = Qt.point(mouse.x - movePos.x, mouse.y - movePos.y);
                    Window.window.x = Window.window.x + delta.x;
                    Window.window.y = Window.window.y + delta.y;
                }
                onPressed: {
                    movePos = Qt.point(mouse.x, mouse.y);
                }
            }
            Rectangle {
                anchors.bottom: parent.bottom
                color: "#1D1D27"
                height: 10
                visible: Qt.platform.os === 'osx'
                width: parent.width
            }
            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                ImageButton {
                    id: btnMin
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    hoveredImage: 'qrc:/qml/images/meeting/model_min_hover.svg'
                    normalImage: 'qrc:/qml/images/meeting/model_min_normal.svg'
                    pushedImage: 'qrc:/qml/images/meeting/model_min_hover.svg'
                    visible: SettingsManager.sidebarViewMode !== SettingsStatus.VM_MIN

                    onClicked: {
                        console.log('switch to min view mode');
                        SettingsManager.sidebarViewMode = SettingsStatus.VM_MIN
                    }
                }
                ImageButton {
                    id: btnMinSelected
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    hoveredImage: 'qrc:/qml/images/meeting/model_min_hover.svg'
                    normalImage: 'qrc:/qml/images/meeting/model_min_hover.svg'
                    pushedImage: 'qrc:/qml/images/meeting/model_min_hover.svg'
                    visible: SettingsManager.sidebarViewMode === SettingsStatus.VM_MIN

                    onClicked: SettingsManager.sidebarViewMode = SettingsStatus.VM_MIN
                }
                ImageButton {
                    id: btnShare
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    hoveredImage: 'qrc:/qml/images/meeting/model_share_hover.svg'
                    normalImage: 'qrc:/qml/images/meeting/model_share_normal.svg'
                    pushedImage: 'qrc:/qml/images/meeting/model_share_hover.svg'
                    visible: SettingsManager.sidebarViewMode !== SettingsStatus.VM_SINGLE

                    onClicked: {
                        console.log('switch to single view mode');
                        SettingsManager.sidebarViewMode = SettingsStatus.VM_SINGLE
                    }
                }
                ImageButton {
                    id: btnShareSelected
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    hoveredImage: 'qrc:/qml/images/meeting/model_share_hover.svg'
                    normalImage: 'qrc:/qml/images/meeting/model_share_hover.svg'
                    pushedImage: 'qrc:/qml/images/meeting/model_share_hover.svg'
                    visible: SettingsManager.sidebarViewMode === SettingsStatus.VM_SINGLE

                    onClicked: SettingsManager.sidebarViewMode = SettingsStatus.VM_SINGLE
                }
                ImageButton {
                    id: btnAll
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    hoveredImage: 'qrc:/qml/images/meeting/model_all_hover.svg'
                    normalImage: 'qrc:/qml/images/meeting/model_all_normal.svg'
                    pushedImage: 'qrc:/qml/images/meeting/model_all_hover.svg'
                    visible: SettingsManager.sidebarViewMode !== SettingsStatus.VM_MULTIPLE

                    onClicked: {
                        console.log('switch to multiple view mode');
                        SettingsManager.sidebarViewMode = SettingsStatus.VM_MULTIPLE
                    }
                }
                ImageButton {
                    id: btnAllSelected
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    hoveredImage: 'qrc:/qml/images/meeting/model_all_hover.svg'
                    normalImage: 'qrc:/qml/images/meeting/model_all_hover.svg'
                    pushedImage: 'qrc:/qml/images/meeting/model_all_hover.svg'
                    visible: SettingsManager.sidebarViewMode === SettingsStatus.VM_MULTIPLE

                    onClicked: SettingsManager.sidebarViewMode = SettingsStatus.VM_MULTIPLE
                }
            }
        }
        Rectangle {
            id: speaker
            anchors.top: idTitle.bottom
            implicitHeight: 34
            visible: SettingsManager.sidebarViewMode === SettingsStatus.VM_MIN
            width: 216

            gradient: Gradient {
                GradientStop {
                    color: "#33333F"
                    position: 0.0
                }
                GradientStop {
                    color: "#292933"
                    position: 1.0
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 0

                Image {
                    Layout.leftMargin: 8
                    height: 24
                    mipmap: true
                    source: "qrc:/qml/images/meeting/microphone.svg"
                    width: 24
                }
                ToolSeparator {
                    id: helloline
                    Layout.leftMargin: 0
                    opacity: 0.8

                    contentItem: Rectangle {
                        implicitHeight: 34
                        implicitWidth: 1

                        gradient: Gradient {
                            GradientStop {
                                color: "#292938"
                                position: 0.0
                            }
                            GradientStop {
                                color: "#1B1B22"
                                position: 1.0
                            }
                        }
                    }
                }
                Label {
                    id: speakerNickname
                    Layout.fillWidth: true
                    Layout.leftMargin: 0
                    Layout.preferredWidth: 152
                    Layout.rightMargin: 4
                    background: null
                    color: "#FFFFFF"
                    elide: Text.ElideRight
                    font.pixelSize: 12
                }
            }
        }
        ListView {
            id: videoList
            anchors.top: idTitle.bottom
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            height: count * 122 + (count > 0 ? (count - 1) * spacing : 0)
            orientation: Qt.Vertical
            spacing: 2
            visible: SettingsManager.sidebarViewMode !== SettingsStatus.VM_MIN
            width: parent.width

            delegate: VideoDelegate {
                accountId: model.accountId
                audioStatus: model.audioStatus
                createdAt: model.createdAt
                height: 122
                nickname: model.nickname
                videoStatus: model.videoStatus
                width: 216
            }
            model: ListModel {
                id: multVideoModel
            }

            MouseArea {
                id: vidoeMouseArea
                anchors.fill: parent
                enabled: SettingsManager.sidebarViewMode === SettingsStatus.VM_MULTIPLE
                hoverEnabled: true

                onWheel: {
                    //console.log("555555", currentPage, nextPage, prePage, wheel.angleDelta.y)
                    const angle = wheel.angleDelta.y;
                    if (scrollEnable && (nextPage && angle < 0) || (prePage && angle > 0)) {
                        scrollEnable = false;
                        goPage(angle / 120);
                    }
                }
            }
            Rectangle {
                id: prePageRect
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: videoList.top
                color: Qt.rgba(255, 255, 255, 0.3)
                height: 14
                visible: prePage && vidoeMouseArea.containsMouse
                width: 50

                Image {
                    anchors.centerIn: parent
                    height: 6
                    mipmap: true
                    source: "qrc:/qml/images/meeting/go_page.svg"
                    width: 10
                }
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        scrollEnable = false;
                        goPage(1);
                    }
                }
            }
            Rectangle {
                id: nextPageRect
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                color: Qt.rgba(255, 255, 255, 0.3)
                height: 14
                visible: nextPage && vidoeMouseArea.containsMouse
                width: 50

                Image {
                    anchors.centerIn: parent
                    height: 6
                    mipmap: true
                    rotation: 180
                    source: "qrc:/qml/images/meeting/go_page.svg"
                    width: 10
                }
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        scrollEnable = false;
                        goPage(-1);
                    }
                }
            }
        }
    }
    Connections {
        function onShareAccountIdChanged() {
            if (shareManager.shareAccountId.length === 0) {
                multVideoModel.clear();
                videoList.forceLayout();
            }
        }

        target: shareManager
    }
    Connections {
        function onActiveSpeakerNicknameChanged() {
            return;
            if (audioManager.activeSpeakerNickname.length !== 0) {
                speakerNickname.text = qsTr("Speaking: ") + audioManager.activeSpeakerNickname;
            } else {
                speakerNickname.text = '';
            }
        }
        function onUserSpeakerChanged(nickName) {
            if (nickName.length !== 0) {
                speakerNickname.text = qsTr("Speaking: ") + nickName;
            } else {
                speakerNickname.text = '';
            }
        }

        target: audioManager
    }
    Connections {
        function onMembersChanged(primaryMember, secondaryMembers, realPage, realCount) {
            if (SettingsManager.sidebarViewMode === SettingsStatus.VM_MIN || !visible) {
                return;
            }
            console.info('Members info changed:', JSON.stringify(primaryMember), JSON.stringify(secondaryMembers), realPage, realCount);
            if (currentPage !== realPage) {
                multVideoModel.clear();
                currentPage = realPage;
            }
            MeetingHelpers.arrangeSpeakerLayout(primaryMember, secondaryMembers, realPage, realCount, null, multVideoModel);
            console.info('Secondary members count: ', multVideoModel.count);
            nextPage = currentPage * pageSize < realCount;
            prePage = currentPage > 1;
            scrollEnable = true;
        }
        function onNicknameChanged(accountId, nickname) {
            var rowCount = multVideoModel.count;
            var found = false;
            for (var i = 0; i < rowCount; i++) {
                var model = multVideoModel.get(i);
                if (model.accountId === accountId) {
                    model.nickname = nickname;
                    found = true;
                }
            }
        }

        target: membersManager
    }

    Connections {
        function onSidebarViewModeChanged() {
            console.log(`sidebar view mode changed, ${SettingsManager.sidebarViewMode}`);
            switchModel();
        }

        target: SettingsManager
    }
}
