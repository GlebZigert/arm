import QtQuick 2.11
import "../../js/axxon.js" as Axxon
import MyQMLEnums 13.37
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
import QtQuick.Controls.Styles 1.4
    import QtQuick.Controls 1.4
Item{
    anchors.fill: parent
    property int cid: -1

    id: base

    property string live: "live"

    property int dy
    property int dx

    property var wnd

    signal open_in_alarm_window(int id)

    signal switch_tlmtr

    Timer {
        id: start_timer
        interval: 500; running: true; repeat: false

        onTriggered:
        {
            multivm.to_page(0)
            multivm.rescale()
            if(multivm.get_cids().length){
            request_URL(multivm.get_cids(),Axxon.camera(multivm.get_cids()[0]).serviceId,"")
            }



    }
    }

    Timer {
        id: shoot
        interval: 500; running: false; repeat: false
        property int msec:0
        property var prev_date : 0
        property int sec : 0
        onTriggered:
        {
            interval: 500
            multivm.to_next_page()


    }
    }

    Timer {
        id: timer
        interval: 7000; running: false; repeat: true
        property int msec:0
        property var prev_date : 0
        property int sec : 0
        onTriggered:
        {
            interval: 5000
            multivm.to_next_page()


    }
    }
    SplitView{
  anchors.fill: parent
        orientation: Qt.Vertical
    Rectangle {
        width: parent.width
        height: parent.height-30
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "gray"
/*
        MouseArea{
             anchors.fill: parent
       //      propagateComposedEvents: true
             onClicked: {

             }

   }
        */

            MultiVM{
                id: multivm

                anchors.fill: parent


            }




    Loaded_cameras {
        anchors.fill: parent
        id: camera_storage
        visible: false
    }

    Rectangle {

        id: tlmt_rect
        x:100
        y:100
        width: 260
        height: 710
        color: "gray"

        Rectangle {
            id: telemetry_menu

            width: 260
            height: 700
            y:10

            //  color: "lightgray"
            color: "green"
            Column{
                height: parent.height

                Preset_List{
                    id: preset_list
                    width: 260
                    height: parent.height-telemetry.height

                }

                Test_Telemetry{
                    id: telemetry

                    width: 260
                    height: 160


                }
            }
        }
        MouseArea {
            id: tlmtr_rect_area
            width: parent.width
            height: 10
            x:0
            y:0
            drag.target: parent
        }



    }
    }

    Rectangle{
          id: panel
          width: parent.width
          height: 40
          Layout.maximumHeight: 40
          Layout.minimumWidth: 40
          color: "lightgray"



    Row{

    anchors.fill: parent

        spacing: 2


        Button{
            width: 40
            height: 40

            style: ButtonStyle {

                label: Image {
                    source: "video-wall-right.png"
                    fillMode: Image.PreserveAspectFit  // ensure it fits
                }
            }

            onClicked: {
                        timer.stop()
                console.log("onClicked .")
                timer.stop()
                shoot.stop()
             //   multivm.to_next_page()
                shoot.start()
            }
        }

        Button{
            width: 40
            height: 40

            style: ButtonStyle {

                label: Image {
                    source: "grid.png"
                    fillMode: Image.PreserveAspectFit  // ensure it fits
                }
            }

            onClicked: {
                        timer.stop()
                console.log("onClicked .")
                timer.stop()
   multivm.next_scale()
            }
        }
        /*
        Rectangle{
            width:40
            height: 40
            opacity: 1
            color:"#00000000"
            Image {
                source: "/qml/video/fullsize.png"
                anchors.fill: parent
                visible: true
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                            timer.stop()
               multivm.next_scale()
                }
            }
        }
        */

        Button{
            width: 40
            height: 40

            style: ButtonStyle {

                label: Image {
                    source:  timer.running ? "play.png" : "pause.png"
                    fillMode: Image.PreserveAspectFit  // ensure it fits
                }
            }

            onClicked: {

                console.log("onClicked .")
                if(timer.running)
                    timer.stop()
                else
                    timer.start()
            }
        }

        /*
        Rectangle{
            width:40
            height: 40
            opacity: 1
            color:"#00000000"
            Image {
                source: timer.running ? "Media-Play-40.png" : "Media-Pause-40.png"
                anchors.fill: parent
                visible: true
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    if(timer.running)
                        timer.stop()
                    else
                        timer.start()
                }
            }
        }
        */


        Button{
            width: 40
            height: 40


            style: ButtonStyle {

                label: Image {
                    source:  "video-wall-remove.png"
                    fillMode: Image.PreserveAspectFit  // ensure it fits
                }
            }

            onClicked: {
                console.log("onClicked .")
                        timer.stop()
               page_delete_view.visible=true
            }
        }

        Button{
            width: 40
            height: 40

            style: ButtonStyle {

                label: Image {
                    source:  "video-wall-add.png"
                    fillMode: Image.PreserveAspectFit  // ensure it fits
                }
            }

            onClicked: {
                console.log("onClicked .")
                        timer.stop()
                page_input_view.visible=true
                page_name_input.forceActiveFocus()

            }

        }

        Rectangle {

            color: "lightblue";
            width: 200
            height: 40
            visible: true
    /*
            radius: 6
            border.width: 4
            border.color: "gray"
    */
            Text {
                x:10
                y:5
                id: pageName
                text: ""
                font.family: "Helvetica"
                font.pointSize: 20
                color: "black"
            }



    }

        Rectangle {

            color: "lightblue";
            width: 200
            height: 40
            visible: true
    /*
            radius: 6
            border.width: 4
            border.color: "gray"
    */
            Text {
                x:10
                y:5
                id: cameraName
                text: ""
                font.family: "Helvetica"
                font.pointSize: 20
                color: "black"
            }



    }

        Rectangle {

            color: "lightblue";
            width: 200
            height: 40
            visible: true
    /*
            radius: 6
            border.width: 4
            border.color: "gray"
    */
            TextInput {
                x:10
                y:5
                id: cameraIpAddr
                readOnly: true
                text: ""
                font.family: "Helvetica"
                font.pointSize: 20
                color: "black"
            }



    }

        Button{
            width: 40
            height: 40

            style: ButtonStyle {

                label: Image {
                    source:  "down.png"
                    fillMode: Image.PreserveAspectFit  // ensure it fits
                }
            }

            onClicked: {
                panel.height=0
                      multivm.rescale()
            }
        }
        /*
        Rectangle{
            x: panel.width-90
            width:40
            height: 40
            opacity: 1
            color:"#00000000"

            Image {

                source: "/qml/video/fullsize.png"
                anchors.fill: parent
                visible: true
            }

            MouseArea{
                anchors.fill: parent

                onClicked: {

              panel.height=0
                    multivm.rescale()
                }
            }
        }
        */

        Button{
            width: 40
            height: 40

            style: ButtonStyle {

                label: Image {
                    source:  "fullscreen.png"
                    fillMode: Image.PreserveAspectFit  // ensure it fits
                }
            }

            onClicked: {

                console.log("visibility: ",wnd.visibility)

                if(wnd.visibility===5){
                wnd.visibility=1
                }else{
                                 wnd.visibility=5
                }
                multivm.rescale_timer_start()
            }
        }



        /*
        Rectangle{
            x: panel.width-45
            width:40
            height: 40
            opacity: 1
            color:"#00000000"

            Image {

               source: "/qml/video/fullsize.png"
                anchors.fill: parent
                visible: true
            }

            MouseArea{
                anchors.fill: parent

                onClicked: {

                    console.log("visibility: ",wnd.visibility)

                    if(wnd.visibility===5){
                    wnd.visibility=1
                    }else{
                                     wnd.visibility=5
                    }
                    multivm.rescale_timer_start()

                }
            }
        }
        */



}

      }
    }

    Rectangle{
        id: page_delete_view
        x:base.width/2-100
        y:base.height/2-20
        width: 200
        height: 40
        color: "lightgray"
        visible: false
        Row{
            anchors.fill: parent

            Button{
                style: ButtonStyle {
                    label: Text {
                        text:"Удалить"
                    }
                }
                width: 100
                height: 40
                onClicked: {
                    multivm.multivm_delete_page()
                    page_delete_view.visible=false
                }
            }
            Button{
                width: 100
                height: 40
                style: ButtonStyle {
                    label: Text {
                        text:"Отмена"
                    }
                }
                onClicked: {
                    page_delete_view.visible=false
                }
            }
        }
    }

    Rectangle{
        id: page_input_view
        x:base.width/2-250
        y:base.height/2-20
        width: 500
        height: 40
        color: "lightblue"
        border.color: "lightgray"
        border.width: 1
        visible: false
        Row{
            anchors.fill: parent
            TextInput {
                id: pageName_input
                width: 300
                height: 40
                text: "Text"
                cursorVisible: false
            }
            Button{
                width: 100
                height: 40
                style: ButtonStyle {
                    label: Text {
                        id: page_name_input
                        text:"Добавить"



                    }
                }
                onClicked: {

                    if(pageName_input.text=="Архив")
                        return

                    if(pageName_input.text=="Тревоги")
                        return

                    multivm.multivm_add_page(pageName_input.text,7)
                    page_input_view.visible=false
                }
            }
            Button{
                width: 100
                height: 40
                style: ButtonStyle {
                    label: Text {
                        text:"Отмена"
                    }
                }
                onClicked: {
                    page_input_view.visible=false
                }
            }
        }
    }

    function give_him_a_camera(){
        console.log("give_him_a_camera()")
        camera_storage.visible=true
    }

    function f_change_camera(id){
        console.log("f_change_camera ",cid)
        cid=id

        if(id!==-1){
            var lcl
            lcl=Axxon.camera(id)
            root.axxon_service_id=lcl.sid
            root.log(lcl.name)
            //   configPanel.state="hide"

            //   telemetry.set_serviceId(lcl.sid)
            //   preset_list.serviceId=lcl.sid

            //   root.log("telemetryControlID: ",lcl.telemetryControlID)
            //   root.telemetryPoint=lcl.telemetryControlID

            var dt=""

            //   root.deviceSelected(panePosition,lcl.sid,lcl.id)
            multivm.set_current_cid(cid)
            request_URL(multivm.get_cids(),lcl.serviceId,dt)
            cameraName.text=lcl.name
            cameraIpAddr.text=lcl.ipadress



        }
    }



    Component.onCompleted: {

        root.frash_URL.connect(f_current_camera_update)
        multivm.give_me_a_camera.connect(give_him_a_camera)

        root.cameraList.updated.connect(camera_storage.update_from_cameraList)
        camera_storage.add_to_space.connect(f_change_camera)

        multivm.open_in_alarm_window.connect(f_open_in_alarm_window)

        multivm.switch_tlmtr.connect(f_switch_tlmtr)

        //   root.cameraList.updated.connect(multivm.reconnect_livestream)

        tlmt_rect.visible=false
        multivm.rescale(multivm.scale)

        multivm.onCompleted.connect(set_the_multivm_settings)

        multivm.currentPage.connect(f_currentPage)

                multivm.selected_cid.connect(f_selected_sid)

        multivm.clicked.connect(f_multivm_clicked)

        multivm.clear.connect(f_clear)

   //     timeline.fullscreen_signal.connect(fullscreen)

   //     timeline.signal_scale.connect(scale)
    }

    function f_clear(){
        cameraName.text=""
        cameraIpAddr.text=""
        pageName.text=""
    }

    function f_multivm_clicked(){
    timer.stop()
    }

    function f_selected_sid(id){
        console.log("f_selected_sid: ",id)
        if(id!==-1){

            cameraName.text=Axxon.camera(id).name
            cameraIpAddr.text=Axxon.camera(id).ipadress

        }else{
           cameraName.text=""
           cameraIpAddr.text=""
        }
    }

    function f_currentPage(nm){

        console.log("f_currentPage: ",nm)
 //   pageName.
        pageName.text=nm
    }

    function set_the_multivm_settings(){
        console.log("set_the_multivm_settings")
        multivm.setVid("VideoWall")

    }

    function f_switch_tlmtr(){
            console.log("videowall f_switch_tlmtr")
        base.switch_tlmtr()
        tlmt_rect.visible=!tlmt_rect.visible
    }

    function f_open_in_alarm_window(id){

        console.log("f_open_in_alarm_window")
        open_in_alarm_window(id)
    }



    function request_URL(cameraId, serviceId, dt,quality){
        Axxon.request_URL(multivm.vid,cameraId, serviceId, dt,"utc","")
    }


    function f_current_camera_update(videowall){

        console.log("f_current_camera_update")
        console.log("videowall: ",videowall)
        console.log("multivm.vid: ",multivm.vid)

        if(videowall!==multivm.vid){
            console.log("это не та стена")
            return
        }


        update_vm()
    }

    function  update_vm()    {

        var cids =  multivm.get_cids()
        for(var one in cids)
        {
            var id=cids[one]
            var lcl=Axxon.camera(id)


            //    preset_list.clear_model()
            //    Tlmtr.preset_info()

            //   Tlmtr.capture_session()
            //   timer.start()

            //        v1.tform1.xScale =1
            //        v1.tform1.yScale =1

            multivm.set_Scale(1);

            multivm.vm_start(id,lcl.liveStream,Mode.LiveStreaming)



        }
              multivm.save()
    }

    function rescale(){
    multivm.rescale()
    }






}
