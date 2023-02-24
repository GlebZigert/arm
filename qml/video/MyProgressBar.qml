import QtQuick 2.0
import QtMultimedia 5.11
import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.5
import QtQuick.Controls.Styles 1.4
import QtQuick 2.9
import QtQuick.Controls 2.2
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

    signal livestream_button_clicked()
    signal signal_dt(string dt)

    signal storage_stop()
    signal moved_at_dt(string dt)
    signal paused_and_moved_at_dt(string dt)
    signal pause_signal()
    signal play_signal()
    signal show_or_hide_calendar()
    signal to_storage_cameras()

    Timer {
        id: timer
        interval: 1; running: true; repeat: true
        property int msec:0
        property var prev_date : 0
        property int sec : 0
        onTriggered:
        {

            var date=new Date().getTime()

        msec=msec+date-prev_date;
            prev_date=date

            if(msec>1000)
            {

                msec=msec-1000
        increase()


                var dt=datetime(slider.value)
                Qt.formatTime(dt,"hh:mm:ss")

                  dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")

                sec++
                if(sec>60)
                {

                sec=0
                update_timelist(dt)
                }
            }
            if (msec<0)
                msec=0;
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

                    timer.msec=0
                    var dt=datetime(slider.value)

                    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")

                    storage_toolbox.visible=true
                    to_storage_toolbox.visible=false

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
        interval: 250; running: false; repeat: false
        onTriggered:
        {

        }
    }

Rectangle {

    width: parent.width
    height: 300

color: "lightgray"

Column {


    width: parent.width
    height: parent.height
    Layout.fillWidth: true
    anchors.fill: parent
    id: main_item

    ListModel{
        id: m_intervals
    }

    ListModel{
        id: m_hours
    }

Slider {
            id: slider
            width: parent.width

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
                show_or_hide_calendar()
            }
        }
    }

    Rectangle{

        width: 160;
        height: 40
        color: "lightgray"

    Row{
        x:20
        y:0
        width: 120;
        height: 40
        id: storage_toolbox


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

            storage_toolbox.visible=true
            to_storage_toolbox.visible=false
    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")
             paused_and_moved_at_dt(get_dt(dt))
       delay.start()
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


            anchors.fill: parent
              visible: true
        }

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

            storage_toolbox.visible=true
            to_storage_toolbox.visible=false

         paused_and_moved_at_dt(get_dt(dt))
        delay.start()

        }
        }
        }
    }

    }

    Rectangle{
        id: to_storage_toolbox
        width: 160;
        height: 40
        color: "lightgray"
        radius: 6
        border.width: 4
        border.color: "gray"

        Text {


            x:10
            y:5
            font.family: "Helvetica"
            font.pointSize: 20
            color: "black"
            text:"В АРХИВ"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {

                    console.log("to_storage_toolbox")

                    var max = "000000T000000.000000"
                            console.log("m_intervals.length ",m_intervals.count)
                    for (var i=0; i < m_intervals.count;i++) {

                       var dt=m_intervals.get(i).end
                         console.log(" dt: ",dt,"; max :",max)
                        if(compare_dt(dt,max)>0){
                        max=dt
                        }




                    }

                    console.log("max :",max)

                    max=max.substring(0,14)+"000000"

                    set_sliders_and_calendar_from_current_datetime_value(max)


                    storage_toolbox.visible=true
                    to_storage_toolbox.visible=false
    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")
                    moved_at_dt(get_dt(max))



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
            x: 10
            y:5
            font.family: "Helvetica"
            font.pointSize: 20
            color: "black"
        }



        MouseArea {
            anchors.fill: parent
            onClicked: {

                if(m_item.mode==m_item.storage)
                {

                    to_live()
                    livestream_button_clicked()

                }
                }
            }
    }

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

    Rectangle{
        id: to_storage_cameras
        width: 160;
        height: 40
        color: "lightgray"
        radius: 6
        border.width: 4
        border.color: "gray"

        Text {


            x:10
            y:5
            font.family: "Helvetica"
            font.pointSize: 20
            color: "black"
            text:"Вернуться к просмотру камер"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {

                m_item.to_storage_cameras()
                }
            }

    }


}
}

}
function increase()
{
    //console.log(slider.value," ",m_item.speed," ",slider.to)

    if((slider.value+m_item.speed)<slider.to)
    {
     slider.value=slider.value+m_item.speed
    }
    else
    {
        //console.log("! slider.value+m_item.speed)<slider.to")
      var dt=new Date(calendar.selectedDate)

      var nextDay = new Date();

      nextDay.setDate(dt.getDate() + 1);

      calendar.selectedDate=nextDay



     slider.value=0;
    }

    var dt=datetime(slider.value)
    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")

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

    timer.sec=sec

    time_rect.color="lightblue"
    var date=new Date().getTime()

    timer.prev_date=date
    timer.start()
}

