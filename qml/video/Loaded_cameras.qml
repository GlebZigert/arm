import QtQuick 2.0
import QtQuick.Layouts 1.5
import Preview 1.0

Item {
    id: container
     width:300
     height: 700
    property int page_size: 50
    property int current: -1

     property int current_page:1

    property var progress_bar

    signal add_to_space(var x)

    signal refresh(var y)


     ListModel{
     id: model

     }

property ListModel page_model: ListModel{ }

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

head.do_it.connect(add_this_camera)
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
current_page=page
go_to_page(current_page)
}

function update_from_cameraList() {

 root.log("update_from_cameraList")
    model.clear()

      for(var j=0;j< root.cameraList.count;j++){

         root.log(j," ",root.cameraList.get(j).name)
         model.append({obj: {
                              id: root.cameraList.get(j).id ,
                              name: root.cameraList.get(j).name ,
                              ipadress:  root.cameraList.get(j).ipadress ,
                              frash_snapshot:root.cameraList.get(j).frash_snapshot,
                          }
                      })
      }

head.set_count(Math.floor(model.count/page_size)+1)
go_to_page(current_page)
}

function add_this_camera()
{

if(container.current>(-1))
{

var x=container.page_model.get(container.current)

add_to_space(x.obj.id)
container.visible=false

}

}

function go_to_page(page){

    var sz=0
    if (page>(model.count/page_size)){

        sz=model.count%page_size

    }else{

        sz=page_size

    }

    var size=sz-container.page_model.count
    if(container.page_model.count<sz){

        size=sz-container.page_model.count


        for(var i=0;i<(size);i++){

            var ind=container.page_model.count
            container.page_model.append({obj:{
            preview_id:ind ,
            id: -1,
            ipadress:  "" ,
            name: "" ,
            frash_snapshot:"",
            }})

        }
    }
    size=container.page_model.count-sz
    if(container.page_model.count>sz){

        for(i=0;i<size;i++){
            var ind=container.page_model.count-1
            container.page_model.remove(ind)
        }
    }

    for(i=0;i<container.page_model.count;i++){
        do_refresh(i)
    }

    for(i=0;i<container.page_model.count;i++)
    {
        var yy=container.page_model.get(i)
    }
}

function do_refresh(i){

    var ind=i+page_size*(current_page-1)
    var x=model.get(ind)
    var y=container.page_model.get(i)

    container.page_model.set(i,{obj:{"preview_id":i,"ipadress":x.obj.ipadress,"id":x.obj.id,"name":x.obj.name}})

    container.refresh({"obj":{"preview_id":i,"ipadress":x.obj.ipadress,"id":x.obj.id,"name":x.obj.name,"frash_snapshot":x.obj.frash_snapshot}})
}

}
