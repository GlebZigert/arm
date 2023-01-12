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
    }

    function set_Scale(val){
        v1.set_Scale(val)
        v2.set_Scale(val)
    }

    function set_vm_source(src){
        v1.set_vm_source(src)
        v2.set_vm_source(src)
    }

    function vm_start(){
        v1.vm_start()
        v2.vm_start()
    }

    function vm_stop(){
        v1.vm_stop()
        v2.vm_stop()
    }
    function vm_shot(){
        v1.vm_shot()
        v2.vm_shot()
    }



}
