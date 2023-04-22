import QtQuick 2.11
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.4
import "../../js/axxon.js" as Axxon
import "../../js/axxon_telemetry_control.js" as Tlmtr
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4
import MyQMLEnums 13.37
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

                property bool selected
                property bool contain_mouse: area.containsMouse ? true : false
                readonly property int uid: model.uid
                property int cid: model.cid
                property int alarm: model.alarm
                Rectangle{
                    id: rect
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

                        onConnectionChanged: {
                        console.log("Vvvvvvm onConnectionChanged")
                        }

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
                      //  md.set_cid_for_uid(-1,vm.uid)
                        good.fullscreen(vvm.uid)

  //rrow.visible=false
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
                            vvm.info()
                          //  good.switch_tlmtr()
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

                        vm.cid=-1

                        vvm.set_vm_cid(-1)
                        vvm.set_vm_source(-1,"")
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


function set_alarm(alarm_){
  alarm= alarm_
    if(alarm){
    rect.color="red"
    }else{
    rect.color="gray"
    }
}


                function set_cid(cid_){
                    cid=cid_
                    vm.cid=cid_
                    vvm.cid=cid_
                 vvm.set_vm_cid(cid_)

                 //на текущем видеоэкране найти uid и выставить ему cid
                 findAndSet(cids,vm.uid,"cid",cid_)

                //    console.log("set cid for uid: ",cid," ",vm.uid)
                    md.set_cid_for_uid(cid_,vm.uid)


                 findAndSet(w_model,vm.uid,"cid",cid_)
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
                            rect.color="gray"

                        var url="";
                        var scale= md.current_scale()
                        for(var j=0;j<scale*scale;j++){

                            var url_ = md.get_url_at(j)
                            var uid_ = md.get_uid_at(j)
                          //        console.log("is ",id, " uid ",uid_," url ",url_)
                            if(uid_ == vm.uid){
                            url=url_
                            }

                        }


                  console.log("выбран cid: ",vm.cid," uid:",vm.uid," url:",url)
                        full.vm_start_1(vm.cid,url,1)
                //    rrow.visible=true
                    }else{
                     rrow.visible=false
                    }

                    vvm.set_selected(val)


                }

                function vm_start(mode){
//console.log(" vm_start(mode)")
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

             function   f_return_connection(connection){
                console.log("f_return_connection ",cid)
                 if(connection==false){
                             console.log("2")


                     var flag=false

                     if(fullscreen_uid>-1){
                     for(var i=0;i<md.get_all_cids().length;i++){
                       //  console.log("look.. ",md.get_uid_at(i)," ",fullscreen_uid)
                         if(md.get_uid_at(i)===fullscreen_uid){
                             flag=true
                         }
                         }
                     }


                     if(flag===true){
                    // console.log("3")
                         full.vm_start_1(cid,Axxon.camera(cid).low,1)
                   //  good.stream_request(cid, "higth")
                     }else{
                   //              console.log("4")

                  good.stream_request(cid, quality)
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
                    //console.log("Rect ",index," создан; uid: ",uid,"; cid:",vm.cid,"; url:",vm.url)
                    if(model.url!==""){
                    vvm.vm_start_1(model.cid,model.url,1)
                    }

    if(vvm.get_connection()){
     //   console.log("no connection")
        var flag=false

        if(fullscreen_uid>-1){
        for(var i=0;i<md.get_all_cids().length;i++){
         //   console.log("look.. ",md.get_uid_at(i)," ",fullscreen_uid)
            if(md.get_uid_at(i)===fullscreen_uid){
                flag=true
            }
            }
        }


        if(flag===true){
       // console.log("3")
       //     full.vm_start_1(cid,Axxon.camera(cid).low,1)
        good.stream_request(cid, "higth")

        }else{
                 //   console.log("4")
     good.stream_request(cid, quality)
        }
    }

                    vvm.return_connection.connect(f_return_connection)

                }

            }
        }

    }
}

