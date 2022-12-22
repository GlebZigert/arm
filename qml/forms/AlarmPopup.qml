import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import "helpers.js" as Helpers
import "../../js/journal.js" as Journal

Popup {
    id: popup
    property var event: ({})
    property int alarmsCount
    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay
    //parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    //implicitWidth: 350

    onVisibleChanged: if (visible) reason.focus = true

    MessageBox {id: messageBox}

    GridLayout {
        id: eventForm
        anchors.margins: 5
        anchors.fill: parent
        columns: 2

        ///////////////////////////////////////////
        Text { text: "Событие"; Layout.alignment: Qt.AlignRight }
        TextField {
            Layout.fillWidth: true
            enabled: false
            text: event && event.text || ''
        }
        ///////////////////////////////////////////
        Text { text: "Время"; Layout.alignment: Qt.AlignRight }
        TextField {
            Layout.fillWidth: true
            enabled: false
            text: event && event.timeString || ''
        }
        ///////////////////////////////////////////
        Text { text: "Система"; Layout.alignment: Qt.AlignRight }
        TextField {
            Layout.fillWidth: true
            enabled: false
            text: event && event.serviceName || ''
        }

        ///////////////////////////////////////////
        Text { text: "Устройство"; Layout.alignment: Qt.AlignRight }
        TextField {
            Layout.fillWidth: true
            enabled: false
            text: event && event.deviceName || ''
        }
        ///////////////////////////////////////////
        Text { text: "Активных тревог"; Layout.alignment: Qt.AlignRight }
        TextField {
            Layout.fillWidth: true
            enabled: false
            text: alarmsCount
        }
        ///////////////////////////////////////////
        Text { text: "Причины"; Layout.alignment: Qt.AlignRight }
        TextField {
            id: reason
            property string name: 'reason'
            Layout.fillWidth: true
            text: event && event.reason || ''
        }
        ///////////////////////////////////////////
        Text { text: "Принятые меры"; Layout.alignment: Qt.AlignRight }
        TextField {
            id: reaction
            property string name: 'reaction'
            Layout.fillWidth: true
            text: event && event.reaction || ''
        }

        ///////////////////////////////////////////
        /*Text { text: ""; Layout.alignment: Qt.AlignRight }
        CheckBox {
            id: reset
            text: "Сбросить тревоги";
            enabled: 0 === alarmsCount
                     || 1 === alarmsCount
                     && "" === event.reason.trim() && reason.text.trim()
                     && "" === event.reaction.trim() && reaction.text.trim()
        }*/

        RowLayout {
            Layout.columnSpan: 2
            Button {
                id: saveEvent
                text: "Записать"
                Layout.fillWidth: true
                onClicked: describeEvent()
            }
            Button {
                text: "Сброс тревог"
                Layout.fillWidth: true
                //enabled: alarmsCount == 0
                onClicked: checkReset()
            }
            Button {
                text: "Отмена"
                Layout.fillWidth: true
                onClicked: popup.close()
            }
        }
        Keys.onReturnPressed: {
            saveEvent.clicked()
            event.accepted = true
        }
    }

    function describeEvent() {
        var payload = {id: event.id},
            ok = Helpers.readForm(eventForm, payload)
        if (ok) {
            //console.log("Desc event:", JSON.stringify(payload))
            root.newTask(0, "DescribeEvent", payload, descDone, fail)
        }
    }

    function descDone() {
        alarmsCount = Journal.activeAlarms(event)
        if (alarmsCount > 0)
            popup.close()
    }

    function checkReset() {
        alarmsCount = Journal.activeAlarms(event)
        if (alarmsCount === 0)
            reset()
        else if (alarmsCount > 0)
            messageBox.ask("Не для всех событий указаны причины\nи принятые меры. Продолжить?", reset)
    }

    function reset() {
        console.log("Reset alarm:", event.deviceId)
        root.newTask(event.serviceId, "ResetAlarm", [event.deviceId], resetDone, fail)
    }

    function resetDone(msg) {
        console.log("AlarmPopup: reset done", msg.data)
        if (true === msg.data)
            popup.close()
    }

    function fail() {
        console.log("AlarmPopup task failed")
    }

}
