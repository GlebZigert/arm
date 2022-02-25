import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
//import QtQuick.Controls.Material 2.11
//import "js/devices-tree.js" as Lib
//import "qml/form-fields" as Forms
import "qml/forms" as Forms
import "js/utils.js" as Utils
import "js/algorithms.js" as Algorithms

RowLayout {
    property ListModel treeModel: root.algorithms
    property bool adminMode: false
    property var forms: ({
        'algo': Qt.createComponent('qml/forms/AlgoForm.qml')
    })

    anchors.fill: parent
    Forms.MyTree {
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
        Layout.minimumWidth: 400
        Loader {
            id: loader
            property int itemId: model && model.id || 0
            property var model//: ({})
            property ListModel newAlgo: ListModel{}
            anchors.margins: 5
            anchors.fill: parent
            sourceComponent: model ? forms[model.form] : undefined
        }
    }

    Component.onCompleted: {
        tree.selected.connect(selected)
        tree.contextMenu.connect(contextMenu)
        treeModel.updated.connect(reloadForm)
    }

    function reloadForm(id) {
        if (loader.model && loader.model.id > 0)
            loader.model = loader.model
    }

    function selected(item) {
        var rootItem = treeModel.get(0)
        // TODO: QT BUG? item <> node from model
        if (item && item.id)
            loader.model = Utils.findItem(rootItem.children, item.id)
        else
            loader.model = item
        //popup.open()
    }

    function contextMenu(item, x, y) {
        console.log(x, y)
    }
}
