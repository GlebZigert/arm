import QtQuick 2.11
import QtQuick.Window 2.11
import "qml/video" as Video
import Qt.labs.settings 1.0
Item{
    anchors.fill: parent







    Window {

 id: wnd2

 x:3840
 y:0
 visibility: "FullScreen"

 /*
 x: settings.x2
 y:settings.y2
 visibility: settings.visibility2
*/
 title: "Тревоги / архив"


        width: Screen.width
        height: Screen.height
   //     minimumHeight: Screen.height
  //      minimumWidth:Screen.width
  //      maximumHeight: Screen.height
  //      maximumWidth   :Screen.width




        visible: true
           //  property alias visibility: "FullScreen"

     //   screen: Qt.application.screens[0]

        Video.StorageAlarm{
            id: alarmWindow
            anchors.fill: parent
            wnd: wnd2
          }

        Component.onCompleted: {
        console.log("wnd onCompleted wnd2: ",wnd2.x," ",wnd2.y," ",wnd2.visibility)// settings.x2," ",settings.y2)

       //  wnd2.x =   settings.x2
      //   wnd2.y =   settings.y2
      //   wnd2.visibility =   wnd2.visibility === 0 ? 2 :wnd2.visibility
        }
    }


    EventLog{
        anchors.fill: parent
    }



    Component.onCompleted:{

        console.log("settings-->")


        console.log(settings.x2)
        console.log(settings.y2)
        console.log(settings.visibility2)
        console.log("<--settings")


        videowall.open_in_alarm_window.connect(alarmWindow.add_camera)

        videowall.switch_tlmtr.connect(f_switch_tlmtr)
        alarmWindow.switch_tlmtr.connect(f_switch_tlmtr)

        /*
        console.log("Экраны: ",
                    Qt.application.screens[0].virtualX," ",
                    Qt.application.screens[0].virtualY," ",
                    Qt.application.screens[1].virtualX," ",
                    Qt.application.screens[1].virtualY," "
                    )
        */







    }

    function f_switch_tlmtr(){
    console.log("f_switch_tlmtr")
    }



}
