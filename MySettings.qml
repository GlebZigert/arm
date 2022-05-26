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
        'backup-db': Qt.createComponent('qml/settings/BackupDB.qml'),
        'get-log': Qt.createComponent('qml/settings/GetLog.qml'),
    })
    anchors.fill: parent

    ListModel {
        id: treeModel
        Component.onCompleted: append({
            id: 1, label: 'Настройки', expanded: true,
            children: [
              {id: 100, label: 'Архивация БД', form: 'backup-db'},
              {id: 200, label: 'Журнал сервера', form: 'get-log'},
            ]
        })
    }

    RowLayout {
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
            implicitWidth: 400
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
        tree.selected.connect(selected)
    }

    function selected(item) {
        loader.model = item
    }
}
