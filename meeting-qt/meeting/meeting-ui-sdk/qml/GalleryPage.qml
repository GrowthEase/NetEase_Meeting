import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import NetEase.Members.Status 1.0
import "components/"
import "utils/dialogManager.js" as DialogManager
import "utils/meetingHelpers.js" as MeetingHelpers
import "utils/galleryUtilities.js" as GalleryUtilities

Rectangle {
    id: root

    property int gridSpacing: 8

    anchors.fill: parent
    anchors.margins: 8
    color: "black"

    Component.onCompleted: {
        viewMode = MainPanel.ViewMode.GridViewMode;
        membersManager.isGalleryView = true;
        membersManager.isWhiteboardView = false;
        currentPage = 1;
        pageSize = membersManager.galleryViewPageSize;
        membersManager.getMembersPaging(pageSize, currentPage, MembersStatus.VIEW_MODE_GALLERY);
    }
    onWidthChanged: {
        const grid = GalleryUtilities.calcGridLayout(gridModel.count);
        const itemSize = GalleryUtilities.calcItemSize(root, grid.columnCount, gridModel.count, gridSpacing);
        const containerSize = GalleryUtilities.calcContainerSize(itemSize, gridSpacing, grid.columnCount, grid.rowCount);
        rootContainer.width = containerSize.width;
        rootContainer.height = containerSize.height;
        GalleryUtilities.updateItemsPosition(itemSize, gridSpacing, grid, gridModel);
    }

    Rectangle {
        id: rootContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "black"

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
                    highQuality: model.highQuality
                    nickname: model.nickname
                    videoStatus: model.videoStatus
                }
            }
        }
        CustomToolButton {
            id: previousPage
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            direction: CustomToolButton.Direction.Left
            height: 60
            width: 60

            onClicked: membersManager.getMembersPaging(pageSize, currentPage - 1, MembersStatus.VIEW_MODE_GALLERY)
        }
        CustomToolButton {
            id: nextPage
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            direction: CustomToolButton.Direction.Right
            height: 60
            width: 60

            onClicked: membersManager.getMembersPaging(pageSize, currentPage + 1, MembersStatus.VIEW_MODE_GALLERY)
        }
        Rectangle {
            id: pageSign
            height: 36
            radius: 19
            visible: labelPageCount.text !== "1"
            width: 80
            x: parent.width / 2 - width / 2
            y: parent.height - 60 //footerContainer.y - 60

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

                Label {
                    id: labelCurrentPage
                    color: "#FFFFFF"
                    text: currentPage.toString()
                }
                Label {
                    color: "#FFFFFF"
                    text: "/"
                }
                Label {
                    id: labelPageCount
                    color: "#FFFFFF"
                }
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
            mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'));
        }
    }
    Connections {
        target: membersManager

        onMembersChanged: {
            if (!visible || shareManager.shareAccountId === authManager.authAccountId) {
                return;
            }
            if (currentPage !== realPage) {
                gridModel.clear();
                currentPage = realPage;
            }
            if (realCount === 1) {
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'));
                return;
            }
            const grid = GalleryUtilities.calcGridLayout(secondaryMembers.length);
            const itemSize = GalleryUtilities.calcItemSize(root, grid.columnCount, secondaryMembers.length, gridSpacing);
            const containerSize = GalleryUtilities.calcContainerSize(itemSize, gridSpacing, grid.columnCount, grid.rowCount);
            rootContainer.width = containerSize.width;
            rootContainer.height = containerSize.height;
            GalleryUtilities.calcItemsPosition(secondaryMembers, itemSize, gridSpacing, grid, gridModel);
            previousPage.visible = currentPage > 1;
            nextPage.visible = currentPage * pageSize < (realCount); // Except myself
            labelPageCount.text = (Math.ceil((realCount) / pageSize)).toString();
        }
        onNicknameChanged: {
            var rowCount = gridModel.count;
            for (var i = 0; i < rowCount; i++) {
                var model = gridModel.get(i);
                if (model.accountId === accountId) {
                    model.nickname = nickname;
                }
            }
        }
    }
}
