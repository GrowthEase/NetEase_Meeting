import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NetEase.Meeting.MoreItemModel 1.0

Popup {
    id: root
    height: itemsContainer.height + 10
    width: globalWidth
    padding: 5
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0
    margins: 0
    background: Rectangle {
        radius: 4
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
    }

    property int globalWidth: 210
    property int insetWidth: 200

    Component.onCompleted: {
    }

    Rectangle {
        id: itemsContainer
        height: listView.count * 32
        width: insetWidth
        radius: 4
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

        MoreItemModel {
            id: listModel
            itemManager: moreItemManager
        }

        ListView {
            id: listView
            model: moreItemManager.moreItemInjected ? listModel : null
            height: count * 32
            delegate: ItemDelegate {
                id: delegate
                width: insetWidth
                height: 32
                background: Rectangle {
                    anchors.fill: parent
                    color: hovered ? "#0000000" : "transparent"
                }
                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    clip: true
                    spacing: 0
                    Image {
                        source: getItemImage(model.itemImage)
                        visible: model.itemImage.length > 0
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18
                        Layout.leftMargin: 8
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Label {
                        text: model.itemTitle
                        font.pixelSize: 14
                        color: '#FFFFFF'
                        Layout.leftMargin: 8
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
                onClicked: {
                    moreItemManager.clickedItem(model.itemGuid)
                    root.close()
                }
            }
        }
    }

    function getItmesCount() {
        return listView.count
    }

    function getItemImage(imagePath) {
        if ('' === imagePath) {
           return ''
        } else if (imagePath.startsWith('qrc:/') || imagePath.startsWith(':/')) {
            return imagePath
        }

        return "image://localImage/" + imagePath
    }
}
