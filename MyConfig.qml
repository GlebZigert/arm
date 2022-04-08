import QtQuick 2.11
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4

import "js/arm-config.js" as ARM

RowLayout {
    //signal send(var pass);
    property int panePosition
    anchors.fill: parent
    // left pane - "menu"
    spacing: 0

    Rectangle {
        id: menu
        Layout.fillHeight: true
        Layout.minimumWidth: 200
        color: "#eee"
        Column {
            anchors.fill: parent
            Repeater {
                id: repeater
                model: [
                    {label: "Подсистемы", component: "DevicesTree"},
                    {label: "Пользователи", component: "UserTree"},
                    {label: "Режимы доступа", component: "RulesTree"},
                    {label: "Контролируемые зоны", component: "ZonesTree"},
                    {label: "Карта и Планы", component: "MyMap"},
                    {label: "Алгоритмы", component: "Algorithms"},
                    {label: "Архив событий", component: "EventLog"},
                    {label: "Настройки", component: "MySettings"},
                ].filter(function (v){return v.component in armConfig})
                delegate: Button {
                    property int bid: index
                    width: parent.width
                    text: modelData.label
                    highlighted: layout.currentIndex == bid
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: "gray"
                    }
                    onClicked: layout.currentIndex = bid
                }
            }
        }
    }
    Rectangle {
        width: 1
        Layout.fillHeight: true
        color: "#80808080"
    }

    // right pane - "content"
    StackLayout {
      id: layout
      //currentIndex: 0 // devices
      //currentIndex: 1 // users
      //currentIndex: 2 // rules
      //currentIndex: 3 // zones
      //currentIndex: 4 // maps
      //currentIndex: 5 // algos
      //currentIndex: 6 // events
      currentIndex: 7 // settings
      Layout.fillWidth: true
      Layout.fillHeight: true

      Repeater {
          model: repeater.model
          delegate: Loader {
              id: loader
              property var activeComponent: modelData.component
              //sourceComponent: modelData.component
              source: modelData.component + ".qml"
              Binding {
                  target: loader.item
                  property: "adminMode"
                  value: true
              }
          }
      }

      onCurrentIndexChanged: {
          if (currentIndex < children.length && children[currentIndex].activate)
              children[currentIndex].activate()
      }
   }
}

