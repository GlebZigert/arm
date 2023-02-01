import QtQuick 2.11
import "../../js/axxon.js" as Axxon


Item{
    anchors.fill: parent
    property int cid: -1

    MultiVM{
        id: multivm
        anchors.fill: parent
    }

    Loaded_cameras {
        anchors.fill: parent
        id: camera_storage
        visible: false
    }


    function give_him_a_camera(){
        console.log("give_him_a_camera()")
        camera_storage.visible=true
    }

    function f_change_camera(id){

        cid=id
        var lcl
        lcl=Axxon.camera(id)
        if(lcl!==-1){
            root.axxon_service_id=lcl.sid
            root.log(lcl.name)
         //   configPanel.state="hide"

         //   telemetry.set_serviceId(lcl.sid)
         //   preset_list.serviceId=lcl.sid

         //   root.log("telemetryControlID: ",lcl.telemetryControlID)
         //   root.telemetryPoint=lcl.telemetryControlID

            var dt=""

         //   root.deviceSelected(panePosition,lcl.sid,lcl.id)
         //   timeline.set_camera_zone(lcl.name)

            multivm.set_current_cid(cid)

            request_URL(v1.get_cids(),lcl.serviceId,dt)
        }
    }



    Component.onCompleted: {

        multivm.give_me_a_camera.connect(give_him_a_camera)
        root.cameraList.updated.connect(camera_storage.update_from_cameraList)
        camera_storage.add_to_space.connect(f_change_camera)
    }




}
