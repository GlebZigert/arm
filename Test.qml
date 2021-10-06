import QtQuick 2.0
import QtQuick 2.0
import QtMultimedia 5.11
import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5


import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

import QtQuick 2.0

import "qml/video" as Video

import "js/axxon_telemetry_control.js" as Tlmtr
import "js/axxon.js" as Axxon

Item{
    id: container
    anchors.fill: parent
    property int panePosition
    property var video: ({
        'Loaded_cameras': Qt.createComponent('qml/video/Loaded_cameras.qml'),
        'Test_Telemetry': Qt.createComponent('qml/video/Test_Telemetry.qml'),
        'TimeList': Qt.createComponent('qml/video/TimeList.qml'),
        'newServiceForm': Qt.createComponent('qml/video/ServiceForm.qml')
    })
    property string telemetryControlID: ""
    property var current_cameraId: -1
    property var current_serviceId: -1


    signal show_videoWall()

    property string pause_play
    property string pause: "pause"
    property string play: "play"
    property string storage_live
    property string storage: "storage"
    property string live: "live"
    property bool interfase_visible: false

    onPanePositionChanged: {

        // console.log("panePosition: ",panePosition)
        // console.log("root.videoPane: ",root.videoPane)


        root.videoPane=panePosition
        // console.log("root.videoPane: ",root.videoPane)
    }


    Timer {
        id:timer
        interval: 5000; running: false; repeat: true
        onTriggered:
        {
        //// console.log(".")
        if((root.storage_live==live)&&(root.pause_play==play))
        {
        //console.log("+")
        Tlmtr.hold_session(current_serviceId)
        timer.start()
        }
        else
        {
            //console.log("-")
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
            //console.log("zoom_timer_timeout")
            Tlmtr.stop_zoom(current_serviceId)
            vm_area.zoom_prev=0
        }
    }

    Timer {
        id: update_intervals_timer
        interval: 5000; running: true; repeat: true
        onTriggered:
        {
           // console.log("[!!]")
            if(current_cameraId!="")
            Axxon.request_intervals(current_cameraId,current_serviceId)


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

      anchors.fill: parent
       clip:true
       Video.VM{
           id: vm

           width: parent.width
           height: parent.height

   //    accesspoint: "ASTRAAXXON/DeviceIpint.2/SourceEndpoint.video:0:0"
           //-------------
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
                   //console.log("[onPressed!!!]")

                //console.log("prev: ",mouseX_prev," ",mouseY_prev)


                   var mx=mouseX-parent.width/2
                    var my=parent.height/2-mouseY


                   var arctn=Math.abs(Math.atan(my/mx))
                       //console.log("arctn: ",arctn)
                   move(mx,my)
                    }
               }


               Timer {
                   id:stop_moving_timer
                   interval: 100; running: false; repeat: false
                   property int msec:0
                   onTriggered:
                   {
                       Tlmtr.stop_moving(current_serviceId)
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

               //console.log("-----------")
               var value=Math.sqrt(mx*mx+my*my)


              //console.log("value: ",value)

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
                //  //console.log(xx-mouseX," ",yy-mouseY)
                //  //console.log("arctn: ",arctn)
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
                      //console.log("(1)")
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
                      //console.log("(2)")
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
                      //console.log("(3)")
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

                          //console.log("[str] ",str)

                          Tlmtr.move(str,current_serviceId)
                 //console.log("[value] ", value)
                 //console.log("[",x," ",y," ",val,"]")

                      x_prev=x
                      y_prev=y
                      val_prev=val
                      }
               }


               onEntered: {
               //console.log("onEntered")
               }
               property var zoom: 0
               property var zoom_prev: 0
               onWheel:
               {
                   if((root.storage_live==live)&&(root.pause_play==play)){
                       //console.log("telemetry")

                       //console.log("---------------------" )


                     if(wheel.angleDelta.y > 0)  // zoom in
                         zoom=1
                     else                        // zoom out
                         zoom=-1

                     if(zoom_prev!=zoom)
                     {
                         if (zoom==1)
                         {
                         Tlmtr.zoom_in(current_serviceId)
                         }
                         if (zoom==-1)
                         {
                         Tlmtr.zoom_out(current_serviceId)
                         }

                     }

                     zoom_prev=zoom

                     zoom_timer.stop()
                     zoom_timer.start()





                   }
                   else
                   {

                     //console.log("---------------------" )
                   if(wheel.angleDelta.y > 0)  // zoom in
                       var zoomFactor = factor
                   else                        // zoom out
                       zoomFactor = 1/factor

           //console.log("zoomFactor ",zoomFactor )
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


                   //console.log("realX ",realX )
                   //console.log("realY ",realY )
                   //console.log("rect.x ", x )
                   //console.log("rect.y ", y )
                   //console.log("tform1.xScale ",tform1.xScale )
                   //console.log("tform1.yScale ",tform1.yScale )
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
                        vm.x =0
                        vm.y =0
                        }

                        //console.log("realX ",realX )
                        //console.log("realY ",realY )
                        //console.log("rect.x ", x )
                        //console.log("rect.y ",y )
                        //console.log("tform1.xScale ",tform1.xScale )
                        //console.log("tform1.yScale ",tform1.yScale )
                    }
                   }
               }
           }
           }
       //---------

       }

       Timer{
       id: delay_timer
       interval: 100; running: false; repeat: false

       onTriggered:
       {
           //console.log("delay timeout")
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

               if(container.interfase_visible)
               {
               bottom_panel.height=0
               timelist_rect.width=0
               }
               else
               {
               bottom_panel.height=160
               timelist_rect.width=100
               }
               container.interfase_visible=!container.interfase_visible
           }

       mouse.accepted=false

    //   request_to_turn_pause_play()
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
                    width: 300
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
       /*
       transitions: [
           Transition {
               from: "*"; to: "*"
               PropertyAnimation {
                   properties: "opacity,anchors.rightMargin,width"
                   easing.type: Easing.OutQuart
                   duration: 500
               }
           }
       ]
       */

   }

