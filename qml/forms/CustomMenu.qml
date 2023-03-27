import QtQuick 2.11
import QtQml 2.11
import QtQuick.Controls 2.4

Menu {
    id: menu
    property var menuItems
    Instantiator {
        delegate: MenuItem {
            text: model.text
            onTriggered: if (menuItems && model.action in menuItems)
                  menuItems[model.action].handler()
            }

        model: ListModel {
            id: menuItemsModel
            ListElement{action: ""; text: ""} // !important
        }
        onObjectAdded: menu.insertItem(index, object)
        onObjectRemoved: menu.removeItem(object)
    }

    function show(menu) {
        menuItems = menu || {}
        menuItemsModel.clear()

        for (let act in menuItems)
            menuItemsModel.append({action: act, text: menuItems[act].text})

        if (menuItemsModel.count > 0)
            popup()
    }
}
