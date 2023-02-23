import QtQuick 2.11
import "../../js/axxon.js" as Axxon
import MyQMLEnums 13.37
import QtQuick.Controls 2.4

Item{
    anchors.fill: parent
    property int cid: -1

    id: base

    property string live: "live"

    property int dy
    property int dx

    signal open_in_alarm_window(int id)

    signal switch_tlmtr

    Timer {
        id: timer
        interval: 5000; running: true; repeat: true
        property int msec:0
        property var prev_date : 0
        property int sec : 0
        onTriggered:
        {
            multivm.to_next_page()


    }
    }

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

    Row{

        x:30
        y:30
        width: parent.width
        height: 20
        spacing: 2


        Button{
            width: 20
            height: 20

            onClicked: {
                console.log("onClicked .")
                multivm.to_next_page()
            }
        }

        Button{
            width: 20
            height: 20

            onClicked: {
                console.log("onClicked .")
            }
        }

        Button{
            width: 20
            height: 20

            onClicked: {
                console.log("onClicked .")
            }
        }

        Button{
            width: 20
            height: 20

            onClicked: {
                console.log("onClicked .")
            }
        }
    }



    function give_him_a_camera(){
        console.log("give_him_a_camera()")
        camera_storage.visible=true
    }

    function f_change_camera(id){

        cid=id
        var lcl
        lcl=Axxon.camera(id)
        if(lcl!==-1){
            root.axxon_service_id=lcl.sid
            root.log(lcl.name)
            //   configPanel.state="hide"

            //   telemetry.set_serviceId(lcl.sid)
            //   preset_list.serviceId=lcl.sid

            //   root.log("telemetryControlID: ",lcl.telemetryControlID)
            //   root.telemetryPoint=lcl.telemetryControlID

            var dt=""

            //   root.deviceSelected(panePosition,lcl.sid,lcl.id)
            //   timeline.set_camera_zone(lcl.name)

            multivm.set_current_cid(cid)

            request_URL(multivm.get_cids(),lcl.serviceId,dt)
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
    }

    function set_the_multivm_settings(){
        console.log("set_the_multivm_settings")
        multivm.multivm_add_page("Вкладка 1")
        multivm.multivm_add_page("Вкладка 2")
        multivm.multivm_add_page("Вкладка 3")
        multivm.multivm_add_page("Вкладка 4")
        multivm.multivm_add_page("Вкладка 5")
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



    function request_URL(cameraId, serviceId, dt){
        Axxon.request_URL(multivm.vid,cameraId, serviceId, dt,"utc")
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
    }




}
