import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Mode 1.0

Popup {
    id: root

    modal: true

    width: parent.width * 0.6
    height: 180

    signal selectMode(int mode)

    background: Rectangle {
        anchors.fill: parent

        radius: 10

        border.width: 2
        border.color: "red"

        color: "#5379b5"

        Text {
            text: qsTr("Select mode")

            font.pixelSize: 30
            color: "white"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
        }

        RowLayout {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            spacing: 20

            Button {
                Layout.fillWidth: true

                onClicked: {
                    selectMode(Mode.Friend)
                    close()
                }

                background: Rectangle {
                    radius: 10
                    color: "#adb9cc"
                    opacity: parent.down || !parent.enabled ? 0.5 : 1

                    Text {
                        text: qsTr("Friend")

                        anchors.centerIn: parent

                        font.pixelSize: 20
                        color: "black"
                    }

                    implicitWidth: 200
                    implicitHeight: 70
                }
            }

            Button {
                Layout.fillWidth: true

                onClicked: {
                    selectMode(Mode.Bot)
                    close()
                }

                background: Rectangle {
                    radius: 10
                    color: "#adb9cc"
                    opacity: parent.down || !parent.enabled ? 0.5 : 1

                    Text {
                        text: qsTr("Bot")

                        anchors.centerIn: parent

                        font.pixelSize: 20
                        color: "black"
                    }

                    implicitWidth: 200
                    implicitHeight: 70
                }
            }

            Button {
                Layout.fillWidth: true

                onClicked: {
                    close()
                    selectMode(Mode.Online)
                }

                background: Rectangle {
                    radius: 10
                    color: "#adb9cc"
                    opacity: parent.down || !parent.enabled ? 0.5 : 1

                    Text {
                        text: qsTr("Online")

                        anchors.centerIn: parent

                        font.pixelSize: 20
                        color: "black"
                    }

                    implicitWidth: 200
                    implicitHeight: 70
                }
            }
        }
    }

}
