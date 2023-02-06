import QtQuick 2.11
import QtQuick.Window 2.11
import "qml/video" as Video

Item{
    anchors.fill: parent


    Window {


        width: Screen.width
        height: Screen.height
        minimumHeight: Screen.height
        minimumWidth:Screen.width
        maximumHeight: Screen.height
        maximumWidth   :Screen.width



        visible: true
        //     visibility: "FullScreen"

        screen: Qt.application.screens[1]

        Video.VideoWall{
            id: videowall
            anchors.fill: parent

        }
    }


    Window {



        width: Screen.width
        height: Screen.height
   //     minimumHeight: Screen.height
  //      minimumWidth:Screen.width
  //      maximumHeight: Screen.height
  //      maximumWidth   :Screen.width

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

        videowall.switch_tlmtr.connect(f_switch_tlmtr)
        alarmWindow.switch_tlmtr.connect(f_switch_tlmtr)

    }

    function f_switch_tlmtr(){
    console.log("f_switch_tlmtr")
    }


}
