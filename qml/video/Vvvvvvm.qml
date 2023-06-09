import QtQuick 2.0
import VideoPlayer 1.0
import "../../js/axxon_telemetry_control.js" as Tlmtr
import "../../js/axxon.js" as Axxon
import MyQMLEnums 13.37

Item {

    id: supreme

  //   anchors.fill: parent


        property bool selected: false

    property bool mouse_pressed

    signal playing
    signal selected

    property string source
    property int cid
     property int uid: -1
    signal return_source(string src)
    signal return_cid(int cid)

    property  int mode: -1

    property int mouse_x
    property int mouse_y

     onActiveFocusChanged:{
   //  console.log("vvvvvvm activeFocus: ",vm.source," ",supreme.activeFocus)


     }




     focus: true

     Keys.onPressed: {
         console.log("!!!0007")

     }

     Keys.onLeftPressed:   {
 //   console.log("onLeftPressed")
         dx=-50;
 stop_moving_timer_dx.stop()
          console.log("Keys.onLeftPressed "," ",cid," ",vm.cid," ",Axxon.camera(vm.cid).telemetryControlID," ",root.telemetryPoint," ",vvm_arrea.containsMouse)
         if(Axxon.camera(vm.cid).telemetryControlID==root.telemetryPoint && vvm_arrea.containsMouse && (supreme.activeFocus && vm.getMode()===Mode.LiveStreaming)){

             vm_area.move(dx,dy,0.5)

         }



     }

     Keys.onRightPressed:  {
  //  console.log("onLeftPressed")
         dx=50;
 stop_moving_timer_dx.stop()

         var x1=vvm_arrea.containsMouse
         var x2=supreme.activeFocus
         var x3=(vm.getMode()===Mode.LiveStreaming)
 console.log("Keys.onRightPressed ",Axxon.camera(vm.cid).telemetryControlID," ",root.telemetryPoint," ",vvm_arrea.containsMouse)
        if(Axxon.camera(vm.cid).telemetryControlID==root.telemetryPoint && vvm_arrea.containsMouse && (supreme.activeFocus && vm.getMode()===Mode.LiveStreaming)){


             vm_area.move(dx,dy,0.5)

         }


     }

     Keys.onUpPressed:     {
 //   console.log("onLeftPressed")
         dy=50;
 stop_moving_timer_dy.stop()
         console.log("Keys.onUpPressed ",Axxon.camera(vm.cid).telemetryControlID," ",root.telemetryPoint," ",vvm_arrea.containsMouse)
         if(Axxon.camera(vm.cid).telemetryControlID==root.telemetryPoint && vvm_arrea.containsMouse && (supreme.activeFocus && vm.getMode()===Mode.LiveStreaming)){


             vm_area.move(dx,dy,0.5)

         }


     }

     Keys.onDownPressed:   {
   // console.log("onDownPressed")
         dy=-50;
 stop_moving_timer_dy.stop()
          console.log("Keys.onDownPressed ",Axxon.camera(vm.cid).telemetryControlID," ",root.telemetryPoint," ",vvm_arrea.containsMouse)
        if(Axxon.camera(vm.cid).telemetryControlID==root.telemetryPoint && vvm_arrea.containsMouse && (supreme.activeFocus && vm.getMode()===Mode.LiveStreaming)){


             vm_area.move(dx,dy,0.5)

         }

     }

     Keys.onReleased:      {
    console.log("Keys.onReleased")

         switch(event.key){

         case Qt.Key_Up:{
             console.log("Key_Up")
        stop_moving_timer_dy.start()

         }
         break

         case Qt.Key_Down:{
console.log("Key_Down")
        stop_moving_timer_dy.start()
         }
         break

         case Qt.Key_Right:{
             console.log("Key_Right")
        stop_moving_timer_dx.start()

         }
         break

         case Qt.Key_Left:{
             console.log("Key_Left")
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
     //   color: selected ? "lightblue" : supreme.activeFocus ? "lightgray" : "gray";
          color: selected ? "lightblue" : "gray";
       //   border.width: 2
       //   border.color: "black"
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




            onSourceChanged: (subject)=> {

         //   console.log("onSourceChanged ", subject)
                                 supreme.source=subject
                        return_source(supreme.source)
            }

            onCidChanged: (subject)=> {

        //    console.log("onSourceChanged ", subject)
                                 supreme.cid=subject
                        return_cid(supreme.cid)
            }

            transform: Scale {
                id: tform1
            }



            MouseArea {

                id: vm_area
                x:(parent.width- width)/2
                y:(parent.height- height)/2

                width: (height/1080)*1920
                height: parent.height
                property double factor: 2.0
                hoverEnabled: true
                propagateComposedEvents: true
                property int x_prev
                property int y_prev
                property int val_prev
                property int mouseX_prev
                property int mouseY_prev


/*
                onContainsMouseChanged: {

                    if(!containsMouse){
                        console.log("--")
                    supreme.focus=false
                    }
                    if(containsMouse){
                          console.log("++")
                    supreme.focus=true
                    }
                }
                */


                onMouseXChanged: {
                    if(mouse_pressed)
                        if(Axxon.camera(vm.cid).telemetryControlID==root.telemetryPoint && vvm_arrea.containsMouse && (supreme.activeFocus && vm.getMode()===Mode.LiveStreaming)){


                         //   console.log(mouse_x," ",mouseX," ",mouse_y," ",mouseY)



                            var mx=mouseX-mouse_x
                             var my=mouse_y-mouseY
                            var arctn=Math.abs(Math.atan(my/mx))

                            var value=Math.sqrt(mx*mx+my*my)

                       //     console.log(mx," ",my," ",value)

                            move(mx/2,my/2,-1)
                        }
                }

                onMouseYChanged: {
                    if(mouse_pressed)
                        if(Axxon.camera(vm.cid).telemetryControlID==root.telemetryPoint && vvm_arrea.containsMouse && (supreme.activeFocus && vm.getMode()===Mode.LiveStreaming)){


                        //    console.log(mouse_x," ",mouseX," ",mouse_y," ",mouseY)

                            var mx=mouseX-mouse_x
                            var my=mouse_y-mouseY
                            var arctn=Math.abs(Math.atan(my/mx))

                            var value=Math.sqrt(mx*mx+my*my)

                        //    console.log(mx," ",my," ",value)
                            move(mx/2,my/2,-1)
                        }
                }


                onPressed: {
                    mouse_pressed=true
                    mouse_x=mouseX
                    mouse_y=mouseY
                    /*
                     console.log("onPressed")
                    if(Axxon.camera(vm.cid).telemetryControlID==root.telemetryPoint && vvm_arrea.containsMouse && (supreme.activeFocus && vm.getMode()===Mode.LiveStreaming)){


                        var mx=mouseX-parent.width/2
                        var my=parent.height/2-mouseY
                        var arctn=Math.abs(Math.atan(my/mx))
                        move(mx/2,my/2)
                    }
                    */
                }


                Timer {
                    id:stop_moving_timer
                    interval: 200; running: false; repeat: false
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
                          vm_area.move(dx,dy,-1)
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
                           vm_area.move(dx,dy,-1)
                    }
                }

                onReleased: {

                      mouse_pressed=false

                     console.log("onReleased")
                if(Axxon.camera(vm.cid).telemetryControlID==root.telemetryPoint && vvm_arrea.containsMouse && (supreme.activeFocus && vm.getMode()===Mode.LiveStreaming)){

                        stop_moving_timer.start()
                    }
                }


                function move(mx,my,val)
                {
                    //  console.log("move ",mx," ",my)

                    if(val===-1){
                     var value=Math.sqrt(mx*mx+my*my)


                    if(value===0)
                        val=0

                    if(value>1)
                        val=0.2

                    if(value>10)
                        val=0.2

                    if(value>50)
                        val=0.5

                    if(value>100)
                        val=1
                    }
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




                    if((x_prev!=x)||(y_prev!=y)||(val_prev!=val))
                    {
                   //     console.log("++")
                        var str=""
                        str=String(x)
                        str=str+" "
                        str=str+String(y)
                        str=str+" "
                        str=str+String(val)
                        str=str+" "

                      //  console.log("move.. ",x," ",y,"    ",value," ",x_prev," ",y_prev,"     ",str)
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
                    console.log("onWheel")

                    var x1=vvm_arrea.containsMouse
                    var x2=supreme.activeFocus
                    var x3=(vm.getMode()===Mode.LiveStreaming)

                    console.log( cid," ",vm.cid ," ",Axxon.camera(vm.cid).telemetryControlID," ",root.telemetryPoint," ",vvm_arrea.containsMouse," ",supreme.activeFocus," ",supreme.activeFocus && vm.getMode()," ",Mode.LiveStreaming)
                    if(Axxon.camera(vm.cid).telemetryControlID==root.telemetryPoint && vvm_arrea.containsMouse && (supreme.activeFocus && vm.getMode()===Mode.LiveStreaming)){


                        if(wheel.angleDelta.y > 0)  // zoom in
                            zoom=1
                        else                        // zoom out
                            zoom=-1
                        console.log("zoom ",zoom_prev," ",zoom)
                        if(zoom_prev!=zoom)
                        {
                            if (zoom==1)
                            {
                             //   console.log("+++")
                                Tlmtr.zoom_in()
                            }
                            if (zoom==-1)
                            {
                                console.log("-")
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


            /*

            Rectangle{
                width: 20
                height: 20

                color:  vvm_arrea.containsMouse ? "green" : "red"
            }

            Rectangle{

                y:20
                width: 20
                height: 20

                color:  mode===Mode.LiveStreaming ? "green" : "red"
            }

            */


            id: vvm_arrea
            anchors.fill:parent
            propagateComposedEvents: true

            hoverEnabled: true

            onPressed: {
                console.log("vvm_arrea onPressed ",vm.cid," ",vm.source)
                delay_timer.start()
                mouse.accepted=false
            }
/*
            onEntered: {
                console.log(" containsMouse ",vvm_arrea.containsMouse)
                supreme.forceActiveFocus()
                }

  */
            onExited:  {
          //  console.log(" containsMouse ",vvm_arrea.containsMouse)
                supreme.focus=false
                dx=0;
                dy=0;
                vm_area.move(dx,dy,-1)
            }


            onContainsMouseChanged: {

                if(!containsMouse){
              //      console.log("--")
                supreme.focus=false
                }
                if(containsMouse){
             //         console.log("++")
                supreme.focus=true
                }
            }


            onReleased: {
  //  console.log("vvm_arrea onReleased")
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

    function set_selected(val){
    selected=val



    }



    function saving_off(){
        vm.saving_off()
    }

    function saving_on(){
    vm.saving_on()
    }

    function set_Scale(val){
        tform1.xScale = val
        tform1.yScale = val

        if(val==1){
            vm.x=(supreme.width- vm.width)/2
            vm.y=(supreme.height- vm.height)/2
        }
    }

    function set_vm_cid(cid){
     //   console.log("set_vm_source ",cid)
       vm.cid=cid

        var lcl = vm.getCid()

        console.log("lcl: ",lcl)

    }

    function set_vm_source(cid,src){
     //   console.log("set_vm_source ",cid," ",src)
    //    vm.cid=cid
        vm.source=src
    }



    function vm_start(mmode){
        mode = mmode
      //  console.log("vm_start ",mode)
        vm.start(mmode)

    }

    function vm_stop(){
           //     console.log("vm_stop ")
              vm.stop()
    }

    function vm_clear(){
           //     console.log("m_clear ")
              vm.clear()
    }

    function vm_shot(){
            //    console.log("vm_shot ")
              vm.shot()
    }




    Component.onCompleted: {

       // supreme.forceActiveFocus()
      //  console.log("vvvvvvm activeFocus: ", supreme.activeFocus)
            selected=false;




    }


}
