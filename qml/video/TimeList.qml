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

                var strings=str.split(":")


                var value=Number(strings[0])*60*60+Number(strings[1])*60+Number(strings[2])


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


        slider.value=slider.value+zoomFactor



               container.update_all()

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


           container.update_all()

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

        var date=Date.fromLocaleString(locale, str_date, "hh:mm:ss")

        var res=Qt.formatTime(date,"hh:mm:ss")

        container.current=res
        update_view()

    }

    function update_view()
    {
var res=0

        for(var i=0;i<model.count;i++)
        {

     //
        list.itemAt(i).set_current((model.get(i).time==container.current) ? 1 : 0)

              if(model.get(i).time==container.current)
                  res=1

        }

    }

    function datetime(value) {
        var str


         var hours=Math.floor(value/3600)
         var min=Math.floor((value-hours*3600)/60)
         var sec=Math.floor((value-hours*3600)-min*60)


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

        var date=Date.fromLocaleString(locale, str_date, "yyyy-MM-dd hh:mm:ss")



        return Qt.formatTime(date,"hh:mm:ss")

    }

  function  update_all()
    {
        var xx=list.height/30

        while(model.count<xx)
        {

            model.append({time: "" })

        }

        var howmutch=1441-(list.height/30)+1

        slider.to=howmutch

        for(var i=0;i<model.count;i++)
        {

        model.set(i,{time:datetime((i+(slider.to-slider.value))*60)})
        }

        update_view()
    }




}
