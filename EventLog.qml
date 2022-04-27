// https://stackoverflow.com/questions/45168702/canonical-way-to-make-custom-tableview-from-listview-in-qt-quick
// printing: https://evileg.com/en/forum/topic/745/
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as QC1
import QtQuick.Layouts 1.5
import "qml/forms" as Forms

RowLayout {
    property bool adminMode: true
    property int panePosition
    //anchors.fill: parent

    ListModel {id: eventsList}

    Item {
        //signal send(var msg);
        readonly property int maxRecords: 200

        Layout.fillHeight: true
        Layout.fillWidth: true

        QC1.TableView {
            id: tableView
            //width: parent.width
            anchors.fill: parent
            frameVisible: false
            model: eventsList
            onDoubleClicked: root.eventSelected(model.get(row))

            QC1.TableViewColumn {
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
                width: 50
            }
            /*QC1.TableViewColumn {
                id: eidColumn
                role: "externalId"
                title: "##"
                width: 50
            }*/

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
                //width: 100
            }
            QC1.TableViewColumn {
                id: deviceColumn
                role: "deviceName"
                title: "Устройство"
                //width: 100
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
                //width: 100
            }
            QC1.TableViewColumn {
                role: "reason"
                title: "Причины"
                //width: tableView.viewport.width - serviceColumn.width - deviceColumn.width
            }
            QC1.TableViewColumn {
                role: "action"
                title: "Принятые меры"
                //width: tableView.viewport.width - serviceColumn.width - deviceColumn.width
            }
        }
    }
    // right panel
    Rectangle {
        visible: adminMode
        color: "lightgray"
        Layout.fillHeight: true
        Layout.minimumWidth: 330
        Forms.EventsFilterForm{}
    }
}

