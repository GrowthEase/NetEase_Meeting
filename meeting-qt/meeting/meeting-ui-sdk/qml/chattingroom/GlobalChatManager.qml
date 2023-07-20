pragma Singleton

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.14
import QtQuick.Controls.Styles 1.4


Rectangle {
    id:globalChatManager

    property int chatMsgCount: 0
    signal noNewMsgNotity()

    Connections {
        target:globalChatManager
        onNoNewMsgNotity: {
            chatMsgCount = 0
        }
    }

}