function get_dt(dt)
{
dt=datetime(slider.value)

    livestream_txt.text=m_item.mode


    var msec=timer.msec

    var str_msec=msec.toString()

    if(msec<100)
    str_msec="0"+str_msec

    if(msec<10)
    str_msec="0"+str_msec

    str_msec=str_msec+"000"

    var str=    Qt.formatDate(dt,"yyyy")+
            Qt.formatDate(dt,"MM")+
            Qt.formatDate(dt,"dd")+
            "T"+
            Qt.formatTime(dt,"hh")+
            Qt.formatTime(dt,"mm")+
            Qt.formatTime(dt,"ss")+
            "."+
            str_msec



    return str

}

Component.onCompleted: {

    for(var i=0;i<24;i++)
    m_hours.append({num:i})

    timer.prev_date=new Date().getTime()



}

function update() {

}

function datetime(value) {
    var str

    value=slider.value
     var hours=Math.floor(value/3600)
     var min=Math.floor((value-hours*3600)/60)
     var sec=((value-hours*3600)-min*60)
     var msec=timer.msec

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

    var str_msec

    str_msec=msec.toString()

    if(msec<100)
    str_msec="0"+msec.toString()

    if(msec<10)
    str_msec="0"+str_msec

    var dt=new Date(calendar.selectedDate).toLocaleTimeString()

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


    var date=Date.fromLocaleString(locale, str_date, "yyyy-MM-dd hh:mm:ss")

    return date

}





function set_sliders_and_calendar_from_current_datetime_value(dt)
{
    console.log("set_sliders_and_calendar_from_current_datetime_value(dt)")

  slider.value=convert_dt_to_slider_value(dt)

    console.log("dt: ",dt)
    console.log("year: ",parseInt(dt.substring(0, 4)))
    console.log("month: ",parseInt(dt.substring(4, 6))-1)
    console.log("day: ",parseInt(dt.substring(6, 8)))



    var date=new Date()

    date.setFullYear(parseInt(dt.substring(0, 4)))
    date.setMonth(parseInt(dt.substring(4, 6))-1)
    date.setDate(parseInt(dt.substring(6, 8)))

   console.log( date.getFullYear())
    console.log( date.getMonth())
    console.log( date.getDay())
    console.log( date)

    console.log("Date: ",date)

    calendar.selectedDate=date

    console.log("calendar.selectedDate: ",calendar.selectedDate)
    m_item.mode=m_item.storage
   livestream_txt.text=m_item.mode
   update_timelist(dt)
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

        var dt=datetime(slider.value)
        timer.prev_date=new Date().getTime()
        timer.start()
        dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")


        play_signal()

    }
    else
    {

        image.source="Media-Pause-40.png"//it was play
         m_item.play=false


            timer.stop()

        var dt=datetime(slider.value)

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

}

function convert_dt(dt)
{
dt=dt.replace("T","")
var value = parseFloat(dt)


return value
}


function compare_dt(dt1, dt2) //из первого вычитаем второе
{
return(convert_dt(dt1)-(convert_dt(dt2)))
}

function convert_dt_to_slider_value(dt)
{



var hour=dt.substring(9,11)
var min=dt.substring(11,13)
var sec=dt.substring(13,15)
var msec=dt.substring(16,22)

var value=hour*3600+min*60+sec*1

return value
}

function check_dt(){

}

function update_slider_intervals(intervals)
{
    console.log("update_slider_intervals: ",intervals)

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


    if(intervals.intervals)
    {

    if(intervals.intervals.length>0)
    for (var i=0;i<intervals.intervals.length;i++) {


    var begin=intervals.intervals[i].begin
    var end=intervals.intervals[i].end


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

          m_intervals.append({begin:my_begin,end:my_end})


        }
    }
}
}

function current_dt()
{

    var dt=datetime(slider.value)

    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")

    var str =get_dt(dt)


    return str
}

function to_storage(){

        m_item.mode=m_item.storage
    livestream_txt.text=m_item.mode
}

function to_live()
{

    m_item.mode=m_item.live
livestream_txt.text=m_item.mode


    var dt= new Date()
    var x=   parseInt(Qt.formatTime(dt,"hh"))*3600+
            parseInt(Qt.formatTime(dt,"mm"))*60+
            parseInt(Qt.formatTime(dt,"ss"))

    slider.value=x

    image.source="Media-Play-40.png"
    m_item.play=true


    calendar.selectedDate=dt
    timer.prev_date=new Date().getTime()
    to_storage_toolbox.visible=true
    storage_toolbox.visible=false
    timer.start()

}

function calendar_data_changed()
{
    m_item.mode=m_item.storage
livestream_txt.text=m_item.mode

    var dt=datetime(slider.value)

    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")

    storage_toolbox.visible=true
    to_storage_toolbox.visible=false
    dt_text.text=Qt.formatDateTime(dt,"dd.MM.yyyy hh:mm:ss")

 moved_at_dt(get_dt(dt))
    update_timelist(dt)
}

function  set_camera_zone(str){
camera_name_zone.text=str
}
}
