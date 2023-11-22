import QtQuick
import QtQuick.Window 2.14
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia 5.12
import NetEase.Meeting.MembersModel 1.0
import NetEase.Meeting.GlobalChatManager 1.0
import NetEase.Settings.SettingsStatus 1.0
import NetEase.Members.Status 1.0
import "components"
import "share"
import "utils/dialogManager.js" as DialogManager
import "utils/meetingHelpers.js" as MeetingHelpers
import "utils/galleryUtilities.js" as GalleryUtilities

Rectangle {
    id: root
    enum ViewMode {
        FocusView,
        GalleryView
    }

    property var currentPrimaryMember: {
    }
    property var currentSpeaker: {
    }
    property int gridSpacing: 4
    property int realCountOfMembers: 0

    function resizeGalleryLayout() {
        if ((realCountOfMembers >= 2 && realCountOfMembers < 5 && secondaryContainer.width >= 340) || (realCountOfMembers >= 5 && realCountOfMembers < 9 && secondaryContainer.width >= 500) || (realCountOfMembers >= 9 && secondaryContainer.width >= 660)) {
            splitViewCurrentViewMode = SplitPage.ViewMode.GalleryView;
        } else {
            splitViewCurrentViewMode = SplitPage.ViewMode.FocusView;
        }
        if (splitViewCurrentViewMode === SplitPage.ViewMode.FocusView) {
            pageSize = 6;
            rootContainer.visible = false;
            idSecondaryView.visible = true;
            if (splitViewLastViewMode !== splitViewCurrentViewMode) {
                membersManager.getMembersPaging(pageSize, currentPage, MembersStatus.VIEW_MODE_FOCUS_WITH_SELF);
            }
            splitViewLastViewMode = splitViewCurrentViewMode;
        }
        if (splitViewCurrentViewMode === SplitPage.ViewMode.GalleryView) {
            pageSize = 16;
            rootContainer.visible = true;
            idSecondaryView.visible = false;
            if (splitViewLastViewMode !== splitViewCurrentViewMode) {
                membersManager.getMembersPaging(pageSize, currentPage, MembersStatus.VIEW_MODE_GALLERY);
            } else {
                const grid = GalleryUtilities.calcGridLayout(gridModel.count);
                const itemSize = GalleryUtilities.calcItemSize(secondaryContainer, grid.columnCount, gridModel.count, gridSpacing);
                const containerSize = GalleryUtilities.calcContainerSize(itemSize, gridSpacing, grid.columnCount, grid.rowCount);
                rootContainer.Layout.preferredWidth = containerSize.width;
                rootContainer.Layout.preferredHeight = containerSize.height;
                GalleryUtilities.updateItemsPosition(itemSize, gridSpacing, grid, gridModel);
            }
            splitViewLastViewMode = splitViewCurrentViewMode;
        }
    }

    anchors.fill: parent

    Component.onCompleted: {
        membersManager.isGalleryView = false;
        if (isNewMeetingLayout) {
            isNewMeetingLayout = false;
            if (splitViewDefaultState === undefined)
                splitViewDefaultState = splitView.saveState();
            else
                splitView.restoreState(splitViewDefaultState);
        } else {
            if (splitViewState !== undefined) {
                splitView.restoreState(splitViewState);
            }
        }
        viewMode = MainPanel.ViewMode.FocusViewLeftToRightMode;
        currentPage = 1;
        if (splitViewLastViewMode === SplitPage.ViewMode.FocusView)
            pageSize = 6;
        if (splitViewLastViewMode === SplitPage.ViewMode.GalleryView)
            pageSize = 16;
        membersManager.getMembersPaging(pageSize, currentPage, MembersStatus.VIEW_MODE_FOCUS_WITH_SELF);
    }
    Component.onDestruction: {
        splitViewState = splitView.saveState();
    }

    SplitView {
        id: splitView
        anchors.fill: parent
        orientation: Qt.Horizontal

        handle: Rectangle {
            id: handleDelegate
            color: SplitHandle.pressed ? "#18181F" : (SplitHandle.hovered ? Qt.lighter("#18181F", 1.1) : "#18181F")
            implicitHeight: 4
            implicitWidth: 4

            containmentMask: Item {
                height: splitView.height
                width: 10
                x: (handleDelegate.width - width) / 2
            }

            Image {
                anchors.verticalCenter: parent.verticalCenter
                height: 24
                source: "qrc:/qml/images/public/button/btn_separator.svg"
                width: 4
            }
        }

        Rectangle {
            id: primaryContainer
            SplitView.fillWidth: true
            SplitView.minimumWidth: mainWindow.width >= 1440 ? 180 : 160
            color: "#000000"

            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.top: parent.top
                anchors.topMargin: 4
                spacing: 10

                Rectangle {
                    color: "#771E1E1E"
                    height: 22
                    visible: (authManager.authAccountId === membersManager.hostAccountId || membersManager.isManagerRole) && videoManager.focusAccountId.length !== 0 && shareManager.shareAccountId.length === 0
                    width: {
                        if (SettingsStatus.UILanguage_en === SettingsManager.uiLanguage) {
                            return 150;
                        } else if (SettingsStatus.UILanguage_ja === SettingsManager.uiLanguage) {
                            return 180;
                        } else {
                            return 90;
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        color: "#FFFFFF"
                        font.pixelSize: 12
                        text: qsTr('Unset Focus')
                    }
                    MouseArea {
                        id: unsetFocus
                        anchors.fill: parent
                        cursorShape: Qt.ClosedHandCursor

                        onClicked: membersManager.setAsFocus(videoManager.focusAccountId, false)
                    }
                }
            }
            ToolButton {
                id: extendView
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 34
                visible: false
                width: 26
                z: 1

                background: Rectangle {
                    color: "#000000"
                    opacity: extendView.down ? 0.5 : 1.0
                    radius: 2
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        showRightList = !showRightList;
                    }
                    onPressAndHold: {
                        extendView.down = true;
                    }
                    onReleased: {
                        extendView.down = false;
                    }
                }
                Image {
                    anchors.centerIn: parent
                    height: 14
                    mipmap: true
                    source: secondaryContainer.visible ? "qrc:/qml/images/public/button/btn_right_white.svg" : "qrc:/qml/images/public/button/btn_left_white.svg"
                    width: 14
                }
            }
            HoverHandler {
                onHoveredChanged: {
                    extendView.visible = hovered;
                }
            }
        }
        Rectangle {
            id: secondaryContainer
            SplitView.maximumWidth: {
                const containerMaxumnWidth = root.width - 160;
                return containerMaxumnWidth;
            }
            SplitView.minimumWidth: 180
            color: "#18181F"
            implicitWidth: 180
            visible: showRightList

            onWidthChanged: {
                if (visible)
                    Qt.callLater(function () {
                            resizeGalleryLayout();
                        });
            }

            ColumnLayout {
                id: rightSideLayout
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                width: parent.width - 4

                Rectangle {
                    id: rootContainer
                    color: "#18181F"
                    visible: false

                    Repeater {
                        model: ListModel {
                            id: gridModel
                        }

                        Rectangle {
                            color: "black"
                            height: model.height
                            width: model.width
                            x: model.x
                            y: model.y

                            VideoDelegate {
                                accountId: model.accountId
                                anchors.fill: parent
                                audioStatus: model.audioStatus
                                createdAt: model.createdAt
                                highQuality: {
                                    if (authManager.authAccountId === model.accountId)
                                        return false;
                                    // if (currentSpeaker && currentSpeaker.accountId && currentSpeaker.accountId === model.accountId)
                                    //     return true;
                                    return model.highQuality;
                                }
                                nickname: model.nickname
                                videoStatus: model.videoStatus
                            }
                        }
                    }
                }
                ListView {
                    id: idSecondaryView
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.maximumWidth: {
                        const paddingSize = 4 * 2;
                        const pageButtonHeight = 0; // 32 * 2;
                        const layoutSpacing = 0; // rightSideLayout.spacing * 2;
                        const itemSpacing = (count - 1) * spacing;
                        const maximumItemHeight = (secondaryContainer.height - paddingSize - pageButtonHeight - layoutSpacing - itemSpacing) / count;
                        return maximumItemHeight * 16 / 9;
                    }
                    Layout.preferredHeight: count * (width * 9 / 16) + ((count - 1) * spacing)
                    orientation: Qt.Vertical
                    spacing: 4

                    property var wheelTimestamp: 0

                    delegate: VideoDelegate {
                        accountId: model.accountId
                        audioStatus: model.audioStatus
                        createdAt: model.createdAt
                        height: idSecondaryView.width * 9 / 16
                        highQuality: {
                            if (authManager.authAccountId === model.accountId)
                                return false;
                            // if (((currentSpeaker && currentSpeaker.accountId) || "") === model.accountId)
                            //     return true;
                            return SettingsManager.remoteVideoResolution;
                        }
                        nickname: model.nickname
                        videoStatus: model.videoStatus
                        width: idSecondaryView.width
                    }
                    model: ListModel {
                        id: secondaryModel
                    }

                    MouseArea {
                        anchors.fill: parent

                        onWheel: {
                            // 如果上一次滚动与本次滚动时间小于 800 毫秒，则忽略
                            if (Date.now() - idSecondaryView.wheelTimestamp < 300)
                                return;
                            if (Qt.platform.os === 'windows') {
                                if (wheel.angleDelta.y < 0 && currentPage * pageSize < (realCountOfMembers)) {
                                    membersManager.getMembersPaging(pageSize, currentPage + 1, MembersStatus.VIEW_MODE_FOCUS_WITH_SELF);
                                }
                                if (wheel.angleDelta.y > 0 && currentPage > 1) {
                                    membersManager.getMembersPaging(pageSize, currentPage - 1, MembersStatus.VIEW_MODE_FOCUS_WITH_SELF);
                                }
                                idSecondaryView.wheelTimestamp = Date.now();
                            } else {
                                if (wheel.pixelDelta.y < 0 && currentPage * pageSize < (realCountOfMembers) && wheel.pixelDelta.y < -30) {
                                    idSecondaryView.wheelTimestamp = Date.now();
                                    membersManager.getMembersPaging(pageSize, currentPage + 1, MembersStatus.VIEW_MODE_FOCUS_WITH_SELF);
                                }
                                if (wheel.pixelDelta.y > 0 && currentPage > 1 && wheel.pixelDelta.y > 30) {
                                    idSecondaryView.wheelTimestamp = Date.now();
                                    membersManager.getMembersPaging(pageSize, currentPage - 1, MembersStatus.VIEW_MODE_FOCUS_WITH_SELF);
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: buttonPrePage
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                width: 32
                color: "#00000000"
                visible: false

                CustomToolButton {
                    anchors.fill: parent
                    direction: CustomToolButton.Direction.Left

                    onClicked: membersManager.getMembersPaging(pageSize, currentPage - 1, MembersStatus.VIEW_MODE_AUTO)
                }
            }

            Rectangle {
                id: buttonNextPage
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                width: 32
                color: "#00000000"
                visible: false

                CustomToolButton {
                    anchors.fill: parent
                    direction: CustomToolButton.Direction.Right

                    onClicked: membersManager.getMembersPaging(pageSize, currentPage + 1, MembersStatus.VIEW_MODE_AUTO)
                }
            }

            HoverHandler {
                id: pageHoverHandler
            }
        }
    }
    Connections {
        target: footerBar

        onScreenShare: {
            if (hasRecordPermission) {
                if (!shareSelector.visible) {
                    shareSelector.open();
                } else {
                    shareSelector.close();
                }
            } else {
                requestPermission.sigOpenSetting.connect(function () {
                        shareManager.openSystemSettings();
                    });
                requestPermission.titleText = qsTr("Screen Record Permission");
                requestPermission.contentText = qsTr('Due to the security control of MacOS system, it is necessary to turn on the system screen recording permission before starting to share the screen%1Open System Preferences > Security and privacy grant access').arg('\r\n\r\n');
                requestPermission.open();
            }
        }
        onShowChatroom: {
            chatBar.show = !chatBar.show;
        }
        onShowMembers: {
            membersBar.show = !membersBar.show;
        }
        onSwitchView: {
            if (shareManager.shareAccountId.length !== 0) {
                toast.show(qsTr("Someone is screen sharing currently, you can't switch the view mode"));
                return;
            }
            if (whiteboardManager.whiteboardSharing && whiteboardManager.whiteboardSharerAccountId.length !== 0) {
                toast.show(qsTr("Someone is whiteboard sharing currently, you can't switch the view mode"));
                return;
            }
            // if (secondaryModel.count !== 0)
            mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/SplitPage.qml'));
        }
    }
    Connections {
        target: membersManager

        onMembersChanged: {
            console.info('Members info changed:', JSON.stringify(primaryMember), JSON.stringify(secondaryMembers), realPage, realCount, viewMode);
            if (realCount === 1) {
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'));
                return;
            }
            root.realCountOfMembers = realCount;
            root.currentPrimaryMember = Object.assign({}, primaryMember, {
                    "highQuality": true
                });
            if (splitViewCurrentViewMode === SplitPage.ViewMode.FocusView) {
                gridModel.clear();
                if (currentPage !== realPage) {
                    secondaryModel.clear();
                    currentPage = realPage;
                }
                MeetingHelpers.arrangeSplitLayout(secondaryMembers, realPage, realCount, primaryContainer, secondaryModel);
                buttonNextPage.visible = false; // currentPage * pageSize < realCount;
                buttonPrePage.visible = false; // currentPage > 1;
                MeetingHelpers.setActiveSpeaker(root.currentPrimaryMember, primaryContainer);
            } else {
                secondaryModel.clear();
                if (currentPage !== realPage) {
                    gridModel.clear();
                    currentPage = realPage;
                }
                const grid = GalleryUtilities.calcGridLayout(secondaryMembers.length);
                const itemSize = GalleryUtilities.calcItemSize(secondaryContainer, grid.columnCount, secondaryMembers.length, gridSpacing);
                const containerSize = GalleryUtilities.calcContainerSize(itemSize, gridSpacing, grid.columnCount, grid.rowCount);
                rootContainer.Layout.preferredWidth = containerSize.width;
                rootContainer.Layout.preferredHeight = containerSize.height;
                GalleryUtilities.calcItemsPosition(secondaryMembers, itemSize, gridSpacing, grid, gridModel);
                MeetingHelpers.setActiveSpeaker(root.currentPrimaryMember, primaryContainer);
                buttonPrePage.visible = Qt.binding(function () {
                        return currentPage > 1 && pageHoverHandler.hovered;
                    });
                buttonNextPage.visible = Qt.binding(function () {
                        return currentPage * pageSize < (realCount) && pageHoverHandler.hovered;
                    });
            }
        }
        onNicknameChanged: {
            const rowCount = secondaryModel.count;
            let found = false;
            for (let i = 0; i < rowCount; i++) {
                const model = secondaryModel.get(i);
                if (model.accountId === accountId) {
                    model.nickname = nickname;
                    found = true;
                }
            }
            if (!found) {
                if (accountId === currentSpeaker.accountId) {
                    currentSpeaker.nickname = nickname;
                }
            }
        }
    }
    Connections {
        target: chatBar

        onVisibleChanged: {
            if (visible) {
                GlobalChatManager.noNewMsgNotity();
            }
        }
    }
}
