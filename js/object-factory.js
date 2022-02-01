var _component;
var _callback;
var _parent;
var _source;

function create(source, parent, callback)
{
    source = "../" + source + ".qml"
    _parent = parent;
    _callback = callback;
    _source = source;
    
    _component = Qt.createComponent(source);
    if (_component.status === Component.Ready || _component.status === Component.Error)
        createDone();
    else
        _component.statusChanged.connect(createDone);
}

function createDone()
{
    if (_component.status === Component.Ready)
    {
        var obj = _component.createObject(_parent);
        if (obj !== null)
            _callback(obj, _source);
        else
            root.log("Error creating object: " + _source);
        
        _component.destroy();
    }
    else if (_component.status === Component.Error)
        root.log("Error creating component: " + _component.errorString());
}