/*
   Rectangle{
   width:40
   height: 40
   color:"lightblue"
   x:parent.width-45
   y:5
   opacity: 0.2

   border.color: "gray"
       border.width: 1
       radius: 2

       Image {


           source: "/qml/video/camera_list.png"
           anchors.fill: parent
             visible: true
       }



   MouseArea{
       anchors.fill: parent

       hoverEnabled: true

                       onMouseXChanged: {
                           //console.log(".")
                                              ////console.log("configPanel show: root width: " + root.width + " mouseX: " + mouseX + "panel width: " + configPanel.width)
                            //   configPanel.state = "show"

                           f_loaded_cameras_on_off()
                               //console.log("profit")


                       }

   }
   }

   */


   MouseArea{
       anchors.fill:parent
        hoverEnabled: true
       propagateComposedEvents: true
       property int flag: 0


                onClicked: {
                flag=1
                }

                onMouseXChanged: {
                //    console.log(rect.width - mouseX," ",configPanel.width)


               //     if(flag==1)
                    /*
                    if ((rect.width - mouseX >(configPanel.width)))
                    {
                        flag=0
                        configPanel.state = "hide"
                        ////console.log("configPanel hide: root width: " + root.width + " mouseX: " + mouseX + "panel width: " + configPanel.width)
                    }
                    */
mouse.accepted = false
                }


   }



   }



      Rectangle {
          id: timelist_rect

                         width: 110
                         height: 700
                         Layout.maximumWidth: 110
               //          color: "lightblue"
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


/*
Rectangle {


  id: tlmtr_rect
            x:500
            y:500
                    width: 460
                    height: 170
                    color: "gray"

                    Row{
                  Video.Test_Telemetry{
            id: telemetry

           width: 210
           height: 160


    }

                  Rectangle{
                      y:10
                      width: 250
                      height: 160
                     Video.Preset_List{
                         id: preset_list
                         anchors.fill: parent

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
*/
}


