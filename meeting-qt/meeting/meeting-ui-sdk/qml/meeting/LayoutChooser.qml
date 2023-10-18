import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NetEase.Meeting.MeetingStatus 1.0

Popup {
    id: root
    enum VideoLayout {
        FocusTopToBottom,
        FocusLeftToRight,
        Gallery
    }

    property int current: LayoutChooser.VideoLayout.FocusTopToBottom
    property bool enableGallery: true
    property bool enableFocusLeftToRight: true

    function startClose() {
        closeTimer.start();
    }
    function stopClose() {
        closeTimer.stop();
    }

    height: 166
    padding: 24
    width: 336

    background: Rectangle {
        color: "#33333F"
        radius: 10
    }

    Component.onCompleted: {
    }
    onClosed: {
        root.closePolicy = Popup.CloseOnEscape | Popup.CloseOnPressOutside;
    }

    MouseArea {
        id: idInfomation
        anchors.centerIn: parent
        height: parent.height + 50
        hoverEnabled: true
        width: parent.width + 50

        onExited: {
            closeTimer.stop();
            close();
        }
    }
    Timer {
        id: closeTimer
        interval: 1000
        repeat: false

        onTriggered: {
            if (!idInfomation.containsMouse) {
                close();
            }
        }
    }
    RowLayout {
        anchors.centerIn: parent
        spacing: 16

        MouseArea {
            Layout.preferredHeight: galleryLayout.childrenRect.height
            Layout.preferredWidth: galleryLayout.childrenRect.width
            cursorShape: enableGallery ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: {
                if (!enableGallery)
                    return;
                current = LayoutChooser.VideoLayout.Gallery;
            }
            ColumnLayout {
                id: galleryLayout
                spacing: 15

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    font.weight: 400
                    opacity: 0.6
                    text: qsTr("Gallery view")
                }
                Image {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 49
                    Layout.preferredWidth: 76
                    source: {
                        if (!enableGallery)
                            return "qrc:/qml/images/meeting/layout_gallery_disabled.svg";
                        if (current === LayoutChooser.VideoLayout.Gallery)
                            return "qrc:/qml/images/meeting/layout_gallery_highlight.svg";
                        return "qrc:/qml/images/meeting/layout_gallery_white.svg"
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter

                    Image {
                        Layout.preferredHeight: 16
                        Layout.preferredWidth: 16
                        source: {
                            if (!enableGallery)
                                return "qrc:/qml/images/public/icons/icon_option_unchecked_disabled.svg"
                            if (current === LayoutChooser.VideoLayout.Gallery)
                                return "qrc:/qml/images/public/icons/icon_option_checked.svg"
                            else
                                return "qrc:/qml/images/public/icons/icon_option_unchecked.svg"
                        }
                    }
                    Label {
                        color: current === LayoutChooser.VideoLayout.Gallery ? "#337EFF" : (enableGallery ? "#FFFFFF" : "gray")
                        font.pixelSize: 14
                        font.weight: 400
                        text: qsTr("Gallery")
                    }
                }
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.topMargin: 35
            color: "#FFFFFF"
            opacity: 0.2
            width: 1
        }
        ColumnLayout {
            spacing: 15

            Label {
                Layout.alignment: Qt.AlignHCenter
                color: "#FFFFFF"
                font.pixelSize: 14
                font.weight: 400
                opacity: 0.6
                text: qsTr("Focus view")
            }
            RowLayout {
                spacing: 16
                MouseArea {
                    Layout.preferredHeight: focusLayout.childrenRect.height
                    Layout.preferredWidth: focusLayout.childrenRect.width
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        current = LayoutChooser.VideoLayout.FocusTopToBottom;
                    }

                    ColumnLayout {
                        spacing: 15

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredHeight: 49
                            Layout.preferredWidth: 76
                            source: current === LayoutChooser.VideoLayout.FocusTopToBottom ? "qrc:/qml/images/meeting/layout_focus_top_to_bottom_highlight.svg" : "qrc:/qml/images/meeting/layout_focus_top_to_bottom_white.svg"
                        }
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                Layout.preferredHeight: 16
                                Layout.preferredWidth: 16
                                source: current === LayoutChooser.VideoLayout.FocusTopToBottom ? "qrc:/qml/images/public/icons/icon_option_checked.svg" : "qrc:/qml/images/public/icons/icon_option_unchecked.svg"
                            }
                            Label {
                                color: current === LayoutChooser.VideoLayout.FocusTopToBottom ? "#337EFF" : "#FFFFFF"
                                font.pixelSize: 14
                                font.weight: 400
                                text: qsTr("Top list")
                            }
                        }
                    }
                }
                MouseArea {
                    Layout.preferredHeight: focusLayout.childrenRect.height
                    Layout.preferredWidth: focusLayout.childrenRect.width
                    cursorShape: enableFocusLeftToRight ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: {
                        if (!enableFocusLeftToRight)
                            return;
                        current = LayoutChooser.VideoLayout.FocusLeftToRight;
                    }

                    ColumnLayout {
                        id: focusLayout
                        spacing: 15

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredHeight: 49
                            Layout.preferredWidth: 76
                            source: {
                                if (!enableFocusLeftToRight)
                                    return "qrc:/qml/images/meeting/layout_focus_left_to_right_disabled.svg";
                                if (current === LayoutChooser.VideoLayout.FocusLeftToRight)
                                    return "qrc:/qml/images/meeting/layout_focus_left_to_right_highlight.svg";
                                return "qrc:/qml/images/meeting/layout_focus_left_to_right_white.svg";
                            }
                        }
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                Layout.preferredHeight: 16
                                Layout.preferredWidth: 16
                                source: {
                                    if (!enableFocusLeftToRight)
                                        return "qrc:/qml/images/public/icons/icon_option_unchecked_disabled.svg"
                                    if (current === LayoutChooser.VideoLayout.FocusLeftToRight)
                                        return "qrc:/qml/images/public/icons/icon_option_checked.svg"
                                    else
                                        return "qrc:/qml/images/public/icons/icon_option_unchecked.svg"
                                }
                            }
                            Label {
                                color: current === LayoutChooser.VideoLayout.FocusLeftToRight ? "#337EFF" : (enableFocusLeftToRight ? "#FFFFFF" : "gray")
                                font.pixelSize: 14
                                font.weight: 400
                                text: qsTr("Right list")
                            }
                        }
                    }
                }
            }
        }
    }
}
