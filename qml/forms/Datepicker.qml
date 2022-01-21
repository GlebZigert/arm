import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4


RowLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    property alias text: textDate.text
    property alias acceptableInput: textDate.acceptableInput
    property alias enabled: textDate.enabled
    property bool upside // show popup at top

    TextField {
        id: textDate
        placeholderText: "например, 02.12.2020"
        text: Qt.formatDate(cal.selectedDate, "dd.MM.yyyy")
        Layout.fillWidth: true
        validator: RegExpValidator { regExp: /^\d\d\.\d\d\.\d\d\d\d$/ }
        color: acceptableInput ? palette.text : "red"
    }
    Button {
        id: button
        enabled: textDate.enabled
        width: height
        font.family: faFont.name
        text: faFont.fa_calendar_alt
        font.pixelSize: 18
        ToolTip.text: "Выбрать дату"
        ToolTip.visible: hovered
        onClicked: popup.open()
        implicitWidth: height
    }
    Popup {
        id: popup
        //x: -100//(parent.width - width) / 2
        //anchors.centerIn: parent
        x: button.x + button.width - width
        y: upside ? button.y - height : button.y + button.height

        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        Calendar{
           id: cal
           selectedDate: new Date()
           onClicked: {
               textDate.text = Qt.formatDate(this.selectedDate, "dd.MM.yyyy");
               popup.close()
           }
        }
    }
}
