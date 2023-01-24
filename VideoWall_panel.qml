import QtQuick 2.0
import QtQuick.Controls 2.4
import "qml/video" as Video
Item {
    anchors.fill: parent
    Rectangle{
    anchors.fill: parent
    color: "green"
    }

    Rectangle {
        width: 300
        anchors {

            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        id: configPanel
        layer.enabled: true
        property string selected: ""
        property string selectedUrl
        property int selectedX: 0
        property int selectedY: 0
        opacity: 0.1
        color: "blue"

        Video.Loaded_cameras {
            id: camera_storage
            anchors.fill:parent
            progress_bar: timeline

        }

        states: [
            State {
                name: "show"
                PropertyChanges {
                    target: configPanel
                    opacity: 1
                    anchors.rightMargin: 0
                    width: 400
                }
            },
            State {
                name: "hide"
                PropertyChanges {
                    target: configPanel
                    opacity: 0.5
                    anchors.rightMargin: configPanel.width
                    width:0
                }
            }
        ]


    }



        Button {

            onClicked:  f_loaded_cameras_on_off()
        }


    Component.onCompleted: {

        root.cameraList.updated.connect(reconnect_livestream)
        camera_storage.add_to_space.connect(f_change_camera)
    }

    function reconnect_livestream(){
        camera_storage.update_from_cameraList()

    }

    function f_loaded_cameras_on_off(){
        if(configPanel.state=="show"){
            configPanel.state="hide"
        }else{
            configPanel.state="show"
        }
    }

    function f_change_camera(id){

                    configPanel.state="hide"
    }

}
