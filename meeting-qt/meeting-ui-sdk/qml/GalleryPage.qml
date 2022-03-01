import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import "components/"
import "utils/dialogManager.js" as DialogManager
import "utils/meetingHelpers.js" as MeetingHelpers

Rectangle {
    anchors.fill: parent
    color: "#000000"

    Component.onCompleted: {
        viewMode = MainPanel.ViewMode.GridViewMode
        membersManager.isGalleryView = true
        membersManager.isWhiteboardView = false
        currentPage = 1
        pageSize = membersManager.galleryViewPageSize
        membersManager.getMembersPaging(pageSize, currentPage)
    }

    Rectangle {
        id: rootContainer
        anchors.fill: parent
        anchors.margins: 8
        color: "#000000"

        onWidthChanged: {
            Qt.callLater(function () {
                membersManager.getMembersPaging(pageSize, currentPage)
            })
        }

        GridLayout {
            id: gridLayout
            anchors.centerIn: parent
            columnSpacing: 8
            rowSpacing: 8
            Repeater {
                model: ListModel {
                    id: gridModel
                }
                Rectangle {
                    Layout.preferredHeight: model.height
                    Layout.preferredWidth: model.width
                    Layout.row: model.row
                    Layout.column: model.column
                    Layout.columnSpan: 2
                    color: "#000000"
                    VideoDelegate {
                        anchors.fill: parent
                        accountId: model.accountId
                        nickname: model.nickname
                        audioStatus: model.audioStatus
                        videoStatus: model.videoStatus
                        highQuality: model.highQuality
                    }
                }
            }
        }

        CustomToolButton {
            id: previousPage
            width: 60
            height: 60
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            direction: CustomToolButton.Direction.Left
            onClicked: membersManager.getMembersPaging(pageSize, currentPage - 1)
        }

        CustomToolButton {
            id: nextPage
            width: 60
            height: 60
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            direction: CustomToolButton.Direction.Right
            onClicked: membersManager.getMembersPaging(pageSize, currentPage + 1)
        }

        Rectangle {
            id: pageSign
            width: 80
            height: 36
            radius: 19
            visible: labelPageCount.text !== "1"
            x: parent.width / 2 - width / 2
            y: parent.height - 60 //footerContainer.y - 60
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
                Label {
                    id: labelCurrentPage
                    text: currentPage.toString()
                    color: "#FFFFFF"
                }
                Label {
                    text: "/"
                    color: "#FFFFFF"
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
                shareSelector.open()
            } else {
                requestPermission.open()
            }
        }
        onShowMembers: {
            membersBar.show = !membersBar.show
            /*
            if (!membersBar.visible) {
                if(sideBarBitmask === 0){
                    if(mainWindow.visibility === Window.FullScreen || mainWindow.visibility === Window.Maximized){
                        mainWindow.width = Screen.desktopAvailableWidth
                    }
                    else{
                        mainWindow.width = defaultWindowWidth + defaultSiderbarWidth
                    }
                }

                sideBarBitmask = sideBarBitmask | 0x01;
            } else {
                if(sideBarBitmask === 0 || chatBar.visible === false){
                    if(mainWindow.visibility === Window.FullScreen || mainWindow.visibility === Window.Maximized){
                        mainWindow.width = Screen.desktopAvailableWidth
                    }
                    else{
                        mainWindow.width = defaultWindowWidth
                    }
                }
                sideBarBitmask = sideBarBitmask & 0xFE;
            }
            */
        }
        onSwitchView: {
            mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'))
        }
        onShowChatroom:{
            chatBar.show = !chatBar.show
            /*
            if (!chatBar.visible) {
                if(sideBarBitmask === 0){
                    if(mainWindow.visibility === Window.FullScreen || mainWindow.visibility === Window.Maximized ){
                        mainWindow.width = Screen.desktopAvailableWidth
                    }
                    else{
                        mainWindow.width = defaultWindowWidth + defaultSiderbarWidth
                    }
                }
                sideBarBitmask = sideBarBitmask | 0x02;

            }
            else{
                if(sideBarBitmask === 0 || membersBar.visible === false){
                    if(mainWindow.visibility === Window.FullScreen || mainWindow.visibility === Window.Maximized){
                        mainWindow.width = Screen.desktopAvailableWidth
                    }
                    else{
                        mainWindow.width = defaultWindowWidth
                    }
                }
                sideBarBitmask = sideBarBitmask & 0xFD;
            }
            */
        }
    }

    Connections {
        target: membersManager
        onMembersChanged: {
            if (!visible || shareManager.shareAccountId === authManager.authAccountId) {
                return
            }

            if (currentPage !== realPage) {
                gridModel.clear()
                currentPage = realPage;
            }
            if (realCount === 1) {
                mainLoader.setSource(Qt.resolvedUrl('qrc:/qml/FocusPage.qml'))
                return
            }
            MeetingHelpers.arrangeGridLayout(secondaryMembers, realPage, realCount, rootContainer, gridLayout, gridModel)
            previousPage.visible = currentPage > 1
            nextPage.visible = currentPage * pageSize < (realCount) // Except myself
            labelPageCount.text = (Math.ceil((realCount) / pageSize)).toString()
        }

        onNicknameChanged:{
            var rowCount = gridModel.count;
            for( var i = 0;i < rowCount;i++ ) {
                var model = gridModel.get(i);
                if(model.accountId === accountId){
                    model.nickname = nickname
                }
            }
        }
    }
}
