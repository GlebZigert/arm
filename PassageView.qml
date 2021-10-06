// https://stackoverflow.com/questions/45168702/canonical-way-to-make-custom-tableview-from-listview-in-qt-quick
// printing: https://evileg.com/en/forum/topic/745/
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as QC1
import QtQuick.Layouts 1.5
import "qml/forms" as Forms
import "js/utils.js" as Utils

Rectangle {
    id: rect
    //color: "yellow"
    Layout.margins: 10
    property int maxImageSize: 250
    property int maxSize: 200
    property int nocache: Date.now()
    property int fontSize: 28
    property int panePosition
    property var empty: ({id: 0, name: "", surename: "", deviceName: "", zoneName: ""})
    property var model: empty
    onModelChanged: nocache = Date.now()

    Row {
        spacing: 15
        Image {
            id: placeholder
            height: rect.height > maxImageSize ? maxImageSize : rect.height
            clip: true
            cache: false
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/user-solid.svg"
            visible: image.status !== 1
        }

        Image {
            id: image
            height: rect.height > maxImageSize ? maxImageSize : rect.height
            clip: true
            cache: false
            fillMode: Image.PreserveAspectFit
            //source: "qrc:/images/user-solid.svg"
            source: "http://" + serverHost + "/0/user?nocache=" + nocache + "&id=" + model.id;
        }

        GridLayout {
            columns: 2
            ///////////////////////////////////////////
            Text { text: "Субъект:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.name + ' ' + model.surename; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
            Rectangle {Layout.columnSpan: 2; Layout.fillWidth: true; height: 2; color: "#e0e0e0"}
            ///////////////////////////////////////////
            Text { text: "Звание:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.rank; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
            ///////////////////////////////////////////
            Text { text: "Организация:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.organization; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
            ///////////////////////////////////////////
            Text { text: "Должность:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.position; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
            ///////////////////////////////////////////
            Text { text: "Проход в:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.zoneName; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
            ///////////////////////////////////////////
            Text { text: "Через:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.deviceName; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
        }
    }

    Component.onCompleted: root.newPassage.connect(newPassage)

    function newPassage(event) {
        var user = Utils.findItem(root.users, event.userId)
        console.log("pass events:", root.activePane, JSON.stringify(event), JSON.stringify(user))
        if (user) {
            model = {
                id: user.id,
                name: user.name || '',
                surename: user.surename || '',
                rank: user.rank || '',
                organization: user.organization || '',
                position: user.position || '',
                deviceName: event.deviceName || '',
                zoneName: event.zoneName || ''
            }
        } else
            model = empty


    }
}
