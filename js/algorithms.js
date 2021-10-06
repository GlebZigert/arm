.import "utils.js" as Utils

var handlers = {
    ListAlgorithms: listAlgos,
    UpdateAlgorithm: updateAlgo,
    DeleteAlgorithm: function (msg) {Utils.deleteItem(algorithms, msg.data)}
}

var algos

//////////////////////////////////////////////////////////////

function listAlgos(msg) {
    //console.log("ALGOS:", JSON.stringify(msg))

    if (!msg.data)
        msg.data = []

    if (algos && validateTree(msg.data))
        return // TODO: update algorithms


    for (var i = 0; i < msg.data.length; i++) {
        complement(msg.data[i])
    }

    algos = root.algorithms.get(0).children
    algos.clear()
    algos.append(msg.data)

    console.log('Rebuild algos tree')
}

function updateAlgo(msg) {
    console.log("Upd ALGOS:", JSON.stringify(msg))
    if (!msg.data)
        return

    var algo = complement(msg.data)
    if (Utils.replaceItem(algos, algo))
        root.algorithms.updated(algo.id)
    else
        algos.append(algo)
}


function validateTree(list) {
    var i,
        id,
        item,
        cache = {}

    for (i = 0; i < algos.count; i++) {
        item = algos.get(i)
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
    data.icon = 'fa_share_alt_square'
    data.form = 'algo'
    return data
}

function newItem() {
    return complement({
        serviceId: 0,
        deviceId: 0,
        targetServiceId: 0,
        targetDeviceId: 0
    })
}
