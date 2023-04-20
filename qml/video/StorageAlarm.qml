import QtQuick 2.4
import "../../js/axxon.js" as Axxon
import MyQMLEnums 13.37
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4
import StreamerContainer_QML_accesser 1.0
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



    property int maxScale

    signal switch_tlmtr
   // visible: false

    StreamerContainer_QML_accesser{
    id: accesser
    }

    ListModel{
        id: alarms

    }



    onVisibleChanged: {

        if(visible==true){
       multivm.rescale(1)
        }

    }

    Timer {
        id: start_timer
        interval: 1000; running: false; repeat: false

        onTriggered:
        {
                 console.log("storagealarm_start_timer ",)

            if(multivm.get_cids().length){


                if( Axxon.camera(multivm.get_cids()[0]).serviceId){
            request_URL(multivm.get_cids(),Axxon.camera(multivm.get_cids()[0]).serviceId,"","")
            }else{
            start_timer.start(1000)
            }
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
            quality: "low"

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
        width: 265
        height: 711
        color: "gray"

        border.width: 1
        border.color: "black"

        Rectangle {
            id: telemetry_menu

            width: 260
            height: 700
            x:1
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

        if(id!==-1 ){
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

            var res =[]
            res.push(id)
            multivm.vm_start(id,lcl.livestream_low,StreamType.Streaming)
            request_URL(res,lcl.serviceId,dt,"higth")


            timeline.set_camera_zone(lcl.name,lcl.ipadress)


        }else{

        timeline.set_camera_zone("","")

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
        timeline.pause_signal.connect(f_paused)
          timeline.pause_signal.connect(f_paused_and_moved_at_dt)
timeline.pause_signal.connect(f_paused)

        calendar.pressed.connect(to_update_intervals_handler_and_go_to_this_dt)

        multivm.stream_request.connect(stream_request)
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

      //  root.cameraList.updated.connect(f_start_timer_start)
    }

    function f_start_timer_start(){
        base.visible=true

         multivm.to_page("Тревоги")
        multivm.rescale()
    start_timer.start()
    }
    function stream_request(id,quality){
      //  console.log("storageAlarm stream_request ",id," ",quality," ",storage_live)
           var res =[]
           res.push(id)
            var serviceId=Axxon.camera(id).serviceId
       //  multivm.vm_start(id,Axxon.camera(id).livestream_low,StreamType.Streaming)
          if(storage_live===storage){

           Axxon.request_URL(multivm.vid,res, serviceId, timeline.current_dt(),"utc",quality)
          }else{

              if(quality=="higth"){
            multivm.vm_start(id,Axxon.camera(id).livestream_low,StreamType.Streaming)
            multivm.vm_start(id,Axxon.camera(id).livestream_higth,StreamType.Streaming)
              }else{
             multivm.vm_start(id,Axxon.camera(id).livestream_low,StreamType.Streaming)
              }

          }


    }

    function scale(){
    multivm.next_scale()
    }

    function f_to_storage_cameras(){


    }

    function set_the_multivm_settings(){
        console.log("set_the_multivm_settings")
        multivm.setVid("storageAlarm")
        multivm.multivm_delete_page("1") ;
        multivm.multivm_delete_page("Тревоги")
        multivm.multivm_add_page("Тревоги",3)




        multivm.rescale(1)

    }

    function eventSelected_handler(event){

        var lcl = event



        console.log("event.commands: ",event.commands);
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

        multivm.add_storage_cameras(cids)

    timeline.set_sliders_and_calendar_from_current_datetime_value(dt)
        storage_live=storage
        request_URL(multivm.get_cids(),Axxon.camera(commands[0][1]).serviceId,dt,"higth")
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

        if(storage_live===live){


            storage_live=live
            pause_play=play
            timeline.to_live()


 //multivm.vm_start(id,Axxon.camera(id).livestream_low,StreamType.Streaming)
            multivm.add_alarm_camera(id)
        }else{
        alarms.append({cid: id})
            console.log("alarms: ",alarms.count)
            for(var i=0;i<alarms.count;i++){
            console.log(alarms.get(i).cid)
            }
            timeline.show_alarms()

        }

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
         //чистим интервалы
            timeline.clear_intervals()

        }

    }

    function update_slider_intervals(){
    //    console.log("update_slider_intervals for cid: ",cid)
        timeline.update_slider_intervals(Axxon.get_intervals(cid))
    }

    function f_play(){
        pause_play=play
        request_URL(multivm.get_cids(),Axxon.camera(cid).serviceId,timeline.current_dt(),"")
    }

    function f_paused(){
        pause_play=pause
      //  multivm.vm_stop()
    }

    function f_paused_and_moved_at_dt(){
        pause_play=pause
     //   multivm.vm_stop()
        pause_play=pause
        f_moved_at_dt(timeline.current_dt())
    }

    function to_update_intervals_handler_and_go_to_this_dt()
    {
        console.log("to_update_intervals_handler_and_go_to_this_dt")
        var dt=timeline.current_dt()
        storage_live=storage
        timeline.to_storage()
        var lcl=Axxon.camera(cid)
        request_URL(multivm.get_cids(),lcl.serviceId,dt,"higth")

    }

    function f_set_live_play()    {

        if(alarms.count>0){

            var res =[]


            for(var i = 0; i<alarms.count; i++)
            {

                var lcl = alarms.get(i).cid
                //  console.log(i," ",lcl)
                if(lcl!=-1){
                    var frash=true
                    for(var j in res){
                        if(res[j]===lcl){
                            frash=false
                        }
                    }
                    if(frash){
                        res.push(lcl)
                    }
                }
            }
            console.log("alarms ",res)


            if(res.length>0){
                multivm.add_alarm_cameras(res)
            }

            alarms.clear()
        }




        storage_live=live
        pause_play=play

          var serviceId=Axxon.camera(multivm.get_cids()[0]).serviceId

        var cids =  multivm.get_cids()
        for(var one in cids)
        {
            var id=cids[one]
             multivm.vm_start(id,Axxon.camera(id).livestream_low,StreamType.Streaming)

        }



        Axxon.request_intervals(cid,Axxon.camera(cid).serviceId)
    }

    function f_moved_at_dt(dt){
        console.log("dt: ",dt)
        storage_live=storage
        request_URL(multivm.get_cids(),Axxon.camera(cid).serviceId,dt,"")
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





    function request_URL(cameraId, serviceId, dt,quality){
        if(dt==""){
            storage_live=live
        }
        Axxon.request_URL(multivm.vid,cameraId, serviceId, dt,"utc",quality)
    }


    function f_current_camera_update(videowall){

   //     console.log("f_current_camera_update")
    //    console.log("videowall: ",videowall)
    //    console.log("multivm.vid: ",multivm.vid)

        if(videowall!==multivm.vid){
        //    console.log("это не та стена")
            return
        }


        update_vm()
    }

    function add_camera(id){

        console.log("storage wall: add_camera: ",id)

        if(!Axxon.check_id(id)){
            console.log("return")
            return
        }

        multivm.add_camera(id,false)
        multivm.save()
        cid = id
    }

    function add_storage_camera(id){
        console.log("storage wall: add_storage_camera: ",id)
        if(!Axxon.check_id(id)){
            console.log("return")
            return
        }
        //console.log("++++")

        multivm.add_storage_camera(id)
        multivm.save()
        cid = id

    }

    function hide_timelines(){

      //  console.log("hide_timelines")
        timeline_rect.height=0
        timelist_rect.width=0
        multivm.rescale()
    }

    function  update_vm()    {
     //    console.log("storagealarm update_vm")
        accesser.start()
        var cids =  multivm.get_cids()
        for(var one in cids)
        {



            var id=cids[one]
            var lcl=Axxon.camera(id)

       //     console.log("lcl: ","frash ",lcl.frash)
               if(lcl.frash){

              Axxon.clear_frash(lcl.id)





            if(pause_play==pause)
            {

                if(storage_live==storage)
                {
                    //vm.source=lcl.snapshot


                 //   if(lcl.snapshot){
                        multivm.vm_start(id,lcl.snapshot,StreamType.Snapshot)
                 //   }
                }
                else
                    if(storage_live==live)
                    {
                     //   multivm.vm_stop()
                        //vm.stop()

                    }
            }
            else
                if(pause_play==play)
                {
                    if(storage_live==storage)
                    {

                    //    if(lcl.storageStream){
                            multivm.vm_start(id,lcl.storageStream,StreamType.Storage)
                    //    }

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

                         //   if(lcl.livestream){
                                multivm.vm_start(id,lcl.liveStream,StreamType.Streaming)
                        //    }
                        }

                }
        }
        }
        multivm.save()
    }


}
