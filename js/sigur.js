.import "utils.js" as Utils

function Sigur(model, serviceId) {
    this.model = model
    this.events = events
    this.serviceId = serviceId
}

Sigur.prototype.updateTree = function (data) {
    var i,
        item,
        list = {},
        root = [],
        model = this.model.children

    for (i in data) {
        //console.log('Seeding Sigur:', JSON.stringify(data[i]), model)
        console.log(data[i].state)

        list[data[i].id] = {
            id: data[i].id,
            serviceId: this.serviceId,
            parentId: data[i].parentId,
            label: data[i].name,
            color: "black",
            children: [],
            form: "sigur"
        }
        if (0 === data[i].parentId)
            root.push(list[data[i].id])
    }
    for (i in list)
        if (list[i].parentId in list)
            list[list[i].parentId].children.push(list[i])

    model.clear()
    model.append(root)
}

Sigur.prototype.update = function (data) {
    console.log('Sigur: UPDATE')
    var maxRecords = 200
    for (var i in data) {
        var color = "gray" // s2c(data[i].states)
        // update tree
        // update events
        let text = data[i].deviceName + ': ' + data[i].name + ' (' + data[i].objectName + ')'
        Utils.logEvent(color, text, data[i].datetime)
    }
}

Sigur.prototype.validateTree = function (data) {
    console.log('Sigur: validateTree')
}
