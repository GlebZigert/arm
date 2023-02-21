import QtQuick 2.11
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.4
import "../../js/axxon.js" as Axxon
import "../../js/axxon_telemetry_control.js" as Tlmtr
import Model 1.0
Item{
    property string vid
    id: good
  //  anchors.fill: parent
    property int scale: 2
    property bool first_time: true
    property int index: 0

    property int fullscreen_uid: -1

    signal selected_cid(int cid)
    signal open_in_alarm_window(int id)
    signal give_me_a_camera
    signal request_URL
    signal switch_tlmtr

    signal ready

    property bool alarm_mode: false

    property bool full

    Model{
    id: md
    }

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
        baselineOffset: 0




        Repeater{
            model: w_model






            Item {

                id: vm

                x: model.x
                y:model.y
                width: model.w
                height: model.h



/*
                onXChanged: {
                    resize_vm()
                }
                onYChanged: {
                    resize_vm()
                }
                onHeightChanged: {
                    resize_vm()
                }
                onWidthChanged: {
                    resize_vm()
                }

                function resize_vm(){
                 //   console.log("resize_vm")
                    vm.x=model.x
                    vm.y=model.y
                    vm.width=model.w
                    vm.height=model.h
                }
                */


                property bool selected
                property bool contain_mouse: area.containsMouse ? true : false
                readonly property int uid: model.uid
                property int cid: model.cid


                Rectangle{
                    anchors.fill: parent
                    color: model.alarm ? "red" : "gray";
                    MouseArea{
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true

                    Vvvvvvm{
                        id: vvm

                   //     readonly property int uid: model.uid

                        x:2
                        y:2
                        width: parent.width-4
                        height: parent.height-4

                      //  anchors.fill: parent

                        property int cid: -1
                        property string url: ""

                    }


                    Text{
                        anchors.fill: parent
                        text: model.cid
                    }



                    Row{

                        x:2
                        y:2
                        width: parent.width
                        height: 20
                        spacing: 2


                    Button{


                    width: 20
                    height: 20
                    visible: selected ? true : false


                    onClicked: {

                        console.log("onClicked .")
                        good.give_me_a_camera()



                    }

                    }

                    Button{


                        width: 20
                        height: 20
                    visible: selected ? true : false


                    onClicked: {

                        console.log("onClicked .")
                        good.open_in_alarm_window(vvm.cid)
                    }

                    }

                    Button{

                        width: 20
                        height: 20
                    visible: selected ? true : false


                    onClicked: {

                        console.log("onClicked .")
                        var uuid = vvm.uid
                        good.fullscreen(vvm.uid)
                    }

                    }

                    Button{


                        width: 20
                        height: 20
                    visible: selected ? true : false


                    onClicked: {

                        console.log("onClicked .,.")
                        good.switch_tlmtr()
                    }

                    }


                    Button{


                        width: 20
                        height: 20
                    visible: selected ? true : false


                    onClicked: {

                        console.log("onClicked .,.")
                        findAndSet(cids,vm.uid,"cid",-1)
                        findAndSet(cids,vm.uid,"url","")
                        vvm.vm_stop()
                        vvm.vm_clear()


                    }



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

                 //на текущем видеоэкране найти uid и выставить ему cid
                 findAndSet(cids,vm.uid,"cid",cid)


                    md.set_cid_for_uid(cid,vm.uid)


                 findAndSet(w_model,vm.uid,"cid",cid)
                }

                function set_Scale(val){

                    vvm.set_Scale(val)
                }

                function set_selected(val){

                selected=val

                    if(val==true){
                    findAndSet(cids,vm.uid,"alarm",false)
                    findAndSet(w_model,vm.uid,"alarm",false)
                    }

                    vvm.set_selected(val)


                }

                function vm_start(mode){

                    vvm.vm_start(mode)
                }

                function vm_stop(){

                    vvm.vm_stop()
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

                    vvm.uid=model.uid

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
                    grid.children[i].set_selected(true)




                    //    preset_list.clear_model()
                    //    Tlmtr.preset_info()

                        var lcl_cid = grid.children[i].cid
                     var lcl=Axxon.camera(lcl_cid)
                    if(lcl!==-1){
                    root.telemetryPoint=lcl.telemetryControlID

                          Tlmtr.preset_info()
                       Tlmtr.capture_session()

                       selected_cid(lcl_cid)
                    }else{
                        root.telemetryPoint=-1
                              Tlmtr.preset_info()
                           Tlmtr.capture_session()


                    }
                     grid.children[i].force_focus()
                    //   timer.start()


                }
                else{
                    grid.children[i].set_selected(false)
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


                full=false
                fullscreen_uid=-1

                /*
                if(good.scale<5){
                    good.scale++
                }
                else{
                    good.scale=1
                }
                */
                md.next_scale()

                rescale(good.scale)

            }
        }
    }



    function add_alarm_camera(id){



          //  cids.clear()


        full=false
            good.scale=1


            for(var i = 0;i<cids.count; i++){

                if(cids.get(i).alarm==false){
                  cids.setProperty(i,"cid",-1)
                  cids.setProperty(i,"url","")
                }


            }





         add_camera(id,true)

    }

    function add_storage_camera(arr){



          //  cids.clear()


        full=false
            good.scale=1


            for(var i = 0;i<cids.count; i++){

                if(cids.get(i).alarm==false){
                  cids.setProperty(i,"cid",-1)
                  cids.setProperty(i,"url","")
                }


            }



        for(var i=0;i<arr.length;i++){

         add_camera(arr[i],false)
        }

    }

    function reconnect_livestream(){

        if(first_time){
            first_time=false
            var src = Axxon.get_cids()


            for(var i=0;i<src.length;i++){
                var lcl = src[i]
                if(i>=cids.count){
                    cids.append({cid:lcl,uid:index++,url:"",alarm:false})
                }else{
                    cids.setProperty(i,"cid",lcl)
                }
            }

            for(var i=0;i<cids.count;i++){
                console.log(cids.get(i).cid)
            }
            rescale(good.scale)


            var serviceId=Axxon.camera(cids.get(0).cid).serviceId


            Axxon.request_URL(vid,get_cids(), serviceId, "","utc")

        }
    }

    function get_cids(){

        var res =[]
        var cids = md.get_cids()
        var count = cids.length
        for(var i = 0; i<cids.length; i++)
        {

            var lcl = md.get_cid_at(i)
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
        console.log("cids: ",res)
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
        console.log(md.get_info())

        md.show()


        full=false

        vid = generateUUID()
        md.vid=vid
        md.add_page()



        md.show()
        //
         good.scale=5
          rescale(good.scale)
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

    function vm_stop(){
        for(var i = 0; i<grid.children.length-1; i++)
        {

        //    if(grid.children[i].selected){

                grid.children[i].vm_stop()

       //     }

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

    function generateUUID(){
        var d = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (d + Math.random()*16)%16 | 0;
            d = Math.floor(d/16);
            return (c === 'x' ? r : (r&0x3|0x8)).toString(16);
        });
        return uuid;
    }



    function rescale(scale){

        console.log("and look at scale here: ",scale)


        scale= md.current_scale()

        saving_on()

        var ww = width/scale
        var hh = height/scale

        grid.rows = scale
        grid.columns = scale

        w_model.clear()




        var id = -1
        for(var i = 0;i < md.get_cids().length;i++){
            //найти на текущей странице камеру с uid и взять ее cid
            if(md.get_uid_at(i) === fullscreen_uid){
                id = md.get_cid_at(i)
            }
        }




        if(full && Axxon.check_id(id)){
            console.log("rescale full")
            for(var i=0;i<md.get_cids().length;i++){
                console.log(".. ",md.get_cid_at(i)," ",id)
                if(md.get_cid_at(i)===id){

                    w_model.append({h:height,
                                       w:width,
                                       x: 0,
                                       y: 0,
                                       uid: md.get_uid_at(i),
                                       cid:md.get_cid_at(i),
                                       url:md.get_url_at(i),
                                       alarm: md.get_alarm_at(i),
                                   })

                    break;
                }
            }

        }else{
            console.log("rescale multi")



            for(var i=0;i<scale*scale;i++){



                w_model.append({h:hh,
                                   w:ww,
                                   x: ww*(i%scale),
                                   y: hh*((i<scale)?0:((i-(i%scale))/scale)),
                                   uid: md.get_uid_at(i),//cids.get(i).uid,
                                   cid: md.get_cid_at(i),// cids.get(i).cid,
                                   url: md.get_url_at(i),// cids.get(i).url,
                                   alarm: md.get_alarm_at(i),// cids.get(i).alarm
                               })
            }
        }





        saving_off()

        good.ready()
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

    function add_camera(id,alarm){

        /*
        var fl=true
        for(var i=0;i<cids.count;i++){
            console.log(cids.get(i).cid," ",id)
            if(cids.get(i).cid===id){
                fl=false
                //выделить этот cid
            }
        }
        */

       // if(fl){
        for(var i=0;i<cids.count;i++){
            if(cids.get(i).cid===id){
        //       cids.setProperty(i,"alarm",alarm)
         //       return

            }
        }

            for(var i=0;i<cids.count;i++){


                if(i>=(good.scale*good.scale)){


                console.log("--- i: ",i," scale: ",good.scale)
                    good.scale++

                }


                if(cids.get(i).cid===-1){
                    cids.setProperty(i,"cid",id)
                    cids.setProperty(i,"alarm",alarm)
 console.log("i: ",i," scale: ",good.scale)



                    break
                    //выделить этот cid

                }
            }

            rescale(good.scale)


            var serviceId=Axxon.camera(id).serviceId

            Axxon.request_URL(vid,get_cids(), serviceId, timeline.get_dt(),"utc")
        }

    function fullscreen(id){



        if(!full){
            console.log("fullscreen ")

            //найти cid этого uid
            var current_cid = -1
            for(var i = 0;i < w_model.count;i++){
                   if(w_model.get(i).uid === id){
                    current_cid = w_model.get(i).cid
                   }
            }


            if(Axxon.check_id(current_cid)){
                console.log("check_id")
                full=true
                fullscreen_uid = id

                /*
                for(var i=0;i<w_model.count;i++){
                    console.log(".. ",w_model.get(i).cid," ",id)
                    if(w_model.get(i).cid===id){
                        console.log("++ ",w_model.get(i).cid," ",id)
                        w_model.setProperty(i,"h",height)
                        w_model.setProperty(i,"w",width)
                        w_model.setProperty(i,"x",0)
                        w_model.setProperty(i,"y",0)
                    }else{
                        console.log("-- ",w_model.get(i).cid," ",id)
                        w_model.setProperty(i,"h",0)
                        w_model.setProperty(i,"w",0)
                        w_model.setProperty(i,"x",0)
                        w_model.setProperty(i,"y",0)
                    }

                }
                */
            }
        }else{
         full=false
            fullscreen_uid=-1


        }

        rescale(good.scale)


    }



}
