import QtQuick 2.0

Column {
    spacing: 5
    anchors.fill: parent

    Row {
        spacing: 5
        Text { text: "ID:"; horizontalAlignment: Text.AlignRight }
        Text { text: model.id }
    }

    Row {
        spacing: 5
        Text { text: "Name:"; horizontalAlignment: Text.AlignRight }
        Text { text: model.label }
    }

    Row {
        spacing: 5
        Text { text: "Num:"; horizontalAlignment: Text.AlignRight }
        Text { text: [model.num1, model.num2, model.num3].join(':') }
    }
    Row {
        spacing: 5
        Text { text: "Тип:"; horizontalAlignment: Text.AlignRight }
        Text { text: model.type || '?'}
    }
    Row {
        spacing: 5
        Text { text: "IP:"; horizontalAlignment: Text.AlignRight }
        Text { text: model.ip || '?'}
    }
    /*Row {
        spacing: 5
        Text { text: "Template:"; horizontalAlignment: Text.AlignRight }
        Text { text: model.form}
    }*/

}
