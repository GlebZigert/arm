.import "constants.js" as Const
.import "crypto.js" as Crypto

function makeURL(endpoint, params) {
    params = params || {}
    var k,
        list = [],
        timestamp = Math.round(Date.now() / 1000, 0),
        token = Crypto.md5(currentUser.token + timestamp)

    for (k in params)
        list.push(k + "=" + encodeURIComponent(params[k]))

    return "http://" + currentUser.id + ":" + token + "@" + serverHost + "/0/" + endpoint + "?" + list.join('&')
}

function linksMap(arr) {
    return (arr || []).map(function (v){return {scope: v[0], id: v[1], flags: v[2]}})
}

function useAlarms() {
    return Const.useAlarms.indexOf(root.armRole) >= 0
}

function checkSticky(event) {
    return Const.stickyStates.indexOf(event.class) >= 0
}

function className(cls) {
    return Const.classNames[100 * Math.floor(cls / 100)] || ''
}

function stateColor(eClass) {
    var cls = 100 * Math.floor(eClass / 100)
    return Const.classColors[cls] || ''
}

function getDeviceTNID(item) {
    return item.serviceId + "-" + item.id
}

function formatFullTime(date) {
    var s = date.getSeconds()
    return formatTime(date) + ':' + (s < 10 ? '0' + s : s)
}

function formatTime(date) {
    var h = date.getHours(),
        m = date.getMinutes()
    return (h < 10 ? '0' + h : h) + ":" + (m < 10 ? '0' + m : m)
}

function formatDate(d) {
    var day = d.getDate(),
        m = d.getMonth() + 1
    return [day < 10 ? '0' + day : day, m < 10 ? '0' + m : m, d.getFullYear()].join('.')
}

function readDate(str) {
    var d = new Date(str)
    return new Date(d.getTime() + d.getTimezoneOffset() * 60 * 1000)
}


function dumpModel(m) {
    for (var i = 0; i < m.count; i++)
        console.log(i, JSON.stringify(m.get(i)))
}


function findItemWithoutPath(model, keys) {
    var i, k,
        found,
        res,
        item;
    if ("number" === typeof keys)
        keys = {id: keys}

    for (i = 0; i < model.count && !res; i++) {
        item = model.get(i)
        //console.log("\t", JSON.stringify(keys), JSON.stringify(item))
        //if (item.serviceId === serviceId) {
        found = true
        for (k in keys)
            if (item[k] !== keys[k]) {
                found = false
                res = findItem(item.children || [], keys)
                break
            }
        if (found)
            res = item
    }
    return res
}

function findPath(model, keys, path) {
    path = path || []

    var i, k,
        found,
        res, // array of keys
        item, node;
    if ("number" === typeof keys)
        keys = {id: keys}

    for (i = 0; i < model.count && !found && path.length === 0; i++) {
        item = model.get(i)
        found = true
        for (k in keys)
            if (item[k] !== keys[k]) {
                found = false
                break
            }
        if (!found && item.children)
            path = findPath(item.children, keys, path)

    }
    if (found || path.length)
        path.unshift(item)

    return path
}

function findItem(model, keys) {
    var path = findPath(model, keys, [])
    return path.pop()
}


/*
function findItem(model, itemId) {
    var i,
        res,
        item;
    // TODO: find by id and scope_id
    if (itemId)
        for (i = 0; i < model.count && !res; i++) {
            item = model.get(i)
            res = item.id === itemId ? item : findItem(item.children || [], itemId)
        }
    return res
}*/


// TODO: can't handle nested structs
function replaceItem(model, data) {
    var i,
        item,
        res = false,
        itemId = data.id;
    // TODO: find by id and scope_id?
    if (itemId)
        for (i = 0; i < model.count && !res; i++) {
            item = model.get(i)
            if (item.id === itemId) {
                model.set(i, data)
                res = true
            } else if (item.children)
                res = replaceItem(item.children, data)
        }
    return res
}

