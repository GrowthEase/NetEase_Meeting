import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Window {
    id: mainWindow
    visible: true
    width: 780
    height: 600
    title: qsTr("NetEase Meeting SDK Sample")

    Component.onCompleted: {
        pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/Login.qml'))
        // meetingManager.initialize()
        // meetingManager.isInitializd()
    }

    ToastManager {
        id: toast
    }

    Loader {
        id: pageLoader
        anchors.fill: parent
    }

    Connections {
        target: mainWindow
        onClosing: {
            if (pageLoader.source.toString() !== 'qrc:/qml/Login.qml') {
                close.accepted = false
                meetingManager.unInitialize()
                pageLoader.setSource(Qt.resolvedUrl('qrc:/qml/Login.qml'))
                return
            }

            meetingManager.unInitialize()
            close.accepted = true
        }
    }
}