Timer {
    id:another_user_timer
    interval: 5000; running: false; repeat: false
    property int msec:0
    onTriggered:
    {
        //console.log("zoom_timer_timeout")
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
         //   locale: Qt.locale("en_AU")

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

container.hide_or_show_menu()

    // console.log("------------------ 1")
    root.test.qwerty()
    // console.log("------------------ 2")

}
}
}


Component.onCompleted: {



   /*
     console.log("Ищем вкладку где Axxon")
//    console.log("кол-во вкладок: ",root.layouts.count)
  for (var i = 0; i < root.panes.length; i++){
      console.log(root.panes[i].symbol," ",root.panes[i].it_s_video)

      if(root.panes[i].it_s_video==1)
          root.videoPane=i+1


    }
  */

//root.videoWall_show()

hide_menu()
show_menu()

   // configPanel.state = "hide"
    //root.requestVideo.connect(request)


    timeline.moved_at_dt.connect(f_moved_at_dt)
    timeline.livestream_button_clicked.connect(f_set_live_play)
    timeline.pause_or_play.connect(f_play_or_pause)
    //request_to_turn_pause_play.connect(timeline.play_or_pause)

        timelist.send_time.connect(timeline.set_time)


 timeline.tree_on_off.connect(f_tree_on_off)

    camera_storage.add_to_space.connect(f_change_camera)

    timeline.show_or_hide_calendar.connect(f_show_or_hide_calendar)


    timeline.signal_telemetry_on_off.connect( f_telemetry_on_off)
    timeline.signal_loaded_cameras_on_off.connect( f_loaded_cameras_on_off)
    timeline.eventlog_on_off.connect( f_eventlog_on_off)

    vm.playing.connect(timeline.timer_start)
    vm.live_playing.connect(vm_live_playing_handler)

    timeline.update_timelist.connect(timelist.set_current)


  //  calendar.pressed.connect(f_current_camera_update)
calendar.pressed.connect(to_update_intervals_handler_and_go_to_this_dt)

root.camera_presets.updated.connect(update_presets)

root.current_camera.updated.connect(f_current_camera_update)

root.rtsp_stream_url.updated.connect(reconnect_livestream)


root. camera_to_livestream.updated.connect( handler_to_camera_to_livestream_updated)

root.eventSelected.connect(eventSelected_handler)


root.update_intervals.updated.connect(to_update_intervals_handler)

root.another_user.updated.connect(show_another_user)

        calendar.enabled=false
        calendar_rect.visible=false
        calendar_rect_area.enabled=false

     //   tlmtr_rect.visible=false
     //   telemetry.set_disabled()
        telemetry_on_off_value=false

       root.storage_live=live
       root.pause_play=play
        //update_vm()

//    console.log("------------------ 1")
    root.test.qwerty()
//    console.log("------------------ 2")
      }
    property bool telemetry_on_off_value: false


function vm_live_playing_handler()
{
    if(root.storage_live==live)
    if(root.pause_play==play)
    {
    timeline.to_live()
        vm.set_live_play()
    }

}

function f_tree_on_off()
{
if(r2.width>0)
    r2.width=0
else
    r2.width=200
}

function reconnect_livestream()
{
    /*
  console.log("[]")
  console.log("[]")
  console.log("[==================================================================================]")
  console.log("[]")
  console.log("[]")
  console.log("[reconnect_livestream]")
  console.log("[]")
  console.log("[]")
  console.log("[==================================================================================]")
  console.log("[]")
  console.log("[]")
  */
    for(var i=0;i< root.rtsp_stream_url.count;i++)
    {
        var x= root.rtsp_stream_url.get(i)
     //   console.log("посмотри: ",x.axxon_id," ",x.state,"      current_cameraId",current_cameraId)
        if(x.axxon_id==current_cameraId)
        {
            /*
            console.log(" ")
            console.log(" ")
            console.log(" ")
            console.log(" ")
            console.log("Камера ",x.point," изменила состояние на ",x.state," ",x.state)
            console.log(" ")
            console.log(" ")
            console.log(" ")
            console.log(" ")
*/


            if(x.state=="lost")
            {
            vm.url_livestream="NOTHING"
            vm.set_live_play()
            }

            if(x.state!="lost")
            {

                for(var j=0;j<root.current_camera.count;j++)
                {
                    var y=root.current_camera.get(j)

                                   if(x.axxon_id==y.id)
                        {
                            vm.url_livestream=y.liveStream

                        }


                    }






             if(root.pause_play==play)
             if(root.storage_live==live)
             vm.set_live_play()
            }


        }

    }

    if(root.pause_play==play)
        if(root.storage_live==live)
            {
         //   console.log("live")
            vm.set_live_play()
            }
  camera_storage.update_from_rtsp_stream_url()

}


