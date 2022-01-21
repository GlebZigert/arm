import QtQuick 2.0
import QtQuick.Layouts 1.5
import Preview 1.0
//Окно в несколько страниц где представлены все доступные элементы (все доступные камеры)
//Отсюда можешь перекидывать камеры в рабочее пространство где камеры будут стримить
Item {
    id: container
     width:300
     height: 700
    property int page_size: 4
    property int current: -1

     property int current_page:1

    property var progress_bar

    signal add_to_space(var x)

    signal refresh(var y)

//------------------------------------
//Модели

//модель
ListModel{
id: model
//dynamicRoles: true
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
model:container.page_model

anchors.fill: parent
anchors.margins: 2
cellWidth: 300
cellHeight: 100

interactive: false

//Делегат
delegate:
//-----------------------------------
Rectangle{
width: 400
height: 100
color: "#ffe4c4"
border.color: "black"
border.width: 2

property int id
//Справа - фото, слева - текст
Row{
//Фото
    Preview{
    id: image
    property int mid: modelData.preview_id
    width: 150
    height: 98
    //url:modelData.frash_snapshot
    }
    /*
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
    */
//Текст
 Rectangle{
        width: 250
        height: 98
    //    color:"white"
color: "#ffe4c4"
    Text {
        id: text
        width: parent.width
        height: 100
        x:10

     //   text: modelData.name
        text: modelData.id
        font.family: "Helvetica"
        font.pointSize: 10

        minimumPointSize: 10
        fontSizeMode: Text.HorizontalFit
        color: "black"
        }
        }



}

function func(y){
//console.log("= refresh =")

//console.log("мой id", image.mid, "и пришедший: ",y.obj.id )
    if(image!=null)
    if(image.mid==y.obj.preview_id){
        //console.log("обновляю:","мой id", image.mid," ",y.obj.name," ",y.obj.frash_snapshot)
        text.text=y.obj.name
        if(image.url!=y.obj.frash_snapshot){
            image.url=y.obj.frash_snapshot
        }
    }


}



Component.onCompleted: {
    console.log("mid: ",image.mid)
    container.refresh.connect(func)
    container.do_refresh(image.mid)

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
        console.log("ind " ,ind)
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
//root.cameraList.updated.connect(update_from_cameraList)

head.do_it.connect(add_this_camera)

head.current_page.connect(change_current_page)

model.clear()
/*
for (var i=0;i<page_size;i++){
    container.page_model.append({obj:{
                              id: -1 ,
                              name: "" ,
                              serviceId: -1,
                              frash_snapshot:"",
                          }})

}
*/
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
function change_current_page(page){
current_page=page
go_to_page(current_page)

}
function update_from_cameraList() {
console.log("[update_from_cameraList]")

    model.clear()
      for(var j=0;j< root.cameraList.count;j++){

         console.log(j," ",root.cameraList.get(j).name)


         model.append({obj: {

                              id: root.cameraList.get(j).id ,
                              name: root.cameraList.get(j).name ,

                              frash_snapshot:root.cameraList.get(j).frash_snapshot,


                          }



                      })

      }

      console.log(" ")
      console.log("model:")
      for(j=0;j< model.count;j++){

         console.log(j," ",model.get(j).obj.name)
      }
      console.log(" ")

head.set_count(Math.floor(model.count/page_size)+1)
go_to_page(current_page)

}

function add_this_camera()
{
    console.log("[add to space]")
    //console.log("container.current ",container.current)
if(container.current>(-1))
{
console.log("container.current ",container.current)
var x=container.page_model.get(container.current)
 //console.log("profit")
    console.log("name ",x.obj.id)
    console.log("name ",x.obj.name)
   // console.log("point ",x.obj.point)
   //  console.log("telemetryControlID ",x.obj.telemetryControlID)
      //console.log("serviceId ",x.obj.serviceId)


add_to_space(x.obj.id)
/*
add_to_space(x.obj.name,
             x.obj.point,
             x.obj.telemetryControlID)
*/
}


}

function go_to_page(page){

    //console.log("[go_to_page] ",page)

    //console.log("container.page_model всего слотов: ",container.page_model.count)

    //console.log("нужно отобразить страницу: ",page)

    //console.log("она последняя? ",page," ",model.count/page_size)

    var sz=0
    if (page>(model.count/page_size)){

        // console.log("ДА")
        sz=model.count%page_size

    }else{

        //  console.log("НЕТ")
        sz=page_size

    }
     // console.log("Нам нужно слотов: ",sz," а у нас ",container.page_model.count)

    var size=sz-container.page_model.count
    if(container.page_model.count<sz){

     //console.log("У нас МЕНЬШЕ чем надо на ",size)
        size=sz-container.page_model.count


        for(var i=0;i<(size);i++){

            var ind=container.page_model.count
            container.page_model.append({obj:{
            preview_id:ind ,
            id: -1,
            name: "" ,
            frash_snapshot:"",
            }})
            //console.log("добавил на позицию: ",ind," теперь слотов: ",container.page_model.count)
        }
    }
    size=container.page_model.count-sz
    if(container.page_model.count>sz){

        //  console.log("У нас БОЛЬШЕ чем надо на",size)

        for(i=0;i<size;i++){

            var ind=container.page_model.count-1
            container.page_model.remove(ind)
               //     console.log("убрал позицию: ",ind," теперь слотов: ",container.page_model.count)
        }
    }

     // console.log("Теперь у на слотов: ",container.page_model.count)


    for(i=0;i<container.page_model.count;i++){

        do_refresh(i)

    }


     console.log(" ")
     console.log("container.page_model: ")
    for(i=0;i<container.page_model.count;i++)
    {
        var yy=container.page_model.get(i)

        console.log(i," ",yy.obj.id)

    }
     console.log(" ")




}

function do_refresh(i){

    console.log("do_refresh ",i)

    var ind=i+page_size*(current_page-1)
    var x=model.get(ind)
    var y=container.page_model.get(i)

    //console.log("...",ind," из",model.count)
    console.log(" ")

    console.log("x.obj.id ",x.obj.id)
    console.log("x.obj.name ",x.obj.name)
    console.log("x.obj.serviceId ",x.obj.serviceId)
    console.log("x.obj.frash_snapshot ",x.obj.frash_snapshot)

    console.log(" ")

    console.log("y.obj.preview_id ",y.obj.preview_id)
    console.log("y.obj.id ",container.page_model.get(i).obj.id)
    console.log("y.obj.name ",container.page_model.get(i).obj.name)
    console.log("y.obj.serviceId ",container.page_model.get(i).obj.serviceId)
    console.log("y.obj.frash_snapshot ",container.page_model.get(i).obj.frash_snapshot)

    console.log(" ")


    container.page_model.set(i,{obj:{"preview_id":i,"id":x.obj.id,"name":x.obj.name}})
/*
    container.page_model.get(i).obj.id=x.obj.id
    container.page_model.get(i).obj.name=x.obj.name
    container.page_model.get(i).obj.frash_snapshot=x.obj.frash_snapshot

    */
    console.log("y.obj.preview_id ",y.obj.preview_id)
    console.log("y.obj.id ",container.page_model.get(i).obj.id)
    console.log("y.obj.name ",container.page_model.get(i).obj.name)
    console.log("y.obj.serviceId ",container.page_model.get(i).obj.serviceId)
    console.log("y.obj.frash_snapshot ",container.page_model.get(i).obj.frash_snapshot)

    console.log(" ")


    container.refresh({"obj":{"preview_id":i,"id":x.obj.id,"name":x.obj.name,"frash_snapshot":x.obj.frash_snapshot}})
}



}
