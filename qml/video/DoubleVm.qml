import QtQuick 2.0

Item {

    signal playing
    signal selected

    Vvvvvvm{
        id: v1

     //   anchors.fill: parent
        x:0
        y:0
        width: 400
        height: 400





        onActiveFocusChanged:{
        console.log("v1 activeFocus: ", v1.activeFocus)


        }

        MouseArea{
        anchors.fill: parent
        onClicked: {
        v1.selected=true
            v2.selected=false
        }
        }
    }

    Vvvvvvm{
        id: v2

     //   anchors.fill: parent
        x:400
        y:0
        width: 400
        height: 400



        onActiveFocusChanged:{
        console.log("v1 activeFocus: ", v1.activeFocus)


        }

        MouseArea{
        anchors.fill: parent
        onClicked: {
        v2.selected=true
            v1.selected=false
        }
        }

    }

    function set_Scale(val){

         if(v1.selected)
        v1.set_Scale(val)

          if(v2.selected)
        v2.set_Scale(val)
    }

    function set_vm_source(src){

        if(v1.selected)
        v1.set_vm_source(src)

        if(v2.selected)
        v2.set_vm_source(src)
    }

    function vm_start(){
         if(v1.selected)
        v1.vm_start()

         if(v2.selected)
        v2.vm_start()
    }

    function vm_stop(){
         if(v1.selected)
        v1.vm_stop()
          if(v2.selected)
        v2.vm_stop()
    }
    function vm_shot(){
         if(v1.selected)
        v1.vm_shot()
          if(v2.selected)
        v2.vm_shot()
    }




}
