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
    property string pause: "pause"
    property string play: "play"

    property int dy
    property int dx



    property string storage_live: ""
    property string pause_play: ""

    signal switch_tlmtr


    Timer {
        id: update_intervals_timer
        interval: 5000; running: true; repeat: true
        onTriggered:
        {
            if(cid!=-1)
                Axxon.request_intervals(cid,Axxon.camera(cid).serviceId)
        }
    }

    SplitView{
        anchors.fill:parent
        orientation: Qt.Vertical

        SplitView{
            width: parent.width
            orientation: Qt.Horizontal
            Layout.fillWidth: true
            Layout.fillHeight: true

        MultiVM{
            id: multivm
            width: parent.width
            Layout.fillWidth: true
            Layout.fillHeight: true


        }


        Rectangle {
            id: timelist_rect

            width: 110
            height: 700
            Layout.maximumWidth: 110
            color: "green"
            TimeList{
                id: timelist
            }
        }

    }

        Rectangle {
            id: timeline_rect
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

    Rectangle {

        id: tlmt_rect
        x:100
        y:100
        width: 260
        height: 710
        color: "gray"

        Rectangle {
            id: telemetry_menu

            width: 260
            height: 700
            y:10

            //  color: "lightgray"
            color: "green"
            Column{
                height: parent.height

                Preset_List{
                    id: preset_list
                    width: 260
                    height: parent.height-telemetry.height

                }

                Test_Telemetry{
                    id: telemetry

                    width: 260
                    height: 160


                }
            }
        }
        MouseArea {
            id: tlmtr_rect_area
            width: parent.width
            height: 10
            x:0
            y:0
            drag.target: parent
        }
    }

    Rectangle{
        width:40
        height: 40

        x:parent.width-45
        y:parent.height-45

        opacity: 1

        color:"#00000000"

        Image {


            source: "/qml/video/fullsize.png"
            anchors.fill: parent
            visible: true
        }

        MouseArea{
            anchors.fill: parent

            onClicked: {

               if(timelist_rect.width==0){
               timelist_rect.width=110
               }else{
               timelist_rect.width=0
               }

               if(timeline_rect.height==0){
               timeline_rect.height=100
               }else{
               timeline_rect.height=0
               }

               multivm.rescale(multivm.scale)



            }
        }
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
        timeline.paused_and_moved_at_dt.connect(f_paused_and_moved_at_dt)
        timeline.show_or_hide_calendar.connect(f_show_or_hide_calendar)
        timeline.livestream_button_clicked.connect(f_set_live_play)
        timeline.play_signal.connect(f_play)
        timeline.pause_signal.connect(f_pause)

        calendar.pressed.connect(to_update_intervals_handler_and_go_to_this_dt)


        root.update_intervals.connect(update_slider_intervals)

        multivm.selected_cid.connect(send_signal_selected_sid)

        multivm.switch_tlmtr.connect(f_switch_tlmtr)

        timelist.send_time.connect(timeline.set_time)
        timeline.update_timelist.connect(timelist.set_current)


        calendar.enabled=false
        calendar_rect.visible=false
        calendar_rect_area.enabled=false

        storage_live=live
        pause_play=play

        tlmt_rect.visible=false

        multivm.rescale(multivm.scale)
    }

    function f_switch_tlmtr(){
        console.log("storageAlarm f_switch_tlmtr")
        base.switch_tlmtr()
        tlmt_rect.visible=!tlmt_rect.visible
    }


    function send_signal_selected_sid(id){
        cid=id
        if(cid!=-1)
            Axxon.request_intervals(cid,Axxon.camera(cid).serviceId)
    }

    function update_slider_intervals(){

        timeline.update_slider_intervals(Axxon.get_intervals(cid))
    }

    function f_play(){
        pause_play=play
        request_URL(multivm.get_cids(),Axxon.camera(cid).serviceId,timeline.current_dt())
    }

    function f_pause(){
        pause_play=pause
        multivm.vm_stop()
    }

    function f_paused_and_moved_at_dt(){
        f_pause()
        pause_play=pause
        f_moved_at_dt(timeline.current_dt())
    }

    function to_update_intervals_handler_and_go_to_this_dt()
    {
        var dt=timeline.current_dt()
        storage_live=storage
        timeline.to_storage()
        var lcl=Axxon.camera(cid)
        request_URL(multivm.get_cids(),lcl.serviceId,dt)

    }

    function f_set_live_play()    {

        storage_live=live
        pause_play=play
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

        if(!Axxon.check_id(id)){
            return
        }

        multivm.add_camera(id)
        cid = id
    }

    function  update_vm()    {

        var cids =  multivm.get_cids()
        for(var one in cids)
        {
            var id=cids[one]
            var lcl=Axxon.camera(id)
            if(pause_play==pause)
            {

                if(storage_live==storage)
                {
                    //vm.source=lcl.snapshot

                    multivm.vm_start(id,lcl.snapshot,Mode.Snapshot)

                }
                else
                    if(storage_live==live)
                    {
                        multivm.vm_stop()
                        //vm.stop()

                    }
            }
            else
                if(pause_play==play)
                {
                    if(storage_live==storage)
                    {

                        multivm.vm_start(id,lcl.storageStream,Mode.StorageStreaming)

                    }
                    else
                        if(storage_live==live)
                        {
                            //preset_list.clear_model()
                            //Tlmtr.preset_info()

                            // Tlmtr.capture_session()
                            // timer.start()
                            //        multivm.tform1.xScale =1
                            //        multivm.tform1.yScale =1
                            multivm.set_Scale(1);





                            //    vm.source=lcl.liveStream
                            //    vm.start()


                            multivm.vm_start(id,lcl.liveStream,Mode.LiveStreaming)
                        }

                }
        }
    }
}
