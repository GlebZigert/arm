import QtQuick 2.11
import QtQuick.Controls 2.11
import QtQuick.Layouts 1.5

import "../../js/utils.js" as Utils

Popup {
    id: badgePreview
    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    property int dpi: 200
    property int fontSize: 22
    property int maxImageSize: 250
    //property real nocache - unherited from the top

    Column {
        spacing: 10
        Rectangle {
            id: badge
            width: childrenRect.width
            height: childrenRect.height
            border.width: 1
            border.color: "gray"
            Row {
                width: 3.375 * dpi
                height: 2.125 * dpi
                spacing: 15
                Image {
                    id: placeholder
                    //width: (rect.width > maxImageSize ? maxImageSize : rect.width) * 0.9
                    width: maxImageSize
                    height: maxImageSize
                    clip: true
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/user-solid.svg"
                    visible: image.status !== 1
                }

                Image {
                    id: image
                    //width: rect.width > maxImageSize ? maxImageSize : rect.width
                    width: maxImageSize
                    height: maxImageSize
                    clip: true
                    cache: false
                    verticalAlignment: Image.AlignTop
                    fillMode: Image.PreserveAspectFit
                    //source: "qrc:/images/user-solid.svg"
                    source: Utils.makeURL("user", {nocache: nocache || Date.now(), id: model.id});
                }

                ColumnLayout {
                    Text { text: model.surename; font.pixelSize: fontSize}
                    Text { text: [model.name, model.middleName].join(' '); font.pixelSize: fontSize}
                    Text { text: model.rank; font.pixelSize: fontSize}
                    Text { text: model.organization; font.pixelSize: fontSize}
                    Text { text: model.position; font.pixelSize: fontSize}
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
