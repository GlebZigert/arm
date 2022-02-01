function readForm(form, payload, tr) {
    var input, name, value,
        inst = '',
        ok = true, // fields acceptable
        transforms = tr || {}

    for (var i = 0; i < form.children.length && ok; i++) {
        input = form.children[i]
        if ('name' in input && (input.enabled /*|| input.visible*/)) {
            name = input.name
            if ('fieldValue' in input) {
                value = input.fieldValue
            } else if (input instanceof TextField) {
                inst = 'TextField'
                value = input.text
                ok = ok && input.acceptableInput
            } else if (input instanceof TextArea) {
                inst = 'TextArea'
                value = input.text
                //ok = ok && input.acceptableInput
            } else if (input instanceof Datepicker) {
                inst = 'Datepicker'
                value = input.text
                ok = ok && input.acceptableInput
            } else if (input instanceof ComboBox) {
                inst = 'ComboBox'
                ok = ok && input.currentIndex >= 0
                value = input.model.count && input.currentIndex >= 0 ? input.model.get(input.currentIndex).id : -1
            } else if (input instanceof CheckBox) {
                inst = 'CheckBox'
                value = input.checked
            } else {
                inst = 'UNKNOWN'
                name = ''
            }
            if (name)
                payload[name] = name in transforms ? transforms[name](value): value
            root.log(name + ' is instance of ' + inst + ' - ' + (ok ? 'OK' : 'FAIL'))
        }
        if (input.children.length)
            ok = ok && readForm(input, payload, tr)
    }
    //inst = ok)
    return ok
}

function getLinks(model) {
    var i,
        link,
        links = []
    for (i = 0; i < model.count; i++) {
        link = model.get(i)
        links.push([link.scope, link.id, link.flags])
    }
    return links
}

function processDevLinks(model, values) {
    var i, k,
        item,
        parts
    for (k in values) {
        parts = k.split(':').map(function (v) {return parseInt(v)})
        for (i = 0; i < model.count; i++) {
            item = model.get(i)
            if (item.id === parts[0] && item.scope === parts[1])
                break
        }
        if (i < model.count) {
            item.flags = item.flags & 0xfffffc | values[k]
            if (0 === item.flags)
                model.remove(i)
        } else if (values[k] !== 0)
            model.append({id: parts[0], scope: parts[1], flags: values[k]})

    }
}
