import QtQuick 2.0
import QtQuick.Controls 2.0

import Mode 1.0

Rectangle {
    id: header
    width: parent.width
    height: 60
    color: "grey"

    Text {
        text: qsTr("Speed")

        font.pixelSize: 15

        visible: speed.visible

        color: "white"

        anchors.horizontalCenter: speed.horizontalCenter
        anchors.bottom: speed.top
        anchors.bottomMargin: -5
    }

    Slider {
        id: speed

        enabled: !timer.running

        anchors.verticalCenterOffset: 5
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 150

        visible: gameManager.mode === Mode.Friend || gameManager.mode === Mode.Bot

        width: 150

        value: 1

        from: 1
        to: 2

        stepSize: 1

        snapMode: "SnapAlways"

        handle: Rectangle {
            x: speed.leftPadding + speed.visualPosition * (speed.availableWidth - width)
            y: speed.topPadding + speed.availableHeight / 2 - height / 2
            implicitWidth: 20
            implicitHeight: 20
            radius: 13
            color: "#f0f0f0"
        }

        onValueChanged: {
            gameManager.speed = value
            keyItem.focus = true
        }
    }

    Button {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 15

        onClicked: {
            modePopup.open()
        }

        enabled: !gameManager.isRun

        background: Rectangle {
            radius: 10
            color: "#61203d"
            opacity: parent.down || !parent.enabled ? 0.5 : 1

            Text {
                text: qsTr("Mode")

                anchors.centerIn: parent

                font.pixelSize: 20
                color: "white"
            }

            implicitWidth: 100
            implicitHeight: 40
        }
    }

    Text {
        id: score
        text: qsTr("Score " + gameManager.firstPoints + " : " + gameManager.secondPoints)

        font.pixelSize: 25

        color: "white"

        anchors.centerIn: parent
    }
}