function m_func(){
//console.log("func!!!12")

}

function f_eventlog_on_off()
{
    if(eventlog.width>0)
       eventlog.width=0
        else
       eventlog.width=700

}

function show_another_user(message){
//console.log(" ")
//    var str
//    var user=root.another_user.get(0)
//    str="Управление забрал "+user.name+" "+user.surename
//console.log(str)
//console.log(" ")
   var user=root.another_user.get(0)
    another_user_text.text=user.message
    another_user_rect.visible=true
    another_user_timer.start()
}

function to_update_intervals_handler()
{
//   console.log("[to_update_intervals_handler]")
//    console.log("root.update_intervals.count ",root.update_intervals.count)
    /*
    var i
    for(i in root.update_intervals)
    {
    console.log("i ",i)
    console.log("root.update_intervals[i] ",root.update_intervals[i])

    console.log("root.update_intervals.count ",root.update_intervals[i].m_intervals.intervals[0].begin)
    console.log("root.update_intervals.count ",root.update_intervals[i].m_intervals.intervals[0].end)
    }
*/
         var x=root.update_intervals.get(0)
    timeline.update_slider_intervals(x.m_intervals)


}

function to_update_intervals_handler_and_go_to_this_dt()
{
to_update_intervals_handler()
    var dt=timeline.current_dt()
  //  console.log(dt)
  //  console.log("[2]")
    root.storage_live=storage
    timeline.to_storage()

request_URL(current_cameraId,current_serviceId,dt)

}

function eventSelected_handler(event)
{
    vm.clear_storage_player()
//console.log("")
//console.log("[ eventSelected_handler ]")
//  console.log('Event selected', JSON.stringify(event))

    var str=event.commands
  // console.log('event.commands', str)
    str=str.replace(/(\[)/g, "")
 // console.log('event.commands', str)
    str=str.replace(/(\])/g,"")
 // console.log('event.commands', str)

    var arr=str.split(",",4)
 //   console.log(arr[0])
 //   console.log(arr[1])
 //   console.log(arr[2])
 //   console.log(arr[3])
    //Взять айди камеры и время

    var serviceId=arr[0]
    var globalDeviceId=arr[1]
    var cameraId="";

    var dt=event.timeString


 //   console.log("serviceId ",serviceId)
 //   console.log("globalDeviceId ",globalDeviceId)

 //   console.log("dt ",dt)


dt= dt.substring(6,10)+
    dt.substring(3,5)+
    dt.substring(0,2)+
    "T"+
    dt.substring(11,13)+
    dt.substring(14,16)+
    dt.substring(17,19)+
    ".000000"

  //  console.log("dt ",dt)
var y
  for(var i=0;i<root.rtsp_stream_url.count;i++)
  {
  var x=root.rtsp_stream_url.get(i)
  //    console.log(i,": ",x.id," ",globalDeviceId)

      if(x.id==globalDeviceId)
      {
      cameraId=x.axxon_id
      y=x
      }
  }

 // console.log(" ")
 //   console.log("cameraId ",cameraId)

 // console.log(" ")
    if(cameraId!="")
    {
        root.activePane=root.videoPane
        root.storage_live=storage
//-------------------------------------------------
        current_cameraId=cameraId
        current_serviceId=serviceId
        //console.log("camera id: ",current_serviceId)
        //console.log("current_serviceId: ",current_serviceId)
        telemetry.set_serviceId(current_serviceId)


        preset_list.serviceId=current_serviceId
        telemetryControlID=y.telemetryControlID
        root.telemetryPoint=telemetryControlID
        telemetry.set_point(y.telemetryControlID)




        //    console.log("[storage]")
        //    console.log("[1]")
           // var dt=timeline.current_dt()
         //   console.log(dt)
         //   console.log("[2]")
        timeline.set_sliders_and_calendar_from_current_datetime_value(dt)
        Axxon.request_URL(current_cameraId,current_serviceId,dt,"utc")

         //update_vm(timeline.get_dt())
//-------------------------------------------------


    }


}

