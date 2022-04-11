import QtQuick 2.0
import QtMultimedia 5.11
import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5


import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1

import VideoPlayer 1.0
//import MyPlayer 1.0
import "qml/video" as Video

import "js/axxon_telemetry_control.js" as Tlmtr
import "js/axxon.js" as Axxon

//Another player

Item{
    id: srv
    anchors.fill: parent
    property int panePosition
    property var video: ({
        'Loaded_cameras': Qt.createComponent('qml/video/Loaded_cameras.qml'),
        'Test_Telemetry': Qt.createComponent('qml/video/Test_Telemetry.qml'),
        'TimeList': Qt.createComponent('qml/video/TimeList.qml'),
        'newServiceForm': Qt.createComponent('qml/video/ServiceForm.qml')
    })
    property string telemetryControlID: ""
    property int current_cameraId: -1
    property int current_serviceId: -1

    property var current
    property bool telemetry_on_off_value: false

    signal show_videoWall()

    property string pause_play
    property string pause: "pause"
    property string play: "play"
    property string storage_live
    property string storage: "storage"
    property string live: "live"
    property bool interfase_visible: false

    property int cid

    onPanePositionChanged: {

        root.videoPane=panePosition

    }


    Timer {
        id:timer
        interval: 5000; running: false; repeat: true
        onTriggered:
        {
            if((root.storage_live===live)&&(root.pause_play===play))
            {
                Tlmtr.hold_session()
                timer.start()
            }
            else
            {
                timer.stop()
            }
        }
    }

    Timer {
        id:zoom_timer
        interval: 300; running: false; repeat: false
        property int msec:0
        onTriggered:
        {
            //root.log("zoom_timer_timeout")
            Tlmtr.stop_zoom()
            vm_area.zoom_prev=0
        }
    }

    Timer {
        id: update_intervals_timer
        interval: 5000; running: true; repeat: true
        onTriggered:
        {
            if(current_cameraId!="")
            Axxon.request_intervals(cid,Axxon.camera(cid).serviceId)
        }
    }



SplitView{
    anchors.fill:parent
    orientation: Qt.Vertical

SplitView{
    width: parent.width
    Layout.fillWidth: true
    Layout.fillHeight: true
    orientation: Qt.Horizontal

  Rectangle {
      id:r2
      width: 50
      Layout.maximumWidth: 300

      DevicesTree{
      anchors.fill: parent
      }

  }

   Rectangle {
        id:rect
        width: parent.width-timeline.width-telemetry_menu.width-eventlog.width
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "lightblue"
        clip: true

   Rectangle { color: "lightgray";
        id:vm_rect
        anchors.fill: parent
        clip:true

        VideoPlayer{
            id: vm
            x:(parent.width- width)/2
            width: (height/1080)*1920
            height: parent.height
            transform: Scale {
               id: tform1
            }

           MouseArea {
               id: vm_area
               anchors.fill: parent
               property double factor: 2.0
               hoverEnabled: true
               property int x_prev
               property int y_prev
               property int val_prev
               property int mouseX_prev
               property int mouseY_prev

               onPressed: {
                    if((root.storage_live==live)&&(root.pause_play==play)){

                    var mx=mouseX-parent.width/2
                    var my=parent.height/2-mouseY
                    var arctn=Math.abs(Math.atan(my/mx))
                    move(mx,my)
                    }
               }

               Timer {
                   id:stop_moving_timer
                   interval: 100; running: false; repeat: false
                   property int msec:0
                   onTriggered:
                   {
                       Tlmtr.stop_moving()
                       vm_area.x_prev=0
                       vm_area.y_prev=0
                   }
               }

               onReleased: {
                    if((root.storage_live==live)&&(root.pause_play==play)){
                   stop_moving_timer.start()
}
               }


               function move(mx,my)
               {

               var value=Math.sqrt(mx*mx+my*my)

               var val=0
                   if(value===0)
                       val=0

                   if(value>0.4)
                       val=0.5

                   if(value>0.4)
                       val=0.5

                   if(value>0.9)
                       val=1

                   var arctn=Math.abs(Math.atan(my/mx))

                   var x=0
                   var y=0
                      if(arctn<0.2)
                      {
                          if(value>0.9)
                                             rect.color="red"
                                         else
                           if(value>0.4)
                          rect.color="yellow"
                           else
                            rect.color="lightgray"

                          if(mx>0)
                          {
                         x=1
                         y=0

                          }
                          else
                          {
                              x=-1
                              y=0
                          }
                      }
                      else
                      if(arctn<1.3)

                      { if(value>0.9)
                              rect.color="green"
                          else
                                          if(value>0.4)
                                              rect.color="lightgreen"
                                          else
                                           rect.color="lightgray"

                          if(my>0)
                          {
                              if(mx>0)
                              {
                                  x=1
                                  y=1
                              }
                              else
                              {
                                  x=-1
                                  y=1
                              }
                          }
                          else
                          {
                              if(mx>0)
                              {
                                  x=1
                                  y=-1
                              }
                              else
                              {
                                  x=-1
                                  y=-1
                              }
                          }





                      }
                      else
                      {          if(value>0.9)
                              rect.color="blue"
                          else
                                                         if(value>0.4)
                                                        rect.color="lightblue"
                                                         else
                                                          rect.color="lightgray"

                          if(my>0)
                          {
                              x=0
                              y=1
                          }
                          else
                          {
                              x=0
                              y=-1
                          }
                      }
                      if((x_prev!=x)||(y_prev!=y)||(val_prev!=val))
                      {

                          var str=""
                          str=String(x)
                          str=str+" "
                          str=str+String(y)
                          str=str+" "
                          str=str+String(val)
                          str=str+" "



                          Tlmtr.move(str)


                      x_prev=x
                      y_prev=y
                      val_prev=val
                      }
               }


               onEntered: {

               }
               property int zoom: 0
               property int zoom_prev: 0
               onWheel:
               {
                   if((root.storage_live==live)&&(root.pause_play==play)){

                     if(wheel.angleDelta.y > 0)  // zoom in
                         zoom=1
                     else                        // zoom out
                         zoom=-1

                     if(zoom_prev!=zoom)
                     {
                         if (zoom==1)
                         {
                         Tlmtr.zoom_in()
                         }
                         if (zoom==-1)
                         {
                         Tlmtr.zoom_out()
                         }
                     }
                     zoom_prev=zoom
                     zoom_timer.stop()
                     zoom_timer.start()
                   }
                   else
                   {
                   if(wheel.angleDelta.y > 0)  // zoom in
                       var zoomFactor = factor
                   else                        // zoom out
                       zoomFactor = 1/factor

                   if(!(tform1.xScale *zoomFactor<1))
                   {
                    if(wheel.angleDelta.y > 0)
                    {
                       var realX = wheel.x * tform1.xScale
                       var realY = wheel.y * tform1.yScale
                       vm.x += (1-zoomFactor)*realX
                       vm.y += (1-zoomFactor)*realY
                       tform1.xScale *=zoomFactor
                       tform1.yScale *=zoomFactor
                     }
                    else
                    {
                        var realX = wheel.x * tform1.xScale
                        var realY = wheel.y * tform1.yScale

                        tform1.xScale *=zoomFactor
                        tform1.yScale *=zoomFactor


                        vm.x += (1-zoomFactor)*realX
                        vm.y += (1-zoomFactor)*realY

                        if(tform1.xScale==1)
                        {

                        vm.x =(vm_rect.width- (vm_rect.height/1080)*1920)/2
                        vm.y =0

                        root.log("rect.x ", vm.x )
                        root.log("rect.y ",vm.y )
                        }
                    }
                   }
               }
           }
           }

       }

       Timer{
       id: delay_timer
       interval: 100; running: false; repeat: false

       onTriggered:
       {

       }


       }


       MouseArea{
       anchors.fill:parent
       propagateComposedEvents: true

       onPressed: {
       delay_timer.start()
       mouse.accepted=false
       }

       onReleased: {

           if(delay_timer.running)
           {

               if(srv.interfase_visible)
               {
               bottom_panel.height=0
               timelist_rect.width=0
               }
               else
               {
               bottom_panel.height=160
               timelist_rect.width=100
               }
               srv.interfase_visible=!srv.interfase_visible
           }

       mouse.accepted=false

       }
       }
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

   MouseArea{
       anchors.fill:parent
        hoverEnabled: true
       propagateComposedEvents: true
       property int flag: 0


                onClicked: {
                flag=1
                }

                onMouseXChanged: {

mouse.accepted = false
                }

   }
   }

      Rectangle {
          id: timelist_rect

                         width: 110
                         height: 700
                         Layout.maximumWidth: 110
                         color: "green"
                         Video.TimeList{
                         id: timelist
                     }
      }

      Rectangle {
          id: telemetry_menu

                         width: 260
                         height: 700
                         Layout.maximumWidth: 260
                       //  color: "lightgray"
                         color: "green"
Column{
    height: parent.height

    Video.Preset_List{
        id: preset_list
        width: 260
        height: parent.height-telemetry.height

    }

    Video.Test_Telemetry{
id: telemetry

width: 260
height: 160
Layout.minimumHeight: 160
Layout.maximumHeight: 160

}
}
    }

      Rectangle{
      id: eventlog
      width: 700
      height: parent.height

      EventLog{
      anchors.fill: parent
      }

      }
 }
   Rectangle {
       id: bottom_panel
       width: parent.width
       height: 100
       Layout.maximumHeight: 100
   color: "green"

             Video.MyProgressBar{
             id: timeline
             calendar: calendar
             anchors.fill: parent
             }
 }

}

Timer {
    id:another_user_timer
    interval: 5000; running: false; repeat: false
    property int msec:0
    onTriggered:
    {
        another_user_rect.visible=false
    }
}

Rectangle {
id: another_user_rect
x:10
y:10
width: 500
height: 100
color:"lightblue"
visible:false
opacity: 50

Text {
    id: another_user_text
    anchors.fill: parent
    text: "123"
    font.family: "Helvetica"
    font.pointSize: 24
    color: "black"
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
            maximumDate: new Date(2022, 05, 1)
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

srv.hide_or_show_menu()

}
}
}


Component.onCompleted: {

    Axxon.get_service_id()
    root.log("Axxon.get_serviceId(): ",Axxon.get_serviceId())
    hide_menu()
    show_menu()
    timeline.to_live()
    root.event_on_camera.connect(f_event_on_camera)
    timeline.moved_at_dt.connect(f_moved_at_dt)
    timeline.paused_and_moved_at_dt.connect(f_paused_and_moved_at_dt)
    timeline.livestream_button_clicked.connect(f_set_live_play)
    timeline.play_signal.connect(f_play)
    timeline.pause_signal.connect(f_pause)
    timelist.send_time.connect(timeline.set_time)
    timeline.tree_on_off.connect(f_tree_on_off)
    camera_storage.add_to_space.connect(f_change_camera)
    root.update_intervals.connect(timeline.update_slider_intervals)
    timeline.show_or_hide_calendar.connect(f_show_or_hide_calendar)
    timeline.signal_telemetry_on_off.connect( f_telemetry_on_off)
    timeline.signal_loaded_cameras_on_off.connect(f_loaded_cameras_on_off)
    timeline.eventlog_on_off.connect( f_eventlog_on_off)
    vm.playing.connect(start_timer_if_its_needed)
    timeline.update_timelist.connect(timelist.set_current)
    calendar.pressed.connect(to_update_intervals_handler_and_go_to_this_dt)
    root.cameraList.updated.connect(reconnect_livestream)
    root.frash_URL.connect(f_current_camera_update)
    root.eventSelected.connect(eventSelected_handler)
    root.another_user.updated.connect(show_another_user)
    calendar.enabled=false
    calendar_rect.visible=false
    calendar_rect_area.enabled=false
    telemetry_on_off_value=false
    root.storage_live=live
    root.pause_play=play

}

function start_timer_if_its_needed(){
    if ( play==root.pause_play){
    timeline.timer_start()
    }
}

function to_update_intervals_handler()
{
    var x=root.update_intervals.get(0)
    timeline.update_slider_intervals(x.m_intervals)
}

function to_update_intervals_handler_and_go_to_this_dt()
{
    var dt=timeline.current_dt()
    root.storage_live=storage
    timeline.to_storage()
    var lcl=Axxon.camera(cid)
    request_URL(lcl.id,lcl.serviceId,dt)

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

function hide_or_show_menu()
{
     if(srv.interfase_visible)
     {
  hide_menu()

     }
     else
     {
       show_menu()
     }
}

function f_event_on_camera(id){

 if( !(
    (root.storage_live==live)&&
    (root.pause_play==play)&&
    (cid==id)
           ))
 {

 root.storage_live=live
 root.pause_play=play
 timeline.to_live()
 f_change_camera(id)
 }

}

function f_change_camera(id){

    cid=id
    var lcl
    lcl=Axxon.camera(cid)
    root.axxon_service_id=lcl.sid
    root.log(lcl.name)
    configPanel.state="hide"

    telemetry.set_serviceId(lcl.serviceId)
    preset_list.serviceId=lcl.serviceId

    root.log("telemetryControlID: ",lcl.telemetryControlID)
    root.telemetryPoint=lcl.telemetryControlID

    var dt=""
    if(root.storage_live==storage){
        dt=timeline.current_dt()

    }
    timeline.set_camera_zone(lcl.name)
    request_URL(lcl.id,lcl.serviceId,dt)
}

function reconnect_livestream(){
  camera_storage.update_from_cameraList()

}

function f_current_camera_update(){
    var lcl
    lcl=Axxon.camera(cid)
    update_vm()
}

function f_tree_on_off(){
    if(r2.width>0)
        r2.width=0
    else
        r2.width=200
}

function show_menu(){

    bottom_panel.height=160
    timelist_rect.width=110
    srv.interfase_visible=true
}

function hide_menu(){

    bottom_panel.height=0
    telemetry_menu.width=0
    timelist_rect.width=0
    eventlog.width=0
    configPanel.state="hide"
    calendar.enabled=false
    calendar_rect.visible=false
    calendar_rect_area.enabled=false
    r2.width=0
    srv.interfase_visible=false
}

function f_loaded_cameras_on_off(){
    if(configPanel.state=="show"){
        configPanel.state="hide"
    }else{
        configPanel.state="show"
    }
}

function f_play(){
    root.pause_play=play
    request_URL(cid,Axxon.camera(cid).serviceId,timeline.current_dt())
}

function f_pause(){
    root.pause_play=pause
    vm.stop()
}

function f_paused_and_moved_at_dt(dt){
    f_pause()
    root.pause_play=pause
    f_moved_at_dt(dt)
}


function f_moved_at_dt(dt){
    root.storage_live=storage
    request_URL(cid,Axxon.camera(cid).serviceId,dt)
}

function request_URL(cameraId, serviceId, dt){
    Axxon.request_URL(cameraId, serviceId, dt,"utc")
}

function f_set_live_play()
{
    root.log("[f_set_live_play]")
    root.storage_live=live
    root.pause_play=play
    var dt=""
    update_vm()
    Axxon.request_intervals(cid,Axxon.camera(cid).serviceId)
}

function  update_vm(id)
 {
    var lcl=Axxon.camera(cid)
   if(root.pause_play==pause)
     {

     if(root.storage_live==storage)
         {
         vm.source=lcl.snapshot
         vm.shot()

         }
     else
     if(root.storage_live==live)
         {
        vm.stop()

         }
     }
 else
 if(root.pause_play==play)
     {
     if(root.storage_live==storage)
         {
         vm.source=lcl.storageStream
         vm.start()

         }
     else
     if(root.storage_live==live)
         {
         preset_list.clear_model()
         Tlmtr.preset_info()

         Tlmtr.capture_session()
         timer.start()
         tform1.xScale =1
         tform1.yScale =1
         root.log("live")
         vm.source=lcl.liveStream
         vm.start()
         }

     }
 }

function f_telemetry_on_off(){
if(telemetry_on_off_value)
{
    telemetry_menu.width=0
    }
    else
    {
    telemetry_menu.width=260
    }
    telemetry_on_off_value=!telemetry_on_off_value

}

function show_another_user(message){

   var user=root.another_user.get(0)
    another_user_text.text=user.message
    another_user_rect.visible=true
    another_user_timer.start()
}

function eventSelected_handler(event){

    var str=event.commands
    str=str.replace(/(\[)/g, "")
    str=str.replace(/(\])/g,"")
    var arr=str.split(",",4)

    var serviceId=arr[0]
    var id=arr[1]
    var cameraId="";

    var dt=event.timeString

    dt= dt.substring(6,10)+
        dt.substring(3,5)+
        dt.substring(0,2)+
        "T"+
        dt.substring(11,13)+
        dt.substring(14,16)+
        dt.substring(17,19)+
        ".000000"

    root.storage_live=storage
    cid=id

    var lcl=Axxon.camera(cid)
    telemetry.set_serviceId(lcl.serviceId)
    preset_list.serviceId=lcl.serviceId
    root.log("telemetryControlID: ",lcl.telemetryControlID)
    root.telemetryPoint=lcl.telemetryControlID

    timeline.set_sliders_and_calendar_from_current_datetime_value(dt)
    Axxon.request_URL(cid,Axxon.camera(id).serviceId,dt,"utc")

}

function f_eventlog_on_off(){
    if(eventlog.width>0)
       eventlog.width=0
        else
       eventlog.width=700

}

}





