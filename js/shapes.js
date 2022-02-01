// https://www.geeksforgeeks.org/how-to-discretize-an-ellipse-or-circle-to-a-polygon-using-c-graphics/

function ellipse(x, y, b, a, seg) {
    seg = seg || Math.max(Math.floor(Math.sqrt(((a + b) / 4) * 20)), 8);
    var angle_shift = 2 * Math.PI / seg, phi = 0;
    var vertices = [];
    for (var i = 0; i < seg; i++) {
        phi += angle_shift;
        vertices.push([x + a / 2 * Math.cos(phi), y + b / 2 * Math.sin(phi)])
    }

    return vertices.map(function (v){return {latitude: v[0], longitude: v[1]}});
}

function rectangle(y, x, w, h) {
    return [
        {latitude: y - h / 2, longitude: x - w / 2},
        {latitude: y - h / 2, longitude: x + w / 2},
        {latitude: y + h / 2, longitude: x + w / 2},
        {latitude: y + h / 2, longitude: x - w / 2}
    ]
}

function rectangle2(y, x, w, h, r) {
    return [
        [-h / 2, -w / 2],
        [-h / 2, +w / 2],
        [+h / 2, +w / 2],
        [+h / 2, -w / 2]
    ].map(function (p0) {
        var p = rp(p0[0], p0[1], r)
        return {latitude: y + p[1], longitude: x + p[0]}
    })
}

function polygon(points) {
    var res = points.split(' ').map(function (v){
        var pair = v.split(',')
        return {latitude: parseFloat(pair[0]), longitude: parseFloat(pair[1])}
    })
    //root.log("POLY:", JSON.stringify(res))
    return res
}

// rotate point
function rp(dx, dy, phi) {
    var sin = Math.sin(-phi / 180 * Math.PI),
        cos = Math.cos(-phi / 180 * Math.PI);
    return [dx * cos - dy * sin, dy * cos + dx * sin]
}

function testPoints() {
    var points = [
        [59.91107793537606, 10.744815826417891],
        [59.907183432795804, 10.754643440256615],
        [59.91467080053557, 10.757561683656263]]
    return points.map(function (v){return {latitude: v[0], longitude: v[1]}})
}
