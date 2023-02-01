import QtQuick 2.11
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.4
import "../../js/axxon.js" as Axxon
Item{
    id: good
    anchors.fill: parent
    property int scale:5
    property bool first_time: true
    property int index: 0

    signal selected_cid(int cid)
    signal give_me_a_camera


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


                Rectangle{
                    anchors.fill: parent
                    color: selected ? "lightgray" : "gray"


                    Text{
                        anchors.fill: parent
                        text: model.cid
                    }
                }




                MouseArea{
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true


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


                function set_cid(cid){
               //  vm.set_vm_cid(cid)

                 findAndSet(cids,vm.uid,"cid",cid)
                 findAndSet(w_model,vm.uid,"cid",cid)
                }

                function findAndSet(model,uid,property_string,val){


                      for(var i = 0;i < model.count;i++){

                             if(model.get(i).uid === uid){

                               model.setProperty(i,property_string,val)

                             }
                      }
                }

            }
        }
    }


        propagateComposedEvents: true

        onClicked: {
            for(var i = 0; i<grid.children.length-1; i++)
            {
                if(grid.children[i].contain_mouse){
                    grid.children[i].selected=true
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
                    cids.append({cid:lcl,uid:index++})
                }else{
                    cids.setProperty(i,"cid",lcl)
                }
            }

            for(var i=0;i<cids.count;i++){
                console.log(cids.get(i).cid)
            }
        }
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

        root.cameraList.updated.connect(reconnect_livestream)
         scale=5
          rescale(5)
    }



    function rescale(scale){


        for(var i = 0;i<scale*scale; i++){
            if(i>=cids.count){
                cids.append({cid:-1,uid:index++})
            }
        }

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
                               cid:cids.get(i).cid
                           })
        }
    }


}
