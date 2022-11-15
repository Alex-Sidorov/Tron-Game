import QtQuick.Window 2.15
import QtQuick 2.0
import QtQml 2.12
import QtQuick.Controls 2.15

import Way 1.0
import Mode 1.0

Window {
    id: app

    width: 640
    height: 640
    visible: true
    title: qsTr("TRON")

    visibility: "Maximized"

    property int maxX: 0
    property int maxY: 0

    property real widthLine: 3

    Component.onCompleted: {
        modePopup.open()

        maxX = gameManager.MAX_X
        maxY = gameManager.MAX_Y
    }

    function resetRound() {
        chartView.clearAll()
        gameManager.resetRound()
    }

    function resetGame() {
        chartView.clearAll()
        gameManager.resetGame();
    }

    ModePopup {
        id: modePopup

        onSelectMode: {
            gameManager.mode = mode
            resetGame()
        }

        onClosed: {
            keyItem.focus = true
        }

        anchors.centerIn: parent
    }

    Header {
       id: header
    }

    Rectangle {
        id: messageArea
        anchors.fill: parent
        anchors.topMargin: 60
        color: "black"
        opacity: 0.4
        visible: !timer.running

        z:1

        Text {
            id: messageText
            text: gameManager.mode != -1 ? qsTr("Tab Enter for start") : qsTr("Select mode")
            color: "white"
            font.pixelSize: 25
            anchors.centerIn: parent
        }
    }

    Item {
        id:keyItem

        focus: true

        enabled: gameManager.mode !== -1

        Keys.onPressed: {

            var key = event.key

            if(key === Qt.Key_Return || key === Qt.Key_Enter)
                timer.running = !timer.running

            if(!timer.running)
                return

            /*if(key === Qt.Key_Escape)
                timer.running = !timer.running*/

            var firstWay = gameManager.firstWay

            if(key === Qt.Key_W  && firstWay !== Way.Down)
                firstWay = Way.Up
            else if (key === Qt.Key_D && firstWay !== Way.Left)
                firstWay = Way.Right
            else if (key === Qt.Key_S && firstWay !== Way.Up)
                firstWay = Way.Down
            else if (key === Qt.Key_A && firstWay !== Way.Right)
                firstWay = Way.Left

            gameManager.firstWay = firstWay

            if(gameManager.mode !== Mode.Friend)
                return

            var secondWay = gameManager.secondWay

            if (key === Qt.Key_Up && secondWay !== Way.Down)
                secondWay = Way.Up
            else if (key === Qt.Key_Right && secondWay !== Way.Left)
                secondWay = Way.Right
            else if (key === Qt.Key_Down && secondWay !== Way.Up)
                secondWay = Way.Down
            else if (key === Qt.Key_Left && secondWay !== Way.Right)
                secondWay = Way.Left

            gameManager.secondWay = secondWay
        }
    }

    Timer {
        id: timer

        running: false
        repeat: true

        interval: 20

        onTriggered: {

            if(chartView.first.count && !gameManager.updatePoints(chartView.first, gameManager.firstWay)) {

                timer.running = false
                resetRound()

                ++gameManager.secondPoints

            } else if(!chartView.first.count)
                chartView.first.append(0, maxY / 2)

                if(chartView.second.count && !gameManager.updatePoints(chartView.second, gameManager.secondWay)) {

                timer.running = false
                resetRound()

                ++gameManager.firstPoints

            } else if(!chartView.second.count)
                chartView.second.append(maxX, maxY / 2)
        }
    }

    Arena {
        id: chartView

        anchors.fill: parent
        anchors.leftMargin: -10
        anchors.rightMargin: -10
        anchors.bottomMargin: -10
        anchors.topMargin: 50
    }
}
