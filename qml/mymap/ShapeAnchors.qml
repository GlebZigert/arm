import QtQuick 2.11

Repeater {
    id: anchors
    model: anchorsModel
    delegate: Rectangle {
        z: 1e9
        rotation: model.r
        transformOrigin: Item.Center
        visible: currentItem && ('text' !== currentItem.type ? true : index % 2 === 0)
        width: handleSize
        height: handleSize
        color: isPoly() && index === anchorsModel.count - 1 ? Qt.rgba(0, 0, 0, 0.5) : Qt.rgba(255, 255, 255, 0.8)
        border.color: "black"
        border.width: 1
        radius: isPoly() || index != 8 ? 0 : handleSize / 2 // special anchor for rotation

        x: model.x - handleSize / 2
        y: model.y - handleSize / 2
        //Component.onCompleted: root.log(index, JSON.stringify(coords1))

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                if (mouse.button === Qt.RightButton)
                    removePoint(index)
                else
                    mouse.accepted = false
            }

            onPressed: {
                if (mouse.button === Qt.LeftButton) {
                    root.log('left press, a', index)
                    currentAnchor = index
                    startPhi = NaN
                    mouse.accepted = false
                } else
                    mouse.accepted = true
            }
        }
    }
}
