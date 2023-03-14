import QtQuick 2.11
import QtQuick.Window 2.11
import "qml/video" as Video
import Qt.labs.settings 1.0
Item{
    anchors.fill: parent




    Window {

        id: wnd1

        x: settings.x1
        y:settings.y1
        visibility: settings.visibility1
        title: "Видеостена"



      //  screen: Qt.application.screens[0]

        width: Screen.width
        height: Screen.height
  //      minimumHeight: Screen.height
   //     minimumWidth:Screen.width
   //     maximumHeight: Screen.height
  //      maximumWidth   :Screen.width



        visible: true
   //     property alias visibility: "FullScreen"



        Video.VideoWall{
            id: videowall
            anchors.fill: parent
            wnd: wnd1

        }

        Component.onCompleted: {
        console.log("wnd1 onCompleted: ",wnd1.x," ",wnd1.y," ",settings.x1," ",settings.y1)

            wnd1.x =   settings.x1
            wnd1.y =   settings.y1
            wnd1.visibility =   wnd1.visibility === 0 ? 2 :wnd1.visibility
        }
    }


    Window {

 id: wnd2


 x: settings.x2
 y:settings.y2
 visibility: settings.visibility2

 title: "Тревоги / архив"


        width: Screen.width
        height: Screen.height
   //     minimumHeight: Screen.height
  //      minimumWidth:Screen.width
  //      maximumHeight: Screen.height
  //      maximumWidth   :Screen.width




        visible: true
           //  property alias visibility: "FullScreen"

        screen: Qt.application.screens[1]

        Video.StorageAlarm{
            id: alarmWindow
            anchors.fill: parent
            wnd: wnd2
          }

        Component.onCompleted: {
        console.log("wnd2 onCompleted: ",wnd2.x," ",wnd2.y," ",settings.x2," ",settings.y2)

         wnd2.x =   settings.x2
         wnd2.y =   settings.y2
         wnd2.visibility =   wnd2.visibility === 0 ? 2 :wnd2.visibility
        }
    }


    EventLog{
        anchors.fill: parent
    }

    Settings {
        id: settings
        property alias x1: wnd1.x
        property alias y1: wnd1.y
        property alias visibility1: wnd1.visibility
        property alias x2: wnd2.x
        property alias y2: wnd2.y
        property alias visibility2: wnd2.visibility
    }

    Component.onCompleted:{

        console.log("settings-->")
        console.log(settings.x1)
        console.log(settings.y1)
        console.log(settings.visibility1)
        console.log(settings.x2)
        console.log(settings.y2)
        console.log(settings.visibility2)
        console.log("<--settings")

    console.log("Экраны: ",wnd1.screen," ",wnd2.screen)

        videowall.open_in_alarm_window.connect(alarmWindow.add_camera)

        videowall.switch_tlmtr.connect(f_switch_tlmtr)
        alarmWindow.switch_tlmtr.connect(f_switch_tlmtr)

        console.log("Экраны: ",
                    Qt.application.screens[0].virtualX," ",
                    Qt.application.screens[0].virtualY," ",
                    Qt.application.screens[1].virtualX," ",
                    Qt.application.screens[1].virtualY," "
                    )







    }

    function f_switch_tlmtr(){
    console.log("f_switch_tlmtr")
    }

    Component.onDestruction: {
        settings.x1 = wnd1.x
        settings.y1 = wnd1.y
        settings.visibility1 = (wnd1.visibility === 0 ? 2 :wnd1.visibility)
        settings.x2 = wnd2.x
        settings.y2 = wnd2.y
        settings.visibility2 =  (wnd2.visibility === 0 ? 2 :wnd2.visibility)
        console.log("settings-->")
        console.log(settings.x1)
        console.log(settings.y1)
        console.log(settings.visibility1)
        console.log(settings.x2)
        console.log(settings.y2)
        console.log(settings.visibility2)
        console.log("<--settings")
    }


}
