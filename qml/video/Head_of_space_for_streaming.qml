import QtQuick 2.0
import QtQuick.Controls 2.4

//Панель с двумя кнопками.
//Кнопки должны располагаться слева и целиком умещаться в границах панели
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


//Кнопка добавления выбранной камеры в рабочее пространство
   Button{
           width:height
           height:container.side

           text:"+"

           onClicked: {
               //root.log("[do_it]")
               do_it()

           }



       }
//Комбобокс с номерами страниц
   ComboBox{
    id: combo
    model:scale_model
    width:height*3
    height:container.side
    wheelEnabled: true



   }


//Кнопка предыдущей страницы
//Уменьшает номер страницы если он больше нуля
//Если равен нулю - переводит на наибольшую
   Button{

       width:height*3
       height:container.side

       onClicked: {
           /*
       var index=combo.currentIndex
       if(index>0)
       {
       combo.currentIndex--
       }
       else
       {
       combo.currentIndex=combo.count-1
       }
       container.current_page_changed()
       }
       */
   }
}
//Кнопка следующей страницы
//Увеличивает номер страницы если он меньше наибольшего
//если наибольший - перводит на первую страницу
   Button{
       width:height*3
       height:container.side

       onClicked: {
           /*
       }

       var index=combo.currentIndex
       if(index<combo.count-1)
       {
       combo.currentIndex++
       }
       else
       {
       combo.currentIndex=0
       }
       container.current_page_changed()
       }
*/
   }

}


Component.onCompleted: {

for(var i=10;i<80;i=i+5)
{
scale_model.append({data:{x:i*30,y:i*20}})
}

/*
scale_model.append({data:{x:300,y:200}})
scale_model.append({data:{x:450,y:300}})
scale_model.append({data:{x:600,y:400}})
scale_model.append({data:{x:750,y:500}})
scale_model.append({data:{x:900,y:600}})
scale_model.append({data:{x:900,y:600}})
*/




combo.activated.connect(scale_changed)



}

function scale_changed()
{
root.log("[scale_change] ",scale_model.get(combo.currentIndex).data.x,
            " ",
            scale_model.get(combo.currentIndex).data.y)



size(scale_model.get(combo.currentIndex).data.x,
     scale_model.get(combo.currentIndex).data.y)

}


}
}


