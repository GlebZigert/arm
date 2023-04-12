.import "utils.js" as Utils
.import "constants.js" as Const

var handlers = {
    ListMaps: listMaps,
    UpdateMap: updateMap,
    DeleteMap: function (msg) {
        Utils.deleteItem(root.maps, msg.data)
    },
    PlanUpload: function (msg) {
        root.planUpload(msg.data)
    },
    /*DeleteMap: function (msg) {
        console.log(JSON.stringify(msg))
        for (var i = 0; i < root.maps.count; i++)
            if (root.maps.get(i).id === msg.data) {
                root.maps.remove(i)
                break
            }
    }*/
}

//////////////////////////////////////////////////////////////

function planImagePath(id) {
    return "/plan?id=" + id + '&rnd=' + Math.round(Math.random() * 1e16)
}

function listMaps(msg) {
//    console.log("############# LIST MAPS:", JSON.stringify((msg.data)))
    root.maps.clear()
    if (!msg.data)
        return

    for (var i = 0; i < msg.data.length; i++) {
        //msg.data[i].imageSource = planImagePath(msg.data[i].id)
        if (!msg.data[i].shapes) {
            msg.data[i].shapes = []
        }
        injectExtra(msg.data[i])
    }

    root.maps.append(msg.data)
    //console.log("Maps COUNT after list", root.maps.count)
}

function updateMap(msg) {
    if (!msg.data)
        return

    var map
    for (var i = 0; i < root.maps.count; i++)
        if ((map = root.maps.get(i)).id === msg.data.id)
            break
    //console.log("=====================")
    //dumpModel(root.maps)

    if (Const.ARM_ADMIN === root.armRole || (msg.data.shapes && msg.data.shapes.length > 0)) {
        injectExtra(msg.data)
        if (i < root.maps.count) { // update existing map
            map.name = msg.data.name
            mergeShapes(map.shapes, msg.data.shapes || [])
        } else // append the new map
            root.maps.append(msg.data)
    } else if (i < root.maps.count) {
        root.maps.remove(i)
    }
    //dumpModel(root.maps)
}

function mergeShapes(model, updates) {
    var i,
        shape,
        shapes = updates.reduce(function (o, v) {o[v.id] = v; return o}, {})

    for (i = model.count - 1; i >= 0 ; i--) {
        shape = model.get(i)
        //if (!shape.id) continue
        if (shape.id in shapes) {
            model.set(i, shapes[shape.id])
            delete shapes[shape.id]
        } else
            model.remove(i)
    }
    for (i in shapes)
        model.append(shapes[i])
}

function injectExtra(map) {
    var i, j,
        device,
        shapes = {}
    map.zoomLevel = 3
    for (j = 0; map.shapes && j < map.shapes.length; j++) {
        //console.log("%%%%%%%%%%%%%%%%%", JSON.stringify(map.shapes[j]))
        device = Utils.findDevice(root.devices, map.shapes[j].sid, map.shapes[j].did)
        //device = Utils.findItem(root.devices, {serviceId: map.shapes[j].sid, id: map.shapes[j].did})
        //console.log("$$$$$$$$$$$$$$", JSON.stringify(device))
        Utils.updateShape(map.shapes[j], device)
        /*device = device || {color: '#808080', display: '', stateType: 'na'}
        map.shapes[j].name = device.name
        map.shapes[j].state = device.stateType
        map.shapes[j].color = device.color
        map.shapes[j].display = device.display*/
    }
}
