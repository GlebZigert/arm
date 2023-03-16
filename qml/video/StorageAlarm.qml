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

    property var wnd

    property string storage_live: ""
    property string pause_play: ""

    signal switch_tlmtr


    onVisibleChanged: {

        if(visible==true){
        rescale(1)
        }

    }

    Timer {
        id: start_timer
        interval: 500; running: true; repeat: false

        onTriggered:
        {
             multivm.to_page(0)
        //    multivm.rescale()
            if(multivm.get_cids().length){
            request_URL(multivm.get_cids(),Axxon.camera(multivm.get_cids()[0]).serviceId,"")
            }


    }
    }

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

    /*
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

            fullscreen_signal()



            }
        }
    }
    */

    function fullscreen()  {



        console.log("visibility: ",wnd.visibility)

        if(wnd.visibility===5){
        wnd.visibility=1
        }else{
                         wnd.visibility=5
        }
        multivm.rescale_timer_start()
/*
    if(timelist_rect.width==0){
       timelist_rect.width=110
    timeline_rect.height=100
    }else{
    timeline_rect.height=0
    timelist_rect.width=0
    }
    */


   // multivm.rescale(multivm.scale)



 }


    function give_him_a_camera(){
        console.log("give_him_a_camera()")
        camera_storage.visible=true
    }

    function f_change_camera(id){
        console.log("f_change_camera ",id)
        cid=id

        if(id!==-1 && multivm.get_current_page_name()==="Архив"){
            var lcl
            lcl=Axxon.camera(id)
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
            timeline.set_camera_zone(lcl.name,lcl.ipadress)


        }else{
            if(id===-1 && multivm.get_current_page_name()!=="Архив"){
        timeline.set_camera_zone("","")
            }
        }
    }



    Component.onCompleted: {

            timeline.storageAlarm_edition()


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
      //  timeline.pause_signal.connect(f_paused)
          timeline.pause_signal.connect(f_paused_and_moved_at_dt)

        calendar.pressed.connect(to_update_intervals_handler_and_go_to_this_dt)


        root.update_intervals.connect(update_slider_intervals)

        multivm.selected_cid.connect(send_signal_selected_sid)

        multivm.switch_tlmtr.connect(f_switch_tlmtr)

        timelist.send_time.connect(timeline.set_time)
        timeline.update_timelist.connect(timelist.set_current)

        root.event_on_camera.connect(f_event_on_camera)

        root.eventSelected.connect(eventSelected_handler)

        multivm.ready.connect(update_vm)

        calendar.enabled=false
        calendar_rect.visible=false
        calendar_rect_area.enabled=false

        storage_live=live
        pause_play=play

        tlmt_rect.visible=false

        multivm.rescale(multivm.scale)

        multivm.onCompleted.connect(set_the_multivm_settings)

        timeline.to_storage_cameras.connect(f_to_storage_cameras)

        timeline.fullscreen_signal.connect(fullscreen)

        timeline.signal_scale.connect(scale)

        timeline.hide_timelines.connect(hide_timelines)
    }

    function scale(){
    multivm.next_scale()
    }

    function f_to_storage_cameras(){
        if(multivm.get_current_page_name()==="Тревоги"){
        multivm.to_page("Архив")
            timeline.set_to_storage_cameras_text("К тревогам")
        }else{
        multivm.to_page("Тревоги")
                        timeline.set_to_storage_cameras_text("Вернуться к просмотру камер")
        }


    }

    function set_the_multivm_settings(){
        console.log("set_the_multivm_settings")
        multivm.setVid("storageAlarm")
        multivm.multivm_add_page("Тревоги")
        multivm.multivm_add_page("Архив")

        multivm.to_page("Архив")

        multivm.rescale(1)

    }

    function eventSelected_handler(event){

        var lcl = event




        var commands =  JSON.parse(event.commands)

        console.log("StorageAlarm eventSelected_handler")

        var cids=[]




        var dt=event.timeString

        dt= dt.substring(6,10)+
                dt.substring(3,5)+
                dt.substring(0,2)+
                "T"+
                dt.substring(11,13)+
                dt.substring(14,16)+
                dt.substring(17,19)+
                ".000000"


        var cids=[]
        for(var i=0;i<commands.length;i++){

       //   console.log(i," ...  ",commands[i][1])
            cids.push(commands[i][1])


        }
        timeline.set_to_storage_cameras_text("К тревогам")
        multivm.add_storage_camera(cids)

    timeline.set_sliders_and_calendar_from_current_datetime_value(dt)
        storage_live=storage
        request_URL(multivm.get_cids(),Axxon.camera(commands[0][1]).serviceId,dt)
      /*
        var str=event.commands


        str=str.replace(/(\[)/g, "")
        str=str.replace(/(\])/g,"")
        var arr=str.split(",",4)

        var serviceId=arr[0]
        var id=arr[1]
        var cameraId="";



        root.storage_live=storage
        cid=id

        console.log("    ")
        console.log(dt)
        console.log("    ")



        var lcl=Axxon.camera(cid)
        telemetry.set_serviceId(lcl.serviceId)
        preset_list.serviceId=lcl.serviceId
        root.log("telemetryControlID: ",lcl.telemetryControlID)
        root.telemetryPoint=lcl.telemetryControlID



        timeline.set_sliders_and_calendar_from_current_datetime_value(dt)
        Axxon.request_URL(v1.get_cids(),Axxon.camera(id).serviceId,dt,"utc")
        */

    }

    function f_event_on_camera(id){


            storage_live=live
            pause_play=play
            timeline.to_live()

            timeline.set_to_storage_cameras_text("Вернуться к просмотру камер")

            multivm.add_alarm_camera(id)
            //Для мультвм выставляем флаг тревожного режима
            //При переходе в тревожный режим чистим его модель
            //добавляем видеоплеер

         //   f_change_camera(id)



    }

    function f_switch_tlmtr(){
        console.log("storageAlarm f_switch_tlmtr")
        base.switch_tlmtr()
        tlmt_rect.visible=!tlmt_rect.visible
    }


    function send_signal_selected_sid(id){
        cid=id
        if(cid!=-1){
            Axxon.request_intervals(cid,Axxon.camera(cid).serviceId)
            timeline.set_camera_zone(Axxon.camera(cid).name,Axxon.camera(cid).ipadress)

        }else{
         timeline.set_camera_zone("","")
        }

    }

    function update_slider_intervals(){
        console.log("update_slider_intervals for cid: ",cid)
        timeline.update_slider_intervals(Axxon.get_intervals(cid))
    }

    function f_play(){
        pause_play=play
        request_URL(multivm.get_cids(),Axxon.camera(cid).serviceId,timeline.current_dt())
    }

    function f_paused(){
        pause_play=pause
        multivm.vm_stop()
    }

    function f_paused_and_moved_at_dt(){
        pause_play=pause
        multivm.vm_stop()
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
        Axxon.request_URL(multivm.vid,cameraId, serviceId, dt,"utc")
    }


    function f_current_camera_update(videowall){

        console.log("f_current_camera_update")
        console.log("videowall: ",videowall)
        console.log("multivm.vid: ",multivm.vid)

        if(videowall!==multivm.vid){
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

        multivm.add_camera(id,false)
        multivm.save()
        cid = id
    }

    function hide_timelines(){

        console.log("hide_timelines")
        timeline_rect.height=0
        timelist_rect.width=0
        multivm.rescale()
    }

    function  update_vm()    {

        var cids =  multivm.get_cids()
        for(var one in cids)
        {
            var id=cids[one]
            var lcl=Axxon.camera(id)

            console.log("lcl: ",lcl.id
                        ," "<<lcl.name
                        ," "<<lcl.liveStream
                        ," "<<lcl.storageStream
                        ," "<<lcl.snapshot
                       )

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
        multivm.save()
    }
}