function handler_to_camera_to_livestream_updated()
{
//console.log("[handler_to_camera_to_livestream_updated]")
    current_cameraId=root.camera_to_livestream.get(0).id

    telemetryControlID=current_camera.get(0).telemetryControlID
    root.telemetryPoint=telemetryControlID


    telemetry.set_point(telemetryControlID)

    root.pause_play=play
    root.storage_live=live

    f_current_camera_update()



    timeline.to_live()
}


function f_current_camera_update()
{


//console.log("[f_current_camera_update !]")

    for(var i=0;i<root.current_camera.count;i++)
    {
        var x=root.current_camera.get(i)
/*
        console.log("id: ", x.id)



        console.log("-------------------------")
        console.log(" ")
        console.log(" ")
        console.log("liveStream: ", x.liveStream)
        console.log(" ")
        console.log(" ")
        console.log("-------------------------")
        //console.log("storageStream: ", x.storageStream)
        //console.log("snapshot: ", x.snapshot)
        */
        var state=false
        //ищем эту камеру
        for(var i=0;i< root.rtsp_stream_url.count;i++)
        {
        //    console.log("наш id: ", x.id)
            var y= root.rtsp_stream_url.get(i)
        //    console.log("x.id: ", y.axxon_id)
            if(x.id==y.axxon_id)
            {
         //   console.log("Состояние этой камеры: ", y.state)

           //     console.log("name           ",y.name)
           //     console.log("id             ",y.id)

                var str=y.name+" "+y.id
              //                 console.log("str             ",str)

            timeline.set_camera_zone(str)


            state=y.state
            }


        }

        if(x.id==current_cameraId)
        {
    //    console.log("[Пришли URL на камеру]")
  // console.log("x.liveStream   ",x.liveStream)
 //  console.log("storageStream  ",x.storageStream)
 //  console.log("snapshot       ",x.snapshot)


            vm.url_livestream=x.liveStream
            vm.url_storagestream=x.storageStream
            vm.url_snapshot=x.snapshot


//Найди состояние камеры!!!



            if(root.storage_live==live)
            {
            if(state!="lost"){
        //       console.log("1")
            update_vm()
            }
            else{
       //     console.log("2")
                vm.url_livestream="NOTHING"
            vm.set_live_play()
            }
            }
            else
            update_vm()

    //      timeline.update_slider_intervals(x.intervals)
         }

       /* }
        else
        {
        vm.set_live_stop()
        }*/
    }


}


    function update_presets()
    {
        //console.log("[update_presets]")
    }

function f_loaded_cameras_on_off()
{
if(configPanel.state=="show")
    configPanel.state="hide"
    else
{
//    Axxon. getListDevices()
    configPanel.state="show"
}
}

