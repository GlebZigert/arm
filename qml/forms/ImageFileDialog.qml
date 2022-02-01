import QtQuick.Dialogs 1.1

FileDialog {
    property bool ready
    property string file: ready ? fileUrl.toString() : ''
    title: "Выберите файл"
    folder: shortcuts.home
    nameFilters: [ "Изображения (*.jpg *.png)"]
    onAccepted: {
        ready = true
      //root.log("You chose", fileUrls)
    }
    onRejected: {
        ready = false
        //root.log("Canceled", fileUrls)
    }
    function reset() {
        ready = false
    }
}
