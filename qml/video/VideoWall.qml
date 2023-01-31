import QtQuick 2.11

Item{
    anchors.fill: parent


    MultiVM{
        id: multivm
        anchors.fill: parent

    }

    function give_him_a_camera(){
    console.log("give_him_a_camera()")
    }

    Component.onCompleted: {


     multivm.give_me_a_camera.connect(give_him_a_camera)
    }




}