function f_telemetry_on_off()
{
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

function  f_show_or_hide_calendar()
{
  //  console.log("----------show_or_hide_calendar")
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



function f_change_camera(x)
{
  // console.log("[f_change_camera(x)]")
configPanel.state="hide"
    //   live_videoOutput.visible=true
   //    image.visible=false
   //    storage_videoOutput.visible=false
//console.log("!!Меняю камеру: id:",x.obj.id," ; имя:",x.obj.name,"; телеметрия:",x.obj.telemetryControlID)
//    vm.accesspoint=x.obj.point
//    vm.reload_livestream()
    current_cameraId=x.obj.axxon_id
    current_serviceId=x.obj.serviceId
    //console.log("camera id: ",current_serviceId)
    //console.log("current_serviceId: ",current_serviceId)
    telemetry.set_serviceId(current_serviceId)


    preset_list.serviceId=current_serviceId
    telemetryControlID=x.obj.telemetryControlID
    root.telemetryPoint=telemetryControlID
    telemetry.set_point(telemetryControlID)


    if(root.storage_live==live)
    {
  //   console.log("[live]")
    request_URL(current_cameraId,current_serviceId,"")
    }
    if(root.storage_live==storage)
    {
     //   console.log("[storage]")
    //    console.log("[1]")
        var dt=timeline.current_dt()
     //   console.log(dt)
     //   console.log("[2]")
    request_URL(current_cameraId,current_serviceId,dt)
    }
     //update_vm(timeline.get_dt())



}

function f_play_or_pause(str,dt)
{
    if(root.storage_live==storage){

    if(str=="play")
        root.pause_play=play
    if(str=="pause")
        root.pause_play=pause

    request_URL(current_cameraId,current_serviceId,dt)
    }

    if(root.storage_live==live){

  //  console.log("[REAL LIVE]")
        if(str=="play")
            root.pause_play=play
        if(str=="pause")
            root.pause_play=pause

       update_vm(dt)
    }
    root.storage_live=storage     //update_vm(dt)

}

function f_moved_at_dt(dt)
{
root.storage_live=storage


    request_URL(current_cameraId,current_serviceId,dt)
     //update_vm(dt)

}

function f_set_live_play()
{
root.storage_live=live
root.pause_play=play
var dt=""

    request_URL(current_cameraId,current_serviceId,dt)
 //update_vm(dt)
}


function hide_or_show_menu()
{
  //  console.log("[hide_or_show_menu] ",container.interfase_visible )

     if(container.interfase_visible)
     {
  hide_menu()

     }
     else
     {
       show_menu()


     }


}

function show_menu()
{
  //  console.log("[show] " )
bottom_panel.height=160
timelist_rect.width=110
 container.interfase_visible=true
}

function hide_menu()
{
 //   console.log("[hide] " )
  bottom_panel.height=0
      telemetry_menu.width=0
  timelist_rect.width=0
      eventlog.width=0
      configPanel.state="hide"

      calendar.enabled=false
      calendar_rect.visible=false
      calendar_rect_area.enabled=false
       r2.width=0
 container.interfase_visible=false
}

function request_URL(cameraId, serviceId, dt)
{
//console.log("камера: ",cameraId,"; сервис: ",serviceId,"; dt: ",dt)
Axxon.request_URL(cameraId, serviceId, dt,"utc")

}

function  update_vm(dt)
 {
    //console.log("[",dt,"]")
 //   console.log("-------------update vm")
 if(root.pause_play==pause)
     {
   //  console.log("pause")
     if(root.storage_live==storage)
         {
      //   console.log("storage")
         vm.set_storage_pause(dt)
         }
     else
     if(root.storage_live==live)
         {
      //   console.log("live")
         vm.set_live_pause()
         }
     }
 else
 if(root.pause_play==play)
     {
   //  console.log("play")
     if(root.storage_live==storage)
         {
       //  console.log("storage")
         vm.set_storage_play(dt)
         }
     else
     if(root.storage_live==live)
         {
         preset_list.clear_model()
         Tlmtr.preset_info(telemetryControlID,current_serviceId)

         root.telemetryPoint=telemetryControlID
         Tlmtr.capture_session(telemetryControlID,current_serviceId)

         timer.start()
         tform1.xScale =1
         tform1.yScale =1


     //    rect.x =0
     //    rect.y =0
     //   console.log("live")
         vm.set_live_play()
         }

     }
 }

function f_qwerty12345(){
//console.log("f_qwerty12345()")
}







}

