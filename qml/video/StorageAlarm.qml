import QtQuick 2.4
import "../../js/axxon.js" as Axxon
import MyQMLEnums 13.37
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4
Item{
    id: base
    anchors.fill: parent
    property int cid: -1

    property string live: "live"
    property string storage: "storage"

    property int dy
    property int dx


    property string storage_live: ""





SplitView{
    anchors.fill:parent
    orientation: Qt.Vertical

    MultiVM{
        id: multivm
        width: parent.width
        Layout.fillWidth: true
        Layout.fillHeight: true


    }

    Rectangle {
        id: bottom_panel
        width: parent.width
        height: 100
        Layout.maximumHeight: 100
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "green"


       MyProgressBar{
            id: timeline
            calendar: calendar
            anchors.fill: parent
        }
}

    }


Rectangle {

    id: calendar_rect
    x:100
    y:100
    width: 300
    height: 300
    color: "gray"

    Calendar {
        id: calendar

        width: parent.width
        height: parent.height-10
        x:0
        y:10

        minimumDate: new Date(2021, 01, 1)
        selectedDate: new Date()
        Drag.active: calendar_rect_area.drag.active
        Drag.hotSpot.x: 10
        Drag.hotSpot.y: 10


    }
    MouseArea {
        id: calendar_rect_area
        width: parent.width
        height: 10
        x:0
        y:0
        drag.target: parent
    }
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
            if(storage_live==storage){
                dt=timeline.current_dt()

            }

         //   root.deviceSelected(panePosition,lcl.sid,lcl.id)
         //   timeline.set_camera_zone(lcl.name)

            multivm.set_current_cid(cid)

            request_URL(multivm.get_cids(),lcl.serviceId,dt)
        }
    }



    Component.onCompleted: {

        timeline.to_live()
        storage_live=live


        root.frash_URL.connect(f_current_camera_update)
        multivm.give_me_a_camera.connect(give_him_a_camera)

        root.cameraList.updated.connect(camera_storage.update_from_cameraList)
        camera_storage.add_to_space.connect(f_change_camera)

        timeline.moved_at_dt.connect(f_moved_at_dt)


        timeline.show_or_hide_calendar.connect(f_show_or_hide_calendar)

        root.update_intervals.connect(timeline.update_slider_intervals)

          timeline.livestream_button_clicked.connect(f_set_live_play)


    }

    function f_set_live_play()    {

        storage_live=live
        update_vm()
        Axxon.request_intervals(cid,Axxon.camera(cid).serviceId)
    }

    function f_moved_at_dt(dt){
        storage_live=storage
        request_URL(multivm.get_cids(),Axxon.camera(cid).serviceId,dt)
    }

    function  f_show_or_hide_calendar()
    {
        if(calendar.enabled==true)
        {
            calendar.enabled=false
            calendar_rect.visible=false
            calendar_rect_area.enabled=false
        }
        else
        {
            calendar.enabled=true
            calendar_rect.visible=true
            calendar_rect_area.enabled=true
        }
    }





    function request_URL(cameraId, serviceId, dt){
        if(dt==""){
        storage_live=live
        }
        Axxon.request_URL(multivm.videowall_id,cameraId, serviceId, dt,"utc")
    }


    function f_current_camera_update(videowall){

 console.log("f_current_camera_update")
 console.log("videowall: ",videowall)
 console.log("multivm.videowall_id: ",multivm.videowall_id)

     if(videowall!==multivm.videowall_id){
         console.log("это не та стена")
         return
     }


        update_vm()
    }

    function add_camera(id){

    console.log("storage wall: add_camera: ",id)

      multivm.add_camera(id)
        cid = id
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

            console.log("storage_live: ",storage_live)

            if(storage_live===live){

            multivm.set_Scale(1);
            multivm.vm_start(id,lcl.liveStream,Mode.LiveStreaming)

            }else  if(storage_live===storage){

                multivm.set_Scale(1);
                multivm.vm_start(id,lcl.storageStream,Mode.StorageStreaming)


            }



        }
    }




}
