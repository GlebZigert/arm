.import "utils.js" as Utils

var userTree

var handlers = {
    ListUsers: function (msg) {
        var id
        //root.log("LIST USERS", JSON.stringify(msg.data))
        if (null === msg.data)
            return
        if (!userTree)
            userTree = new UserTree(root.users.get(0).children)
        userTree.updateTree(msg.data)
    },

    UpdateUser: function (msg) {
        // TODO: update root.currentUser if needed
        if (userTree)// check that operator have user list
            userTree.updateUser(msg.data)
    },
    DeleteUser: function (msg) {
        //root.log(JSON.stringify(msg))
        // TODO: what if deleted current user?
        if (userTree) // check that operator have user list
            userTree.deleteUser(msg.data)
    },
    UserInfo: function (msg) {userTree.userInfo(msg.data)}
}

//////////////////////////////////////////////////////////////

function UserTree(model) {
    this.model = model
    this.tid = 1
}

UserTree.prototype.updateTree = function (data) {
    // TODO: update tree only if required
    var i,
        item,
        list = {},
        root = [];
    //root.log("User tree:", JSON.stringify(data))
    for (i in data) {
        list[data[i].id] = newItem(data[i])
        list[data[i].id].tid = this.tid++ // treeID
        if (0 === data[i].parentId)
            root.push(list[data[i].id])
    }
    for (i in list)
        if (list[i].parentId in list)
            list[list[i].parentId].children.push(list[i])

    this.model.clear()
    this.model.append(root)
    //this.cache = makeCache(model.children, {}) // TODO: maybe just {}?
    //root.log("UserTree", JSON.stringify(root))
}

UserTree.prototype.deleteUser = function (id) {
    Utils.deleteItem(this.model, id)
}

// TODO: this func is absolete
UserTree.prototype.append = function (list, item) {
    item.tid = this.tid++
    list.append(item)
}

UserTree.prototype.updateUser = function (data) {
    // TODO: maybe rewrite using model.set()?
    //{"id":13,"parentId":2,"type":4,"name":"7358t","surename":"Sdsfgdfgdf","login":""}
    root.log("UPD USER", JSON.stringify(data))
    var i,
        exclude = ['id', 'type', 'role', 'icon', 'form', 'cards', 'zones', 'devices'],
        item = findUserOrParent(this.model, data.id, data.parentId)

    if (!item && data.parentId !== 0) {
        return // not found
    }

    if (!item) {
        // new item in root
        this.append(this.model, newItem(data))
    } else if (item.id === data.id) {
        // update
        for (i in item)
            if (exclude.indexOf(i) < 0 && i in data)
                item[i] = data[i]
        item.label = item.surename + ' ' + item.name
        fillInfo(item, data)
        root.users.updated(item.id)
    } else if (item.id === data.parentId) {
        // new user
        this.append(item.children, newItem(data))
    }
    // TODO: sort (use DelegateModel? https://martin.rpdev.net/2019/01/15/using-delegatemodel-in-qml-for-sorting-and-filtering.html)
}

UserTree.prototype.userInfo = function (data) {
    //root.log("USER INFO", JSON.stringify(data))
    var user = Utils.findItem(this.model, data.id)
    if (user) {
        //root.log("USER INFO", JSON.stringify(user))
        fillInfo(user, data)
        //root.log("USER INFO UPD", JSON.stringify(user.devices))
        root.users.updated(data.id)
    }
}

// findUserOrParent => findItem(model, parentId) then findItem(parent.children, id)
function findUserOrParent(model, userId, parentId) {
    var i,
        res,
        item;

    for (i = 0; i < model.count && !res; i++) {
        item = model.get(i)
        if (item.id === userId)
            return item
        if (item.children.count > 0)
            res = findUserOrParent(item.children, userId, parentId)
        if (!res && item.id === parentId)
            res = item
    }
    return res
}

function newItem(data) {
    var types = {
            1: 'fa_user_friends',// group
            2: 'fa_user_tie',// personal
            3: 'fa_user_secret',// guest
            4: 'fa_car',// car
        },
        label = [];
    if (data.surename)
        label.push(data.surename)
    if (data.name)
        label.push(data.name)

    return {
        id: data.id || 0,
        type: data.type || 0,
        isGroup: 1 === data.type,
        role: data.role || 0,
        parentId: data.parentId,
        name: data.name || '',
        surename: data.surename || '',
        middleName: data.middleName || '',
        rank: data.rank || '',
        organization: data.organization || '',
        position: data.position || '',

        label: label.length ? label.join(' ') : '',
        login: data.login || '',

        //icon: 'fa_circle',
        color: "#666",
        icon: types[data.type] || '',
        form: "user",
        children: [],
        cards: [{card: "+Новый ключ"}],
        devices: Utils.linksMap(data.devices),
        zones: Utils.linksMap(data.zones)
        //accessRules: (data.accessRules || []).map(function (v){return {scope: v[0], id: v[1]}}),
        //devices: (data.devices || []).map(function (v){return {scope: v[0], id: v[1]}})
        //accessRules: [1, 2, 3, 4, 5, 6, 7].map(function (){return {id: 1 + Math.round(Math.random()*15)}})
    }
}


function fillInfo(user, data) {
    user.zones.clear()
    if (null !== data.zones)
        user.zones.append(Utils.linksMap(data.zones))

    user.devices.clear()
    if (null !== data.devices)
        user.devices.append(Utils.linksMap(data.devices))

    user.cards.clear()
    //user.cards.append((data.cards || []).map(function (v){return {card: parseInt(v, 16).toString(10)}}))

    if (null !== data.cards)
        user.cards.append((data.cards || []).map(function (v){return {card: v}}))
    user.cards.append({card: "+Новый ключ"})
}
