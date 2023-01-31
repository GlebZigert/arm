import QtQuick 2.11
import QtQuick.Layouts 1.0
import "../../js/axxon.js" as Axxon
Item{
    anchors.fill: parent
    property int scale:5

    ListModel {

        id: w_model
        dynamicRoles: true

    }

    ListModel {

        id: cids
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
            model: w_model

            Item {

                x: model.x
                y:model.y
                width: model.w
                height: model.h

                property bool selected
                property bool contain_mouse: area.containsMouse ? true : false

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

var src = Axxon.get_cids()


     for(var i=0;i<src.length;i++){
         var lcl = src[i]
     if(i>=cids.count){
         cids.append({cid:lcl})
     }else{
     cids.setProperty(i,"cid",lcl)
     }
     }

     for(var i=0;i<cids.count;i++){
     console.log(cids.get(i).cid)
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
        cids.append({cid:-1})
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
                            cid:cids.get(i).cid
                            })

         }

    }



}
