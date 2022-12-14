import QtQuick 2.13
import "qml/forms" as Forms

Forms.JournalStub {
    id: tableView
    property int panePosition

    frameVisible: false
    model: root.events
}

