import QtQuick 2.11
import QtQuick.Window 2.11
import "qml/video" as Video
import Qt.labs.settings 1.0
Item{
    anchors.fill: parent

    property int panePosition

        Video.VideoWall{
            id: videowall
            anchors.fill: parent


          }



    Component.onCompleted:{





        videowall.switch_tlmtr.connect(f_switch_tlmtr)

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
