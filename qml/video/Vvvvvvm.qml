import QtQuick 2.0
import VideoPlayer 1.0
import "../../js/axxon_telemetry_control.js" as Tlmtr
import MyQMLEnums 13.37
Item {

    id: supreme

  //   anchors.fill: parent


        property bool selected: parent.selected

    signal playing
    signal selected




     onActiveFocusChanged:{
     console.log("vvvvvvm activeFocus: ", supreme.activeFocus)


     }


     focus: true

     Keys.onPressed: {
         console.log("!!!0007")

     }

     Keys.onLeftPressed:   {

         dx=-1;
 stop_moving_timer_dx.stop()
         if((root.storage_live==live)&&(root.pause_play==play)){

             vm_area.move(dx,dy)

         }



     }

     Keys.onRightPressed:  {

         dx=1;
 stop_moving_timer_dx.stop()
         if((root.storage_live==live)&&(root.pause_play==play)){

             vm_area.move(dx,dy)

         }


     }

     Keys.onUpPressed:     {

         dy=1;
 stop_moving_timer_dy.stop()
         if((root.storage_live==live)&&(root.pause_play==play)){

             vm_area.move(dx,dy)

         }


     }

     Keys.onDownPressed:   {

         dy=-1;
 stop_moving_timer_dy.stop()
         if((root.storage_live==live)&&(root.pause_play==play)){

             vm_area.move(dx,dy)

         }

     }

     Keys.onReleased:      {

         switch(event.key){

         case Qt.Key_Up:{
        stop_moving_timer_dy.start()

         }
         break

         case Qt.Key_Down:{

        stop_moving_timer_dy.start()
         }
         break

         case Qt.Key_Right:{
        stop_moving_timer_dx.start()

         }
         break

         case Qt.Key_Left:{
        stop_moving_timer_dx.start()

         }
         break
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

    Rectangle {
        color: selected ? "lightgray" : "gray";
        id:vm_rect
        anchors.fill: parent
        clip:true





        onActiveFocusChanged:{
        console.log("vm activeFocus: ", vm.activeFocus)

        }

        VideoPlayer{

       //     fillColor: "green"
            id: vm
            x:(parent.width- width)/2
            y:(parent.height- height)/2

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
                        move(mx/2,my/2)
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

                Timer {
                    id:stop_moving_timer_dx
                    interval: 100; running: false; repeat: false
                    property int msec:0
                    onTriggered:
                    {
                            console.log("stop_moving_timer_dx")
                       dx=0
                          vm_area.move(dx,dy)
                    }
                }

                Timer {
                    id:stop_moving_timer_dy
                    interval: 100; running: false; repeat: false
                    property int msec:0
                    onTriggered:
                    {
                        console.log("stop_moving_timer_dy")
                      dy=0
                           vm_area.move(dx,dy)
                    }
                }

                onReleased: {
                    if((root.storage_live==live)&&(root.pause_play==play)){
                        stop_moving_timer.start()
                    }
                }


                function move(mx,my)
                {
                    //  console.log("move ",mx," ",my)
                    var value=Math.sqrt(mx*mx+my*my)

                    var val=0
                    if(value===0)
                        val=0

                    if(value>0.4)
                        val=0.2

                    if(value>0.4)
                        val=0.2

                    if(value>0.9)
                        val=0.5

                    //   console.log("val ",val)
                    var arctn=Math.abs(Math.atan(my/mx))

                    var x=0
                    var y=0
                    if(arctn<0.2)
                    {
 /*
                        if(value>0.9)
                            rect.color="red"
                        else
                            if(value>0.4)
                                rect.color="yellow"
                            else
                                rect.color="lightgray"
*/
                        if(mx>0)
                        {
                            x=1
                            y=0

                        }
                        else if(mx<0)
                        {
                            x=-1
                            y=0
                        }else{
                            x=0
                            y=0
                        }
                    }
                    else
                        if(arctn<1.3)

                        {

 /*
                            if(value>0.9)
                                rect.color="green"
                            else
                                if(value>0.4)
                                    rect.color="lightgreen"
                                else
                                    rect.color="lightgray"
*/
                            if(my>0)
                            {
                                if(mx>0)
                                {
                                    x=1
                                    y=1
                                }
                                else if(mx<0)
                                {
                                    x=-1
                                    y=1
                                }else{
                                    x=0
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
                                else if(mx<0)
                                {
                                    x=-1
                                    y=-1
                                }else{
                                    x=0
                                    y=-1
                                }

                            }





                        }
                        else
                        {

 /*
                            if(value>0.9)
                                rect.color="blue"
                            else
                                if(value>0.4)
                                    rect.color="lightblue"
                                else
                                    rect.color="lightgray"
*/
                            if(my>0)
                            {
                                x=0
                                y=1
                            }
                            else if(my<0)
                            {
                                x=0
                                y=-1
                            }else{
                                x=0
                                y=0
                            }
                        }


                    console.log("move.. ",x," ",y,"    ",x_prev," ",y_prev,"     ",str)

                    if((x_prev!=x)||(y_prev!=y)||(val_prev!=val))
                    {
                        console.log("+")
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




                                    vm.x=(supreme.width- vm.width)/2
                                    vm.y=(supreme.height- vm.height)/2


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

/*
            Rectangle{
            anchors.fill: parent
           color:  vvm_arrea.containsMouse ? "green" : "red"
            }
            */

            id: vvm_arrea
            anchors.fill:parent
            propagateComposedEvents: true

            hoverEnabled: true

            onPressed: {
                delay_timer.start()
                mouse.accepted=false
            }

            onEntered: {
                console.log(" containsMouse ",vvm_arrea.containsMouse)
                supreme.forceActiveFocus()
                }


            onExited:  {
            console.log(" containsMouse ",vvm_arrea.containsMouse)
                supreme.focus=false
                dx=0;
                dy=0;
                vm_area.move(dx,dy)
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

    Text {
        text: activeFocus ? "I have active focus!" : "I do not have active focus"
    }

    function set_Scale(val){
        tform1.xScale = val
        tform1.yScale = val

        if(val==1){
            vm.x=(supreme.width- vm.width)/2
            vm.y=(supreme.height- vm.height)/2
        }
    }

    function set_vm_source(src){
        vm.source=src
    }

    function vm_start(mode){
        vm.start(mode)
    }

    function vm_stop(){
              vm.stop()
    }
    function vm_shot(){
              vm.shot()
    }




    Component.onCompleted: {

       // supreme.forceActiveFocus()
        console.log("vvvvvvm activeFocus: ", supreme.activeFocus)
            selected=false;



    }


}
