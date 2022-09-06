import QtQuick 2.11
import QtQuick.Controls 2.11
import QtQuick.Layouts 1.5
import QtQuick.Window 2.0

import "../../js/utils.js" as Utils

Popup {
    id: badgePreview
    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    property int dpi: 200
    property real dpiScale: 200 / Screen.pixelDensity / 25.4
    property var user
    property var badgeItem: root.badges.count > 0 ? root.badges.get(0) : null
    property var replacements: ({
        '=Фамилия': 'surename',
        '=Имя': 'name',
        '=Отчество': 'middleName',
        '=Звание': 'rank',
        '=Организация': 'organization',
        '=Должность': 'position',
    })

    //property real nocache - unherited from the top

    Column {
        spacing: 10

        Rectangle { // Badge contour
            border.color: "#999"
            border.width: 2
            radius: blindZone

            property real blindZone: 0.1 * dpi
            width: badgeItem ? 2 * blindZone + dpi * (badgeItem.landscape ? 3.375 : 2.125) : 0
            height: badgeItem ? 2 * blindZone + dpi * (badgeItem.landscape ? 2.125 : 3.375) : 0

            Item { // badge content
                id: badge
                clip: true
                anchors.fill: parent
                anchors.margins: parent.blindZone

                Item { // photo placeholder
                    property real size: badgeItem ? Math.min(parent.width, parent.height) * parseInt(badgeItem.photoSize) / 100 : 0
                    anchors.horizontalCenter: badgeItem && badgeItem.landscape ? undefined : parent.horizontalCenter
                    x: badgeItem && badgeItem.landscape ? 0 : NaN
                    width: size
                    height: size
                    Image {
                        id: placeholder
                        anchors.fill: parent
                        anchors.margins: 5
                        opacity: .5
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/images/user-solid.svg"
                        visible: image.status !== 1
                    }
                    Image {
                        id: image
                        anchors.fill: parent
                        //clip: true
                        cache: false
                        verticalAlignment: Image.AlignTop
                        fillMode: Image.PreserveAspectFit
                        source: Utils.makeURL("user", {nocache: nocache || Date.now(), id: model.id});
                    }
                }
                Item {
                    id: badgeText
                    anchors.fill: parent

                    Repeater {
                        model: badgeItem && badgeItem.labels || []
                        delegate: Label {
                            property real offs: 0 === model.align ? 0 : width  // 0: left, 1: right, 2: center
                            // calculated x & y
                            property real cx: badgeText.width * model.x - offs / (2 === model.align ? 2 : 1)
                            property real cy: badgeText.height * model.y - height / 2
                            x: cx < 0 ? 0 : cx + width <= badgeText.width ? cx : badgeText.width - width
                            y: cy < 0 ? 0 : cy + height <= badgeText.height ? cy : badgeText.height - height
                            padding: model.padding * dpiScale
                            width: model.width > 0 ? badgeText.width * model.width : 2 * padding +  paintedWidth
                            horizontalAlignment: [Text.AlignLeft, Text.AlignRight, Text.AlignHCenter][model.align]
                            property string subs: replacements[model.text] || ''
                            text: subs ? user[subs] : model.text
                            color: model.color
                            font.pixelSize: model.font * dpiScale
                            font.bold: model.style & 4
                            font.italic: model.style & 2
                            font.underline: model.style & 1
                            background: Rectangle {color: model.background}
                        }
                    }
                }
            }
        }
        Button {
            anchors.right: parent.right
            text: "Печать"
            onClicked: badge.grabToImage(function (res) { // ALT: ShaderEffectSource
                //res.saveToFile("something.png");
                printer.print(res.image, dpi)
            }) //, Qt.size(form.width * 10, form.height * 10)        }
        }
    }
}
