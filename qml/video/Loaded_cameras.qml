import QtQuick 2.0
import QtQuick.Layouts 1.5

//Окно в несколько страниц где представлены все доступные элементы (все доступные камеры)
//Отсюда можешь перекидывать камеры в рабочее пространство где камеры будут стримить
Item {
    id: container
     width:300
     height: 700
    property int page_size: 8
    property int current: -1

    property var progress_bar

    signal add_to_space(var x)



//------------------------------------
//Модели

//модель
ListModel{
id: model
//dynamicRoles: true
}

ListModel{
id: page_model

//dynamicRoles: true
}

//------------------------------------
Rectangle
{
anchors.fill:parent
border.color: "black"
border.width: 2
Column{
anchors.fill:parent

//Шапка
Head {
id: head
width:parent.width
height: 30


}
//Основная часть


Rectangle{


id: list


width:parent.width
height: parent.height-head.height


GridView {


id: rpt
model: page_model

anchors.fill: parent
anchors.margins: 2
cellWidth: 300
cellHeight: 100

interactive: false

//Делегат
delegate:
//-----------------------------------
Rectangle{
width: 300
height: 100
color: "#ffe4c4"
border.color: "black"
border.width: 2
//Справа - фото, слева - текст
Row{
//Фото
    Image {
        id: image

        width: 150
        height: 98

 //       width: (videoOutput.height/1080)*1920
 //       height: videoOutput.height
   //     anchors.fill: parent
          visible: true
        property string accesspoint:modelData.point
 //       source: "http://root:root@192.168.0.187:8000/live/media/snapshot/"+accesspoint
          source: modelData.Snapshot

    }
//Текст
 Rectangle{
        width: 150
        height: 98
    //    color:"white"
color: "#ffe4c4"
    Text {
        width: 150
        height: 100
        x:10

        text: modelData.name
     //   text: modelData.Count
        font.family: "Helvetica"
        font.pointSize: 20

        minimumPointSize: 10
        fontSizeMode: Text.Fit
        color: "black"
        }
        }



}

Component.onCompleted: {


}
//По нажатию мыши индек модели эого экземепляра должен быть выбран. Как?
/*
MouseArea {
    id: area
    anchors.fill: parent

    drag.target: parent
    propagateComposedEvents : bool
    onReleased:
    {
        //console.log("[onReleased]")


    }
    onPressed: {
        var ind = rpt.indexAt(coords.mouseX, coords.mouseY)
        //console.log(coords.mouseX," ", coords.mouseY)
        //console.log("ind " ,ind)
        //console.log(rpt.model.get(ind).obj.name)
         mouse.accepted = false
    }

}
*/
}
MouseArea {
    id: coords
        anchors.fill: parent
        hoverEnabled: true


    onPressed: {

        var ind = rpt.indexAt(coords.mouseX, coords.mouseY)
        //console.log(coords.mouseX," ", coords.mouseY)
        //console.log("ind " ,ind)
        ////console.log(rpt.model.get(ind).obj.name)

        container.current=ind

        add_this_camera()


    }



}
//------------------------------------
}

}

}
}
//------------------------------------

Component.onCompleted: {
//Подгружаем камеры с сервера
//root.rtsp_stream_url.updated.connect(update_from_rtsp_stream_url)

head.do_it.connect(add_this_camera)

head.current_page.connect(go_to_page)

model.clear()

    /*
    for(var i=0;i<30;i++)
    {
        model.append({obj:{number:i.toString(),
                           name: "камера "+i.toString(),

                         }})
        //console.log("[look vat this]",model.get(i).obj.number)
    }
*/

    var xx=model.count/page_size+1
    //console.log("----xx------------------------------------",xx)
  //  for(var i=0;i<(Math.floor(model.count/page_size)+1);i++)

head.set_count(Math.floor(model.count/page_size)+1)

//go_to_page(0)



}

function update_from_rtsp_stream_url() {
console.log("[update_from_rtsp_stream_url]")
 //////console.log("[ UPDATE ]")
 //////console.log(rtsp_stream_url.count)
model.clear()

    for(var i=0;i<root.rtsp_stream_url.count;i++)
    {
        var x=root.rtsp_stream_url.get(i)
       console.log("name ",x.name)
        //console.log("point ",x.point)
         //console.log("telemetryControlID ",x.telemetryControlID)
         //console.log("serviceId ",x.serviceId)
        model.append({ obj: x})
/*
     model.append({ obj: {name:x.name,
                          point:x.point,
                          stream:"rtsp://root:root@192.168.0.187:50554/hosts/"+ x.point,
                          telemetryControlID: x.telemetryControlID
                      }})

*/

    }

    for(var i=0;i<model.count;i++)
    {
  //console.log("[url_Model.count]",i)
  //console.log("[url_Model.get(url_Model.count).name]",model.get(i).obj.name)
  //console.log("[url_Model.get(url_Model.count).point]",model.get(i).obj.point)
  //console.log("[url_Model.get(url_Model.count).stream]",model.get(i).obj.stream)
    }
head.set_count(Math.floor(model.count/page_size))
    go_to_page(0)

}

function add_this_camera()
{
    //console.log("container.current ",container.current)
if(container.current>(-1))
{

var x=rpt.model.get(container.current)
 //console.log("profit")
    //console.log("name ",x.obj.name)
     //console.log("point ",x.obj.point)
      //console.log("telemetryControlID ",x.obj.telemetryControlID)
      //console.log("serviceId ",x.obj.serviceId)

add_to_space(x)
/*
add_to_space(x.obj.name,
             x.obj.point,
             x.obj.telemetryControlID)
*/
}


}

function go_to_page(page)
{
console.log("[go_to_page] ",page)
page_model.clear()
for(var i=0;i<page_size;i++)
{
    var ind=i+page_size*page
    if(ind<model.count)
    {
//        console.log("model.get(i+page_size*page).obj: ",model.get(i+page_size*page).obj)
        page_model.append({obj:model.get(i+page_size*page).obj
                              })

        /*
page_model.append({obj:{number: model.get(i+page_size*page).obj.number,
                        name: model.get(i+page_size*page).obj.name,
                          point: model.get(i+page_size*page).obj.point,
                          telemetryControlID: model.get(i+page_size*page).obj.telemetryControlID
                      }})
    */

    }



}

}



}
