import QtQuick 2.0
//simport QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
//import QtQuick.Dialogs 1.1
import "../../js/utils.js" as Utils

Popup {
    property alias devicesTree: devTree.model
    property var callback
    x: (parent.width - width) / 2
    width: 300
    height: 500
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    onClosed: if (callback) callback(null)

    MyTree {
        id: devTree
        //model: root.devices
        anchors.fill: parent
        clip: true
        getTNID: Utils.getDeviceTNID
    }
    Component.onCompleted: {
        devTree.selected.connect(function (item) {
            if (callback)
                callback(item)
            callback = null
            close()
        })
    }

    function display(serviceId, deviceId, cb) {
        devTree.findItem({id: deviceId, serviceId: serviceId})
        callback = cb
        open()
    }
}


