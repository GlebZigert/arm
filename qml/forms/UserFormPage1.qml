import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4

//import io.qt.examples.imageMaker 1.0


Flickable {
    clip: true
    contentHeight: form.height
    ScrollBar.vertical: ScrollBar {policy: ScrollBar.AsNeeded} // .AlwaysOn
    property bool changeable: adminMode && (armConfig[activeComponent] & 1)

    property var modelId: model.id
    onModelIdChanged: {
        fileDialog.reset()
        //previewBadge()
    }

    property var roles: ([
        {id: 0, text: "Без АРМ"},
        {id: 1, text: "Администратор"},
        {id: 2, text: "Дежурный по ВЧ"},
        {id: 3, text: "Дежурный по КПП и КТП"},
        {id: 4, text: "Начальник Караула"},
        {id: 5, text: "Оператор ТСО"},
        {id: 6, text: "Защита ГосТайны"},
        {id: 7, text: "Бюро Пропусков"}])

    property var allTypes: ([
        {id: 0, text: "= выберите тип ="},
        {id: 1, text: "Группа"},
        {id: 2, text: "Сотрудник"},
        {id: 3, text: "Посетитель"},
        {id: 4, text: "Транспортное средство"}])


    property int type: allTypes[typeCombo.currentIndex].id

    property var fields: ({
        0: [],
        1: ['name', 'add-children'],
        2: ['photo', 'name', 'surename', 'middleName', 'rank', 'organization', 'position', 'role', 'login', 'password', 'cards'],
        3: ['photo', 'name', 'surename', 'middleName', 'organization', 'cards'],
        4: ['photo', 'name', 'surename', 'middleName', 'rank', 'organization', 'cards'],
    }[type].reduce(function (a, v){a[v] = true; return a}, {}))
    // substitutions for field names for specific types
    property var subs: ({
        0: {},
        1: {name: 'Название'},
        2: {},
        3: {},
        4: {name: 'Гос. номер', surename: 'Тип ТС', middleName: 'Марка', rank: 'Цвет'}
    }[type])

    GridLayout {
        id: form
        columns: 2
        width: parent.width
    //    Layout.preferredWidth: parent.width

        property alias cardsComboBox: cardsCombo
        // visible fields per user type

        Image {
            id: image
            //visible: !!fields['photo'];
            property int lph: sourceSize.height / (sourceSize.width || 1) * width
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.preferredHeight: lph > width ? width : lph
            clip: true
            cache: false
            fillMode: Image.PreserveAspectFit
            source: !fields['photo'] ? '' : "http://" + serverHost + "/0/user?nocache=" + nocache + "&id=" + model.id;
        }

        ///////////////////////////////////////////
        Text { text: "Тип"; visible: typeCombo.visible; Layout.alignment: Qt.AlignRight}
        property int type0: model['type'] || 0 // is there workaround?
        ComboBox {
            id: typeCombo
            Layout.fillWidth: true
            property string name: 'type'
            textRole: "text"
            enabled: newItem && changeable
            //visible: enabled
            model: ListModel{} // allTypes
            currentIndex: {for (var i = allTypes.length - 1; i > 0 && allTypes[i].id !== form.type0; i--); newItem ? 0 : i}
            background: Rectangle {
                // https://github.com/qt/qtquickcontrols2/blob/5.11/src/imports/controls/ComboBox.qml#L93
                implicitWidth: 140
                implicitHeight: 40

                color: !parent.currentIndex ? "#33ff0000" : parent.down ? parent.palette.mid : parent.palette.button
                border.color: parent.palette.highlight
                border.width: !parent.editable && parent.visualFocus ? 2 : 0
                visible: !parent.flat || parent.down
            }
            Component.onCompleted: model.append(allTypes)

            //color: model[currentIndex].value
        }
        ///////////////////////////////////////////
        Text { text: "Фотография"; visible: !!fields['photo']; Layout.alignment: Qt.AlignRight}
        Button {
            enabled: changeable
            Layout.fillWidth: true
            visible: !!fields['photo'];
            text: !fileDialog.file ? "Выбрать файл" : fileDialog.file.split(/[/\/]/).pop()
            onClicked: fileDialog.open()

        }
        ///////////////////////////////////////////
        Text { text: subs['name'] || "Имя"; visible: !!fields['name']; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'name'
            property bool showIt: !!fields[name]
            enabled: showIt && changeable
            visible: showIt
            Layout.fillWidth: true
            text: newItem ? '' : model[name] || ''
            validator: RegExpValidator { regExp: /\S+.*/ }
            color: acceptableInput ? palette.text : "red"
        }
        ///////////////////////////////////////////
        Text { text: subs['surename'] || 'Фамилия'; visible: !!fields['surename']; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'surename'
            property bool showIt: !!fields[name]
            enabled: showIt && changeable
            visible: showIt
            Layout.fillWidth: true
            //placeholderText: 'Фамилия'
            text: newItem ? '' : model[name] || ''
            validator: RegExpValidator { regExp: /\S+.*/ }
            color: acceptableInput ? palette.text : "red"
        }
        ///////////////////////////////////////////
        Text { text: subs['middleName'] || 'Отчество'; visible: !!fields['middleName']; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'middleName'
            property bool showIt: !!fields[name]
            enabled: showIt && changeable
            visible: showIt
            Layout.fillWidth: true
            text: newItem ? '' : model[name] || ''
            //validator: RegExpValidator { regExp: /\S+.*/ }
            //color: acceptableInput ? palette.text : "red"
        }
        ///////////////////////////////////////////
        Text { text: subs['rank'] || 'Звание'; visible: !!fields['rank']; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'rank'
            property bool showIt: !!fields[name]
            Layout.fillWidth: true
            enabled: showIt && changeable
            visible: showIt
            text: newItem ? '' : model[name] || ''
            //validator: RegExpValidator { regExp: /\S+.*/ }
            //color: acceptableInput ? palette.text : "red"
        }
        ///////////////////////////////////////////
        Text { text: subs['organization'] || 'Организация'; visible: !!fields['organization']; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'organization'
            property bool showIt: !!fields[name]
            Layout.fillWidth: true
            enabled: showIt && changeable
            visible: showIt
            text: newItem ? '' : model[name] || ''
            //validator: RegExpValidator { regExp: /\S+.*/ }
            //color: acceptableInput ? palette.text : "red"
        }
        ///////////////////////////////////////////
        Text { text: subs['position'] || 'Должность'; visible: !!fields['position']; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'position'
            property bool showIt: !!fields[name]
            Layout.fillWidth: true
            enabled: showIt && changeable
            visible: showIt
            text: newItem ? '' : model[name] || ''
            //validator: RegExpValidator { regExp: /\S+.*/ }
            //color: acceptableInput ? palette.text : "red"
        }
        ///////////////////////////////////////////
        Text { text: "Тип АРМ"; visible: !!fields['role']; Layout.alignment: Qt.AlignRight}
        property int role0: model['role'] || 0 // is there workaround?
        ComboBox {
            id: roleCombo
            Layout.fillWidth: true
            property string name: 'role'
            property bool showIt: !!fields[name]
            textRole: "text"
            visible: showIt
            enabled: showIt && newItem && changeable
            model: ListModel{} // all roles
            currentIndex: {for (var i = roles.length - 1; i > 0 && roles[i].id !== form.role0; i--); newItem ? 0 : i}
            Component.onCompleted: model.append(roles)

            //color: model[currentIndex].value
        }
        ///////////////////////////////////////////
        Text { text: "Логин"; visible: !!fields['login'] && roleCombo.currentIndex > 0; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'login'
            property bool showIt: !!fields[name] && roleCombo.currentIndex > 0
            visible: showIt
            enabled: showIt && changeable
            Layout.fillWidth: true
            placeholderText: 'Логин'
            text: newItem ? '' : model[name] || ''
            validator: RegExpValidator { regExp: /\S{2,20}/ }
            color: acceptableInput ? palette.text : "red"
        }
        ///////////////////////////////////////////
        Text { text: "Пароль"; visible: !!fields['password'] && roleCombo.currentIndex > 0; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'password'
            property bool showIt: !!fields[name] && roleCombo.currentIndex > 0
            visible: showIt
            enabled: showIt && changeable
            Layout.fillWidth: true
            placeholderText: 'Пароль'
            text: newItem ? '' : model[name] || ''
            echoMode: TextInput.Password
            validator: RegExpValidator { regExp: newItem ? /.{4,20}/ : /.{0,0}||.{4,20}/ }
            color: acceptableInput ? palette.text : "red"
        }
        Text { text: "Ключи"; visible: !!fields['cards'] && changeable; Layout.alignment: Qt.AlignRight }
        RowLayout {
            visible: !!fields['cards'] && changeable
            Layout.fillWidth: true
            spacing: 10
            property ListModel cardsList: model.cards
            ComboBox {
                id: cardsCombo
                property string name: 'cards'
                property var fieldValue
                property int lastIndex: -1
                property bool showIt: !!fields[name]
                enabled: showIt
                visible: showIt
                Layout.fillWidth: true
                textRole: "card"
                //text: newItem ? '' : model[name] || ''
                //validator: RegExpValidator { regExp: /[0-9a-f]{6,12}/i }
                validator: RegExpValidator { regExp: /((\d{1,3},\d{1,5}|\d{1,6}) )?\d{1,3},\d{1,5}/i }
                model: parent.cardsList
                onCurrentIndexChanged: {
                    if (currentIndex >= 0)
                        lastIndex = currentIndex

                    if (model && model.count > 0 && currentIndex === model.count - 1) {
                        editable = true
                        Qt.callLater(function (){editText = ''})
                    } else
                        editable = false
                    if (model && model.count === 0)
                        Qt.callLater(function (){if (lastIndex < model.count) currentIndex = lastIndex})
                }
                onModelChanged: {
                    editable = false
                    currentIndex = model && model.count > 1 ? 0 : -1
                    calcValue()
                }

                function calcValue() {
                    var i, value = []
                    if (model)
                        for (i = 0; i < model.count - 1; i++)
                            value.push(model.get(i).card)
                    cardsCombo.fieldValue = value
                    //console.log(cardsCombo.fieldValue)
                }

                function apply() {
                    if (acceptableInput) {
                        var txt = editText
                        editable = false
                        //model.insert(0, {card: txt}) // BUG: leaves blank item in combobox
                        //currentIndex = model.
                        model.append(model.get(currentIndex))
                        model.setProperty(currentIndex, 'card', txt)
                        calcValue()
                    }
                }

                function remove() {
                    model.remove(currentIndex)
                    if (currentIndex === model.count - 1)
                        currentIndex--
                    calcValue()
                }
            }
            Button {
                visible: cardsCombo.editable
                implicitWidth: height
                font.family: faFont.name
                font.pixelSize: 18
                text: faFont.fa_check
                ToolTip.text: "Сохранить"
                ToolTip.visible: hovered
                onClicked: cardsCombo.apply()

            }
            Button {
                visible: cardsCombo.currentIndex >= 0 && cardsCombo.currentIndex !== cardsCombo.model.count - 1
                implicitWidth: height
                font.family: faFont.name
                font.pixelSize: 18
                text: faFont.fa_trash
                ToolTip.text: "Удалить ключ"
                ToolTip.visible: hovered
                onClicked: cardsCombo.remove()
            }
            /*Button {
                visible: cardsCombo.currentIndex >= 0 && cardsCombo.currentIndex !== cardsCombo.model.count - 1
                implicitWidth: height
                font.family: faFont.name
                font.pixelSize: 18
                text: faFont.fa_address_card
                ToolTip.text: "Печатать"
                ToolTip.visible: hovered
                onClicked: imgmaker.printImage()
            }*/
        }

        /////////////////////////////////////////////
        /*property bool showBadge: !newItem && !!fields['photo'] && Image.Ready === image.status
        Text { text: "Бейдж"; visible: form.showBadge; Layout.alignment: Qt.AlignRight }
        ImageMaker {
            visible: form.showBadge
            Layout.alignment: Qt.AlignRight
            id: imgmaker
            width: 290
            height: 180
        }*/

        ///////////////////////////////////////////
        Text { text: "Добавить"; visible: !!fields['add-children'] && itemId; Layout.alignment: Qt.AlignRight }
        Button {
            property bool showIt: !!fields['add-children'] && itemId
            enabled: showIt && changeable
            visible: showIt
            text: "+ дочерний элемент"
            onClicked: {
                loader.makeNewUser(model.id)
            }
        }
        ///////////////////////////////////////////
        /*Text { text: "Template:";  Layout.alignment: Qt.AlignRight }
        Text { text: model.form}
        ///////////////////////////////////////////
        Text { text: "ID:";  Layout.alignment: Qt.AlignRight }
        Text { text: itemId}*/
    }
    /*function previewBadge() {
        imgmaker.test()
        var photo="http://" + serverHost + "/0/user?nocache=" + nocache + "&id=" + model.id
        imgmaker.take_photo_from_url_and_set_name_and_surename(photo, model['name'], model['surename']);
    }*/

}
