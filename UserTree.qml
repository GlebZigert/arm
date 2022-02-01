import QtQuick 2.11
//import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
//import QtQuick.Controls.Material 2.11
//import "js/devices-tree.js" as Lib
//import "qml/form-fields" as Forms
import "qml/forms" as Forms
import "js/users.js" as Users
import "js/utils.js" as Utils

Item {
    signal send(var message)
    property ListModel treeModel: root.users
    property bool adminMode: false
    property var forms: ({
        'user': Qt.createComponent('qml/forms/UserForm.qml'),
    })

    anchors.fill: parent
    RowLayout {
        anchors.fill: parent
        Forms.MyTree {
            id: tree
            model: treeModel
            //anchors.margins: 10
            //anchors.fill: parent
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        // right panel
        Rectangle {
            visible: adminMode
            color: "lightgray"
            Layout.fillHeight: true
            //Layout.minimumWidth: 300
            implicitWidth: 400

            Loader {
                id: loader
                anchors.fill: parent
                anchors.margins: 5
                //property int itemId // why don't use (model && model.id || 0) here?
                property int itemId: model && model.id || 0
                property int nocache // for user image url
                property bool newItem: 0 === itemId
                property var model //({})
                property ListModel newUser: ListModel{}
                sourceComponent: model && 'form' in model ? forms[model.form] : undefined
                //onModelChanged: itemId = model && model['id'] || 0

                function makeNewUser(parentId) {
                    root.log("NEW:", parentId)
                    newUser.clear()
                    newUser.append([Users.newItem({parentId: parentId})])
                    model = newUser.get(0)
                }

                /*Connections {
                    target: loader.item
                    onSelectNode: {
                        tree.selectNode(id)
                        root.log("Connection", id)
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
        treeModel.updated.connect(reloadForm)
    }

    function reloadForm(id) {
        if (loader.model && loader.model.id === id) {
            root.log("RELOAD!")
            loader.nocache = Math.round(Math.random() * 2e9)
            loader.model = loader.model
        }
    }

    function selected(item) {
        // TODO: QT BUG? item <> node from model
        if (item.id) { // existing user
            if (item.zones.count === 0 || item.devices.count === 0)
                root.newTask('configuration', 'UserInfo', item.id, infoDone, function (){root.log('UserInfo failed')})
            else
                loader.model = Utils.findItem(treeModel.get(0).children, item.id)
        } else {// new user
            //loader.model = Utils.findItem(treeModel.get(0).children, item.id)
            loader.makeNewUser(0)
        }
        //popup.open()
    }

    function infoDone(msg) {
        //root.log("INFO DONE:", JSON.stringify(msg))
        var user,
            id = msg.data.id
        if (id) {
            loader.model = Utils.findItem(treeModel.get(0).children, id)
        }
        //root.users.updated()
        //loader.model = user
    }
}
