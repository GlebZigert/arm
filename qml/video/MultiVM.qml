import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.0

Item {

    id:supreme

  anchors.fill: parent
    signal playing
    signal selected

    ListModel {
        id: work_model

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

        model: work_model




        Item {
            width: supreme.width/grid.columns
            height: supreme.height/grid.rows

        //      width: (height/1080)*1920
        //      height: 250

            signal isSelected(int index)

            property int index
            property bool selected
            property bool contain_mouse: area.containsMouse ? true : false

            Rectangle{
                width: supreme.width/grid.columns
                height: supreme.height/grid.rows
            color: selected? "lightgray" : "gray"

             }


            Vvvvvvm{
                id: vm

                width: supreme.width/grid.columns
                height: supreme.height/grid.rows



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



    Component.onCompleted: {


    console.log("multivm ",supreme.width," ",supreme.height," ",grid.width," ",grid.height)
        for(var i=0;i<20;i++){
            work_model.append({index: i})
        }

    }
}
