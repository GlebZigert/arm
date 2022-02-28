import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Layouts 1.5
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtWebSockets 1.0
//import QtQuick.Controls.Material 2.11
import QtGraphicalEffects 1.0

import "qml/myvideo" as MyVideo

SplitView {
anchors.fill: parent
orientation: Qt.Vertical


Rectangle {
id: centerItem
Layout.minimumHeight: 50
height: 800
color: "lightgray"
Text {
text: "View 2"
anchors.centerIn: parent
}
//-------------------------------------
SplitView {
    anchors.fill: parent
    orientation: Qt.Horizontal
//----------------------------------------
    /*
    MyScreen {
        id:screen
         Layout.minimumWidth: 50
        Layout.maximumWidth: 1600

        Text {
            text: "View 1"
            anchors.centerIn: parent
        }
    }
    */
//----------------------------------------
    MyVideo.Space_for_streaming {
        id: space
        Layout.minimumWidth: 50
        Layout.fillWidth: true



    }

//----------------------------------------
    MyVideo.Loaded_cameras {
        id: camera_storage
    Layout.minimumWidth: 5
    Layout.maximumWidth: 300
    progress_bar: timeline


    }



//-------------------------------------

}
}
MyVideo.MyProgressBar{
    id: timeline
    width: parent.width
    Layout.minimumHeight: 200
    height: 200
}

//------------------------------------
Component.onCompleted: {
camera_storage.add_to_space.connect(space.add_camera_to_space)


    timeline.storage_play.connect(space.f_storage_play)
    timeline.storage_pause.connect(space.f_storage_pause)
    timeline.storage_stop.connect(space.f_storage_stop)
    timeline.storage_snapshot.connect(space.f_storage_snapshot)

    space.current_dt_request.connect(timeline.send_dt)
    timeline.signal_dt.connect(space.update_dt)
}

//Добавляем камеру из хранилища камер в рабочее пространство
function add_on_big_screen(name,point)
{
   root.log("Добавляю камеру :",name," ",point)
//    space.add_camera_to_space(name,point)
}

}
