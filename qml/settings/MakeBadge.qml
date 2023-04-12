import QtQuick 2.12
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.0

import "../../js/utils.js" as Utils
import "../forms/helpers.js" as Helpers
import "../forms" as Forms

ColumnLayout {
    id: form
    anchors.fill: parent

    property bool asyncWait
    property int currentLabel: -1
    property var currentLabelItem: null === badgeItem || currentLabel < 0 ? null : badgeItem.labels.get(currentLabel)
    property var badgeItem: root.badges.count > 0 ? root.badges.get(0) : null

    Text { text: model.label; font.pixelSize: 14; font.bold: true }
    Rectangle {Layout.fillWidth: true; height: 2; color: "gray"}

    Rectangle { // Badge contour
        property real k: 3.375 / 2.125 // card's sides proportion
        property real w: orientation.landscape ? parent.width : parent.width / k
        property real h: !orientation.landscape ? parent.width : parent.width / k
        border.color: "#999"
        border.width: 2
        radius: 5
        Layout.alignment: Qt.AlignHCenter // Qt.AlignCenter
        Layout.preferredWidth: w
        Layout.preferredHeight: h
        Item { // inner container (for spacing)
            clip: true
            anchors.fill: parent
            anchors.margins: 10
            Rectangle { // photo placeholder
                property real size: Math.min(parent.width, parent.height) * parseInt(photoSize.value) / 100
                anchors.horizontalCenter: orientation.landscape ? undefined : parent.horizontalCenter
                x: orientation.landscape ? 0 : NaN
                color: "#f0f0f0"
                width: size
                height: size
                Image {
                    id: placeholder
                    anchors.fill: parent
                    anchors.margins: 5
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/user-solid.svg"
                    visible: true //image.status !== 1
                }

            }
            Item {
                id: badgeText
                anchors.fill: parent

                property real dx
                property real dy
                // x & y overflow
                property real ox
                property real oy
                property bool taken // currently controlled with mouse

                function savePosition() {
                    if (currentLabelItem) {
                        setProperty('x', Math.round(1e4 * (currentLabelItem.x + (dx - ox) / width)) / 1e4)
                        setProperty('y', Math.round(1e4 * (currentLabelItem.y + (dy - oy) / height)) / 1e4)
                    }
                    taken = false
                    ox = oy = dx = dy = 0
                }

                DragHandler {
                    target: null
                    onCentroidChanged: if (parent.taken) {
                        if (0 !== centroid.pressedButtons) {
                            parent.dx = centroid.position.x - centroid.pressPosition.x
                            parent.dy = centroid.position.y - centroid.pressPosition.y
                        } else
                            badgeText.savePosition()
                    }
                }

                Repeater {
                    model: badgeItem && badgeItem.labels || []
                    delegate: Label {
                        property real dx: index !== currentLabel ? 0 : parent.dx
                        property real dy: index !== currentLabel ? 0 : parent.dy
                        property real offs: 0 === model.align ? 0 : width  // 0: left, 1: right, 2: center
                        // calculated X & Y
                        property real cx: dx + badgeText.width * model.x - offs / (2 === model.align ? 2 : 1)
                        property real cy: dy + badgeText.height * model.y - height / 2
                        // overflow X & Y
                        property real ox : cx < 0 ? cx : cx + width <= badgeText.width ? 0 : cx + width - badgeText.width
                        property real oy : cy < 0 ? cy : cy + height <= badgeText.height ? 0 : cy + height - badgeText.height
                        onOxChanged: badgeText.ox = ox
                        onOyChanged: badgeText.oy = oy
                        x: cx - ox
                        y: cy - oy
                        width: model.width > 0 ? badgeText.width * model.width : 2 * padding +  paintedWidth
                        padding: model.padding
                        horizontalAlignment: [Text.AlignLeft, Text.AlignRight, Text.AlignHCenter][model.align]
                        text: model.text
                        color: model.color
                        font.pixelSize: model.font
                        font.bold: model.style & 4
                        font.italic: model.style & 2
                        font.underline: model.style & 1
                        background: Rectangle {color: model.background}
                        ToolTip {
                            visible: badgeText.taken && index === currentLabel//ma.pressed || ma.containsPress
                            text: Math.round(1e4 * (model.x + (dx - ox) / badgeText.width)) / 1e4
                                  + ' ' + Math.round(1e4 * (model.y + (dy - oy) / badgeText.height)) / 1e4
                        }
                        MouseArea {
                            anchors.fill: parent
                            onReleased: badgeText.savePosition() // minor movement, drag is not recognized automatically
                            onPressed: {
                                badgeText.taken = true
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
            currentIndex: badgeItem && badgeItem.landscape ? 0 : 1
            onCurrentIndexChanged: if (badgeItem) badgeItem.landscape = 0 === currentIndex
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
            value: badgeItem && badgeItem.photoSize || from
            onValueChanged: if (badgeItem) badgeItem.photoSize = value
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
                maximumLength: 32
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
                hoverEnabled: true
                ToolTip.visible: hovered
                ToolTip.text: "Размер шрифта"
            }

            ComboBox {
                //implicitWidth: 2 * height
                Layout.fillWidth: true
                font.family: faFont.name
                popup.font.family: font.family
                model: [faFont.fa_align_left, faFont.fa_align_right, faFont.fa_align_center]
                currentIndex: getProperty('align', -1) // -1 || currentIndex
                onCurrentIndexChanged: setProperty('align', currentIndex)
                hoverEnabled: true
                ToolTip.visible: hovered
                ToolTip.text: "Выравнивание"
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
                hoverEnabled: true
                ToolTip.visible: hovered
                ToolTip.text: "Жирный"
            }

            Button {
                id: italicSwitch
                checkable: true
                checked: getProperty('style', 0) & 2
                implicitWidth: height
                font.family: faFont.name
                text: faFont.fa_italic
                onClicked: parent.calcStyle()
                hoverEnabled: true
                ToolTip.visible: hovered
                ToolTip.text: "Курсив"
            }

            Button {
                id: underlineSwitch
                checkable: true
                checked: getProperty('style', 0) & 1
                implicitWidth: height
                font.family: faFont.name
                text: faFont.fa_underline
                onClicked: parent.calcStyle()
                hoverEnabled: true
                ToolTip.visible: hovered
                ToolTip.text: "Подчёркнутый"
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
                hoverEnabled: true
                ToolTip.visible: hovered
                ToolTip.text: "Заливка"
            }

            Button {
                implicitWidth: height
                font.family: faFont.name
                text: faFont.fa_pen
                onClicked: colorDialog.set('color')
                hoverEnabled: true
                ToolTip.visible: hovered
                ToolTip.text: "Текст"
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
                hoverEnabled: true
                ToolTip.visible: hovered
                ToolTip.text: value + '%'
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
            hoverEnabled: true
            ToolTip.visible: hovered
            ToolTip.text: value
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Button {
            implicitWidth: height
            font.family: faFont.name
            text: faFont.fa_plus
            hoverEnabled: true
            ToolTip.visible: hovered
            ToolTip.text: "Добавить надпись"
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
            hoverEnabled: true
            ToolTip.visible: hovered
            ToolTip.text: "Удалить надпись"
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
        if (currentLabelItem)
            badgeItem.labels.setProperty(currentLabel, name, value)
    }

    function getProperty(name, dflt) {
        return currentLabelItem ? currentLabelItem[name] : dflt
    }

    function saveBadge() {
        var o = Utils.toObject(root.badges),
            s = {name: 'badges', value: JSON.stringify(o)}
        //console.log("BADGE>", JSON.stringify(o))
        asyncWait = true
        root.newTask(0, 'UpdateSettings', s, done, fail)
    }


    function done() {
        asyncWait = false
    }


    function fail(txt) {
        asyncWait = false
        messageBox.error("Операция не выполнена: " + txt)
    }
}
