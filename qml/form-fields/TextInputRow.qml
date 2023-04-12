import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5


RowLayout {
    property string label: ""
    property string name: ""

    Text {
        text: label;
        Layout.preferredWidth: 120;
        horizontalAlignment: Text.AlignRight
    }
    TextField {
        property string name: name
    }
}
