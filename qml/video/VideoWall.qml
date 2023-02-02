import QtQuick 2.11
import "../../js/axxon.js" as Axxon
import MyQMLEnums 13.37

Item{
    anchors.fill: parent
    property int cid: -1

    property string live: "live"

    property int dy
    property int dx

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

            request_URL(multivm.get_cids(),lcl.serviceId,dt)
        }
    }



    Component.onCompleted: {

        root.frash_URL.connect(f_current_camera_update)
        multivm.give_me_a_camera.connect(give_him_a_camera)

        root.cameraList.updated.connect(camera_storage.update_from_cameraList)
        camera_storage.add_to_space.connect(f_change_camera)

    }





    function request_URL(cameraId, serviceId, dt){
        Axxon.request_URL(multivm.videowall_id,cameraId, serviceId, dt,"utc")
    }


    function f_current_camera_update(){
        console.log("f_current_camera_update")
        update_vm()
    }

    function  update_vm()    {

        var cids =  multivm.get_cids()
        for(var one in cids)
        {
            var id=cids[one]
            var lcl=Axxon.camera(id)


            //    preset_list.clear_model()
            //    Tlmtr.preset_info()

            //   Tlmtr.capture_session()
            //   timer.start()

            //        v1.tform1.xScale =1
            //        v1.tform1.yScale =1

            multivm.set_Scale(1);

            multivm.vm_start(id,lcl.liveStream,Mode.LiveStreaming)



        }
    }




}
