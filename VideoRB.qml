import QtQuick 2.11
import QtQuick.Window 2.11
import "qml/video" as Video

Item{
    anchors.fill: parent


    Window {

        id: videowall
        x: 100
        y: 100
        width: 1000
        height: 800

        visible: true
        visibility: "FullScreen"

         screen: Qt.application.screens[1]

        Video.VideoWall{

            anchors.fill: parent

        }
    }

/*
    Window {

        id: alarmWindow
        x: 100
        y: 100
        width: 1000
        height: 800

        visible: true
        visibility: "FullScreen"

         screen: Qt.application.screens[1]
    }
    */

    EventLog{
        anchors.fill: parent
    }
}