Vvvvvvm{
    id: full


        anchors.fill: parent
//     readonly property int uid: model.uid
        visible: false
    onConnectionChanged: {
    console.log("Vvvvvvm onConnectionChanged")
    }

    Button{
        width: 20
        height: 20
        onClicked: {
        stream_request(full.get_cid(),quality)
        full.visible=false
        fullscreen_uid=-1
        }
    }

    function   f_return_connection(connection){
       console.log("full f_return_connection ",cid)
        if(connection==false){
                    console.log("2")


            var flag=false

            if(fullscreen_uid>-1){
            for(var i=0;i<md.get_all_cids().length;i++){
              //  console.log("look.. ",md.get_uid_at(i)," ",fullscreen_uid)
                if(md.get_uid_at(i)===fullscreen_uid){
                    flag=true
                }
                }
            }


            if(flag===true){
           // console.log("3")
                full.vm_start_1(cid,Axxon.camera(cid).low,1)
          //  good.stream_request(cid, "higth")
            }else{
          //              console.log("4")

         good.stream_request(cid, quality)
            }

        }
       }

    Component.onCompleted: {
    full.return_connection.connect(f_return_connection)
    }

}

        onClicked: {
          //  console.log("+++++++++++++++++++++++++++++")
         //   console.log("select by click")
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

       // console.log("add_alarm_camera")
        md.to_page("Тревоги")

        full.visible=false
        good.scale=1


        md.clear_if_not_alarm()

        for(var i = 0;i < md.get_cids().length;i++){
            //   console.log("смотрю ",md.get_cid_at(i)," ",id)
            if(md.get_cid_at(i) === id){
                var uid =  md.get_uid_at(i)
                md.set_url_for_uid(Axxon.camera(id).livestream_low,uid)

                return
            }
        }
        //md.set_scale(2)
        var res = md.check_the_scale(id,"",true)
        md.save_to_settings()

        if(res===true){
            rescale(good.scale,true)
        }else{
        refresh()
        }

        var serviceId=Axxon.camera(id).serviceId
       // console.log("5")
        good.stream_request(id,"low")

        //  add_camera(id,true)
        md.save_to_settings()
    }

        function add_storage_camera(id){

             add_camera(id,false)
        }

        function add_alarm_cameras(arr){

           // console.log("Multivm add_alarm_cameras array")
            //md.to_page("Архив")
            //  cids.clear()
            full.visible=false



            good.scale=1
            md.clear_if_not_alarm()
            md.set_scale(2)
            for(var i=0;i<arr.length;i++){


               //
                md.check_the_scale(arr[i],"",true)

            }
            md.save_to_settings()
            rescale(good.scale,true)
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
          //  console.log(i," ",lcl)
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
     //   console.log("cids: ",res)
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

   //     vid = generateUUID()
   //     md.vid=vid

   //     md.show()


        good.onCompleted()



    }

    function set_alarm(index,alarm){
      // console.log("multivm vm_start(cid,src,mode) ",cid," ",src," ",mode)
        for(var i = 0; i<grid.children.length-1; i++)
        {


            if(i==index){

               console.log("set_cid ",alarm," for ",i)

                grid.children[i].set_alarm(alarm)


            }

        }

    }

    function set_cid(index,cid){
      // console.log("multivm vm_start(cid,src,mode) ",cid," ",src," ",mode)
        for(var i = 0; i<grid.children.length-1; i++)
        {


            if(i==index){

               console.log("set_cid ",cid," for ",i)

                grid.children[i].set_cid(cid)


            }

        }

    }

    function vm_start(cid,src,mode){
      // console.log("multivm vm_start(cid,src,mode) ",cid," ",src," ",mode)
        if(src==""){
        vm_stop_at_cid(cid)
            return
        }

        for(var i = 0; i<grid.children.length-1; i++)
        {

            var lcl = grid.children[i].cid
            if(lcl==cid){

               // console.log("mode ",mode)

                grid.children[i].set_vm_source(cid,src)
                grid.children[i].vm_start(mode)

            }

        }

        if(full.cid==cid){
            full.set_vm_source(cid,src)
            full.vm_start(mode)
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

    function vm_stop_at_cid(cid){
        for(var i = 0; i<grid.children.length-1; i++)
        {

        //    if(grid.children[i].selected){
                if(grid.children[i].cid===cid){
                grid.children[i].vm_stop()
                }

       //     }

        }

        if(full.get_cid()==cid){

        full.vm_stop()
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



    function refresh(){
        console.log("refresh")

        scale= md.current_scale()
        var ww = width/scale
        var hh = height/scale

        for(var i=0;i<scale*scale;i++){


            var cid_old = w_model.get(i).cid
            var cid_new = md.get_cid_at(i)

            var url_old = w_model.get(i).url
            var url_new = md.get_url_at(i)

            var uid_old = w_model.get(i).uid
            var uid_new = md.get_uid_at(i)

            var alarm_old = w_model.get(i).alarm
            var alarm_new = md.get_alarm_at(i)


            console.log(" ")

            if(cid_old!=cid_new){

                console.log("uid  : ",uid_old," ",uid_new)
                console.log("cid  : ",cid_old," ",cid_new)
                console.log("url  : ",url_old," ",url_new)
                console.log("alarm: ",alarm_old," ",alarm_new)
                w_model.setProperty(i,"cid"  ,cid_new  )
                w_model.setProperty(i,"url"  ,url_new  )

                good.set_cid(i,cid_new)
                good.set_alarm(i,alarm_new)

                good.stream_request(cid_new,quality)

            }

/*
            console.log("--")


            console.log(w_model.get(i).uid)
            console.log(w_model.get(i).cid)
            console.log(w_model.get(i).url)
            console.log(w_model.get(i).alarm)

console.log("")



            w_model.setProperty(i,"uid"  ,md.get_uid_at(i)  )
            w_model.setProperty(i,"cid"  ,md.get_cid_at(i)  )
            w_model.setProperty(i,"url"  ,md.get_url_at(i)  )
            w_model.setProperty(i,"alarm",md.get_alarm_at(i))

            console.log(w_model.get(i).uid)
            console.log(w_model.get(i).cid)
            console.log(w_model.get(i).url)
            console.log(w_model.get(i).alarm)

          //  stream_request(w_model.get(i).cid,quality)
console.log("--")
            */
        }

    }

    function rescale(scale,save){

     //  console.log("rescale-->")


        scale= md.current_scale()
 //console.log("and look at scale here: ",scale)

        if(save){
        saving_on()
        //console.log("с сохранением")
        }else{
        //console.log("без сохранения")
        }

        var ww = width/scale
        var hh = height/scale

        grid.rows = scale
        grid.columns = scale

        w_model.clear()


        var flag=false





            for(var i=0;i<scale*scale;i++){

                var url = md.get_url_at(i)
                var cid = md.get_cid_at(i)

                if(url=="" && cid>-1){
                //    console.log("пустой cid ",cid)
                    var serviceId=Axxon.camera(get_cids()[0]).serviceId
                        //    console.log("6")
                       good.stream_request(cid, quality)
                }


/*
                console.log("append ")
                console.log("uid  ",md.get_uid_at(i))
                console.log("cid  ",md.get_cid_at(i))
                console.log("url  ",md.get_url_at(i))
                console.log("alarm  ",md.get_alarm_at(i))
*/
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
       // }





        saving_off()

        good.ready()
        md.save_to_settings()



         //   console.log("flag")



     //    console.log("<--rescale")
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

        console.log("add_camera ",id," ",alarm)
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
             console.log("смотрю ",md.get_cid_at(i)," ",id)
            if(md.get_cid_at(i) === id){

               console.log("такая камера уже есть ",id)
                md.set_alarm_for_uid(true,(md.get_uid_at(i)))

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
console.log("1")
      //  md.set_scale(1)
        console.log("1")
        var res = md.check_the_scale(id,Axxon.camera(id),"",alarm)
        console.log("1")
         md.save_to_settings()
        console.log("1")
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
console.log("res = ",res )
        if(res===true){
            rescale(good.scale,true)
        }else{
        refresh()
        }
console.log("1")

            var serviceId=Axxon.camera(id).serviceId

        //    Axxon.request_URL(vid,get_cids(), serviceId, timeline.get_dt(),"utc",quality)
        console.log("7")
        good.stream_request(id,good.quality)
console.log("1")
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


        if(fullscreen_uid!=-1){
          good.fullscreen(fullscreen_uid)
        }

        md.to_next_page()
        rescale(good.scale,false)
        good.currentPage(md.get_current_page_name())
        good.selected_cid(-1)


    }

    function fullscreen(id){
        console.log("function fullscreen(id) ",id, "full ",fullscreen_uid)

        var qquality=good.quality
        if(fullscreen_uid==-1){
            for(var i = 0;i < w_model.count;i++){
                   if(w_model.get(i).uid === id){
                       if(Axxon.check_id(w_model.get(i).cid)){


                           var url="";
                           var scale= md.current_scale()
                           for(var j=0;j<scale*scale;j++){

                               var url_ = md.get_url_at(j)
                               var uid_ = md.get_uid_at(j)
                                     console.log("is ",id, " uid ",uid_," url ",url_)
                               if(uid_ == id){
                               url=url_
                               }

                           }

                           full.vm_start_1(w_model.get(i).cid,
                                         url,
                                         1
                                         )
                         //  stream_request(w_model.get(i).cid,"higth")

                         //   md.set_url_for_uid("",id)
                           fullscreen_uid = id
                           full.visible=true
                           qquality="higth"
                       }
                   }
            }
        }else{



             md.set_url_for_uid("",id)
          //  full.vm_start()

        fullscreen_uid=-1
            full.visible=false
        }


        /*
        var current_cid=-1
        for(var i = 0;i < w_model.count;i++){
               if(w_model.get(i).uid === id){


                     good.stream_request(w_model.get(i).cid, qquality)

               }
        }
*/


    }

    function save(){
        md.save_to_settings()
    }

    function next_scale(){
        if(fullscreen_uid!=-1){
            return
        }


        console.log("1")
        good.stream_request(fullscreen_uid,good.quality)
        fullscreen_uid=-1
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
