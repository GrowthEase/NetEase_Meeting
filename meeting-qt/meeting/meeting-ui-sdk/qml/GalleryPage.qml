import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import "components/"
import "utils/dialogManager.js" as DialogManager
import "utils/meetingHelpers.js" as MeetingHelpers

Rectangle {
    id: root

    property int gridSpacing: 8
    function calcContainerSize(itemSize, spacing, columnCount, rowCount) {
        const columnSpacing = (columnCount - 1) * spacing;
        const rowSpacing = (rowCount - 1) * spacing;
        const containerWidth = itemSize.width * columnCount + columnSpacing;
        const containerHeight = itemSize.height * rowCount + rowSpacing;
        return {
            "width": containerWidth,
            "height": containerHeight
        };
    }
    function calcGridLayout(memberCount) {
        let columnCount = 1;
        if (memberCount >= 10) {
            columnCount = 4;
        } else if (memberCount >= 5) {
            columnCount = 3;
        } else if (memberCount >= 2) {
            columnCount = 2;
        } else {
            columnCount = 1;
        }
        const rowCount = Math.ceil(memberCount / columnCount);
        return {
            "columnCount": columnCount,
            "rowCount": rowCount
        };
    }
    function calcItemSize(outsider, columnCount, memberCount, spacing) {
        let itemWidth = 0;
        let itemHeight = 0;
        const rowCount = Math.ceil(memberCount / columnCount);
        const columnSpacing = (columnCount - 1) * spacing;
        const rowSpacing = (rowCount - 1) * spacing;
        itemWidth = (outsider.width - columnSpacing) / columnCount;
        itemHeight = itemWidth / 16 * 9;

        // 当高度超出了 containerSize.height 时，需要重新计算 itemWidth 和 itemHeight
        // 计算方式为先计算高度，然后根据高度计算宽度，宽高比例为 16/9
        if (itemHeight * rowCount + rowSpacing > outsider.height) {
            itemHeight = (outsider.height - rowSpacing) / rowCount;
            itemWidth = itemHeight / 9 * 16;
        }
        return {
            "width": itemWidth,
            "height": itemHeight
        };
    }
    function calcItemsPosition(members, itemSize, spacing, gridLayout, listModel) {
        listModel.clear();
        let currentRow = 0;
        for (let index = 0; index < members.length; index++) {
            if (index % gridLayout.columnCount === 0)
                currentRow++;
            let itemX = (index % gridLayout.columnCount) * (itemSize.width + spacing);
            let itemY = (currentRow - 1) * (itemSize.height + spacing);
            let member = members[index];
            // 如果是最后一行，居中显示
            const lastRowItemCount = members.length % gridLayout.columnCount;
            if (currentRow === gridLayout.rowCount && lastRowItemCount > 0) {
                const lastRowX = (gridLayout.columnCount - lastRowItemCount) / 2 * (itemSize.width + spacing);
                itemX = lastRowX + (index % gridLayout.columnCount) * (itemSize.width + spacing);
                itemY = (currentRow - 1) * (itemSize.height + spacing);
            }
            Object.assign(member, {
                x: itemX,
                y: itemY,
                width: itemSize.width,
                height: itemSize.height
            });
            listModel.append(member);
        }
    }
    function updateItemsPosition(itemSize, spacing, gridLayout, listModel) {
        let currentRow = 0;
        for (let index = 0; index < listModel.count; index++) {
            if (index % gridLayout.columnCount === 0)
                currentRow++;
            let itemX = (index % gridLayout.columnCount) * (itemSize.width + spacing);
            let itemY = (currentRow - 1) * (itemSize.height + spacing);
            let member = listModel.get(index);
            // 如果是最后一行，居中显示
            const lastRowItemCount = listModel.count % gridLayout.columnCount;
            if (currentRow === gridLayout.rowCount && lastRowItemCount > 0) {
                const lastRowX = (gridLayout.columnCount - lastRowItemCount) / 2 * (itemSize.width + spacing);
                itemX = lastRowX + (index % gridLayout.columnCount) * (itemSize.width + spacing);
                itemY = (currentRow - 1) * (itemSize.height + spacing);
            }
            member.x = itemX
            member.y = itemY
            member.width = itemSize.width
            member.height = itemSize.height
        }
    }

    anchors.fill: parent
    anchors.margins: 8
    color: "black"

    Component.onCompleted: {
        viewMode = MainPanel.ViewMode.GridViewMode;
        membersManager.isGalleryView = true;
        membersManager.isWhiteboardView = false;
        currentPage = 1;
        pageSize = membersManager.galleryViewPageSize;
        membersManager.getMembersPaging(pageSize, currentPage);
    }
    onWidthChanged: {
        const grid = calcGridLayout(gridModel.count);
        const itemSize = calcItemSize(root, grid.columnCount, gridModel.count, gridSpacing);
        const containerSize = calcContainerSize(itemSize, gridSpacing, grid.columnCount, grid.rowCount);
        rootContainer.width = containerSize.width;
        rootContainer.height = containerSize.height;
        updateItemsPosition(itemSize, gridSpacing, grid, gridModel);
    }

    Timer {
        id: fetchMemberTimer
        interval: 10
        repeat: false
        running: false

        onTriggered: {
            membersManager.getMembersPaging(pageSize, currentPage);
        }
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
                    highQuality: !SettingsManager.remoteVideoResolution ? (model.index > 3 ? false : true) : true
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

            onClicked: membersManager.getMembersPaging(pageSize, currentPage - 1)
        }
        CustomToolButton {
            id: nextPage
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            direction: CustomToolButton.Direction.Right
            height: 60
            width: 60

            onClicked: membersManager.getMembersPaging(pageSize, currentPage + 1)
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
            const grid = calcGridLayout(secondaryMembers.length);
            const itemSize = calcItemSize(root, grid.columnCount, secondaryMembers.length, gridSpacing);
            const containerSize = calcContainerSize(itemSize, gridSpacing, grid.columnCount, grid.rowCount);
            rootContainer.width = containerSize.width;
            rootContainer.height = containerSize.height;
            calcItemsPosition(secondaryMembers, itemSize, gridSpacing, grid, gridModel);
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
