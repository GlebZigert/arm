import QtQuick 2.11
import QtQuick.Controls 1.4
import "../../js/axxon_telemetry_control.js" as Tlmtr

Item {



    id: container

    property var serviceId
    property int current_tlmtr_id: -1

    Rectangle{
    anchors.fill: parent
    color: "gray"


    Column{

        anchors.fill: parent

         Rectangle{
             x:5
             width: parent.width-10
             height: 20
             color: "gray"

             Row{
           spacing: 5
             anchors.fill: parent

             Rectangle{
             height: parent.height
             width: 50
             Text{

                      visible: true
             text: "   +"
                 }
             MouseArea{
                 anchors.fill: parent
             onClicked: {

                 var res
                 res =true
                 for(var i=0;i<model.count;i++)
                 {
                 if(model.get(i).index<0)
                     res=false
                 }


                 if(res)
                 model.append({num: model.count+1,index:-1,
                              name:""
                               })
             }
             }
             }



             Rectangle{
             height: parent.height
             width: 50
             Text{

                      visible: true
             text: "   -"
                 }
             MouseArea{
                 anchors.fill: parent
             onClicked: {
             remove(list.selected)
                 list.selected=-1
             }
             }
             }

             Rectangle{
              height: parent.height
              width: 90

              Text{

                       visible: true
              text: " Ред"
                  }

              MouseArea{
                  anchors.fill: parent
              onClicked: {
               edit_text(list.selected)
              }
              }
              }

             }

             MouseArea{
             anchors.fill: parent
             propagateComposedEvents: true
             onClicked: {

                 mouse.accepted=false
             }
             }
         }

    Rectangle{
        id: rect
        width: parent.width
        height: parent.height-10
    color: "gray"

    Rectangle{
    x:5
    y:5
    width: parent.width-5
    height: parent.height-5
    anchors.centerIn: parent.Center
    color: "lightblue"

    clip:true

    ListModel{
        id: model


    }


    ScrollView {
         id: sview
         anchors.fill: parent
         highlightOnFocus: true
          clip: true

         horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
         verticalScrollBarPolicy: Qt.ScrollBarAsNeeded

     Column{
    Repeater{
        id: list

anchors.fill: parent

     model: model



     property int selected: -1
     property int current: -1

     delegate: Rectangle {

            id: unit

         color:"lightblue"


     width: rect.width
     height: 30

      property  int number:num
      property  int ind:index


         Text{
                x:10
                y:5

                  visible: true
         text: name
             }


         TextField {
             id: text_field
             visible: false
             width: parent.width
             height: 30
             placeholderText: qsTr("Enter name")
             focus: true
             activeFocusOnPress: true


             property int ind: index

              onAccepted:{


              if(ind<0)
              {
               Tlmtr.add(text_field.text,serviceId)
              }
              else
              {
              Tlmtr.edit(ind,text_field.text,serviceId)
              }


              }

              Keys.onPressed: {
                      if (event.key == Qt.Key_Enter) {

                          text_field.visible=false
                          event.accepted = true

                      }
                  }



         }


         MouseArea{
             id: area
             anchors.fill: parent
             onClicked: {

    //
                 if(number==list.selected)
                 {

                  list.current=parent.number
                 }
                 else
                 {
                 list.selected=parent.number

                 }
                 update_view()
             }

         }




         Component.onCompleted: {
             if(ind == -1)
                 text_field.visible=true
             text_field.forceActiveFocus()

}

function set_edit_signal()
{

Tlmtr.edit(text_field.text,serviceId)
}

function show_text_field(fl)
{

    if(fl)
    {
    if(text_field.visible)
    {

        text_field.visible=false
        area.enabled=true
    }
    else
    {

     text_field.visible=true
     text_field.focus=true
     text_field.forceActiveFocus()
        area.enabled=false
    }

    }
    else
    {

    text_field.visible=false
        area.enabled=true
    }
}

         function  set_current(fl)
         {
             if(fl)
             {

             Tlmtr.go_to_preset(index,container.serviceId)

             }
             else
             {
                 border.width=0
             }

         }

         function set_normal()
         {

         border.width=0
         color="lightblue"

         }

         function select(fl)
         {

             if(fl)
             {
          color="#d8edf3"
             }
             else
             {
         color="lightblue"
             }


         }
     }





     }
     }

}


    }



    }
    }




    }

    Component.onCompleted: {
    root.camera_presets.updated.connect(update_model)
    }

    function remove(num)
    {
        for(var i=0;i<list.count;i++)
        {

        var x=list.itemAt(i)

            if(x.number==list.selected)
            {

            Tlmtr.remove(x.ind,serviceId)

            }

        }
    }

    function edit_text(num)
    {

           for(var i=0;i<list.count;i++)
           {

           var x=list.itemAt(i)

           x.show_text_field(x.number==list.selected?true:false)

           }


    }

    function clear_model()
    {
    model.clear()
    }

    function update_view()
    {

        for(var i=0;i<model.count;i++)
        {

                if(model.get(i).index<0)
                    model.remove(i)


        }



       for(var i=0;i<list.count;i++)
       {

       var x=list.itemAt(i)
 x.show_text_field(0)
           var res=0

           x.select(x.number==list.selected?true:false)
           x.set_current(x.number==list.current?true:false)

       }

    }

    function update_current_preset()
    {
       for(var i=0;i<list.count;i++)
       {
       var x=list.itemAt(i)
           if(x.number==list.selected)
              x.select()
           else
              x.set_normal()
       }

    }

    function update_model()
    {
    model.clear()

        for(var i=0;i<root.camera_presets.count;i++)
        {
            var x=root.camera_presets.get(i)

        model.append({num: i,index:x.index,
                     name:x.name
                      })
        }

    }

}
