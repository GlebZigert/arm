import QtQuick 2.0
import "../../js/axxon_telemetry_control.js" as Tlmtr
import "../../js/axxon.js" as Axxon
Item {

    property int serviceId:-1


    property int x_prev:0
    property int y_prev:0
    property int val_prev:0
    Rectangle{
        id: rect
    anchors.fill:parent
    color: "lightblue"


    Joystick{
    id: control

    }

    Timer {
        id:zoom_timer
        interval: 100; running: false; repeat: false
        property int msec:0
        onTriggered:
        {

            Tlmtr.stop_zoom()

        }
    }




    Component.onCompleted: {

    control.joystick_moved.connect(move)

    }


    function move(mx,my)
    {


    var value=Math.sqrt(mx*mx+my*my)

    var val=0
        if(value===0)
            val=0

        if(value>0.1)
            val=0.1

        if(value>0.2)
            val=0.2

        if(value>0.3)
            val=0.3

        if(value>0.4)
            val=0.4

        if(value>0.5)
            val=0.5

        if(value>0.6)
            val=0.6

        if(value>0.7)
            val=0.7

        if(value>0.8)
            val=0.8

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



  }

    function set_disabled()
    {
    control.set_disabled()
    }

    function set_enabled()
    {
    control.set_enabled()
    }

    function set_serviceId(id)
    {
    serviceId=id

    }

}
