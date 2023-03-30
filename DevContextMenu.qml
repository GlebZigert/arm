import QtQuick 2.11
import QtQml 2.11

import QtQuick.Controls 2.4

import "js/journal.js" as Journal
import "js/utils.js" as Utils

Menu {
    id: menu
    property var extraMenu
    property bool lazyAlarmProcessing: root.settings && root.settings.lazyAlarmProcessing || false
      Instantiator {
          delegate: MenuItem {
              text: model.text
              onTriggered: {
                  if (!model.action) {
                      var payload = {deviceId: model.deviceId, command: model.command, argument: model.argument || 0}
                      //console.log('ContextMenu: Sending', JSON.stringify(payload), 'to #', model.serviceId)
                      root.send(model.serviceId, 'ExecCommand', payload);
                  } else if ('ResetAlarm' === model.action) {
                          root.send(model.serviceId, 'ResetAlarm', [model.deviceId])
                  } else if ('ResetAlarms' === model.action) {
                        let ids = Journal.pendingAlarms(model.serviceId)
                        if (ids.length > 0)
                            root.send(model.serviceId, 'ResetAlarm', ids)
                  } else if ('ShowAlarms' === model.action) {
                        let ids = Journal.pendingAlarms(model.serviceId)
                        if (ids.indexOf(model.deviceId) >= 0)
                            alarmsList.showDeviceAlarm(model.deviceId)
                  } else if (extraMenu && model.action in extraMenu) {
                      extraMenu[model.action].handler()
                  }
              }
          }

          model: ListModel {
              id: menuItemsModel
              ListElement{action: ""; text: "placeholder"; command: 0; argument: 0; serviceId: 0; deviceId: 0} // !important
          }
          onObjectAdded: menu.insertItem(index, object)
          onObjectRemoved: menu.removeItem(object)
      }

      function show(serviceId, deviceId, em) {
          extraMenu = em || {}
          var list = [],
              service = root.services[serviceId]
          //console.log(serviceId, deviceId)

          if (0 === serviceId || service && 'lost' === Utils.className(service.model.status.tcp))
              return // no menu when connection with the underlaying service is lost

          // menu from service
          if (service && ('contextMenu' in service)) {
              // don't forget override null (null means context commands are unavailable, possible no conn with server?)
              list = service.contextMenu(serviceId ? deviceId : 0) || [] // 0 for subsystem root
              //console.log("ContextMenu:", JSON.stringify(list))
          }

          var pa = Journal.pendingAlarms(serviceId)
          //console.log(JSON.stringify(pa))
          if (Utils.useAlarms() && pa.length > 0) {
              if (lazyAlarmProcessing && (0 === deviceId || 0 === serviceId)) { // TODO: check core service (id = 0)
                  list.push({
                      action: "ResetAlarms",
                      text: "Сброс тревог",
                      serviceId: serviceId,
                      deviceId: 0,
                      command: 0
                  })
              }
              if (deviceId > 0 && pa.indexOf(deviceId) >= 0) {
                  list.push({
                      action: "ShowAlarms",
                      text: "Обработка тревог",
                      serviceId: serviceId,
                      deviceId: deviceId,
                      command: 0
                  })
                  if (lazyAlarmProcessing) {
                      list.push({
                          action: "ResetAlarm",
                          text: "Сброс тревоги",
                          serviceId: serviceId,
                          deviceId: deviceId,
                          command: 0
                      })
                  }
              }
          }

          for (let act in extraMenu)
              list.unshift({
                  action: act,
                  text: extraMenu[act].text,
                  serviceId: serviceId,
                  deviceId: deviceId,
                  command: 0
              })


          if (list && list.length > 0) {
              menuItemsModel.clear()
              menuItemsModel.append(list)
              popup()
          }

      }
}
