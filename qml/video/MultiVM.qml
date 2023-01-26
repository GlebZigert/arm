import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.0



Item {

    id:supreme

    property int index: 0
    signal playing
    signal selected

    property int scale;

    ListModel {
        id: w_model

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



              //  property string source


                onReturn_source: (subject)=> {

                                     console.log("MultiVM onSourceChanged ", subject)

                    console.log("model.count ", w_model.count)

                                         for(var i = 0;i < w_model.count-1;i++){

                                         console.log(i," ",w_model.get(i).uid)
                                            console.log(i," ",uid)
                                             if(w_model.get(i).uid === uid){
                                                w_model.setProperty(i,"url",subject)

                                             console.log("w_model")
                                             for(i=0;i<w_model.count-1;i++){

                                               console.log(i," ",w_model.get(i).url)

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

            function set_selected(val){
            selected=val
            vm.selected=val
           //     console.log("selected ",val)
            }

            Component.onCompleted: {
                console.log("Rect ",index," is onCompleted ",selected)
            selected=false
                  resize_vm()
            }

            function set_Scale(val){

                vm.set_Scale(val)
            }

            function set_vm_source(src){


                vm.set_vm_source(src)
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

    function set_vm_source(src){
        for(var i = 0; i<grid.children.length; i++)
        {

            if(grid.children[i].selected){

                grid.children[i].set_vm_source(src)

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

        if(width==0)
            return

        if(height==0)
            return

        console.log("MultiVM onWidthChanged Item wh: ",width," ",height," ",scale);


        var ww = width/scale
        var hh = height/scale

        grid.rows = scale
        grid.columns = scale

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

            if(i>=w_model.count){
                w_model.append({h:hh,w:ww,
                                   x: ww*(i%scale),
                                   y: hh*((i<scale)?0:((i-(i%scale))/scale)),
                                   uid: index++,
                                   url:""
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
                      w_model.get(i).url," ",
                      w_model.get(i).h," ",
                      w_model.get(i).w," ",
                      w_model.get(i).x," ",
                      w_model.get(i).y," ",

                      )




        }


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
    resize()


    }


    }

    }

    Component.onCompleted: {


    console.log("multivm ",supreme.width," ",supreme.height," ",grid.width," ",grid.height)

        scale=5;
    w_model.clear()
        resize();



    }
}
