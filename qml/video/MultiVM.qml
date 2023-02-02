import QtQuick 2.11
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.4
import "../../js/axxon.js" as Axxon
import "../../js/axxon_telemetry_control.js" as Tlmtr
Item{
    property int videowall_id: -1
    id: good
    anchors.fill: parent
    property int scale:5
    property bool first_time: true
    property int index: 0

    signal selected_cid(int cid)
    signal give_me_a_camera
    signal request_URL

    ListModel {

        id: w_model
        dynamicRoles: true

    }

    ListModel {

        id: cids
        dynamicRoles: true

    }

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true


    GridLayout {

        anchors.fill: parent
        id: grid
        columnSpacing: 0
        rowSpacing: 0
        rows: 5
        columns: 5
        baselineOffset: 1



        Repeater{
            model: w_model

            Item {

                id: vm

                x: model.x
                y:model.y
                width: model.w
                height: model.h

                property bool selected
                property bool contain_mouse: area.containsMouse ? true : false
                readonly property int uid: model.uid
                property int cid: model.cid


                Rectangle{
                    anchors.fill: parent
                    color: selected ? "lightgreen" : "green"
                    MouseArea{
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true

                    Vvvvvvm{
                        id: vvm

                   //     readonly property int uid: model.uid

                        anchors.fill: parent

                        property int cid: -1
                        property string url: ""

                    }

                    Text{
                        anchors.fill: parent
                        text: model.cid
                    }
                    Button{
                    x:10
                    y:10
                    width: 10
                    height: 10
                    visible: selected ? true : false


                    onClicked: {

                        console.log("onClicked .")
                        good.give_me_a_camera()
                    }

                    }

                    function get_cid(){
                    return vvm.cid
                    }

                }






                }





                function set_cid(cid){
                    vm.cid=cid
                    vvm.cid=cid
                 vvm.set_vm_cid(cid)

                 findAndSet(cids,vm.uid,"cid",cid)
                 findAndSet(w_model,vm.uid,"cid",cid)
                }

                function set_Scale(val){

                    vvm.set_Scale(val)
                }

                function vm_start(mode){

                    vvm.vm_start(mode)
                }

                function force_focus(){
                vvm.forceActiveFocus()
                }


                function set_vm_source(cid,url){

                    vvm.set_vm_source(cid,url)
                    findAndSet(cids,vm.uid,"url",url)
                    findAndSet(w_model,vm.uid,"url",url)
                }

                function saving_off(){
                    vvm.saving_off()
                }

                function saving_on(){
                vvm.saving_on()
                }


                function findAndSet(model,uid,property_string,val){


                      for(var i = 0;i < model.count;i++){

                             if(model.get(i).uid === uid){

                               model.setProperty(i,property_string,val)

                             }
                      }
                }

                Component.onCompleted: {

                 //   selected=false
                 //   resize_vm()
                    set_cid(model.cid)

                    set_vm_source(model.cid,model.url)
                 //   console.log("Rect ",index," создан ",uid," ",vm.cid," ",vm.url)
                    vvm.vm_start(1)

                }

            }
        }
    }


        propagateComposedEvents: true

        onClicked: {
            console.log("select by click")
            for(var i = 0; i<grid.children.length-1; i++)
            {
                if(grid.children[i].contain_mouse){
                    grid.children[i].selected=true


                    //    preset_list.clear_model()
                    //    Tlmtr.preset_info()

                        var lcl_cid = grid.children[i].cid
                     var lcl=Axxon.camera(lcl_cid)
                    if(lcl!==-1){
                    root.telemetryPoint=lcl.telemetryControlID
                          Tlmtr.preset_info()
                       Tlmtr.capture_session()


                    }else{
                        root.telemetryPoint=-1
                              Tlmtr.preset_info()
                           Tlmtr.capture_session()


                    }
                     grid.children[i].force_focus()
                    //   timer.start()
                }
                else{
                    grid.children[i].selected=false
                }
            }
        }
    }

    Rectangle{
        x: parent.width-50
        y: 20
        width: 30
        height: 30
        color: "lightblue"

        MouseArea{
            anchors.fill:parent
            onClicked: {
                if(scale<5){
                    scale++
                }
                else{
                    scale=2
                }
                rescale(scale)
            }
        }
    }



    onHeightChanged: resize()
    onWidthChanged: resize()

    function resize(){

        var ww = width/scale
        var hh = height/scale

        for(var i=0;i<w_model.count;i++){

            w_model.setProperty(i,"h",hh)
            w_model.setProperty(i,"w",ww)
            w_model.setProperty(i,"x",ww*(i%scale))
            w_model.setProperty(i,"y",hh*((i<scale)?0:((i-(i%scale))/scale)))


        }
    }

    function reconnect_livestream(){

        if(first_time){
            first_time=false
            var src = Axxon.get_cids()


            for(var i=0;i<src.length;i++){
                var lcl = src[i]
                if(i>=cids.count){
                    cids.append({cid:lcl,uid:index++,url:""})
                }else{
                    cids.setProperty(i,"cid",lcl)
                }
            }

            for(var i=0;i<cids.count;i++){
                console.log(cids.get(i).cid)
            }
            rescale(scale)


            var serviceId=Axxon.camera(cids.get(0).cid).serviceId


            Axxon.request_URL(videowall_id,get_cids(), serviceId, "","utc")

        }
    }

    function get_cids(){

        var res =[]
        for(var i = 0; i<cids.count; i++)
        {

            var lcl = cids.get(i).cid
            if(lcl!=-1){
                var frash=true
                for(var j in res){
                    if(res[j]===lcl){
                    frash=false
                    }
                }
                if(frash){
                res.push(lcl)
                }
            }
        }
        return res
    }

    function set_current_cid(cid){
        for(var i = 0; i<grid.children.length; i++)
        {
            if(grid.children[i].selected){
                grid.children[i].set_cid(cid)
            }
        }
    }

    Component.onCompleted: {

    //    root.cameraList.updated.connect(reconnect_livestream)
         scale=5
          rescale(5)
    }

    function vm_start(cid,src,mode){
        for(var i = 0; i<grid.children.length-1; i++)
        {

            var lcl = grid.children[i].cid
            if(lcl==cid){

                console.log("mode ",mode)
                grid.children[i].set_vm_source(cid,src)
                grid.children[i].vm_start(mode)

            }

        }
    }

    function set_Scale(val){

        for(var i = 0; i<grid.children.length; i++)
        {

            if(grid.children[i].selected){

                grid.children[i].set_Scale(val)

            }

        }
    }



    function rescale(scale){


        for(var i = 0;i<scale*scale; i++){
            if(i>=cids.count){
                cids.append({cid:-1,uid:index++,url:""})
            }
        }

        saving_on()

        var ww = width/scale
        var hh = height/scale

        grid.rows = scale
        grid.columns = scale

        w_model.clear()

        console.log("cids.count ",cids.count)

        for(var i=0;i<scale*scale;i++){
            w_model.append({h:hh,w:ww,
                               x: ww*(i%scale),
                               y: hh*((i<scale)?0:((i-(i%scale))/scale)),
                               uid: cids.get(i).uid,
                               cid:cids.get(i).cid,
                               url:cids.get(i).url
                           })
        }

            saving_off()
    }

    function saving_on(){
        for(var i = 0; i<grid.children.length-1; i++)
        {
          grid.children[i].saving_on()

        }

    }

    function saving_off(){
        for(var i = 0; i<grid.children.length-1; i++)
        {
          grid.children[i].saving_off()

        }
    }



}
