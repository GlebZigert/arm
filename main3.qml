import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.11
import QtQuick.Layouts 1.5
import QtQuick.Controls 1.4

Window {
  title: qsTr("Hello World")
  id: window
  width: 800
  height: 600
  visible: true

  Item {
      anchors.fill: parent
/*
      Rectangle {
          id: menu
          color: 'red'
          anchors.right: parent.right
          anchors.left: parent.left
          height: 80
          Button {
              text: "layout 1"
              onClicked: layout.currentIndex = 0
          }
          Button {
              text: "layout 2"
              onClicked: layout.currentIndex = 1
              anchors.right: parent.right
          }
      }
*/
      Row {
            id: menu
            Button {
              text: "red view"
              onClicked: layout.currentIndex = 0
            }
            Button {
              text: "green view"
              onClicked: layout.currentIndex = 1
            }
            Button {
              text: "combo view"
              onClicked: layout.currentIndex = 2
            }
          }
    StackLayout {
          id: layout
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          anchors.left: parent.left
          anchors.top: menu.bottom
          currentIndex: 1
          Rectangle {
              color: 'teal'
              implicitWidth: 200
              implicitHeight: 200
          }
          SplitView {
              anchors.fill: parent
              orientation: Qt.Horizontal

              /*Rectangle {
                  width: 200
                  Layout.maximumWidth: 400
                  color: "lightblue"
                  Text {
                      text: "View 1"
                      anchors.centerIn: parent
                  }
              }*/
              MyMap {
                  width: 400
              }
              MyVideo {
                  Layout.minimumWidth: 50
                  Layout.fillWidth: true

              }

              /*Rectangle {
                  id: centerItem
                  Layout.minimumWidth: 50
                  Layout.fillWidth: true
                  color: "lightgray"
                  Text {
                      text: "View 2"
                      anchors.centerIn: parent
                  }
              }
              /*Rectangle {
                  width: 200
                  color: "lightgreen"
                  clip: true
                  Text {
                      text: "View 3"
                      anchors.centerIn: parent
                  }
              }*/
          }
          SplitView {
              anchors.fill: parent
              orientation: Qt.Horizontal

              MyVideo {
                  Layout.minimumWidth: 50
                  Layout.fillWidth: true

              }
              MyMap {
                  width: 400
              }

          }
/*
          Rectangle {
              color: 'plum'
              implicitWidth: 300
              implicitHeight: 200
          }*/
      }
  }
}
