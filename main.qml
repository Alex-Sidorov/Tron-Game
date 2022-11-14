import QtQuick.Window 2.15
import QtQuick 2.0
import QtCharts 2.0
import QtQml 2.12

Window {
    width: 640
    height: 640
    visible: true
    title: qsTr("TRON")

    visibility: "Maximized"

    property int firstWay: 1
    property int secondWay: 3

    property int maxX: 100
    property int maxY: 100

    property real step: 0.5

    property real widthLine: 3

    property var hash: new Set()

    property int firstWonCount: 0
    property int secondWonCount: 0

    /*onFirstWayChanged: {
        console.log("first: " + firstWay)
    }

    onSecondWayChanged: {
        console.log("second: " + secondWay)
    }*/

    function resetRound() {
        first.clear()
        second.clear()

        firstWay = 1
        secondWay = 3

        hash.clear()
    }

    function updatePoints(series, way) {

        var point = series.at(series.count - 1)

        switch (way) {
        case 0:
            point.y += step
            break

        case 1:
            point.x += step
            break

        case 2:
            point.y -= step
            break

        case 3:
            point.x -= step
            break

        default: break
        }

        if(point.x > maxX) {

            series.append(point.x + 10, point.y)
            series.append(point.x, maxY + 10)
            series.append(-10, maxY + 10)
            series.append(-10, point.y)

            point.x = 0

        } else if(point.x < 0) {

            series.append(-10, point.y)
            series.append(-10, maxY + 10)
            series.append(maxX + 10, maxY + 10)
            series.append(maxX + 10, point.y)

            point.x = maxX
        }

        if(point.y > maxY) {

            series.append(point.x , maxY + 10)
            series.append(maxX + 10, maxY + 10)
            series.append(maxX + 10, -10)
            series.append(point.x, -10)

            point.y = 0

        } else if(point.y < 0) {

            series.append(point.x , -10)
            series.append(maxX + 10, -10)
            series.append(maxX + 10, maxY + 10)
            series.append(point.x, maxY + 10)

            point.y = maxY
        }

        /*if(point.x > maxX || point.x < 0 || point.y > maxY || point.y < 0)
            return false*/

        if(hash.has( point ))
            return false

        series.append(point.x, point.y)
        hash.add(point)

        return true
    }

    Rectangle {
        width: parent.width
        height: 60
        color: "grey"
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
            text: qsTr("Tab Enter for start")
            color: "white"
            font.pixelSize: 25
            anchors.centerIn: parent
        }
    }

    Item {

        focus: true

        Keys.onPressed: {

            if(event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                timer.running = !timer.running

            if(!timer.running)
                return

            if(event.key === Qt.Key_W && firstWay !== 2)
                firstWay = 0
            else if (event.key === Qt.Key_D && firstWay !== 3)
                firstWay = 1
            else if (event.key === Qt.Key_S && firstWay !== 0)
                firstWay = 2
            else if (event.key === Qt.Key_A && firstWay !== 1)
                firstWay = 3
            else if (event.key === Qt.Key_Up && secondWay !== 2)
                secondWay = 0
            else if (event.key === Qt.Key_Right && secondWay !== 3)
                secondWay = 1
            else if (event.key === Qt.Key_Down && secondWay !== 0)
                secondWay = 2
            else if (event.key === Qt.Key_Left && secondWay !== 1)
                secondWay = 3
            /*else if(event.key === Qt.Key_Escape)
                timer.running = !timer.running*/
        }
    }

    Timer {
        id: timer

        running: false
        repeat: true

        interval: 20

        onTriggered: {

            if(first.count && !updatePoints(first, firstWay)) {

                timer.running = false
                resetRound()

                ++secondWonCount

            } else if(!first.count)
                first.append(0, maxY / 2)

            if(second.count && !updatePoints(second, secondWay)) {

                timer.running = false
                resetRound()

                ++firstWonCount

            } else if(!second.count)
                second.append(maxX, maxY / 2)
        }
    }

    Text {
        id: score
        text: qsTr("Score " + firstWonCount + " : " + secondWonCount)

        font.pixelSize: 25

        color: "white"

        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ChartView {
        id: chartView

        anchors.fill: parent
        anchors.leftMargin: -10
        anchors.rightMargin: -10
        anchors.bottomMargin: -10
        anchors.topMargin: 50

        animationOptions: ChartView.NoAnimation
        antialiasing: true
        legend.visible: false
        backgroundColor: "#22274f"
        backgroundRoundness: 0

        property bool openGL: true

        ValueAxis {
            id: axisY
            min: 0
            max: maxY

            visible: false
            gridVisible: false
            labelsVisible: false
        }


        ValueAxis {
            id: axisX
            min: 0
            max: maxX

            gridVisible: false
            visible: false
            labelsVisible: false
        }

        LineSeries {
            id: first
            useOpenGL: chartView.openGL
            axisY: axisY
            axisX: axisX
            color: "red"
            width: widthLine

            /*onPointAdded: {
                console.log("first point:" + first.at(first.count - 1))
            }*/
        }

        LineSeries {
            id: second
            axisY: axisY
            axisX: axisX
            useOpenGL: chartView.openGL
            color: "yellow"
            width: widthLine

            /*onPointAdded: {
                console.log("second point:" + second.at(second.count - 1))
            }*/
        }
    }
}
