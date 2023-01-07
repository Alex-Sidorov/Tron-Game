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

        gameManager.resetArea.connect(chartView.clearAll)

        client.connectSuccessfully.connect(connectedSuccessfully);
        client.disconnectedFromHost.connect(disconnectedFromHost);
        client.waitingPlayer.connect(waitingPlayer);
        client.waitConnect.connect(waitConnection);
        client.newPoints.connect(addPoints)
        client.startGame.connect(startGame)
        client.errorConnectToHost.connect(()=>
                                          {
                                              gameManager.isRun = false
                                              console.log("error connection")
                                              gameManager.mode = Mode.None
                                              modePopup.open()
                                          })
    }

    Component.onDestruction: {
        gameManager.resetArea.disconnect(chartView.clearAll)
    }

    function startGame() {
        gameManager.isRun = true
    }

    function disconnectedFromHost() {
        console.log("disconnected")
    }

    function waitingPlayer() {
        messageText.text = qsTr("Waiting player")
        console.log("waiting player")
    }

    function waitConnection() {
        messageText.text = qsTr("Wait connection")
        console.log("wait connection")
    }

    function connectedSuccessfully() {
        messageText.text = qsTr("Connected to server")
        console.log("connected")
    }

    function addPoints(first, second) {
        chartView.first.append(first.x, first.y)
        chartView.second.append(second.x, second.y)
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

            if(gameManager.mode == Mode.Online)
                client.disconnectFromHost()

            if(mode == Mode.Online) {
                client.connectToHost()
            }else if(mode == Mode.Friend || mode == Mode.Bot)
                messageText.text = qsTr("Tab Enter for start")
            else
                messageText.text = qsTr("Select mode")

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
        visible: !gameManager.isRun

        z:1

        Text {
            id: messageText
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

            if(/*gameManager.isRun &&*/ gameManager.mode === Mode.Online)
                onlineNavigation(key)
            else
                offlineNavigation(key)

        }

        function onlineNavigation(key) {

            /*if(key === Qt.Key_Return || key === Qt.Key_Enter)
                gameManager.isRun = !gameManager.isRun

            if(!gameManager.isRun)
                return*/

            var way = client.curWay

            if(key === Qt.Key_W  && way !== "down")
                client.curWay = "up"
            else if (key === Qt.Key_D && way !== "left")
                client.curWay = "right"
            else if (key === Qt.Key_S && way !== "up")
                client.curWay = "down"
            else if (key === Qt.Key_A && way !== "right")
                client.curWay = "left"

            client.sendWay(client.curWay)
        }

        function offlineNavigation(key) {

            if(key === Qt.Key_Return || key === Qt.Key_Enter)
                gameManager.isRun = !gameManager.isRun

            if(!gameManager.isRun)
                return

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

        running: gameManager.isRun && gameManager.mode === Mode.Friend
        repeat: true

        interval: 20

        onTriggered: {
            gameManager.gameIteration(chartView.first, chartView.second)
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
