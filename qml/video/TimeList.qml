import QtQuick 2.11
import QtQuick.Controls 2.4


import QtQuick.Layouts 1.5
Item {
    id: container
anchors.fill: parent

property var current:-1
signal send_time(var time)

    ListModel{
        id: model
        dynamicRoles: true


 //       ListElement {ind: 1 }
 //       ListElement {ind: 2 }
 //       ListElement {ind: 3 }
 //       ListElement {ind: 4 }
 //       ListElement {ind: 5 }

    }

    Rectangle {
          anchors.fill: parent
            color: "lightblue"

        Row{
           anchors.fill: parent
           Column{
               width: 70
        height: parent.height

          Repeater{
       id: list
       anchors.fill: parent



    model: model


    //interactive: false

    delegate: Rectangle {
        color:"lightblue"
        x:0
    width: parent.width
    height: 30
        Text{
            x:10
            y:5
        text: time

        MouseArea{
            anchors.fill: parent
            onClicked: {

                var str=time
            //root.log(str)

                var strings=str.split(":")
                //root.log(strings[0])
                //root.log(strings[1])
                //root.log(strings[2])

                var value=Number(strings[0])*60*60+Number(strings[1])*60+Number(strings[2])
                //root.log(value)

                container.current=time
   update_view()
            send_time(value)
            }

        }
}
    function set_current(fl)
    {
    if(fl)
    {
    color="#d8edf3"
    }
    else
    {
    color="lightblue"
    }
    }



    MouseArea{
    anchors.fill: parent
    propagateComposedEvents: true

    onClicked: {
    mouse.accepted = false
    }

    onWheel: {



        var zoomFactor
        if(wheel.angleDelta.y > 0)  // zoom in
            var zoomFactor = 1
        else                        // zoom out
            zoomFactor = -1

        //root.log(zoomFactor)

        slider.value=slider.value+zoomFactor

        //root.log("===onWheel")

               container.update_all()
 /*
//--------
        var xx=list.height/30
        //root.log("count ",model.count)
        while(model.count<xx)
        {
                    //root.log("count ",model.count)
            model.append({time: "" })

        }

        //root.log("count ",list.model.count)


        var howmutch=1440-(list.height/30)+1

        slider.to=howmutch

        //root.log("slider.to ",slider.to)

        //root.log("slider.value ",slider.value)

        //root.log("count ",model.count)

        for(var i=0;i<model.count;i++)
        {
            //root.log("--dt ",datetime((i+(slider.to-slider.value))*60))
        model.set(i,{time:datetime((i+(slider.to-slider.value))*60)})
        }

        update_view()
*/
    }




    }



    }
    }

    }

   Slider {
       id: slider
       height: parent.height
       from: 1
       to: 1440
       value: 1440
       stepSize: 1.0
       orientation: Qt.Vertical
       wheelEnabled: true

       onMoved: {
           //root.log("[onMoved]")

           container.update_all()
           /*
           var xx=list.height/30

           while(model.count<xx)
           {
               model.append({time: "" })
           }


           //root.log("count ",list.model.count)


           var howmutch=1440-(list.height/30)+1

           slider.to=howmutch

           //root.log("slider.to ",slider.to)

           //root.log("slider.value ",slider.value)

           for(var i=0;i<model.count;i++)
           {
               //root.log(datetime((i+(slider.to-slider.value))*60))
           model.set(i,{time:datetime((i+(slider.to-slider.value))*60)})
           }

           update_view()
*/









       }

   }



}





    Component.onCompleted: {
        model.clear()
    for(var i=0;i<30;i++)
       model.append({time: datetime(i*60) })
    }

}
    function set_current(dt)
    {
        root.log("set_current")
        var hours= Qt.formatTime(dt,"hh")
        var min= Qt.formatTime(dt,"mm")
        var sec= Qt.formatTime(dt,"ss")
        root.log("hour: ",hours)
       root.log("min: ",min)
       root.log("sec: ",sec)



        //root.log(hours,":",min,":",sec)

        var str_hour
        if(hours<10)
        str_hour="0"+hours.toString()
        else
        str_hour=hours.toString()


        var str_min
        if(min<10)
        str_min="0"+min.toString()
        else
        str_min=min.toString()

        var str_sec
        if(sec<10)
        str_sec="0"+sec.toString()
        else
        str_sec=sec.toString()

        //root.log("str_sec: ",str_sec)

        var dt=new Date(calendar.selectedDate).toLocaleTimeString()




      var str_date
        if(hours<10)
        str_date =
                      hours.toString()+":"+min.toString()+":00"//+str_sec//+"."+str_msec
        else
        str_date =    hours.toString()+":"+min.toString()+":00"//+str_sec//+"."+str_msec



  //root.log("str_date: ",str_date)




        var date=Date.fromLocaleString(locale, str_date, "hh:mm:ss")


        //root.log("DATE: ",date)

        var res=Qt.formatTime(date,"hh:mm:ss")

        //root.log("Qt.formatTime(date,hh:mm:ss): ",res)










        container.current=res



          update_view()

    }

    function update_view()
    {
var res=0
//root.log(" container.current", container.current)
        for(var i=0;i<model.count;i++)
        {

     //
        list.itemAt(i).set_current((model.get(i).time==container.current) ? 1 : 0)

              if(model.get(i).time==container.current)
                  res=1

        }
    /*
        if(res==0)
        {
          var date=Date.fromLocaleString(locale, container.current, "hh:mm:ss")
            //root.log("================================================")

            var hh=Qt.formatTime(date,"hh")
            var mm=Qt.formatTime(date,"mm")
            //root.log("hh "+Qt.formatTime(date,"hh"))
            //root.log("mm "+Qt.formatTime(date,"mm"))
            //root.log("ss "+Qt.formatTime(date,"ss"))

            slider.value=1440-hh*60-mm

            var hhh=Math.floor((list.height/30))

            if(slider.value>hhh)
             {
               var newval=Math.floor(hhh/2)
                slider.value=slider.value-newval

             }

            for(var i=0;i<model.count;i++)
            {
                //root.log(datetime((i+(slider.to-slider.value))*60))
            model.set(i,{time:datetime((i+(slider.to-slider.value))*60)})
            }

            for(var i=0;i<model.count;i++)
            {

         //
            list.itemAt(i).set_current((model.get(i).time==container.current) ? 1 : 0)

                  if(model.get(i).time==container.current)
                      res=1

            }

        }
    */

    }

    function datetime(value) {
        var str


         var hours=Math.floor(value/3600)
         var min=Math.floor((value-hours*3600)/60)
         var sec=Math.floor((value-hours*3600)-min*60)

    //    //root.log("datetime(value)")
   //     //root.log("hour: ",hour)
    //    //root.log("min: ",min)
    //    //root.log("min: ",sec)

        var str_hour
        if(hours<10)
        str_hour="0"+hours.toString()
        else
        str_hour=hours.toString()


        var str_min
        if(min<10)
        str_min="0"+min.toString()
        else
        str_min=min.toString()

        var str_sec
        if(sec<10)
        str_sec="0"+sec.toString()
        else
        str_sec=sec.toString()

        //root.log("str_sec: ",str_sec)

        var dt=new Date(calendar.selectedDate).toLocaleTimeString()




      var str_date
        if(hours<10)
        str_date =    Qt.formatDate(calendar.selectedDate,"yyyy")+"-"+
                      Qt.formatDate(calendar.selectedDate,"MM")+"-"+
                      Qt.formatDate(calendar.selectedDate,"dd")+" "+"0"+
                      +hours.toString()+":"+str_min+":00"//+str_sec//+"."+str_msec
        else
        str_date =    Qt.formatDate(calendar.selectedDate,"yyyy")+"-"+
                          Qt.formatDate(calendar.selectedDate,"MM")+"-"+
                          Qt.formatDate(calendar.selectedDate,"dd")+" "+
                          +hours.toString()+":"+str_min+":00"//+str_sec//+"."+str_msec



        var dateTimeString= "2013-09-17 09:56:06"

        //root.log("str_date ",str_date)


        var date=Date.fromLocaleString(locale, str_date, "yyyy-MM-dd hh:mm:ss")



        return Qt.formatTime(date,"hh:mm:ss")

    }

  function  update_all()
    {
        var xx=list.height/30
        //root.log("count ",model.count)
        while(model.count<xx)
        {
                    //root.log("count ",model.count)
            model.append({time: "" })

        }

        //root.log("count ",list.model.count)


        var howmutch=1440-(list.height/30)+1

        slider.to=howmutch

        //root.log("slider.to ",slider.to)

        //root.log("slider.value ",slider.value)

        //root.log("count ",model.count)

        for(var i=0;i<model.count;i++)
        {
            //root.log("--dt ",datetime((i+(slider.to-slider.value))*60))
        model.set(i,{time:datetime((i+(slider.to-slider.value))*60)})
        }

        update_view()
    }




}
