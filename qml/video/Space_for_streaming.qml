import QtQuick 2.0
import QtMultimedia 5.11
import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5

import "../../js/axxon.js" as Tlmtr


Item {
    id:container

    property bool move:false

    signal set_storage_play(string dt,int speed)
    signal set_storage_pause()

    signal set_storage_snapshot(string dt)

    signal current_dt_request()

    signal set_live_play()
    signal set_live_pause()

    signal play_or_pause()



    Keys.onPressed: {
         console.log("!!!003")

    }




    signal signal_to_set_size(int x,int y)
signal take_it_on_big_screen(string name,string point)
    property int current: -1



    Timer {
        id:mouse_timer
        interval: 200; running: false; repeat: false
        onTriggered:
        {

            var mode=work_model.get(rpt.current)._mode

            if(mode=="live")
            {
                var point=  work_model.get(rpt.current)._telemetryControlID
               Tlmtr.capture_session(lcl.sid,point)
               container.move=true
            }
        }
    }

    ListModel {
        id: model

        dynamicRoles: true

           Component.onCompleted: {


        }
    }
    ListModel {
        id: work_model

        dynamicRoles: true

           Component.onCompleted: {


        }
     }

    Rectangle{
        anchors.fill:parent
        color: "#9adbda"




        Column{
        anchors.fill:parent


        Head_of_space_for_streaming {
        id: head
        width:parent.width
        height: 30


        }



        Rectangle{
            id: space
            width:parent.width
            height: parent.height-head.height




       Repeater{
            id: rpt
            property int mode: 1
            property int current: -1
            property int sz:space.width/((ll+2)*3)
            property int ll:4
            anchors.fill:parent
            model: work_model



            delegate:

                Rectangle {

                    id: unit

                    color: _color

                    visible: _visible

               //     Layout.fillWidth: true
                    x:_x
                    y:_y
                    width: _width
                    height: _height
             //       anchors.top:parent.top

               Column{
                anchors.fill:parent
                Text {
                    width: parent.width;
                    height: 20;

                    text: name
                 //   text: modelData.Count
                    font.family: "Helvetica"
                    font.pointSize: 100

                    minimumPointSize: 10
                    fontSizeMode: Text.Fit
                    color: "black"
                }
                Rectangle{

                    width: parent.width
                    height: parent.height-20
                    color:"lightblue"



                    VM{

                    id: rpt_vm
                    anchors.fill: parent

                    accesspoint: point

                    Component.onCompleted: {

                    container.set_storage_play.connect(set_storage_play)
                    container.set_storage_pause.connect(set_storage_pause)
                    container.set_storage_snapshot.connect(set_storage_snapshot)

                    container.set_live_play.connect(set_live_play)
                    container.set_live_pause.connect(set_live_pause)
                    }
                    }

                    MouseArea {
                        anchors.fill: parent
                        id:area



                        property bool move: false

                        property int xx: 0
                        property int yy: 0

                        property int speed_x: 0
                        property int speed_y: 0


                        onPressed: {
                        mouse_timer.stop()
                            xx=mouseX
                            yy=mouseY
                        mouse_timer.start()


                        }

                        onReleased:  {

                            if(mouse_timer.running)
                            {

                                if (_id==rpt.current)
                                {

                                    container.play_or_pause()
                                }


                                rpt.current=_id

                                rpt.mode=2
                                space.update()

                            }
                            else
                            {


                         Tlmtr.stop_moving()
                            }


                        container.move=false

                        }

                        onMoveChanged: {

                        mouse_x_y()

                        }


                        onMouseXChanged: {
                        mouse_x_y()
                        }
                        onMouseYChanged: {
                        mouse_x_y()
                        }

                        function mouse_x_y()
                        {

                            if (container.move==true)
                            {
                             var mx= xx-mouseX
                                var my=yy-mouseY


                                if((Math.abs(mx)>10)||
                                (Math.abs(my)>10))
                                {

                             var arctn=Math.abs(Math.atan(my/mx))


                                if(arctn<0.2)
                                {

                                    if(mx>0)
                                    {
                                    Tlmtr.left()
                                    }
                                    else
                                    {
                                      Tlmtr.right()
                                    }
                                }
                                else
                                if(arctn<0.8)
                                {

                                    if(my>0)
                                    {
                                        if(mx>0)
                                        {
                                        Tlmtr.top_left()
                                        }
                                        else
                                        {
                                          Tlmtr.top_right()
                                        }
                                    }
                                    else
                                    {
                                        if(mx>0)
                                        {
                                          Tlmtr.bottom_left()
                                        }
                                        else
                                        {
                                          Tlmtr.bottom_right()
                                        }
                                    }





                                }
                                else
                                {

                                    if(my>0)
                                    {
                                    Tlmtr.top()
                                    }
                                    else
                                    {
                                      Tlmtr.bottom()
                                    }
                                }
                            }

                            }
                        }




                    }


                }





                }
               Component.onCompleted:
               {
               container.signal_to_set_size.connect(set_size)

               }

               function set_size(x,y)
               {

               unit.width=x
               unit.height=y


               }


            }


}

       onWidthChanged: {

       update()
       }


       onHeightChanged: {

       update()
       }
       Component.onCompleted: {

       }
       function update()
       {
       var mode=rpt.mode
           mode=2
           //root.log("mode:",mode)
           switch(mode)
           {
           case 1:
           table()
           break;

           case 2:
           main_in_centr()
           break;

           }
       }

       function table()
       {

       var sz=Math.sqrt((space.width*space.height)/(6*(work_model.count+Math.sqrt(work_model.count)*2+1)))
       var row=0
       var column=0
       var columns= space.width/(sz*3)
       var xxx=Math.floor((space.width/sz)/3)*3

       sz=width/xxx

          columns= space.width/(sz*3)





       for(var i=0;i<work_model.count;i++)
       {


       work_model.set(i,{"_x":sz*3*column,
                    "_y":sz*2*row,
                    "_width":sz*3,
                    "_height":sz*2
                 })

       column++
       if(column>(columns-1))
           {
           column=0
           row++
           }
       }



       }

       function main_in_centr()
       {

        var ll=rpt.ll
       var sz=space.width/((ll+2)*3)


        var row=0
        var column=0
       var rows=ll
       var cashback=space.width%((ll+2)*3)

           for(var i=0;i<work_model.count;i++)
           {
           var id=work_model.get(i)._id
           if(id==rpt.current)
           {

            work_model.set(i,{"_width":sz*3*ll,
                         "_height":sz*2*ll,
                         "_x":sz*3,
                          "_y":0
                      })

           }
           else
           {

               work_model.set(i,{"_width":sz*3,
                            "_height":sz*2,
                            "_x":(sz*3*(ll+1))*column,
                             "_y":sz*2*row
                         })

               row++
               if(row==ll)
               {
               column=1
               row=0
               }
           }
           }
       }
}
}
}

    Component.onCompleted:
    {

    head.size.connect(set_size)

    set_size(500,400)

    }

function update_work_model()
{


for(var i1=0;i1<model.count;i1++)
{
var x=model.get(i1)



    var res=false
    for(var j=0;j<work_model.count;j++)
    {

    var y=work_model.get(j).name
        if(y===x.name)
        {

        res=true
        }



    }

    if(res===false)
   {

    work_model.append({name: x.name,
                          point: x.point,

                          _visible: x._visible,
                          _color:x._color,
                          _mode:x._mode,
                          _telemetryControlID: x.telemetryControlID,

                          _x:rpt.sz*3*i1,
                          _y:rpt.sz*2*i1,
                          _width:rpt.sz*3,
                          _height:rpt.sz*2,
                          _id:i1



                      })




   }


}

}



function on_screen()
{

var name=work_model.get(current).name
var point=work_model.get(current).point
var mode=work_model.get(current).mode
var dt= work_model.get(current).dt
var speed= work_model.get(current).speed



}




function add_camera_to_space(x)
{

   model.append({name: x.obj.name,
                      point: x.obj.point,
                      telemetryControlID:x.obj.telemetryControlID,
                      current_serviceId: x.obj.serviceId,

                      _visible: true,
                      _color:"lightblue",
                      _mode:"live"
                   })

    update_work_model()
}

function set_size(x,y)
{


signal_to_set_size(x,y)
}

function f_play(dt,speed)
{
if(dt=="")
{
f_play_live_stream()
}
else
{
f_storage_play(dt,speed)
}

}


function f_storage_play(dt,speed)
{
for(var i=0;i<work_model.count;i++)
    {
    work_model.set(i,{"_mode":"streaming"})
    work_model.set(i,{"_dt":dt})
    work_model.set(i,{"_speed":speed})


    }


if(current>-1)
{
    var _name=work_model.get(current).name
    var _point=work_model.get(current).point
    var _mode=work_model.get(current).mode
    var _dt= work_model.get(current).dt
    var _speed= work_model.get(current).speed

    screen.add(_name,_point,_mode,_dt,_speed)
}

set_storage_play(dt,speed)



}
function f_pause()
{

    var mode=work_model.get(0)._mode

    if(mode=="live")
    {
    set_live_pause()
    }
    else
    {
    set_storage_pause()
    }



}
function f_storage_stop()
{



    for(var i=0;i<work_model.count;i++)
        {
        work_model.set(i,{"_mode":"streaming"})
        }
storage_stop()

}
function f_storage_snapshot(dt)
{


        for(var i=0;i<work_model.count;i++)
            {
    work_model.set(i,{"_mode":"snapshot"})
    work_model.set(i,{"_dt":dt})
            }

    set_storage_snapshot(dt)



}

function update_dt(_dt)
{
    for(var i=0;i<work_model.count;i++)
     {

work_model.set(i,{"_dt":_dt})

     }
    if(current>-1)
    {
        var _name=work_model.get(current).name
        var _point=work_model.get(current).point
        var _mode=work_model.get(current).mode
        _dt= work_model.get(current).dt
        var _speed= work_model.get(current).speed

        screen.add(_name,_point,_mode,_dt,_speed)
    }


}

function f_play_live_stream()
{
    //root.log("[ f_play_live_stream]")



    for(var i=0;i<work_model.count;i++)
     {

  work_model.set(i,{"_mode":"live"})

     }


    container.set_live_play()



    if(current>-1)
    {
        var _name=work_model.get(current).name
        var _point=work_model.get(current).point
        var _mode=work_model.get(current).mode
        var _dt= work_model.get(current).dt
        var _speed= work_model.get(current).speed


    }
}
}







