import QtQuick 2.11
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.4
import "../../js/axxon.js" as Axxon
import "../../js/axxon_telemetry_control.js" as Tlmtr
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4

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
    signal stream_request(int id,string quality)
    signal open_in_alarm_window(int id)
    signal give_me_a_camera
    signal request_URL
    signal switch_tlmtr

    property string quality

    signal playing

    signal ready

    signal onCompleted

    signal currentPage(string nm)

    property bool alarm_mode: false

    property bool full

    signal clicked

    signal clear

    onWidthChanged: {

            rescale_timer.stop()
          rescale_timer.start()
    }

    onHeightChanged: {

            rescale_timer.stop()
          rescale_timer.start()
    }

    onXChanged: {

            rescale_timer.stop()
          rescale_timer.start()
    }

    onYChanged: {
        rescale_timer.stop()
      rescale_timer.start()
    }




    onQualityChanged: {

    console.log("onQualityChanged: ",quality)
    }





    Timer {
        id: rescale_timer
        interval: 100; running: false; repeat: false
        property int msec:0
        property var prev_date : 0
        property int sec : 0
        onTriggered:
        {
            console.log("rescale timer")
            multivm.rescale(good.scale,true)

        }
    }

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
        propagateComposedEvents: true
Rectangle{
           anchors.fill: parent
           color:"gray"
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

                        TextField {
                            id: txt
                        x: 10
                        y: 0
                        width: text.length*10
                        height: 20
                        text: Axxon.camera(vm.cid)==-1 ? "" : Axxon.camera(vm.cid).name

                        style: TextFieldStyle{
                            textColor: "black"
                            background: Rectangle{
                            radius: 2
                            opacity: 0.5
                            implicitWidth: txt.width
                            implicitHeight: 20
                            border.color: "white"
                            border.width: 1
                            }

                        }

                        }

                    }

                    Row{
                        id: rrow


 visible: selected ? true : false
                        x:2
                        y:2
                        width: parent.width
                        height: 20
                        spacing: 2


                    Button{

                        id: btn_select_camera




                    width: 40
                    height: 40


                    style: ButtonStyle {

                        label: Image {
                            source: "select-camera.png"
                            fillMode: Image.PreserveAspectFit  // ensure it fits
                        }
                    }

                    onClicked: {

                        console.log("onClicked .")
                        good.give_me_a_camera()
  rrow.visible=false



                    }

                    }

                    Button{




                        width: 40
                        height: 40
                    visible: selected ? true : false

id: btn_flip_camera
                    style: ButtonStyle {

                        label: Image {
                            source: "flip-camera.png"
                            fillMode: Image.PreserveAspectFit  // ensure it fits
                        }
                    }

                    onClicked: {

                        console.log("onClicked .")
                        good.open_in_alarm_window(vvm.cid)
  rrow.visible=false
                    }

                    }

                    Button{

                        width: 40
                        height: 40
                    visible: selected ? true : false

   id: btn_fullscreen
                    style: ButtonStyle {

                        label: Image {
                            source: "fullscreen.png"
                            fillMode: Image.PreserveAspectFit  // ensure it fits
                        }
                    }

                    onClicked: {

                        console.log("onClicked .")
                        var uuid = vvm.uid
                        good.fullscreen(vvm.uid)
  rrow.visible=false
                    }

                    }

                    Button{

                        width: 40
                        height: 40

   id: btn_switch_tlmtr
                        style: ButtonStyle {

                            label: Image {
                                source: "telemetry.png"
                                fillMode: Image.PreserveAspectFit  // ensure it fits
                            }
                        }

                        onClicked: {

                            console.log("onClicked .,.")
                            good.switch_tlmtr()
                            rrow.visible=false
                        }
                    }


                    Button{

id: btn_clear_camera
                        width: 40
                        height: 40


                    style: ButtonStyle {

                        label: Image {
                            source: "delete.png"
                            fillMode: Image.PreserveAspectFit  // ensure it fits
                        }
                    }


                    onClicked: {

                   //     console.log("onClicked .,.")

                   //     console.log("set cid for uid: ",-1," ",vm.uid)
                        md.set_cid_for_uid(-1,vm.uid)
                        md.set_url_for_uid("",vm.uid)

                    //    findAndSet(cids,vm.uid,"cid",-1)
                    //    findAndSet(cids,vm.uid,"url","")
                        vvm.vm_stop()
                        vvm.vm_clear()
                        txt.text=""
                    rrow.visible=false


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

                //    console.log("set cid for uid: ",cid," ",vm.uid)
                    md.set_cid_for_uid(cid,vm.uid)


                 findAndSet(w_model,vm.uid,"cid",cid)
                }

                function set_Scale(val){

                    vvm.set_Scale(val)
                }

                function set_selected(val){

                selected=val

                    if(val==true){

                        rrow.visible=!rrow.visible
                    findAndSet(cids,vm.uid,"alarm",false)
                    findAndSet(w_model,vm.uid,"alarm",false)

                       md.set_alarm_for_uid(false,vm.uid)

                  console.log("выбран cid: ",vm.cid," uid:",vm.uid," url:",vm.url)
                    rrow.visible=true
                    }else{
                     rrow.visible=false
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
                    md.set_url_for_uid(url,vm.uid)
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

                    if(md.get_current_page_name()=="Тревоги"){
                 //   btn_select_camera.visible=true
                    //    btn_select_camera.width=0

                        btn_flip_camera.visible=false
                            btn_flip_camera.width=0

                    }

                    if(md.get_current_page_name()=="Архив"){

                        btn_flip_camera.visible=false
                            btn_flip_camera.width=0

                    }

                 //   selected=false
                 //   resize_vm()
                    set_cid(model.cid)

                    vvm.uid=model.uid

                    set_vm_source(model.cid,model.url)
                    console.log("Rect ",index," создан; uid: ",uid,"; cid:",vm.cid,"; url:",vm.url)
                    vvm.vm_start(1)

                }

            }
        }
    }
}



        onClicked: {
            console.log("+++++++++++++++++++++++++++++")
            console.log("select by click")
            for(var i = 0; i<grid.children.length-1; i++)
            {
                if(grid.children[i].contain_mouse){
                    grid.children[i].set_selected(true)




                    //    preset_list.clear_model()
                    //    Tlmtr.preset_info()

                        var lcl_cid = grid.children[i].cid
                     var lcl=Axxon.camera(lcl_cid)
                           selected_cid(lcl_cid)

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
                    grid.children[i].set_selected(false)
                }
            }
           good.clicked()
        }
    }





    function add_alarm_camera(id){

        md.to_page("Тревоги")

          //  cids.clear()


        full=false
            good.scale=1


        md.clear_if_not_alarm()

/*
            for(var i = 0;i<cids.count; i++){

                if(cids.get(i).alarm==false){
                    console.log("сид  ",id, "не тревога")
               //   cids.setProperty(i,"cid",-1)
               //   cids.setProperty(i,"url","")
                }else{
                  console.log("сид  ",id, "тревога")
                }
            }
            */





         add_camera(id,true)
 md.save_to_settings()
    }

        function add_storage_camera(id){

             add_camera(id)
        }

    function add_storage_cameras(arr){

console.log("Multivm add_storage_camera")
 //md.to_page("Архив")
          //  cids.clear()


        full=false
            good.scale=1
   md.clear_if_not_alarm()
/*
            for(var i = 0;i<cids.count; i++){

                if(cids.get(i).alarm==false){
                  cids.setProperty(i,"cid",-1)
                  cids.setProperty(i,"url","")
                }


            }
            */





        for(var i=0;i<arr.length;i++){

         add_camera(arr[i],false)
        }
 md.save_to_settings()
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

         //   for(var i=0;i<cids.count;i++){
         //       console.log(cids.get(i).cid)
        //    }
            rescale(good.scale,true)


            var serviceId=Axxon.camera(cids.get(0).cid).serviceId


            Axxon.request_URL(vid,get_cids(), serviceId, "",quality)

        }
    }

    function get_cids(){

        var res =[]
        var cids = md.get_cids()
        var count = cids.length
        for(var i = 0; i<cids.length; i++)
        {

            var lcl = md.get_cid_at(i)
        //    console.log(i," ",lcl)
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
        console.log("set_current_cid ",cid)
        for(var i = 0; i<grid.children.length; i++)
        {
            if(grid.children[i].selected){
                grid.children[i].set_cid(cid)
            }
        }
    }

    Component.onCompleted: {
        console.log("storagealarm_ multivm quality: ",quality)
        console.log(md.get_info())
        full=false
   //     vid = generateUUID()
   //     md.vid=vid

   //     md.show()


        good.onCompleted()



    }

    function vm_start(cid,src,mode){
        console.log("vm_start ",cid," ",src," ",mode)
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



    function rescale(scale,save){

       console.log("rescale-->")


        scale= md.current_scale()
 console.log("and look at scale here: ",scale)

        if(save){
        saving_on()
        console.log("с сохранением")
        }else{
        console.log("без сохранения")
        }

        var ww = width/scale
        var hh = height/scale

        grid.rows = scale
        grid.columns = scale

        w_model.clear()


        var flag=false

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

                    var url = md.get_url_at(i)
                    var cid = md.get_cid_at(i)

                    if(url=="" && cid>-1){
                        console.log("пустой cid ",cid)
                    flag=true
                    }

                    console.log("append ")
                    console.log("uid  ",md.get_uid_at(i))
                    console.log("cid  ",md.get_cid_at(i))
                    console.log("url  ",md.get_url_at(i))
                    console.log("alarm  ",md.get_alarm_at(i))




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
            console.log("rescale multi, fullscreen_uid = ",fullscreen_uid)
            if(fullscreen_uid!==-1){
            good.stream_request(fullscreen_uid,"low")
        fullscreen_uid=-1
            }
            console.log("get_current_page_name ",md.get_current_page_name())
            console.log("scale ",scale)
            for(var i=0;i<scale*scale;i++){

                var url = md.get_url_at(i)
                var cid = md.get_cid_at(i)

                if(url=="" && cid>-1){
                    console.log("пустой cid ",cid)
                flag=true
                }


                console.log("append ")
                console.log("uid  ",md.get_uid_at(i))
                console.log("cid  ",md.get_cid_at(i))
                console.log("url  ",md.get_url_at(i))
                console.log("alarm  ",md.get_alarm_at(i))

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
        md.save_to_settings()

        if(flag){
            console.log("flag")
              var serviceId=Axxon.camera(get_cids()[0]).serviceId
                    Axxon.request_URL(vid,get_cids(), serviceId, "","utc",quality)
        }
         console.log("<--rescale")
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

        console.log("add_camera ",id)
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

        for(var i = 0;i < md.get_cids().length;i++){
          //   console.log("смотрю ",md.get_cid_at(i)," ",id)
            if(md.get_cid_at(i) === id){
          //     console.log("такая камера уже есть ",id)
                return
            }
        }

        /*
        var cids = get_cids()
        console.log("cids", cids," ",cids.length)
        for(var i=0;i<cids.count;i++){
            console.log("смотрю ",cids.get(i).cid," ",id)
            if(cids.get(i).cid===id){
                console.log("такая камера уже есть ",id)
        //       cids.setProperty(i,"alarm",alarm)
         //       return

            }
        }
        */




       // if(fl){

        /*
        for(var i=0;i<cids.count;i++){
            if(cids.get(i).cid===id){
        //       cids.setProperty(i,"alarm",alarm)
         //       return

            }
        }
        */

        md.set_scale(1)
        md.check_the_scale(id,alarm)
         md.save_to_settings()
        /*
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
            */

            rescale(good.scale,true)


            var serviceId=Axxon.camera(id).serviceId

            Axxon.request_URL(vid,get_cids(), serviceId, timeline.get_dt(),"utc",quality)
        }

    function setVid(vvid){
        md.vid=vvid
        vid=vvid

    }

    function multivm_add_page(name,maxScale){
        console.log("multivm ad_page: ",name)

        console.log("...1")
        md.add_page(name,maxScale)
        console.log("md.get_current_page_name() ",md.get_current_page_name())
        rescale(good.scale,true)
        console.log("...2")
        good.currentPage(md.get_current_page_name())
    }

    function to_page(name){
    md.to_page("Тревоги")
        rescale(good.scale,false)
        good.currentPage(md.get_current_page_name())
        good.selected_cid(-1)
    }

    function multivm_delete_page(name){

        md.delete_page(md.current_page())

        good.currentPage(md.get_current_page_name())

        w_model.clear()

        good.clear()
    }

    function to_next_page(){

        md.to_next_page()
        rescale(good.scale,false)
        good.currentPage(md.get_current_page_name())
        good.selected_cid(-1)


    }

    function fullscreen(id){

    var quality="low"
 var current_cid = -1
        if(!full){
            console.log("fullscreen ")

            //найти cid этого uid

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

            //              var res =[]
           //     res.push(id)
           //      var serviceId=Axxon.camera(id).serviceId
           //               Axxon.request_URL(vid,res, serviceId, timeline.get_dt(),"utc","higth")
            }
            quality="higth"
        }else{
         full=false
            for(var i = 0;i < w_model.count;i++){
                   if(w_model.get(i).uid === id){
                    current_cid = w_model.get(i).cid
                   }
            }

            fullscreen_uid=-1
         //   var res =[]
        //    res.push(id)
        //     var serviceId=Axxon.camera(id).serviceId
        //    Axxon.request_URL(vid,res, serviceId, timeline.get_dt(),"utc","")
             quality="low"
        }
        console.log("emit stream_request ", current_cid, " quality ",quality)
        good.stream_request(current_cid,quality)
        rescale(good.scale,true)


    }

    function save(){
    md.save_to_settings()
    }

    function next_scale(){
        if(fullscreen_uid!=-1){
        return
        }

        full=false
          good.stream_request(fullscreen_uid,"low")
    //   fullscreen_uid=-1
    md.next_scale()
        rescale(good.scale,true)
    }

    function rescale_timer_start(){
    rescale_timer.start()
    }

    function get_current_page_name(){
    return md.get_current_page_name()
    }



}
