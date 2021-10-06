import QtQuick 2.11
//import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
//import QtQuick.Controls.Material 2.11
//import "js/devices-tree.js" as Lib
//import "qml/form-fields" as Forms
//import "qml/forms" as Forms

Item {
    signal send(var message)
    property ListModel treeModel: root.users
    property bool adminMode: false
    property var forms: ({
        'user': Qt.createComponent('qml/forms/UserForm.qml'),
        /*'service': Qt.createComponent('qml/forms/ServiceForm.qml'),
        'newServiceForm': Qt.createComponent('qml/forms/ServiceForm.qml')*/

    })
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        MyTree {
            id: tree
            model: treeModel
            anchors.margins: 10
            //anchors.fill: parent
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        // right panel
        Rectangle {
            visible: adminMode
            color: "lightgray"
            Layout.fillHeight: true
            Layout.minimumWidth: 300
            Loader {
                id: loader
                property bool newItem: false
                property var model: ({})
                sourceComponent: model && 'form' in model ? forms[model.form] : undefined
                onModelChanged: {
                    newItem = model && !model['id']
                }

                /*Connections {
                    target: loader.item
                    onSelectNode: {
                        tree.selectNode(id)
                        console.log("Connection", id)
                    }
                }
                Binding {
                    target: loader.item
                    property: "newItem"
                    value: false
                }*/
                //sourceComponent: model ? forms[model.template] : null
                //source: 'template' in model ? 'qml/forms/'+forms[model.template]+'.qml' : ''
            }
        }
    }
    Component.onCompleted: {
        //this.send.connect(Lib.onSend)
        //Lib.init({tree: tree, send: root.send, model: root.devList})
        //tree.model = root.devices
        tree.selected.connect(selected)
    }

    function selected(item) {
        loader.model = item
        //popup.open()
    }
}
