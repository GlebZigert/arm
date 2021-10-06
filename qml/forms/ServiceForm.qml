import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1
import "helpers.js" as Helpers

ColumnLayout {
    anchors.fill: parent
    anchors.margins: 5
    spacing: 5

    property string type0: model['type'] || '' // is there workaround?
    property var allTypes: ([
        {value: "", text: "= выберите тип ="},
        {value: "rif", text: "Риф+"},
        {value: "axxon", text: "ITV Axxon Next"},
        {value: "z5rweb", text: "Z5R Web"},
        {value: "parus", text: "Монитор ИБП"},
        //{value: "ipmon", text: "Пингатор"}
    ])

    property var extraForms: ({
        "ipmon": Qt.createComponent('IPMonForm.qml'),
        "parus": Qt.createComponent('ParusForm.qml')
    })

    property string type: allTypes[typeCombo.currentIndex].value
    // visible fields per user type
    property var fields: ({
        "":       [],
        "rif":    ['title', 'host', 'keepAlive'],
        "axxon":  ['login','password','title', 'host'],
        "z5rweb": ['title', 'keepAlive', 'url'],
        "ipmon": ['title'],
        "parus": ['title'],
    }[type].reduce(function (a, v){a[v] = true; return a}, {}))

    /*RowLayout {
        id: topButtons
        //width: parent.width
        Repeater {
            model: ['Сервис', 'Дополнительно']
            delegate: Button {
                Layout.fillWidth: true
                text: modelData
                palette {
                    button: index === stack.currentIndex ? "transparent" : undefined
                }
                onClicked: stack.currentIndex = index
            }
        }
    }*/

    GridLayout {
        id: form
        columns: 2
        //anchors.margins: 5

        ///////////////////////////////////////////
        Text { text: "Тип"; Layout.alignment: Qt.AlignRight}
        ComboBox {
            id: typeCombo
            //width: 200
            Layout.fillWidth: true
            property string name: 'type'
            property string fieldValue
            textRole: "text"
            enabled: 0 === itemId
            model: allTypes
            currentIndex: {for (var i = model.length - 1; i > 0 && model[i].value !== type0; i--);i}
            onCurrentIndexChanged: fieldValue = model[currentIndex].value

            background: Rectangle {
                // https://github.com/qt/qtquickcontrols2/blob/5.11/src/imports/controls/ComboBox.qml#L93
                implicitWidth: 140
                implicitHeight: 40

                color: !parent.currentIndex ? "#33ff0000" : parent.down ? parent.palette.mid : parent.palette.button
                border.color: parent.palette.highlight
                border.width: !parent.editable && parent.visualFocus ? 2 : 0
                visible: !parent.flat || parent.down
            }

            //color: model[currentIndex].value
        }
        ///////////////////////////////////////////
        Text { text: "Название"; visible: !!fields['title'];  Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'title'
            Layout.fillWidth: true
            enabled: !!fields[name]
            visible: enabled
            placeholderText: 'Новая подсистема'
            text: model && model[name] || ''
            validator: RegExpValidator { regExp: /\S+.*/ }
            color: acceptableInput ? palette.text : "red"
        }
        ///////////////////////////////////////////
        Text { text: "Сервер:"; visible: !!fields['host'];  Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'host'
            Layout.fillWidth: true
            enabled: !!fields[name]
            visible: enabled
            placeholderText: '192.168.0.1:2973'
            //text: model[name] || (defaults[model['Type']] ? defaults[model.Type][name] : '1')
            text: model && model[name] || ''
            validator: RegExpValidator { regExp: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{2,5}/ }
            color: acceptableInput ? palette.text : "red"
        }
        ///////////////////////////////////////////
        Text { text: "Логин:"; visible: !!fields['login']; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'login'
            Layout.fillWidth: true
            enabled: !!fields[name]
            visible: enabled
            text: model && model[name] || ''
        }
        ///////////////////////////////////////////
        Text { text: "Пароль:"; visible: !!fields['password'];  Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'password'
            Layout.fillWidth: true
            enabled: !!fields[name]
            visible: enabled
            text: model && model[name] || ''
            echoMode: TextInput.Password
        }
        ///////////////////////////////////////////
        Text { text: "Интервал:"; visible: !!fields['keepAlive'];  Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'keepAlive'
            Layout.fillWidth: true
            enabled: !!fields[name]
            visible: enabled
            text: model && model[name] || ''
            placeholderText: '5'
            validator: IntValidator{bottom: 3; top: 60}
            color: acceptableInput ? "black" : "red"
        }
        ///////////////////////////////////////////
        Text { text: "Сервер БД:"; visible: !!fields['dbHost'];  Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'dbHost'
            Layout.fillWidth: true
            enabled: !!fields[name]
            visible: enabled
            placeholderText: '192.168.0.1:3306'
            text: model && model[name] || ''
            validator: RegExpValidator { regExp: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{2,5}/ }
            color: acceptableInput ? palette.text : "red"
        }
        ///////////////////////////////////////////
        Text { text: "Имя БД:"; visible: !!fields['dbName'];  Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'dbName'
            Layout.fillWidth: true
            enabled: !!fields[name]
            visible: enabled
            text: model && model[name] || ''
        }
        ///////////////////////////////////////////
        Text { text: "Логин:"; visible: !!fields['dbLogin']; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'dbLogin'
            Layout.fillWidth: true
            enabled: !!fields[name]
            visible: enabled
            text: model && model[name] || ''
        }
        ///////////////////////////////////////////
        Text { text: "Пароль:"; visible: !!fields['dbPassword'];  Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'dbPassword'
            Layout.fillWidth: true
            enabled: !!fields[name]
            visible: enabled
            text: model && model[name] || ''
            echoMode: TextInput.Password
        }
        ///////////////////////////////////////////
        Text {text: "URL:"; visible: !!fields['url'];  Layout.alignment: Qt.AlignRight }
        TextField {
            Layout.fillWidth: true
            enabled: !!fields['url']
            visible: enabled
            readOnly: true
            selectByMouse: true
            text: itemId && model.type === 'z5rweb' ? ("http://" + serverHost + "/" + model.serviceId + "/z5rweb") : ''
        }
        ///////////////////////////////////////////
        /*Text { text: "Template:";  Layout.alignment: Qt.AlignRight }
        Text { text: model && model.form}*/
        ///////////////////////////////////////////
        //Text { text: "Test:";  Layout.alignment: Qt.AlignRight }
        //RadioButton { text: qsTr("Small") }
        ///////////////////////////////////////////
    }
    Rectangle { // separator
        visible: itemId > 0 && type in extraForms
        Layout.fillWidth: true
        height: 2
        color: "gray"
        Layout.topMargin: 10
        Layout.bottomMargin: 10
    }
    Loader {
        visible: itemId > 0
        Layout.fillWidth: true
        sourceComponent: extraForms[type]
    }

    Item { // height filler
        Layout.fillHeight: true
    }

    // buttons
    RowLayout {
        Layout.fillWidth: true
        //Layout.preferredHeight: 30
        Button {
            text: 0 === itemId ? "Создать" : "Обновить"
            Layout.fillWidth: true
            onClicked: {
                var name, value,
                    ok = true, // fields acceptable
                    payload = {id: itemId},
                    transforms = {keepAlive: parseInt}

                ok = Helpers.readForm(form, payload, transforms)
                payload.type = payload.type || model['type']
                if (ok && payload.type) {
                    console.log(JSON.stringify(payload))
                    //root.send('configuration', 'UpdateService', payload)
                    root.newTask('configuration', 'UpdateService', payload, done, function (){console.log('UpdateService failed')})
                } else
                    popup.open()
            }
            function done(msg) {
                //console.log("SVC done >>>", JSON.stringify((msg)))
                // INFO: s.serviceId is setted once, during the new service creation and s.id becomes 0
                tree.findItem({serviceId: msg.data.serviceId || msg.data.id})
            }
        }
        Button {
            text: "Удалить"
            visible: itemId != 0
            Layout.fillWidth: true
            onClicked: {
                root.send('configuration', 'DeleteService', itemId)
            }
        }
    }

    Component {
        id: emptyExtra
        Item {}
    }

    MessageDialog {
        id: popup
        title: "Ошибка"
        icon: StandardIcon.Critical
        text: "Форма заполнена не полностью, либо неправильно."
        onAccepted: console.log("OK")
    }
}
