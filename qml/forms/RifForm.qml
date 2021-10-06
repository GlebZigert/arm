import QtQuick 2.0

Column {
    spacing: 5
    anchors.fill: parent
    anchors.margins: 5

    Row {
        spacing: 5
        Text { text: "Name:"; horizontalAlignment: Text.AlignRight }
        Text { text: model.label }
    }
    Row {
        spacing: 5
        Text { text: "Color:"; horizontalAlignment: Text.AlignRight }
        Text { text: color }
    }
    Row {
        spacing: 5
        Text { text: "Num:"; horizontalAlignment: Text.AlignRight }
        Text { text: model.num.count}
    }
    Row {
        spacing: 5
        Text { text: "Тип:"; horizontalAlignment: Text.AlignRight }
        Text { text: model.type || '?'}
    }
    /*Row {
        spacing: 5
        Text { text: "Template:"; horizontalAlignment: Text.AlignRight }
        Text { text: model.form}
    }*/

}
