import QtQuick 2.11
import QtQuick.Dialogs 1.1

MessageDialog {
    property var yesCb
    property var noCb
    onAccepted: {yesCb && yesCb(); reset()}
    onRejected: {noCb && noCb(); reset()}
    //onYes: accepted()
    //onNo: rejected()

    function reset() {
        yesCb = noCb = null
    }

    function show(ttl, txt) {
        title = ttl
        text = txt
        standardButtons = StandardButton.Ok
        open()
    }
    function error(txt, yesCallback) {
        icon = StandardIcon.Critical
        yesCb = yesCallback
        show('Ошибка', txt)
    }
    function warning(txt, yesCallback) {
        icon = StandardIcon.Warning
        yesCb = yesCallback
        show('Внимание', txt)
    }
    function information(txt, yesCallback) {
        icon = StandardIcon.Information
        yesCb = yesCallback
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