function replaceDevice(model, serviceId, data) {
    var i,
        deviceId = data.id,
        item;
    for (i = 0; i < model.count; i++) {
        item = model.get(i)
//        console.log("\t", serviceId, deviceId, JSON.stringify(item))
        if (item.serviceId === serviceId) {
            if (item.id === deviceId) {
                model.set(i, data)
                return true
            } else if (item.children)
                replaceDevice(item.children, serviceId, data)
        }
    }
    return false
}


function findDevice(model, serviceId, deviceId) {
    return findItem(model, {id: deviceId, serviceId: serviceId})
    /*var i,
        res,
        item;

    for (i = 0; i < model.count && !res; i++) {
        item = model.get(i)
            if (item.id === deviceId && item.serviceId === serviceId) {
                res = item
                //console.log("AAAAAAAAAAAAAA\t", serviceId, deviceId, JSON.stringify(item))
            } else
                res = findDevice(item.children || [], serviceId, deviceId)
    }
    return res*/
}

function deleteItem(model, itemId) {
    var i,
        res,
        item;

    for (i = 0; model && i < model.count; i++) {
        item = model.get(i)
        if (item.id === itemId) {
            model.remove(i)
            break;
        } else if (item.children)
            deleteItem(item.children, itemId)
    }
}

// updates list = [{serviceId, deviceId, color, animation}...]
function updateShape(shape, dev) {
    var state = dev && dev.mapState || 'na'
    shape.name = dev && dev.name || ''
    shape.state = state // for icons
    shape.color = Const.classColors[state.replace(/\d+$/, '')] || 'gray'
    shape.display = dev && dev.display || ''
    shape.tooltip = dev && dev.mapTooltip || '?'
}

function updateMaps(dev) {
    var i, j, shapes, shape
    for (i = 0; i < root.maps.count; i++) {
        shapes = maps.get(i).shapes
        for (j = 0; shapes && j < shapes.count; j++) {
            shape = shapes.get(j)
            if (shape.sid === dev.serviceId && shape.did === dev.id)
                updateShape(shape, dev)
        }
    }
}

/*function serviceColor(status) {
    // service can be model or object (hash)
    if ("offline" === status.tcp || "offline" === status.db)
        return "gold"
    else if ("error" === status.tcp || "error" === status.db)
        return "blue"
    else if ("online" === status.tcp || "online" === status.db)
        return "green"
    else
        return "lightgray"
}*/

function setInitialStatus(model, statusUpdate) {
    var status = model.status
    model.status = {tcp: 0, db: 0, self: 0}
    for (var i in status)
        statusUpdate(status[i])
}

function setServiceStatus(model, sid) {
    var key = Const.serviceStatuses[sid]
    if (!key) {
        return
    }
    var status = model.status
    status[key] = sid
    model.status = status

    var max = Math.max(model.status.self, model.status.tcp, model.status.db),
        color = stateColor(max)
    model.color = color
    //console.log(max, color, JSON.stringify(model.status))
}

function makeCache(model, cache) {
    var i, item
    for (i = 0; i < model.count; i++) {
        item = model.get(i)
        cache[item.id] = item
        if (item.children && item.children.count > 0)
            makeCache(item.children, cache)
    }
    return cache
}

function mapParents(id, model, parents) {
    var i, item
    for (i = 0; i < model.count; i++) {
        item = model.get(i)
        parents[item.id] = id
        if (item.children && item.children.count > 0)
            mapParents(item.id, item.children, parents)
    }
    return parents
}


/*
function findItem(model, id, scope) {
    var i, res, item;
    if (!model)
        return res;
    for (i = 0; i < model.count && !res; i++) {
        item = model.get(i)
        res = 0 === scope && item.id === id ? item : findItem(item.children, id, item.id === scope ? 0 : scope)
    }
    return res
}
*/

