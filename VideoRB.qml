import QtQuick 2.11
import QtQuick.Window 2.11
import "qml/video" as Video

Item{
    anchors.fill: parent


    Window {


        x: 100
        y: 100
        width: 1000
        height: 800

        visible: true
        //     visibility: "FullScreen"

        screen: Qt.application.screens[1]

        Video.VideoWall{
            id: videowall
            anchors.fill: parent

        }
    }


    Window {


        x: 100
        y: 100
        width: 1000
        height: 800

        visible: true
        //    visibility: "FullScreen"

        screen: Qt.application.screens[1]

        Video.StorageAlarm{
            id: alarmWindow
            anchors.fill: parent

        }
    }


    EventLog{
        anchors.fill: parent
    }

    Component.onCompleted:{

        videowall.open_in_alarm_window.connect(alarmWindow.add_camera)

    }


}
