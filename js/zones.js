.import "utils.js" as Utils
.import "journal.js" as Journal
.import "constants.js" as Const

var handlers = {
    ListZones: listZones,
    UpdateZone: updateZone,
    EnterZone: enterZone,
    DeleteZone: function (msg) {Utils.deleteItem(zones, msg.data)}
}

var zones

//////////////////////////////////////////////////////////////

function listZones(msg) {
    //console.log("ListZONES:", JSON.stringify(msg))
    //var ext = complement({id: 0, name: 'Внешняя территория'})
    //delete ext.form

    if (!msg.data)
        msg.data = []

    //if (zones && validateTree(msg.data))
        //return

    for (var i = 0; i < msg.data.length; i++) {
        complement(msg.data[i])
        Journal.complementEvents(msg.data[i].entranceEvents)
    }

    zones = root.zones.get(0).children
    zones.clear()
    //zones.append(ext)
    //console.log("Zones.JS Zone data", JSON.stringify(msg.data))
    zones.append(msg.data)

   // console.log('Rebuild zones tree')
}

function updateZone(msg) {
    //console.log("UpdZONES:", JSON.stringify(msg))
    if (!msg.data)
        return

    var zone
    for (var i = 0; i < zones.count; i++)
        if ((zone = zones.get(i)).id === msg.data.id)
            break

    if (i < zones.count) {
        zone.label = zone.name = msg.data.name
        zone.maxVisitors = msg.data.maxVisitors
        root.zones.updated(zone.id)
    } else // new zone
        zones.append(complement(msg.data))
}


function validateTree(list) {
    var i,
        id,
        item,
        cache = {}

    for (i = 0; i < zones.count; i++) {
        item = zones.get(i)
        cache[item.id] = item
    }

    for (i = 0; i < list.length; i++) {
        id = list[i].id
        if (!(id in cache) || list[i].id !== id && list[i].name !== item.name)
            return false
    }
    return true
}

function complement(data) {
    data.label = data.name
    data.icon = 'fa_puzzle_piece'
    data.form = 'zone'
    data.devices = Utils.linksMap(data.devices)
    if (!data.entranceEvents)
        data.entranceEvents = []
    return data
}

function enterZone(event) {
    if ([Const.ARM_ADMIN, Const.ARM_SECRET].indexOf(root.armRole) < 0)
            return // control visitor's location not for all ARM

    //console.log("enterZONE:", JSON.stringify(event))
    var zone,
        del = false,
        add = false,
        zones = root.zones.get(0).children
    // 1.find user
    for (var i = 0; (!del || !add) && i < zones.count; i++) {
        zone = zones.get(i)
        for (var j = 0; !del && j < zone.entranceEvents.count; j++)
            if (event.userId === zone.entranceEvents.get(j).userId) {
                zone.entranceEvents.remove(j)
                del = true
                //console.log('DEL from zone')
            }
        if (zone.id === event.zoneId) {
            zone.entranceEvents.append(event)
            add = true
            //console.log('ADD to zone')
        }
    }
}
