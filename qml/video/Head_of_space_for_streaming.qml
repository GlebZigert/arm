import QtQuick 2.0
import QtQuick.Controls 2.4


Rectangle{
    id:container
    property int side: (width>height)?height:width
     //   anchors.fill:parent
color: "gray"


signal do_it()
signal size(int x,int y)

ListModel{
id: scale_model
}


Grid {
    columns: 4
    spacing: 2
    anchors.fill:parent



   Button{
           width:height
           height:container.side

           text:"+"

           onClicked: {

               do_it()

           }



       }

   ComboBox{
    id: combo
    model:scale_model
    width:height*3
    height:container.side
    wheelEnabled: true



   }


   Button{

       width:height*3
       height:container.side

       onClicked: {

   }
}

   Button{
       width:height*3
       height:container.side

       onClicked: {

   }

}


Component.onCompleted: {

for(var i=10;i<80;i=i+5)
{
scale_model.append({data:{x:i*30,y:i*20}})
}

combo.activated.connect(scale_changed)

}

function scale_changed()
{

     size(scale_model.get(combo.currentIndex).data.x,
     scale_model.get(combo.currentIndex).data.y)

}


}
}


