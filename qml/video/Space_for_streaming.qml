import QtQuick 2.0
import QtMultimedia 5.11
import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5

import "../../js/axxon.js" as Tlmtr
//Место с окнами камер  в которые идет стрим и откуда можно увеличить размер окна

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




    signal signal_to_set_size(int x,int y)
signal take_it_on_big_screen(string name,string point)
    property int current: -1



    Timer {
        id:mouse_timer
        interval: 200; running: false; repeat: false
        onTriggered:
        {

            //console.log("mouse timer timeout")
            var mode=work_model.get(rpt.current)._mode

            if(mode=="live")
            {
                var point=  work_model.get(rpt.current)._telemetryControlID
               //console.log("work_model.get(rpt.current).telemetryControlID : ",work_model.get(rpt.current)._telemetryControlID)
               Tlmtr.capture_session(point)
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

        //Шапка
        Head_of_space_for_streaming {
        id: head
        width:parent.width
        height: 30


        }
        //Основная часть


        Rectangle{
            id: space
            width:parent.width
            height: parent.height-head.height
//------------------------------------------------
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

                    /*

                    Test_Repeater{
                     anchors.fill: parent
                    }
*/

                    VM{

                    id: rpt_vm
                    anchors.fill: parent
             //       width: 300
             //       height: 250

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
                            //console.log("+")
                                if (_id==rpt.current)
                                {
                                    //console.log("[current]")
                                    container.play_or_pause()
                                }

                                //console.log("area onClicked")
                                rpt.current=_id
                                //console.log(rpt.current)
                                rpt.mode=2
                                space.update()

                            }
                            else
                            {
                            //console.log("-")

                         Tlmtr.stop_moving()
                            }


                        container.move=false

                        }

                        onMoveChanged: {
                            //console.log("[onMoveChanged]")
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
                   //     //console.log(mx," ",mx)

                                if((Math.abs(mx)>10)||
                                (Math.abs(my)>10))
                                {

                             var arctn=Math.abs(Math.atan(my/mx))
                     //       //console.log(xx-mouseX," ",yy-mouseY)
                            //console.log("arctn: ",arctn)

                                if(arctn<0.2)
                                {
                                //console.log("(1)")
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
                                //console.log("(2)")
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
                                //console.log("(3)")
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
                                else
                                {
                              //   console.log(mx," ",my)
                                }
                            }
                        }




                    }


                }





                }
               Component.onCompleted:
               {
               container.signal_to_set_size.connect(set_size)
               //set_size(dndGrid.cellWidth,dndGrid.cellHeight)



                   //console.log("добавлен:  ",name)
                   //console.log("добавлен:  ",point)
                   //console.log("добавлен:  ",visible)
                   //console.log("добавлен:  ",color)
               }

               function set_size(x,y)
               {
               //console.log("[vm] ",x," ",y)
               unit.width=x
               unit.height=y

         //      rpt_vm.width=x
         //      rpt_vm.height=y
               }


            }


}
//------------------------------------------------
       onWidthChanged: {
           //console.log("onWidthChanged:")
       update()
       }


       onHeightChanged: {
            //console.log("onHeightChanged:")
       update()
       }
       Component.onCompleted: {
/*
           var sz=rpt.sz
           for(var i=0;i<9;i++)
           {

           model.append({_x:sz*3*i,
                            _y:sz*2*i,
                            _width:sz*3,
                            _height:sz*2,
                            _text:i.toString(),
                            _id:i,
                      //      _image:image_model.get(i).imagePath

                        })
           }
           */




    //   model.append({_x:100,_y:0,_width:100,_height:100})
    //   model.append({_x:200,_y:200,_width:150,_height:150})


       }
       function update()
       {
       var mode=rpt.mode
           mode=2
           //console.log("mode:",mode)
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
       //console.log("table")
       //console.log("Math.sqrt(work_model.count) :  ",Math.sqrt(work_model.count))
       //console.log("Math.sqrt(work_model.count)*2+1 :  ",Math.sqrt(work_model.count)*2+1)

       var sz=Math.sqrt((space.width*space.height)/(6*(work_model.count+Math.sqrt(work_model.count)*2+1)))
       var row=0
       var column=0
       var columns= space.width/(sz*3)




       //console.log("sz: ",sz)

       //console.log("space.width/sz: ",Math.floor((space.width/sz)/3)*3)
       //console.log("space.height/sz: ",space.height/sz)


       var xxx=Math.floor((space.width/sz)/3)*3

       sz=width/xxx

          columns= space.width/(sz*3)





       for(var i=0;i<work_model.count;i++)
       {

           //console.log(model.get(i).name)

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
       //console.log("main_in_centr")
        var ll=rpt.ll
       var sz=space.width/((ll+2)*3)


        var row=0
        var column=0
       var rows=ll
       var cashback=space.width%((ll+2)*3)

       //console.log("space.width: ",space.width)
       //console.log("((ll+2)*3): ",((ll+2)*3))
       //console.log("space.width/((ll+2)*3): ",space.width/((ll+2)*3))
       //console.log("Math.floor(space.width/((ll+2)*3)): ",Math.floor(space.width/((ll+2)*3)))

       //console.log("space.width%((ll+2)*3): ",space.width%((ll+2)*3))
       //console.log(": ")
           for(var i=0;i<work_model.count;i++)
           {
           var id=work_model.get(i)._id
           if(id==rpt.current)
           {
       //Увеличиваем его и помещаем в центр
            work_model.set(i,{"_width":sz*3*ll,
                         "_height":sz*2*ll,
                         "_x":sz*3,
                          "_y":0
                      })

           }
           else
           {
               //console.log("name ",work_model.get(i).name)
               //console.log("row",row)
               //console.log("_x",sz*3*(ll+1)*column)
               //console.log("_y",sz*2*row)

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

//обновлям рабочую модель
function update_work_model()
{


for(var i1=0;i1<model.count;i1++)
{
var x=model.get(i1)
    //console.log("добавить? ",x.name)


    var res=false
    for(var j=0;j<work_model.count;j++)
    {
        //console.log("--",j)
    var y=work_model.get(j).name
        if(y===x.name)
        {
                //console.log("уже есть! ")
        res=true
        }



    }

    if(res===false)
   {
    //console.log("добавляю:  ",x.name)
    //console.log("добавляю:  ",x.point)
    //console.log("добавляю: telemetryControlID: ",x.telemetryControlID)
    //console.log("добавляю:  ",x._visible)
    //console.log("добавляю:  ",x._color)
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


//Делаем одну из камер невидимой
function on_screen()
{

    //console.log("[hide_camera]------------------------------")

var name=work_model.get(current).name
var point=work_model.get(current).point
var mode=work_model.get(current).mode
var dt= work_model.get(current).dt
var speed= work_model.get(current).speed





    /*
//console.log(work_model.get(current).cost)
//console.log(work_model.get(current).name)
    //console.log(work_model.get(current).color)
//work_model.get(current).name="12345"
work_model.set(current,{"cost":"12345"})
work_model.set(current,{"visible":false})
work_model.set(current,{"_color":"purple"})
//console.log(work_model.get(current).cost)
//console.log(work_model.get(current).name)
//console.log(work_model.get(current).color)
*/


}



//Добавляем камеру из хранилища камер в рабочее пространство
function add_camera_to_space(x)
{
//console.log("!!Добавляю камеру:",x.obj.name," ",x.obj.point,x.obj.telemetryControlID)
 //   camera.add_to_space(name,point)
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
//console.log("[grid] ",x," ",y)
//dndGrid.cellWidth=x
//dndGrid.cellHeight=y

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
//storage_stop()



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
    //console.log("[f_pause]")
    var mode=work_model.get(0)._mode
        //console.log(mode)
    if(mode=="live")
    {
    set_live_pause()
    }
    else
    {
    set_storage_pause()
    }


/*
set_storage_pause()
    for(var i=0;i<work_model.count;i++)
        {
//        work_model.set(i,{"_mode":"snapshot"})
        }
    */

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
// storage_stop()
//storage_snapshot(dt)

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
        var _dt= work_model.get(current).dt
        var _speed= work_model.get(current).speed

        screen.add(_name,_point,_mode,_dt,_speed)
    }


}

function f_play_live_stream()
{
    //console.log("[ f_play_live_stream]")



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

     //  screen.add(_name,_point,_mode,_dt,_speed)
    }




}

//---------------------------------

}







