import QtQuick 2.11
import QtQml 2.11
//import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
//import QtQuick.Controls.Material 2.11
//import "js/devices-tree.js" as Lib
//import "qml/form-fields" as Forms
import "qml/forms" as Forms
import "js/utils.js" as Utils

Item {
    //signal send(var message)
    property int panePosition
    property ListModel treeModel: root.devices
    property bool adminMode: false
    property var forms: ({
        'parus': Qt.createComponent('qml/forms/ParusForm.qml'),
        'ipmon': Qt.createComponent('qml/forms/IPMonForm.qml'),
        'z5rweb': Qt.createComponent('qml/forms/Z5RWebForm.qml'),
        'rif': Qt.createComponent('qml/forms/RifForm.qml'),
        'service': Qt.createComponent('qml/forms/ServiceForm.qml')
    })
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        Forms.MyTree {
            id: tree
            model: treeModel
            anchors.margins: 10
            labelPadding: 1
            //anchors.fill: parent
            Layout.fillHeight: true
            Layout.fillWidth: true
            getTNID: Utils.getDeviceTNID
        }
        // right panel
        Rectangle {
            visible: adminMode
            color: "lightgray"
            Layout.fillHeight: true
            implicitWidth: 300
            Loader {
                id: loader
                property int itemId: model && model.serviceId || 0
                property var model//: ({})
                anchors.margins: 5
                anchors.fill: parent
                //width: parent.width
                //height: parent.height
                sourceComponent: model && model.form && forms[model.form] || undefined
                //sourceComponent: model ? forms[model.template] : null
                //source: 'template' in model ? 'qml/forms/'+forms[model.template]+'.qml' : ''
            }
        }
    }

    DevContextMenu {id: contextMenu}

    Component.onCompleted: {
        //this.send.connect(Lib.onSend)
        //Lib.init({tree: tree, send: root.send, model: root.devList})
        //tree.model = root.devices
        tree.selected.connect(selected)
        tree.contextMenu.connect(showMenu)
        root.deviceSelected.connect(deviceSelected)
    }

    function deviceSelected(pane, serviceId, deviceId) {
        //console.log("DEVICE SEL:", pane, serviceId, deviceId)
        if (pane === panePosition)
            tree.findItem({serviceId: serviceId, id: deviceId})
    }

    function showMenu(item) {
        //console.log('SHOW:', item.serviceId, item.id)
        //console.log("EX:", tree.currentItemExpanded)
        // serviceId is undefined for subsystem node
        var extraMenu = {}

        if (item.children && item.children.count > 0)
            extraMenu[tree.currentItemExpanded ? "CollapseAll" : "ExpandAll"] = {
                text: tree.currentItemExpanded ? "Свернуть всё" : "Раскрыть всё",
                handler: () => tree.toggleFold({serviceId: item.serviceId, id: item.id})
            }
        contextMenu.show(item, extraMenu)
    }

    function selected(item) {
        //console.log("SELECTED DEV:", item.serviceId + '->' + item.id)
        if (item && (item.id || item.serviceId))
            loader.model = Utils.findItem(treeModel.get(0).children, {id: item.id, serviceId: item.serviceId})
        else
            loader.model = item
    }
}
