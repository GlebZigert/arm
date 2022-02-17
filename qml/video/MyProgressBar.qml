import QtQuick 2.0
import QtMultimedia 5.11
import QtQuick 2.11
import QtMultimedia 5.11
import QtQuick.Controls 1.4
//import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
import QtQuick.Controls.Styles 1.4
import QtQuick 2.9
import QtQuick.Controls 2.2
//import QtQuick.Controls.Styles 1.4
//import QtQuick.Controls 1.4
import "../../js/axxon.js" as Axxon

Item {
    id: m_item

    property bool play: true

    property string live: "РЕАЛЬНОЕ ВРЕМЯ"
    property string storage: "ЗАПИСЬ"
    property string mode: m_item.live
    property int speed: 1

    property var calendar

    signal signal_telemetry_on_off()
    signal signal_loaded_cameras_on_off()
    signal update_timelist(var dt)
    signal eventlog_on_off()
    signal tree_on_off()


//    signal dt_moved(string dt,int speed)

//    signal do_snapshot_rt()



        signal livestream_button_clicked()
        signal signal_dt(string dt)



        signal storage_stop()
        signal moved_at_dt(string dt)
        signal paused_and_moved_at_dt(string dt)
        signal pause_signal()
        signal play_signal()

     signal show_or_hide_calendar()

    Timer {
        id: timer
        interval: 1; running: true; repeat: true
        property int msec:0
        property var prev_date : 0
        property var sec : 0
        onTriggered:
        {

            var date=new Date().getTime()
            //root.log(prev_date," ",date)


        msec=msec+date-prev_date;
            prev_date=date
root.log("msec: ",msec)
            if(msec>1000)
            {

                msec=msec-1000
        increase()


                var dt=datetime(slider.value)
                Qt.formatTime(dt,"hh:mm:ss")
               //  root.log("!")
                  dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")

                sec++
                if(sec>60)
                {
              //      //root.log("[update_timelist(dt)]")
                sec=0
                update_timelist(dt)
                }
            }








        }


    }

    Timer {
        id: scroll_timer
        interval: 100; running: false; repeat: false
        onTriggered:
        {


                if(slider.pressed)
                {
                 scroll_timer.start()
                }
                else
                {

                //root.log("[!!!]")

              //      take_a_pause()
                    timer.msec=0
                    var dt=datetime(slider.value)

                    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")
                 moved_at_dt(get_dt(dt))
                    update_timelist(dt)
                 }

                if(m_item.play==false)
                {

                }

            }

    }

    Timer {
        id: delay
        interval: 500; running: false; repeat: false
        onTriggered:
        {



        }
    }




//    signal play_streaming()
//    signal pause_streaming()
//    signal stop_streaming()
Rectangle {

    width: parent.width
    height: 300

color: "lightgray"




Column {


    width: parent.width
    height: parent.height
  //  Layout.fillHeight: true
    Layout.fillWidth: true
    anchors.fill: parent



    id: main_item



    ListModel{
        id: m_intervals


    }

    ListModel{
        id: m_hours


    }

Slider { //сутки от 0 до 24
            id: slider
            width: parent.width
        //    height: 25
            from: 0
            value: 25
            stepSize: 1
            to: 86399
            wheelEnabled: true


            leftPadding: 0
            rightPadding: 0

            onMoved: {


                scroll_timer.stop()
                scroll_timer.start()

                var dt=datetime(slider.value)
                dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")

                m_item.mode=m_item.storage
               livestream_txt.text=m_item.mode



            }




            onPressedChanged:
            {
                if(pressed)
                {

                            m_item.mode=m_item.storage
                           livestream_txt.text=m_item.mode

                    var dt=datetime(slider.value)
                    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")
                }
                else
                {
                    scroll_timer.start()
                    var dt=datetime(slider.value)
                    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")


                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 4
                implicitHeight: 26
                radius: 1
                color: slider.pressed ? "#f0f0f0" : "#f6f6f6"
                border.color: "black"
            }


                background: Rectangle {
                    implicitWidth: 200
               //     implicitHeight: slider.height
                    color: "gray"
                    radius: 1



                        Repeater {

anchors.fill: parent

                            model: m_intervals
                            delegate: Rectangle {

                               x: convert_dt_to_slider_value(begin)*(slider.width/slider.to)
                               y:5
                               width: (convert_dt_to_slider_value(end)-convert_dt_to_slider_value(begin))*(slider.width/slider.to)
                               height: slider.height-10
                               color: "#d8edf3"
                               radius: 1

                            }
                        }


                        Repeater {

                           anchors.fill: parent

                            model: m_hours
                            delegate: Rectangle {

                                Text{
                                x:slider.availableWidth/24*model.num
                                y:slider.height/2-height/2
                                width: 10
                                height: 10
                                text: model.num
                                color: "black"


                                }


                            }

                        }



                    /*
                    Rectangle {
                                id: slider_active_interval
                                x:0
                                y:0
                                implicitWidth: 0
                                implicitHeight: slider.height
                                color: "#d8edf3"
                                radius: 1
                    }
                    */

                }



        }


Row {
    spacing: 6
    padding: 10


    Rectangle {
        id: time_rect
        color: "lightblue";
        width: 300;
        height: 40
        visible: true

        radius: 6
        border.width: 4
        border.color: "gray"


        Text {
            x:10
            y:5
            id: dt_text
            text: ""
            font.family: "Helvetica"
            font.pointSize: 20
            color: "black"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
            //    stop_streaming()
                root.log("show_or_hide_calendar")
                show_or_hide_calendar()

            }
        }


    }



       Rectangle {
        id: prev
        width: 40;
        height: 40
 color: "lightgray";

        Image {


            source: "Arrowhead-Left-01-40.png"
            anchors.fill: parent
              visible: true
        }

        MouseArea {
            anchors.fill: parent
        onClicked: {
            if(!delay.running){



            timer.stop()
          //      timer.msec=0

            timer.msec=timer.msec-50
            if(timer.msec<1)
              {
              timer.msec=999
        slider.value=slider.value-1


              }
            var dt=datetime(slider.value)

            dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")

            image.source="Media-Pause-40.png"//it was play
             m_item.play=false
            m_item.mode=m_item.storage
        livestream_txt.text=m_item.mode
             paused_and_moved_at_dt(get_dt(dt))
   delay.start()
        }else{
                console.log("running")
                }
        }
        }
    }

    Rectangle {
        width: 40
        height: 40
        id: play

        color: "lightgray";


        Image {
            id: image

            source:"Media-Play-40.png"

     //       width: (storage_videoOutput.height/1080)*1920
     //       height: storage_videoOutput.height
            anchors.fill: parent
              visible: true
        }
/*
        Text {
            id: pause_play_text
            text: "PLAY"
            font.family: "Helvetica"
            font.pointSize: 24
            color: "black"
        }
        */
        MouseArea {
            anchors.fill: parent
            onClicked: {


                play_or_pause()

            }

        }
    }

        Rectangle {
        id: next
        width: 40;
        height: 40

 color: "lightgray";

        Image {


            source: "Arrowhead-Right-01-40.png"
            anchors.fill: parent
              visible: true
        }
        MouseArea {
            anchors.fill: parent
        onClicked: {
            if(!delay.running){


            timer.stop()
           //     timer.msec=0

            timer.msec=timer.msec+50
            if(timer.msec>999)
              {
                timer.msec=0
                increase()

              }
            var dt=datetime(slider.value)

            dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")

            image.source="Media-Pause-40.png"//it was play
             m_item.play=false
            m_item.mode=m_item.storage
        livestream_txt.text=m_item.mode
         paused_and_moved_at_dt(get_dt(dt))
        delay.start()

        }else{
        console.log("running")
        }
        }
        }
    }

    Rectangle {
        id: livestream
        color: "lightblue";
        width: 300;
        height: 40

        radius: 6
        border.width: 4
        border.color: "gray"

        Text {

            id: livestream_txt
            text: m_item.mode
            x: 10
            y:5
            font.family: "Helvetica"
            font.pointSize: 20
            color: "black"
        }



        MouseArea {
            anchors.fill: parent
            onClicked: {
            //    stop_streaming()
                //root.log('[.]',livestream_txt.text)

                if(m_item.mode==m_item.storage)
                {
                    to_live()
                    livestream_button_clicked()

                }

                }

            }


    }
    /*
    Button{
        id: telemetry_on_offff
        width: 50;
        height: 40
        text: ">"


        onClicked: {


        signal_telemetry_on_off()

        }
    }
    */

    Rectangle {
     id: telemetry_on_off
     width: 40;
     height: 40
color: "lightgray";

     Image {


         source: "telemetry.png"
         anchors.fill: parent
           visible: true
     }

     MouseArea {
         anchors.fill: parent
     onClicked: {

         signal_telemetry_on_off()

     }
     }
 }

    Rectangle {
     id: camera_list
     width: 40;
     height: 40
color: "lightgray";

     Image {


         source: "camera_list.png"
         anchors.fill: parent
           visible: true
     }

     MouseArea {
         anchors.fill: parent
     onClicked: {

          signal_loaded_cameras_on_off()

     }
     }
 }

    Rectangle {
     id: event_log
     width: 40;
     height: 40
color: "lightgray";

     Image {


         source: "eventlog.png"
         anchors.fill: parent
           visible: true
     }

     MouseArea {
         anchors.fill: parent
     onClicked: {

          eventlog_on_off()

     }
     }
 }

    Rectangle {
     id: tree
     width: 40;
     height: 40
color: "lightgray";

     Image {


         source: "tree.png"
         anchors.fill: parent
           visible: true
     }

     MouseArea {
         anchors.fill: parent
     onClicked: {

          tree_on_off()

     }
     }
 }

    Rectangle {

        color: "lightgray";
        width: 300;
        height: 40
        visible: true

        radius: 6


    Text{
        x:10
        y:5
        id: camera_name_zone
        width: 40
        height: 240




        font.family: "Helvetica"
        font.pointSize: 20
        color: "black"
    }
    }

    /*
        ComboBox {
            id: speed_combobox
            model: ListModel {
                  id: speed_combobox_model
                  ListElement { text: "1" }
                  ListElement { text: "2" }
                  ListElement { text: "5" }
                  ListElement { text: "10" }


              }

            wheelEnabled: true

            onHighlightedIndexChanged:  {
            //root.log("speed_combobox.currentText",speed_combobox.currentText)
            m_item.speed=speed_combobox.currentText

                var dt=datetime(slider.value)

                dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")
                get_dt(dt)
            }
        }
    */


}
}






}
function increase()
{
    if((slider.value+m_item.speed)<slider.to)
    {
     slider.value=slider.value+m_item.speed
    }
    else
    {
      var dt=new Date(calendar.selectedDate)

      var nextDay = new Date();

      nextDay.setDate(dt.getDate() + (slider.value+m_item.speed-slider.to));

      calendar.selectedDate=nextDay



     slider.value=0;
    }

    var dt=datetime(slider.value)
    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")
 //   Axxon.send_dt(str)


}



function timer_stop()
{

timer.stop()
    timer.msec=0
time_rect.color="lightgray"
}

function timer_start()
{
    console.log("timer_start()")

    var dt=datetime(slider.value)
    Qt.formatTime(dt,"ss")
    var sec= Qt.formatTime(dt,"ss")
//root.log("секунд: ",sec)
    timer.sec=sec

time_rect.color="lightblue"
    var date=new Date().getTime()
//       //root.log(prev_date," ",date)
//       //root.log(date-prev_date)
    timer.prev_date=date
timer.start()
}



function get_dt(dt)
{
dt=datetime(slider.value)
//    storage_stop()
//    m_item.mode=m_item.storage
    livestream_txt.text=m_item.mode


    var msec=timer.msec

    var str_msec=msec.toString()

    if(msec<100)
    str_msec="0"+str_msec

    if(msec<10)
    str_msec="0"+str_msec

    str_msec=str_msec+"000"




 //   //root.log("[get_dt]--------------------------------------------------------")
    var str=    Qt.formatDate(dt,"yyyy")+
            Qt.formatDate(dt,"MM")+
            Qt.formatDate(dt,"dd")+
            "T"+
            Qt.formatTime(dt,"hh")+
            Qt.formatTime(dt,"mm")+
            Qt.formatTime(dt,"ss")+
            "."+
            str_msec

    //root.log("[",str,"]")

    return str

}
//"rtsp://root:root@192.168.0.187:50554/archive/hosts/ASTRAAXXON/DeviceIpint.2/SourceEndpoint.video:0:1/20210427T143416.870000?speed=1"



Component.onCompleted: {

    for(var i=0;i<24;i++)
        m_hours.append({num:i})
//livestream_button_clicked()
    timer.prev_date=new Date().getTime()
//to_live()

    console.log("[myprogressbar]")


 //   root.stream_from_storage.updated.connect(update)




}

function update() {

   // var x=root.stream_from_storage.get(1)
  //  //root.log(x.name)
  //  screen.source=x.stream


}



function datetime(value) {
    var str

    value=slider.value
     var hours=Math.floor(value/3600)
     var min=Math.floor((value-hours*3600)/60)
     var sec=((value-hours*3600)-min*60)
     var msec=timer.msec
     ////root.log("часы ",hours)
     ////root.log("мин ",min)
     ////root.log("сек ",sec)

    var str_hour
    if(hours<10)
    str_hour="0"+hours.toString()
    else
    str_hour=hours.toString()

    ////root.log("str_hour ",str_hour)

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

    var str_msec

    str_msec=msec.toString()

    if(msec<100)
    str_msec="0"+msec.toString()

    if(msec<10)
    str_msec="0"+str_msec


 //   ////root.log("calendar.data "+calendar.selectedDate)

  //  root.log("calendar.selectedDate: ",calendar.selectedDate)
    var dt=new Date(calendar.selectedDate).toLocaleTimeString()





//    ////root.log("dt "+dt)


//    ////root.log("dd "+Qt.formatDate(calendar.selectedDate,"dd"))
//   ////root.log("dd "+Qt.formatDate(calendar.selectedDate,"MM"))
//    ////root.log("dd "+Qt.formatDate(calendar.selectedDate,"yyyy"))




//
//    str=    Qt.formatDate(calendar.selectedDate,"yyyy")+
//            Qt.formatDate(calendar.selectedDate,"MM")+
//            Qt.formatDate(calendar.selectedDate,"dd")+
//           "T"+str_hour+str_min+str_sec
//
    ////root.log("str_hour ",str_hour)


  var str_date
    if(hours<10)
    str_date =    Qt.formatDate(calendar.selectedDate,"yyyy")+"-"+
                  Qt.formatDate(calendar.selectedDate,"MM")+"-"+
                  Qt.formatDate(calendar.selectedDate,"dd")+" "+"0"+
                  +hours.toString()+":"+str_min+":"+str_sec//+"."+str_msec
    else
    str_date =    Qt.formatDate(calendar.selectedDate,"yyyy")+"-"+
                      Qt.formatDate(calendar.selectedDate,"MM")+"-"+
                      Qt.formatDate(calendar.selectedDate,"dd")+" "+
                      +hours.toString()+":"+str_min+":"+str_sec//+"."+str_msec






    var dateTimeString= "2013-09-17 09:56:06"
     ////root.log("str: ",str)
     ////root.log("str_date: ",str_date)
     ////root.log("dateTimeString: ",dateTimeString)

    var date=Date.fromLocaleString(locale, str_date, "yyyy-MM-dd hh:mm:ss")

 //   var date=Date.fromLocaleDateString(locale, str_date, "dd.MM.yyyy hh:mm:ss")

    ////root.log(Date.fromLocaleString(locale, dateTimeString, "yyyy-MM-dd hh:mm:ss"));
//    ////root.log(Date.fromLocaleString(locale, str_date, "yyyy-MM-dd hh:mm:ss"));
    //root.log("//========================================  ",date)

    ////root.log("dd "+Qt.formatDate(date,"dd"))
    ////root.log("MM "+Qt.formatDate(date,"MM"))
    ////root.log("yyyy "+Qt.formatDate(date,"yyyy"))
    ////root.log("hh "+Qt.formatTime(date,"hh"))
    ////root.log("mm "+Qt.formatTime(date,"mm"))
    ////root.log("ss "+Qt.formatTime(date,"ss"))



    return date

}





function set_sliders_and_calendar_from_current_datetime_value(dt)
{
  slider.value=convert_dt_to_slider_value(dt)

    m_item.mode=m_item.storage
   livestream_txt.text=m_item.mode
   update_timelist(dt)
    /*
root.log(dt)

    var x=   parseInt(Qt.formatTime(dt,"hh"))*3600+
            parseInt(Qt.formatTime(dt,"mm"))*60+
            parseInt(Qt.formatTime(dt,"ss"))

    slider.value=x
    */
}

function take_a_pause()
{

image.source="Media-Pause-40.png" //it was play

m_item.play=false


timer.stop()
    timer.msec=0
pause()

}


function send_dt()
{
    var dt=datetime(slider.value)
    signal_dt(get_dt(dt))
}





function play_or_pause()
{

    if(m_item.play==false)
    {
        image.source="Media-Play-40.png"
        m_item.play=true
   //root.log("------------------")
    //root.log("[play!]")
        var dt=datetime(slider.value)

        dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")
        root.log("=======================")
        root.log(" ")
        root.log(" ")
        root.log(" ")
 root.log("Запустил на времени: ",dt)
      root.log(" ")
      root.log(" ")
      root.log(" ")
        root.log("=======================")

        play_signal()

    }
    else
    {

        image.source="Media-Pause-40.png"//it was play
         m_item.play=false
        //root.log("------------------")
        //root.log("[pause]")

            timer.stop()
    //        timer.msec=0
    //     pause()
        var dt=datetime(slider.value)
          root.log("=======================")
          root.log(" ")
          root.log(" ")
          root.log(" ")
   root.log("Остановил на времени: ",dt," ",timer.msec)
        root.log(" ")
        root.log(" ")
        root.log(" ")
          root.log("=======================")
        dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")



        m_item.mode=m_item.storage
       livestream_txt.text=m_item.mode

        pause_signal()
    }



}

function set_time(value)
{

    slider.value=value

    scroll_timer.stop()
    scroll_timer.start()

    var dt=datetime(slider.value)
    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")
    m_item.mode=m_item.storage
   livestream_txt.text=m_item.mode
////root.log("[!!!]")
}

function convert_dt(dt)
{
dt=dt.replace("T","")
var value = parseFloat(dt)
////root.log(value)

return value
}
/*
function convert_dt_to_slider_value(dt)
{

var year=dt.slice(0,4)
var mouth=dt.slice(4,6)
var day=dt.slice(6,8)


//root.log("year", year)
//root.log("mouth", mouth)
//root.log("day", day)

var hour=dt.slice(9,11)
var min=dt.slice(11,13)
var sec=dt.slice(13,15)
var msec=dt.slice(16,22)

//root.log("hour ", hour)
//root.log("min ", min)
//root.log("sec ", sec)
//root.log("msec ", msec)

var value=hour*3600+min*60+sec

return value
}
*/

function compare_dt(dt1, dt2) //из первого вычитаем второе
{
return(convert_dt(dt1)-(convert_dt(dt2)))
}

function convert_dt_to_slider_value(dt)
{






////root.log("year", year)
////root.log("mouth", mouth)
////root.log("day", day)

var hour=dt.substring(9,11)
var min=dt.substring(11,13)
var sec=dt.substring(13,15)
var msec=dt.substring(16,22)

//root.log("hour ", hour)
//root.log("min ", min)
//root.log("sec ", sec)
////root.log("msec ", msec)

var value=hour*3600+min*60+sec*1

return value
}

function update_slider_intervals(intervals)
{

   // calendar.selectedDate



 //   root.log("[update_slider_intervals]")
 //    root.log("интервалы: ", JSON.stringify(intervals))
//    root.log(intervals)
    m_intervals.clear()
var dt=datetime(0)

 var c_begin= Qt.formatDate(dt,"yyyy")+
            Qt.formatDate(dt,"MM")+
            Qt.formatDate(dt,"dd")+
            "T"+"000000.000000"




var c_end=   Qt.formatDate(dt,"yyyy")+
Qt.formatDate(dt,"MM")+
Qt.formatDate(dt,"dd")+
"T"+"235959.999999"

//----------------

  //  root.log("c_begin ",c_begin)
  //  root.log("c_end ",c_end)



    if(intervals.intervals)
    {
  //   root.log("кол-во интервалов: ",intervals.intervals.length)
    if(intervals.intervals.length>0)
    for (var i=0;i<intervals.intervals.length;i++) {

 //   root.log("--- ",i)
    var begin=intervals.intervals[i].begin
    var end=intervals.intervals[i].end

   // root.log("begin ",begin)
   // root.log("end ",end)

        if(compare_dt(c_begin,end)>0)
        {
     //   root.log("полностью позади")

        }
        else
        if(compare_dt(begin,c_end)>0)
        {

     //   root.log("полностью спереди")

        }
        else
        {

        var my_begin
        var my_end

            if(compare_dt(c_begin,begin)>0)
            my_begin=c_begin
            else
            my_begin=begin

            if(compare_dt(c_end,end)>0)
            my_end=end
            else
            my_end=c_end

  //      root.log("my_begin ",my_begin)
  //      root.log("my_end ",my_end)

            //root.log("slider begin ",convert_dt_to_slider_value(my_begin))
            //root.log("slider end ",convert_dt_to_slider_value(my_end))
            //root.log("slider to ",slider.to)
      //     convert_dt_to_slider_value(dt)


      //    var x=convert_dt_to_slider_value(my_begin)*(slider.width/slider.to)
      //    var width=(convert_dt_to_slider_value(my_end)-convert_dt_to_slider_value(my_begin))*(slider.width/slider.to)


          m_intervals.append({begin:my_begin,end:my_end})

     //     m_intervals.append({_x:x,_width:width})

        }








    }
}

/*
    root.log("интервалы: ",m_intervals.count)
        if(m_intervals.count>0)
        for(var i=0;i<m_intervals.count;i++)
        {
        root.log("интервал: ",i)
      root.log("_x: ",m_intervals.get(i)._x)
   root.log("_width: ",m_intervals.get(i)._width)
        }
        */

}

function current_dt()
{
    root.log("[current_dt()]")
    var dt=datetime(slider.value)

    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")

    var str =get_dt(dt)

    root.log("str ",str)
    return str
}

function to_storage(){
    root.log("[to storage]")
        m_item.mode=m_item.storage
    livestream_txt.text=m_item.mode
}

function to_live()
{
root.log("[to live]")
    m_item.mode=m_item.live
livestream_txt.text=m_item.mode


    var dt= new Date()
    //root.log("-----------------------------------[dt]",dt)



    var x=   parseInt(Qt.formatTime(dt,"hh"))*3600+
            parseInt(Qt.formatTime(dt,"mm"))*60+
            parseInt(Qt.formatTime(dt,"ss"))

    slider.value=x

    image.source="Media-Play-40.png"
    m_item.play=true


    calendar.selectedDate=dt
    timer.prev_date=new Date().getTime()
    timer.start()
//в графе времени даты отобразить текущее настояшее время дату
//на слайдере переестить бегунок на позицию соответствующее текущему времени
}

function calendar_data_changed()
{
    m_item.mode=m_item.storage
livestream_txt.text=m_item.mode

    var dt=datetime(slider.value)

    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")
 moved_at_dt(get_dt(dt))
    update_timelist(dt)
}

function  set_camera_zone(str){
camera_name_zone.text=str
}







}



