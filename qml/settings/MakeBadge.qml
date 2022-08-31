import QtQuick 2.12
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.0

import "../../js/utils.js" as Utils
import "../forms/helpers.js" as Helpers
import "../forms" as Forms

ColumnLayout {
    id: form
    property bool asyncWait
    property int currentLabel: -1
    property var currentLabelItem: currentLabel < 0 ? null : badgeItem.labels.get(currentLabel)
    //onCurrentLabelChanged: currentLabelItem = currentLabel < 0 ? null : badgeItem.get(currentLabel)
    property var badgeItem: root.badges.get(0)

    /*ListModel {
        id: list0
        Component.onCompleted: append([{name: "Main", photoSize: 50, labels: [
            {text: 'Фамилия', x: .5, y: 0, color: 'black', background: 'yellow', font: 14, style: 0, align: 0, width: .5, padding: 5},
            {text: 'Имя', x: .5, y: .15, color: 'black', background: 'yellow', font: 14, style: 1, align: 2, width: .5, padding: 5},
            {text: 'Отчество', x: .3, y: .3, color: 'black', background: 'yellow', font: 14, style: 2, align: 0, width: .3, padding: 5},
            {text: 'Звание', x: .1, y: .45, color: 'black', background: 'yellow', font: 14, style: 3, align: 0, width: 0, padding: 5},
            {text: 'Организация', x: .5, y: .6, color: 'black', background: 'yellow', font: 14, style: 4, align: 1, width: .5, padding: 5},
            {text: 'Должность', x: 0, y: .75, color: 'black', background: 'yellow', font: 14, style: 7, align: 0, width: 0, padding: 5}
        ]}])
    }*/

    anchors.fill: parent

    Text { text: model.label; font.pixelSize: 14; font.bold: true }
    Rectangle {Layout.fillWidth: true; height: 2; color: "gray"}

    Rectangle {
        id: badge
        property real k: 3.375 / 2.125
        property real w: orientation.landscape ? parent.width : parent.width / k
        property real h: !orientation.landscape ? parent.width : parent.width / k
        border.color: "#999"
        border.width: 2
        radius: 5
        Layout.alignment: Qt.AlignHCenter // Qt.AlignCenter
        Layout.preferredWidth: w
        Layout.preferredHeight: h
        GridLayout {
            columns: orientation.landscape ? 2 : 1
            anchors.margins: 10
            anchors.fill: parent
            Rectangle {
                property real size: Math.min(badge.childrenRect.width, badge.childrenRect.height) * parseInt(photoSize.value) / 100
                Layout.alignment: Qt.AlignTop | Qt.AlignCenter
                border.color: "#900"
                border.width: 2
                implicitWidth: size
                implicitHeight: size
            }
            Rectangle {
                property real dx
                property real dy
                // x & y overflow
                property real ox
                property real oy

                function savePosition() {
                    setProperty('x', currentLabelItem.x + dx / width)
                    setProperty('y', currentLabelItem.y + dy / height)
                    ox = oy = dx = dy = 0
                }

                id: badgeText
                color: "#f0f0f0"
                Layout.fillWidth: true
                Layout.fillHeight: true

                DragHandler {
                    target: null
                    onCentroidChanged: {
                        if (0 !== centroid.pressedButtons) {
                            parent.dx = centroid.position.x - centroid.pressPosition.x - parent.ox
                            parent.dy = centroid.position.y - centroid.pressPosition.y - parent.oy
                        } else
                            badgeText.savePosition()
                    }
                }

                Repeater {
                    model: badgeItem.labels
                    delegate: Label {
                        property real dx: index !== currentLabel ? 0 : parent.dx
                        property real dy: index !== currentLabel ? 0 : parent.dy
                        property real offs: 0 === model.align ? 0 : width  // 0: left, 1: right, 2: center
                        // calculated x & y
                        property real cx: dx + badgeText.width * model.x - offs / (2 === model.align ? 2 : 1)
                        property real cy: dy + badgeText.height * model.y - height / 2
                        x: cx < 0 ? 0 : cx + width <= badgeText.width ? cx : badgeText.width - width
                        y: cy < 0 ? 0 : cy + height <= badgeText.height ? cy : badgeText.height - height
                        clip: true
                        padding: model.padding
                        width: model.width > 0 ? badgeText.width * model.width : 2 * padding +  paintedWidth
                        horizontalAlignment: [Text.AlignLeft, Text.AlignRight, Text.AlignHCenter][model.align]
                        text: model.text
                        color: model.color
                        font.pixelSize: model.font
                        font.bold: model.style & 4
                        font.italic: model.style & 2
                        font.underline: model.style & 1
                        background: Rectangle {color: model.background}
                        MouseArea {
                            anchors.fill: parent
                            onReleased: badgeText.savePosition() // minor movement, drag is not recognized automatically
                            onPressed: {
                                badgeText.ox = cx < 0 ? cx : cx + width <= badgeText.width ? 0 : cx + width - badgeText.width
                                badgeText.oy = cy < 0 ? cy : cy + height <= badgeText.height ? 0 : cy + height - badgeText.height
                                currentLabel = index
                            }
                        }
                    }
                }
            }
        }
    }

    GridLayout {
        columns: 2
        ///////////////////////////////////////////
        Text {text: "Ориентация"; Layout.alignment: Qt.AlignRight}
        ComboBox {
            id: orientation
            property bool landscape: 0 === currentIndex
            currentIndex: badgeItem.landscape ? 0 : 1
            onCurrentIndexChanged: badgeItem.landscape = 0 === currentIndex
            Layout.fillWidth: true
            model: ['Горизонтальная', 'Вертикальная']
        }

        ///////////////////////////////////////////
        Text {text: "Размер фото"; Layout.alignment: Qt.AlignRight}
        Slider {
            id: photoSize
            from: 20
            to: 100
            stepSize: 1
            value: badgeItem.photoSize
            onValueChanged: badgeItem.photoSize = value
        }

        ///////////////////////////////////////////
        Text {text: "Надпись"; Layout.alignment: Qt.AlignRight}
        RowLayout {
            ComboBox {
                id: labelContent
                model: ['Текст', 'Фамилия', 'Имя', 'Отчество', 'Звание', 'Организация', 'Должность']
                // currentIndex is updated first, text is updated after
                onCurrentTextChanged: 'Текст' !== currentText && setProperty('text',  '=' + currentText)
                currentIndex: {
                    var i, txt = getProperty('text', '')
                    return '=' !== txt[0] || (i = model.indexOf(txt.substring(1))) < 0 ? 0 : i
                }
            }

            TextField {
                enabled: 0 === labelContent.currentIndex
                //id: spacing
                Layout.fillWidth: true
                text: enabled ? getProperty('text', 'Текст') : ''
                onTextChanged: text.length && setProperty('text', text)
                Layout.preferredWidth: 70
            }
        }
        ///////////////////////////////////////////
        Text {text: "Стиль"; Layout.alignment: Qt.AlignRight}
        RowLayout {
            ComboBox {
                property int base: 12 // min font size
                property int idx: getProperty('font', -1)
                //implicitWidth: 2 * height
                Layout.fillWidth: true
                model: Array.from({length: 21}, (_, i) => i + base)
                currentIndex: idx < 0 ? idx : idx - base
                onCurrentIndexChanged: setProperty('font', currentIndex + base)
            }

            ComboBox {
                //implicitWidth: 2 * height
                Layout.fillWidth: true
                font.family: faFont.name
                popup.font.family: font.family
                model: [faFont.fa_align_left, faFont.fa_align_right, faFont.fa_align_center]
                currentIndex: getProperty('align', -1) // -1 || currentIndex
                onCurrentIndexChanged: setProperty('align', currentIndex)
            }

            // bold, italic, undeline
            Button {
                id: boldSwitch
                checkable: true
                checked: getProperty('style', 0) & 4
                implicitWidth: height
                font.family: faFont.name
                text: faFont.fa_bold
                onClicked: parent.calcStyle()
            }

            Button {
                id: italicSwitch
                checkable: true
                checked: getProperty('style', 0) & 2
                implicitWidth: height
                font.family: faFont.name
                text: faFont.fa_italic
                onClicked: parent.calcStyle()
            }

            Button {
                id: underlineSwitch
                checkable: true
                checked: getProperty('style', 0) & 1
                implicitWidth: height
                font.family: faFont.name
                text: faFont.fa_underline
                onClicked: parent.calcStyle()
            }
            function calcStyle() {
                var b = boldSwitch.checked ? 4 : 0,
                    i = italicSwitch.checked ? 2 : 0,
                    u = underlineSwitch.checked ? 1 : 0
                setProperty('style', b + i + u)
            }
        }
        ///////////////////////////////////////////
        Text {text: "Цвет"; Layout.alignment: Qt.AlignRight}
        RowLayout {
            Button {
                implicitWidth: height
                font.family: faFont.name
                text: faFont.fa_paint_roller
                onClicked: colorDialog.set('background')
            }

            Button {
                implicitWidth: height
                font.family: faFont.name
                text: faFont.fa_pen
                onClicked: colorDialog.set('color')
            }
        }
        ///////////////////////////////////////////
        Text {text: "Ширина"; Layout.alignment: Qt.AlignRight}
        RowLayout {
            Slider {
                id: labelWidth
                enabled: !autoWidth.checked
                from: 20
                to: 100
                stepSize: 1
                value: getProperty('width', 0) * 100
                onValueChanged: enabled && Qt.callLater(setProperty, 'width', value / 100) // to avoid loopback
                ToolTip {text: parent.value; visible: parent.hovered}
            }
            CheckBox {
                id: autoWidth
                text: 'Авто'
                checked:  0 === getProperty('width', 0)
                onCheckedChanged: if (checked) Qt.callLater(setProperty, 'width', 0)
            }
        }
        ///////////////////////////////////////////
        Text {text: "Отступы"; Layout.alignment: Qt.AlignRight}
        Slider {
            from: 0
            to: 20
            stepSize: 1
            value: getProperty('padding', from)
            onValueChanged: setProperty('padding', value)
            ToolTip {text: parent.value; visible: parent.hovered}
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Button {
            implicitWidth: height
            font.family: faFont.name
            text: faFont.fa_plus
            ToolTip {text: "Добавить надпись"; visible: parent.hovered}
            onClicked: {
                badgeItem.labels.append({text: 'Текст', x: .5, y: .5, color: 'black', background: 'transparent', font: 14, style: 0, align: 0, width: 0, padding: 0})
                currentLabel = badgeItem.labels.count - 1
            }
        }

        Button {
            enabled: null !== currentLabelItem
            implicitWidth: height
            font.family: faFont.name
            text: faFont.fa_trash
            ToolTip {text: "Удалить надпись"; visible: parent.hovered}
            onClicked: {
                Qt.callLater(badgeItem.labels.remove, currentLabel)
                currentLabel = -1

            }
        }
    }


    /******************************************************************************************************/
    Item {Layout.fillHeight: true} // spacer

    RowLayout {
        Layout.fillWidth: true
        Button {
            text: "Сохранить макет"
            enabled: !asyncWait
            Layout.fillWidth: true
            onClicked: saveBadge()
        }
    }
    Forms.MessageBox {id: messageBox}

    ColorDialog {
        // TODO: check modality
        id: colorDialog
        property string prop
        title: "Выберите цвет"
        modality: Qt.ApplicationModal
        onAccepted: setProperty(prop, colorDialog.color.toString())
        onRejected: setProperty(prop, 'transparent')

        function set(name) {
            prop = name
            open()
        }
    }

    function setProperty(name, value) {
        //console.log("SP:", name, value)
        if (currentLabel >= 0)
            badgeItem.labels.setProperty(currentLabel, name, value)
    }

    function getProperty(name, dflt) {
        return currentLabelItem ? currentLabelItem[name] : dflt
    }

    function saveBadge() {
        var s = JSON.stringify({'badges': Utils.toObject(root.badges)})
        asyncWait = true
        root.newTask(0, 'SaveSettings', s, done, fail)
    }


    function done() {
        asyncWait = false
    }


    function fail(txt) {
        asyncWait = false
        messageBox.error("Операция не выполнена: " + txt)
    }
}
