import QtQuick 2.11
import QtQml 2.11

import QtQuick.Controls 2.4


Menu {
    id: menu
      Instantiator {
          delegate: MenuItem {
              text: model.text
              onTriggered: {
                  var payload = {deviceId: model.deviceId, command: model.command, argument: model.argument || 0}
                  root.log('ContextMenu: Sending', JSON.stringify(payload), 'to #', model.serviceId)
                  root.send(model.serviceId, "ExecCommand", payload);
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
          var list,
              service = root.services[serviceId || deviceId]
          if (service && ('contextMenu' in service)) {
              list = service.contextMenu(serviceId ? deviceId : 0) // 0 for subsystem root
              //root.log("ContextMenu:", JSON.stringify(list))
              if (list.length > 0) {
                  menuItemsModel.clear()
                  menuItemsModel.append(list)
                  popup()
              }
          }
      }
}
