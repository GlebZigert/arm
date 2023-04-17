import QtQuick 2.11
import QtQuick.Window 2.11
import "qml/video" as Video
import Qt.labs.settings 1.0
Item{
    anchors.fill: parent
    property int panePosition


        Video.StorageAlarm{
            id: alarmWindow
            anchors.fill: parent
            maxScale: 3

          }

 onPanePositionChanged: root.videoPane=panePosition
    Component.onCompleted:{



root.eventSelected.connect(eventSelected_handler)


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

    function eventSelected_handler(){
     //   console.log("OnlyStorageAlarm eventSelected_handler ")
     //   console.log("userSettings.videoMode: ",userSettings.videoMode)
     //   console.log("root.videopane: ",root.videoPane)
        if(userSettings.videoMode==1){
            if(root.videoPane>-1){
                root.activePane=root.videoPane
            }
        }
    }

}
