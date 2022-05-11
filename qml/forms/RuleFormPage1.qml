import QtQuick 2.0
import QtQuick.Layouts 1.5
//import QtQuick.Controls 1.4
import QtQuick.Controls 2.4


GridLayout {
    id: form
    columns: 2
    //Layout.fillWidth: true

    ///////////////////////////////////////////
    Text { text: "Название:"; Layout.alignment: Qt.AlignRight }
    TextField {
        property string name: 'name'
        enabled: changeable
        Layout.fillWidth: true
        placeholderText: "Введите название"
        validator: RegExpValidator { regExp: /\S+.*/ }
        text: !itemId ? '' : model[name] || ''
        color: acceptableInput ? palette.text : "red"
    }
    ///////////////////////////////////////////
    Text { text: "Описание:";  Layout.alignment: Qt.AlignRight }
    TextArea {
        property string name: 'description'
        enabled: changeable
        Layout.fillWidth: true
        placeholderText: "Введите описание"
        text: !itemId ? '' : model[name] || ''
        wrapMode: TextEdit.Wrap
        background: Rectangle {
                width: parent.width
                implicitHeight: 60
                //border.color: control.enabled ? "#21be2b" : "transparent"
                border.color: "#21be2b"
            }
    }
    ///////////////////////////////////////////
    Text { text: "Начало:";  Layout.alignment: Qt.AlignRight }
    Datepicker {
        property string name: 'startDate'
        enabled: changeable
        text: 0 < itemId && model[name] || ''
    }
    ///////////////////////////////////////////
    Text { text: "Окончание:";  Layout.alignment: Qt.AlignRight }
    Datepicker {
        property string name: 'endDate'
        enabled: changeable
        text: 0 < itemId && model[name] || ''
    }
    /*///////////////////////////////////////////
    Text { text: "Template:";  Layout.alignment: Qt.AlignRight }
    Text { text: model.form}*/
    ///////////////////////////////////////////
    //Text { text: "Test:";  Layout.alignment: Qt.AlignRight }
    //RadioButton { text: qsTr("Small") }
    ///////////////////////////////////////////
    Component.onCompleted: {}
}

