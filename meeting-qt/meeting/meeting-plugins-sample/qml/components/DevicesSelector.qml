import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import NEMeeting 1.0

Rectangle {
    ColumnLayout {
        id: devicesContainer
        anchors.fill: parent
        spacing: 0
        Label { text: qsTr('Playout devices: ') }
        ComboBox {
            Layout.fillWidth: true
            textRole: "deviceName"
            valueRole: "deviceId"
            currentIndex: {
                return nemDevices.currentPlayoutIndex
            }

            model: NEMDeviceModel {
                id: listModel
                deviceController: nemDevices
                deviceType: NEMDevices.DEVICE_TYPE_PLAYOUT
            }
            onActivated: {
                nemDevices.selectDevice(NEMDevices.DEVICE_TYPE_PLAYOUT, currentValue)
            }
        }
        Label { text: qsTr('Record devices: ') }
        ComboBox {
            Layout.fillWidth: true
            textRole: "deviceName"
            valueRole: "deviceId"
            currentIndex: {
                return nemDevices.currentRecordIndex
            }
            model: NEMDeviceModel {
                deviceController: nemDevices
                deviceType: NEMDevices.DEVICE_TYPE_RECORD
            }
            onActivated: {
                nemDevices.selectDevice(NEMDevices.DEVICE_TYPE_RECORD, currentValue)
            }
        }
        Label { text: qsTr('Capture devices: ') }
        ComboBox {
            Layout.fillWidth: true
            textRole: "deviceName"
            valueRole: "deviceId"
            currentIndex: {
                return nemDevices.currentCaptureIndex
            }
            model: NEMDeviceModel {
                deviceController: nemDevices
                deviceType: NEMDevices.DEVICE_TYPE_CAPTURE
            }
            onActivated: {
                nemDevices.selectDevice(NEMDevices.DEVICE_TYPE_CAPTURE, currentValue)
            }
        }
    }
}
