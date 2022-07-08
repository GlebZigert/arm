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
    property real nocache: Date.now()
    property int fontSize: 22
    property int panePosition
    property var empty: ({id: 0, time: "", name: "", surename: "", rank: "", organization: "", position: "", deviceName: "", zoneName: ""})
    property var model: empty
    onModelChanged: nocache = Date.now()
    Column {
        width: parent.width
        Label {
            clip: true
            width: parent.width
            padding: 3
            text: model.message
            font.pixelSize: fontSize
            background: Rectangle {
               color: "#ddd"
            }
        }
        //Text {text: model.message; font.pixelSize: fontSize}
        Row {
            spacing: 15
            Image {
                id: placeholder
                width: (rect.width > maxImageSize ? maxImageSize : rect.width) * 0.9
                clip: true
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/user-solid.svg"
                visible: image.status !== 1
            }

            Image {
                id: image
                width: rect.width > maxImageSize ? maxImageSize : rect.width
                clip: true
                cache: false
                fillMode: Image.PreserveAspectFit
                //source: "qrc:/images/user-solid.svg"
                source: Utils.makeURL("user", {nocache: nocache, id: model.id});
            }

            GridLayout {
                columns: 2
                //Rectangle {Layout.columnSpan: 2; Layout.fillWidth: true; height: 2; color: "#e0e0e0"}
                ///////////////////////////////////////////
                Text { text: "Время:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
                Text { text: model.time; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
                ///////////////////////////////////////////
                Text { text: "Субъект:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
                Text { text: model.name + ' ' + model.surename; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
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

    }
    Component.onCompleted: root.userIdentified.connect(userIdentified)

    function userIdentified(event) {
        var user = Utils.findItem(root.users, event.userId)
        //console.log("pass events:", root.activePane, JSON.stringify(event), JSON.stringify(user))
        if (user) {
            model = {
                id: user.id,
                name: user.name || '',
                surename: user.surename || '',
                rank: user.rank || '',
                organization: user.organization || '',
                position: user.position || '',
                deviceName: event.deviceName || '',
                zoneName: event.zoneName || '',
                message: event.text,
                time: event.timeString
            }
        } else
            model = empty
    }
}
