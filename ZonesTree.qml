import QtQml 2.11
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as QC1
import QtQuick.Layouts 1.5

//import QtQuick.Controls.Material 2.11
//import "js/devices-tree.js" as Lib
//import "qml/form-fields" as Forms
import "qml/forms" as Forms
import "js/utils.js" as Utils
import "js/constants.js" as Const

Item {
    property int panePosition
    property ListModel treeModel: root.zones
    property bool adminMode: false
    property var forms: ({
        'zone': Qt.createComponent('qml/forms/ZoneForm.qml')
    })
    //anchors.fill: parent

    ListModel {
        id: userList
    }

    RowLayout {
        anchors.fill: parent
        QC1.SplitView {
            orientation: Qt.Horizontal
            Layout.fillHeight: true
            Layout.fillWidth: true

            Forms.MyTree {
                id: zonesTree
                model: treeModel
                anchors.margins: 10
                //anchors.fill: parent
                width: 200
                Layout.minimumWidth: 200

            }
            QC1.TableView {
                id: tableView
                //width: parent.width
                frameVisible: false
                model: userList

                QC1.TableViewColumn {
                    id: idColumn
                    role: "id"
                    title: "#"
                    width: 50
                }

                QC1.TableViewColumn {
                    id: timeColumn
                    role: "timeString"
                    title: "Время"
                    width: 140
                }
                QC1.TableViewColumn {
                    role: "userName"
                    title: "Посетитель"
                    //width: tableView.viewport.width - serviceColumn.width - deviceColumn.width
                }
                QC1.TableViewColumn {
                    id: deviceColumn
                    role: "deviceName"
                    title: "Точка"
                    //width: 100
                }
                QC1.TableViewColumn {
                    id: serviceColumn
                    role: "serviceName"
                    title: "Подсистема"
                    //width: 100
                }
                QC1.TableViewColumn {
                    id: textColumn
                    role: "text"
                    title: "Событие"
                }
            }
        }
        // right panel
        Rectangle {
            visible: adminMode
            color: "lightgray"
            Layout.fillHeight: true
            //Layout.minimumWidth: 300
            implicitWidth: 300
            Loader {
                id: loader
                property int itemId: model && model.id || 0
                property var model//: ({})
                //width: parent.width
                anchors.fill: parent
                sourceComponent: model ? forms[model.form] : undefined
                //sourceComponent: model ? forms[model.template] : null
                //source: 'template' in model ? 'qml/forms/'+forms[model.template]+'.qml' : ''
            }
        }
    }
    Menu {
        id: menu
          Instantiator {
              delegate: MenuItem {
                  text: model.text
                  onTriggered: {
                      var payload = {zoneId: model.zoneId, command: model.command}
                      console.log('Zone ContextMenu: Sending', JSON.stringify(payload))
                      root.send(0, 'ZoneCommand', payload);
                  }
              }

              model: ListModel {id: menuItemsModel}
              onObjectAdded: menu.insertItem(index, object)
              onObjectRemoved: menu.removeItem(object)
          }
    }
    Component.onCompleted: {
        zonesTree.selected.connect(selected)
        zonesTree.contextMenu.connect(contextMenu)
        treeModel.updated.connect(reloadForm)
    }

    function reloadForm(id) {
        if (loader.model && loader.model.id > 0)
            loader.model = loader.model
    }

    function selected(item) {
        // TODO: QT BUG? item <> node from model
        var zone
        if (item && item.id) {
            zone = Utils.findItem(treeModel.get(0).children, item.id)
            loader.model = zone
            //console.log("ZonesTree EntEv:", zone.entranceEvents)
            tableView.model = zone.entranceEvents || userList
        } else {
            loader.model = item
            tableView.model = userList
        }
        //popup.open()
    }

    function contextMenu(item, x, y) {
        if (1 === item.id)
            return
        // TODO: move settings to arm-config.js
        if ([Const.ARM_UNIT, Const.ARM_GUARD].indexOf(root.armRole) < 0)
            return

        var list = [
            {zoneId: item.id, command: Const.EC_ARMED, text: "Поставить на охрану"},
            {zoneId: item.id, command: Const.EC_DISARMED, text: "Снять с охраны"},
            {zoneId: item.id, command: Const.POINT_BLOCKED, text: "Заблокировать"},
            {zoneId: item.id, command: Const.EC_FREE_PASS, text: "Свободный проход"},
            {zoneId: item.id, command: Const.EC_NORMAL_ACCESS, text: "Штатный доступ"}
        ]
        menuItemsModel.clear()
        menuItemsModel.append(list)
        menu.popup()
    }
}
