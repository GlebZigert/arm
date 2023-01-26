import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.0



Item {

    id:supreme

    property int index: 0
    signal playing
    signal selected_cid(int cid)

     signal selected

    property int scale;

    ListModel {
        id: w_model

        dynamicRoles: true

     }

    ListModel {
        id: lcl_model

        dynamicRoles: true

     }



    GridLayout {
        anchors.fill: parent
        id: grid

        columnSpacing: 0



        rowSpacing: 0
           rows: 5
           columns: 5




 baselineOffset: 1

    Repeater{
    //    id: rpt

        model: w_model




        Item {
            x: model.x
            y:model.y
            width: model.w
            height: model.h


        //      width: (height/1080)*1920
        //      height: 250

            signal isSelected(int index)

            property int index
            property bool selected
            property bool contain_mouse: area.containsMouse ? true : false



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


            Rectangle{

                anchors.fill: parent

          //      x: model.x
           //     y:model.y
          //      width: model.w
          //      height: model.h


            color: selected? "lightyellow" : "yellow"

             }



            Vvvvvvm{
                id: vm

           //     readonly property int uid: model.uid

                anchors.fill: parent

           //     x: model.x
           //     y:model.y
           //     width: model.w
           //     height: model.h

                property int cid: -1
                property string url: ""
              //  property string source


                onReturn_source: (subject)=> {

                                     console.log("MultiVM onSourceChanged ", subject)

                    console.log("model.count ", w_model.count)

                                         for(var i = 0;i < w_model.count-1;i++){

                                         console.log(i," ",w_model.get(i).uid)
                                       //     console.log(i," ",uid)
                                             if(w_model.get(i).uid === uid){

                                                console.log("w_model.setProperty(",i,",url,",subject,")")
                                                w_model.setProperty(i,"url",subject)

                                             console.log("w_model", w_model.get(i).url)
                                             for(i=0;i<w_model.count-1;i++){

                                               console.log(i," ",w_model.get(i).url)

                                             }

                                             console.log("PROFIT")
                                         }

                                         }
                                 }

                onReturn_cid: (subject)=> {

                                     console.log("MultiVM onCidChanged ", subject)

                    console.log("model.count ", w_model.count)

                                         for(var i = 0;i < w_model.count-1;i++){

                                         console.log(i," ",w_model.get(i).uid)
                                            console.log(i," ",uid)
                                             if(w_model.get(i).uid === uid){
                                                w_model.setProperty(i,"cid",subject)
                                                  vm.cid = subject
                                             console.log("uid ",uid," cid",vm.cid)
                                             console.log("w_model")
                                             for(i=0;i<w_model.count-1;i++){

                                               console.log(i," ",w_model.get(i).cid)

                                             }

                                             console.log("PROFIT")
                                         }

                                         }
                                 }



                onActiveFocusChanged:{
                console.log("v1 activeFocus: ", v1.activeFocus)






                }

            }

            MouseArea{
                id: area
                width: supreme.width/grid.columns
                height: supreme.height/grid.rows
        hoverEnabled: true
           onClicked: {
           console.log(index)

           }


            }

            function get_cid(){
            return vm.cid
            }

            function set_selected(val){
            selected=val
            vm.selected=val
           //     console.log("selected ",val)
            }

            Component.onCompleted: {
                console.log("Rect ",index," is onCompleted ",selected)
            selected=false
                  resize_vm()
                  set_vm_source(model.cid,model.url)
                  vm.vm_start(1)
            }

            function set_Scale(val){

                vm.set_Scale(val)
            }

            function set_vm_source(cid,src){


                vm.set_vm_source(cid,src)
            }

            function vm_start(mode){

                vm.vm_start(mode)
            }

            function vm_stop(){

                vm.vm_stop()
            }
            function vm_shot(){

                vm.vm_shot()
            }

            function saving_off(){
                vm.saving_off()
            }

            function saving_on(){
            vm.saving_on()
            }

        }

}


}


    MouseArea{
    anchors.fill: parent

    onClicked: {

        for(var i = 0; i<grid.children.length-1; i++)
        {

            if(grid.children[i].contain_mouse){

                console.log(i,
                            " var child is ",
                            grid.children[i].index,
                            " ",
                            grid.children[i].contain_mouse );

                grid.children[i].selected=true



             grid.children[i].set_selected(true)
             console.log("---cid",grid.children[i].get_cid())
              selected_cid(grid.children[i].get_cid())


            }
            else{
               grid.children[i].selected=false
                 grid.children[i].set_selected(false)
            }





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

    function set_vm_source(cid,src){
        for(var i = 0; i<grid.children.length; i++)
        {

            if(grid.children[i].selected){

                grid.children[i].set_vm_source(cid,src)

            }

        }
    }

    function vm_start(mode){
        for(var i = 0; i<grid.children.length; i++)
        {

            if(grid.children[i].selected){

                console.log("mode ",mode)
                grid.children[i].vm_start(mode)

            }

        }
    }

    function vm_stop(){
        for(var i = 0; i<grid.children.length; i++)
        {

            if(grid.children[i].selected){

                grid.children[i].vm_stop()

            }

        }
    }
    function vm_shot(){
        for(var i = 0; i<grid.children.length; i++)
        {

            if(grid.children[i].selected){

                grid.children[i].vm_shot()

            }

        }
    }

    onHeightChanged: resize()
    onWidthChanged: resize()

    function resize(){

        var ww = width/supreme.scale
        var hh = height/supreme.scale

        console.log("Меняю размеры w_model ",w_model.count)
        for(var i=0;i<w_model.count;i++){

          console.log(i," ",w_model.get(i).uid," ",w_model.get(i).url)

            w_model.setProperty(i,"h",hh)
            w_model.setProperty(i,"w",ww)
            w_model.setProperty(i,"x",ww*(i%supreme.scale))
            w_model.setProperty(i,"y",hh*((i<supreme.scale)?0:((i-(i%supreme.scale))/supreme.scale)))


        }
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

    function rescale(scale){

        if(width==0)
            return

        if(height==0)
            return

        console.log("MultiVM rescale Item wh: ",width," ",height," ",scale);

        saving_on()

        var ww = width/scale
        var hh = height/scale

        grid.rows = scale
        grid.columns = scale

        lcl_model.clear()

        for(var i = 0;i < w_model.count;i++){

        lcl_model.append({cid:w_model.get(i).cid, url: w_model.get(i).url,uid:w_model.get(i).uid})
  }


    console.log("w_modell count ",w_model.count)

         for(var i = 0;i < w_model.count;i++){
        console.log("w.. ",w_model.get(i).uid," ",w_model.get(i).cid," ",w_model.get(i).url)
        }

         console.log("lcl model count ",lcl_model.count)

        for(var i = 0;i < lcl_model.count;i++){
        console.log("lcl.. ",lcl_model.get(i).cid," ",lcl_model.get(i).url)
        }

        w_model.clear()
/*
        console.log("Исходная w_model ",w_model.count)
        for(var i=0;i<w_model.count;i++){

          console.log(i," ",w_model.get(i).uid," ",w_model.get(i).url)

        }


        console.log("Чищу w_model ",w_model.count)
        for(var i=0;i<w_model.count;i++){

            if(w_model.count>scale*scale)
            if(w_model.get(i).url===""){
                console.log("remove ",i," ",w_model.get(i).uid," ",w_model.get(i).url)
                w_model.remove(i,1)
                i--
            }

        }


        console.log("Меняю размеры w_model ",w_model.count)
        for(i=0;i<w_model.count;i++){

          console.log(i," ",w_model.get(i).uid," ",w_model.get(i).url)

            w_model.setProperty(i,"h",hh)
            w_model.setProperty(i,"w",ww)
            w_model.setProperty(i,x,ww*(i%scale))
            w_model.setProperty(i,y,hh*((i<scale)?0:((i-(i%scale))/scale)))


        }

*/


        for(var i=0;i<scale*scale;i++){


            var url, cid,uid

            if(lcl_model.count>i){
            url=lcl_model.get(i).url
            cid=lcl_model.get(i).cid
                uid=lcl_model.get(i).uid
            }else{
            cid=-1
            url=""
                uid=index++
            }
console.log("Добавляю ",cid," ",url)
            if(i>=w_model.count){
                w_model.append({h:hh,w:ww,
                                   x: ww*(i%scale),
                                   y: hh*((i<scale)?0:((i-(i%scale))/scale)),
                                   uid: uid,
                                   cid: cid,
                                   url:url
                               })
            }
        }

        console.log("Меняю размеры w_model ",w_model.count)
        for(i=0;i<w_model.count;i++){

          console.log(i," ",w_model.get(i).uid," ",w_model.get(i).url)

            w_model.setProperty(i,"h",hh)
            w_model.setProperty(i,"w",ww)
            w_model.setProperty(i,x,ww*(i%scale))
            w_model.setProperty(i,y,hh*((i<scale)?0:((i-(i%scale))/scale)))


        }

        console.log("Итоговая w_model ",w_model.count)
        for(i=0;i<w_model.count;i++){

          console.log(i," ",
                      w_model.get(i).uid," ",
                      w_model.get(i).cid," ",
                      w_model.get(i).url," ",
                      w_model.get(i).h," ",
                      w_model.get(i).w," ",
                      w_model.get(i).x," ",
                      w_model.get(i).y," ",

                      )




        }

    saving_off()

    }

    Rectangle{
    x: supreme.width-50
    y: 20
    width: 30
    height: 30
    color: "lightgray"

    MouseArea{
    anchors.fill:parent
    onClicked: {
    if(supreme.scale<5){
        supreme.scale++
    }
                else{
    supreme.scale=2
    }
    rescale(supreme.scale)


    }


    }

    }

    Component.onCompleted: {


    console.log("multivm ",supreme.width," ",supreme.height," ",grid.width," ",grid.height)

        supreme.scale=5;
    w_model.clear()
      rescale(supreme.scale)



    }
}
