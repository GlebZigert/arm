import QtQuick 2.0
import QtQuick.Layouts 1.5
import Preview 1.0

Item {
    id: container
     width:300
     height: 700
    property int page_size: 50

     property int page:1

    property var progress_bar

    signal add_to_space(var x)

     ListModel {

         id: model
         dynamicRoles: true

     }
//------------------------------------
Rectangle
{
anchors.fill:parent
border.color: "black"
border.width: 2
Column{
anchors.fill:parent


Head {
id: head
width:parent.width
height: 30
}

Rectangle{

id: list

width:parent.width
height: parent.height-head.height

GridView {

id: rpt
model:container.page_model
anchors.fill: parent
anchors.margins: 2
cellWidth: 300
cellHeight: 100
interactive: false

delegate:

Rectangle{
width: 400
height: 100
color: "#ffe4c4"
border.color: "black"
border.width: 2

property int id

Row{

    Preview{
    id: image
    property int mid: modelData.preview_id
    width: 150
    height: 98

    }



 Rectangle{
        width: 250
        height: 98

         color: "#ffe4c4"

     Column{

        Text {
            id: text
            width: parent.width
            height: 10
            x:10
            y:0
            text: modelData.id
            font.family: "Helvetica"
            font.pointSize: 10
            minimumPointSize: 10
            fontSizeMode: Text.HorizontalFit
            color: "black"
        }

        Text {
            id: ipadrfield
            width: parent.width
            height: 10
            x:10
            y:20
            text: modelData.ipadress
            font.family: "Helvetica"
            font.pointSize: 10
            minimumPointSize: 10
            fontSizeMode: Text.HorizontalFit
            color: "black"
        }
   }


}

}

function func(y){

    if(image!=null)
    if(image.mid==y.obj.preview_id){

        text.text=y.obj.name
        if(image.url!=y.obj.frash_snapshot){
            image.url=y.obj.frash_snapshot
        }
    }
}

Component.onCompleted: {
    root.log("mid: ",image.mid)
    container.refresh.connect(func)
    container.do_refresh(image.mid)
}

}
MouseArea {
    id: coords
        anchors.fill: parent
        hoverEnabled: true

    onPressed: {
        var ind = rpt.indexAt(coords.mouseX, coords.mouseY)
        root.log("ind " ,ind)
        container.current=ind
        add_this_camera()
    }
}

}

}

}
}

Component.onCompleted: {


head.current_page.connect(change_current_page)
model.clear()
var xx=model.count/page_size+1
head.set_count(Math.floor(model.count/page_size)+1)
head.cancel.connect(f_cancel)

}

function f_cancel(){
container.visible=false
}

function change_current_page(page){

go_to_page(page)
}





function go_to_page(page){

    console.log("go_to_page ",page)
    container.page=page
   container.page_size

    var begin=page*page_size;
    model.clear()
    for(var i=page;i<page_size;i++){
    if(i<root.cameraList.count){
        model.append({obj: {
                                     id: root.cameraList.get(j).id ,
                                     name: root.cameraList.get(j).name ,
                                     ipadress:  root.cameraList.get(j).ipadress ,
                                     stream:root.cameraList.get(j).livestream_low,
                                 }
                             })
        console.log("cid    ", root.cameraList.get(j).id)
        console.log("name   ", root.cameraList.get(j).name)
        console.log("ip     ", root.cameraList.get(j).ipadress)
        console.log("stream ", root.cameraList.get(j).livestream_low)
    }
    }



}



}
