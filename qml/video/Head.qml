import QtQuick 2.0
import QtQuick.Controls 2.4

//Панель с двумя кнопками.
//Кнопки должны располагаться слева и целиком умещаться в границах панели
Rectangle{
    id:container
    property int side: (width>height)?height:width
     //   anchors.fill:parent
color: "gray"

signal current_page(int page)
signal do_it()

ListModel{
id: model
}


Grid {
    columns: 4
    spacing: 2
    anchors.fill:parent

/*
//Кнопка добавления выбранной камеры в рабочее пространство
   Button{
           width:height
           height:container.side

           onClicked: {
               //console.log("[do_it]")
               do_it()

           }

       }
   */
//Комбобокс с номерами страниц
   ComboBox{
    id: combo
    model:model
    width:height*4
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
   }

//Кнопка следующей страницы
//Увеличивает номер страницы если он меньше наибольшего
//если наибольший - перводит на первую страницу
   Button{
       width:height*3
       height:container.side

       onClicked: {
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

   }

}


//функция для добавления страиницы
//добавляет итем в комбобокс


function set_count(val)
{
model.clear()
    for(var i=0;i<val;i++)
     model.append({number:i+1})
}
/*
function add_page()
{
model.append({number:(combo.count+1)})
//console.log("[add_page] ",combo.count)

}
*/
Component.onCompleted: {
combo.activated.connect(current_page_changed)

}

function current_page_changed()
{
    var dt=new Date();
console.log("------------------------------------------------------------------------------------- ",dt," current_page_changed ")
current_page(combo.currentIndex+1)
}


}


