import QtQuick 2.11
import QtMultimedia 5.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5

import "../../js/axxon_telemetry_control.js" as Tlmtr
import "../../js/axxon.js" as Axxon

Item {

    property int serviceId:-1

    property string point: "ASTRAAXXON/DeviceIpint.2/TelemetryControl.0"

    Timer {
        id:timer
        interval: 5000; running: false; repeat: true
        onTriggered:
        {

        if (drop_area.containsMouse)
        {

        Tlmtr.hold_session()

        }
        else
        {

        timer.stop()
        }



        }

    }

Rectangle{
    width: 260
    height: 160
    border.color: "gray"
    border.width: 2
    radius: 5
}

Row{


    Rectangle{

    width: 160
    height: 160
    color: "lightgray"
    border.color: "gray"
    border.width: 2
    radius: 5
    Test_Control{
        id: control

    }


    }


//Zoom
    Rectangle{

    width: 50
    height: 160
    color: "lightgray"

    Column{
    anchors.fill:parent
    Rectangle{
    id: zoom_in
    color:"lightgray"
    width: parent.width
    height: parent.height/2
    border.color: "gray"
    border.width: 2
    radius: 5

    MouseArea{
        id: zoom_area
    anchors.fill:parent
        onPressed: {
        Tlmtr.zoom_in()
        }
        onReleased: {

            Tlmtr.stop_zoom()
        }
    }
    }


    Rectangle{
    id: zoom_out
    color:"lightgray"
    width: parent.width
    height: parent.height/2
    border.color: "gray"
    border.width: 2
    radius: 5

    MouseArea{
    anchors.fill:parent
    propagateComposedEvents: true
        onPressed: {
        Tlmtr.zoom_out()
        }
        onReleased: {

            Tlmtr.stop_zoom()
        }
    }
    }

    }


    }


    //Focus
        Rectangle{

        width: 50
        height: 160
        color: "lightgray"

        Column{
        anchors.fill:parent
        Rectangle{
        id: focus_in
        color:"lightgray"
        width: parent.width
        height: parent.height/2
        border.color: "gray"
        border.width: 2
        radius: 5

        MouseArea{
            id: focus_area
        anchors.fill:parent
            onPressed: {
            Tlmtr.focus_in()
            }
            onReleased: {

                Tlmtr.stop_focus()
            }
        }
        }


        Rectangle{
        id: focus_out
        color:"lightgray"
        width: parent.width
        height: parent.height/2
        border.color: "gray"
        border.width: 2
        radius: 5

        MouseArea{
        anchors.fill:parent
        propagateComposedEvents: true
            onPressed: {
            Tlmtr.focus_out()
            }
            onReleased: {

                Tlmtr.stop_focus()
            }
        }
        }

        }


        }


}
    MouseArea {
        id: drop_area
        hoverEnabled: true

        anchors.fill: parent

        propagateComposedEvents : true


    onClicked: {
        mouse.accepted=false}

    onPressed: {
        mouse.accepted=false

    }

    onReleased: {

        Tlmtr.stop_moving()
    }

    onEntered: {

        Tlmtr.capture_session(point)
        timer.start()



    }



        property int zoom: 0
        property int zoom_prev: 0

        onWheel:
        {



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

}

    Timer {
        id:zoom_timer
        interval: 300; running: false; repeat: false
        property int msec:0
        onTriggered:
        {

            Tlmtr.stop_zoom()
            drop_area.zoom_prev=0
        }
    }

    function set_point(str)
    {
    point=str
    Tlmtr.capture_session(point)
    }



    function set_disabled()
    {
    drop_area.enabled=false
    zoom_area.enabled=false
    control.set_disabled()
    }

    function set_enabled()
    {
    drop_area.enabled=true
    zoom_area.enabled=true
    control.set_enabled()
    }

    function set_serviceId(id)
    {
    serviceId=id
    control.set_serviceId(id)
    }

}













