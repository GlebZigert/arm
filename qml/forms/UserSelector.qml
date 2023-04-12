import QtQuick 2.0
//simport QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
//import QtQuick.Dialogs 1.1


Popup {
    property var callback
    property alias userTree: tree.model
    x: (parent.width - width) / 2
    width: 300
    height: 500
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    onClosed: if (callback) callback(null)

    MyTree {
        id: tree
        //model: root.users
        anchors.fill: parent
        clip: true
    }
    Component.onCompleted: {
        tree.selected.connect(function (item) {
            if (item && item.isGroup)
                return
            if (callback)
                callback(item)
            callback = null
            close()
        })
    }

    function display(userId, cb) {
        tree.findItem(userId)
        callback = cb
        open()
    }
}
