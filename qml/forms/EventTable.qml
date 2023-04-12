import QtQuick 2.13
import QtQuick.Controls 1.4 as QC1

QC1.TableView {
    //property bool colorizeEvents: true

    QC1.TableViewColumn {
        //visible: colorizeEvents
        role: "color"
        title: ""
        width: 20
        delegate: Text {
            padding: 4
            horizontalAlignment: Text.AlignHCenter
            color: styleData.value || 'gray'
            font.family: faFont.name
            text: faFont.fa_circle
            //font.pixelSize: 14
        }
    }

    QC1.TableViewColumn {
        id: idColumn
        role: "id"
        title: "#"
        width: 60
    }

    QC1.TableViewColumn {
        id: timeColumn
        role: "timeString"
        title: "Время"
        width: 140
    }

    QC1.TableViewColumn {
        id: serviceColumn
        role: "serviceName"
        title: "Источник"
        width: 110
    }
    QC1.TableViewColumn {
        id: deviceColumn
        role: "deviceName"
        title: "Устройство"
        width: 110
    }
    QC1.TableViewColumn {
        id: textColumn
        role: "text"
        title: "Событие"
        //width: tableView.viewport.width - serviceColumn.width - deviceColumn.width
    }
    QC1.TableViewColumn {
        role: "userName"
        title: "Пользователь"
        //width: tableView.viewport.width - serviceColumn.width - deviceColumn.width
    }
    QC1.TableViewColumn {
        role: "zoneName"
        title: "Зона"
        width: 110
    }
    QC1.TableViewColumn {
        role: "reason"
        title: "Причины"
        //width: tableView.viewport.width - serviceColumn.width - deviceColumn.width
    }
    QC1.TableViewColumn {
        role: "reaction"
        title: "Принятые меры"
        //width: tableView.viewport.width - serviceColumn.width - deviceColumn.width
    }
}
