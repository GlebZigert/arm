import QtQuick 2.11
import QtQuick.Dialogs 1.1

MessageDialog {
    property var yesCb
    property var noCb
    onAccepted: if (yesCb) yesCb()
    onRejected: if (noCb) noCb()
    onYes: onAccepted()
    onNo: onRejected()

    function show(ttl, txt) {
        title = ttl
        text = txt
        yesCb = noCb = null
        standardButtons = StandardButton.Ok
        open()
    }
    function error(txt) {
        icon = StandardIcon.Critical
        show('Ошибка', txt)
    }
    function warning(txt) {
        icon = StandardIcon.Warning
        show('Внимание', txt)
    }
    function information(text) {
        icon = StandardIcon.Information
        show('Информация', txt)
    }

    function ask(txt, yesCallback, noCallback) {
        title = "Внимание"
        text = txt
        yesCb = yesCallback
        noCb = noCallback
        icon = StandardIcon.Question
        standardButtons = StandardButton.Yes | StandardButton.No
        open()
    }
}
