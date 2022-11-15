import QtQuick 2.0
import QtCharts 2.0

ChartView {
    id: chartView

    property alias first: first
    property alias second: second

    animationOptions: ChartView.NoAnimation
    antialiasing: true
    legend.visible: false
    backgroundColor: "#22274f"
    backgroundRoundness: 0

    function clearAll() {
        first.clear()
        second.clear()
    }

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
    }

    LineSeries {
        id: second
        axisY: axisY
        axisX: axisX
        useOpenGL: chartView.openGL
        color: "yellow"
        width: widthLine
    }

    /*LineSeries { //for online
        id: third
        axisY: axisY
        axisX: axisX
        useOpenGL: chartView.openGL
        color: "green"
        width: widthLine
    }*/
}
