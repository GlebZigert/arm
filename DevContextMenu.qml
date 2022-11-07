import QtQuick 2.11
import QtQml 2.11

import QtQuick.Controls 2.4

import "js/journal.js" as Journal
import "js/utils.js" as Utils

Menu {
    id: menu
      Instantiator {
          delegate: MenuItem {
              text: model.text
              onTriggered: if (Infinity !== model.deviceId) {
                  var payload = {deviceId: model.deviceId, command: model.command, argument: model.argument || 0}
                  //console.log('ContextMenu: Sending', JSON.stringify(payload), 'to #', model.serviceId)
                  root.send(model.serviceId, "ExecCommand", payload);
              } else {
                    var ids = Journal.pendingAlarms(model.serviceId)
                    if (ids.length > 0)
                        root.send(model.serviceId, "ResetAlarm", ids)
              }
          }

          model: ListModel {
              id: menuItemsModel
              ListElement{text: "placeholder"; command: 0; argument: 0; serviceId: 0; deviceId: 0}
          }
          onObjectAdded: menu.insertItem(index, object)
          onObjectRemoved: menu.removeItem(object)
      }
      function show(serviceId, deviceId) {
          var list = [],
              service = root.services[serviceId]

          if (service && ('contextMenu' in service)) {
              list = service.contextMenu(serviceId ? deviceId : 0) // 0 for subsystem root
              //console.log("ContextMenu:", JSON.stringify(list))
          }

          var pa = Journal.pendingAlarms(serviceId)
          if (Utils.useAlarms() && service && 0 === deviceId && pa.length > 0) {
              list.push({
                  text: "Сброс тревог",
                  serviceId: serviceId,
                  deviceId: Infinity,
                  command: 0
              })
          }

          if (list && list.length > 0) {
              menuItemsModel.clear()
              menuItemsModel.append(list)
              popup()
          }

      }
}
