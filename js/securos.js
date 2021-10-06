.import "utils.js" as Utils

function Securos(model, events, serviceId) {
    this.model = model
    this.events = events
    this.serviceId = serviceId
}

Securos.prototype.updateTree = function (data) {
    var i,
        list = [],
        model = this.model.children

    for (i in data) {
        //console.log('Seeding Sigur:', JSON.stringify(data[i]), model)
        console.log(data[i].state)

        list.push({
            id: data[i].id,
            serviceId: this.serviceId,
            label: data[i].name,
            color: "black",
            children: [],
            form: "sigur"
        })
    }
    model.clear()
    //if (list.length)
        model.append(list)
}

Securos.prototype.update = function (data) {
    console.log('Sigur: UPDATE')
    var maxRecords = 200
    for (var i in data) {
        var color = "gray" // s2c(data[i].states)
        // update tree
        // update events
        /*let dt = new Date(1e3 * data[i].datetime)
        let time = dt.toDateString() + ' ' + dt.toLocaleTimeString()
        var text = data[i].deviceName + ': ' + data[i].name + ' (' + data[i].objectName + ')'

        Utils.logEvent(color, text, state.datetime)*/
    }
}

Securos.prototype.validateTree = function (data) {
    console.log('Sigur: validateTree stub')
}
