import QtQuick 2.11
import QtQuick.Window 2.11

Window {
    width: 640
    height: 480

    title: 'Accordion'
    visible: true

    MyTree {
        id: tree
        anchors.fill: parent
        anchors.margins: 10
    }

    function update() {
        var data = [
            {"childrens":[{"childrens":[{"childrens":[],"label":"101 (ubuntu-xenial)","focused":true,"type":"lxc"},{"childrens":[],"label":"101 (ubuntu-xenial)","type":"lxc"},{"childrens":[],"label":"101 (ubuntu-xenial)","type":"lxc"},{"childrens":[],"label":"101 (ubuntu-xenial)","type":"lxc"},{"childrens":[],"label":"101 (ubuntu-xenial)","type":"lxc"},{"childrens":[],"label":"101 (ubuntu-xenial)","type":"lxc"},{"childrens":[],"label":"101 (ubuntu-xenial)","type":"lxc"},{"childrens":[],"label":"101 (ubuntu-xenial)","type":"lxc"},{"childrens":[],"label":"101 (ubuntu-xenial)","type":"lxc"},{"childrens":[],"label":"101 (ubuntu-xenial)","type":"lxc"},{"childrens":[],"label":"01 (ubuntu-xenial)","type":"lxc"},{"childrens":[],"label":"10 (ubuntu-xenial)","type":"lxc"},{"childrens":[{"childrens":[],"label":"101 (ubuntu-xenial)","type":"lxc"}, {"childrens":[],"label":"101 (ubuntu-xenial)","type":"lxc"}],"label":"101 (ubuntu-xenial)","type":"lxc"},{"childrens":[],"label":"100 (pvetest-stretch)","type":"qemu"}],"label":"debianpro","type":"node"}],"label":"debianpro","type":"remote"},
            {"childrens":[{"childrens":[{"childrens":[],"label":"103 (stretch01)","type":"lxc"},{"childrens":[],"label":"104 (ubuntu18-ct)","type":"lxc"},{"childrens":[],"label":"107 (no-ipv4)","type":"lxc"},{"childrens":[],"label":"100 (Win10MSEdge)","type":"qemu"},{"childrens":[],"label":"101 (Win7IE8)","type":"qemu"},{"childrens":[],"label":"102 (stretchdocker)","type":"qemu"},{"childrens":[],"label":"106 (ubuntu18-vm)","type":"qemu"},{"childrens":[],"label":"108 (pve5.3)","type":"qemu"},{"childrens":[],"label":"109 (pve5.2)","type":"qemu"}],"label":"nena","type":"node"}],"label":"nena","type":"remote"},
            {"s":[{"childrens":[{"childrens":[],"label":"101 (saltmaster)","type":"lxc"},{"childrens":[],"label":"102 (gitlab)","type":"lxc"},{"childrens":[],"label":"103 (aptcacher)","type":"lxc"},{"childrens":[],"label":"104 (psql1)","type":"lxc"},{"childrens":[],"label":"105 (monitor1)","type":"lxc"},{"childrens":[],"label":"106 (spads01)","type":"lxc"},{"childrens":[],"label":"111 (file01)","type":"lxc"},{"childrens":[],"label":"100 (win10)","type":"qemu"}],"label":"srv01","type":"node"}],"label":"srv01","type":"remote"}
        ];

        tree.model.clear();
        /*data.forEach(function(row) {
            //console.log(row.label)
            tree.model.append(row);
            //console.log(tree.model)
        });*/
        //data[0].childrens[0].childrens[1].focused = true
        var m = tree.model
        m.append({"focused": true, "expanded": false, "label":"101 (ubuntu-xenial)","type":"lxc","childrens":[]})
        m.append({"focused": false, "expanded": false, "label":"102 (bubuntu-xenial)","type":"lxc","childrens":[]})
        m.get(0).childrens.append({"expanded": false, "label":"101 (ubuntu-xenial)","type":"lxc","childrens":[]})
    }

    Component.onCompleted: {
        update();
    }
}
