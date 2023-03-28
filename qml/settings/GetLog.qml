import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.2

import "../forms/helpers.js" as Helpers
import "../forms" as Forms
import "../../js/upload.js" as Upload
import "../../js/utils.js" as Utils

ColumnLayout {
    id: form
    property bool asyncWait

    anchors.fill: parent

    Text { text: model.label; font.pixelSize: 14; font.bold: true }
    Rectangle {Layout.fillWidth: true; height: 2; color: "gray"}
    Text {
        wrapMode: Text.WordWrap
        //Layout.fillHeight: true
        Layout.fillWidth: true
        text: "Получение архива системного журнала сервера Риф-7 за последние 24 часа для диагностики неполадок разработчиком."
    }

    Item {Layout.fillHeight: true}

    Button {
        text: "Загрузить"
        enabled: !asyncWait
        Layout.fillWidth: true
        //onClicked: getLog()
        onClicked: saveDialog.open()
    }

    Forms.MessageBox {id: messageBox}

    FileDialog {
            id: saveDialog
            selectExisting: false
            nameFilters: ["ZIP files (*.zip)", "All files (*)"]
            onAccepted: getLog()
        }

    function getLog() {
        var url = Utils.makeURL('get-log')
        Upload.readFile(url, function (arrayBuffer) {
            if (arrayBuffer)
                saveLog(arrayBuffer)
            else {
                asyncWait = false
                messageBox.error("Не удаётся получить файл журнала с сервера")
            }
        })

    }

    function saveLog(data) {
        var fn = saveDialog.fileUrl,
            xhr = new XMLHttpRequest()
        xhr.open("PUT", fn, false)
        xhr.send(data)
        asyncWait = false
    }
}
