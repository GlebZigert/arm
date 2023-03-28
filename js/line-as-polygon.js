// adopted from https://gist.github.com/kekscom/4194148
/**
 * @author Jan Marsch (@kekscom)
 * @example see http://jsfiddle.net/osmbuildings/2e5KX/5/
 * @example thickLineToPolygon([{x:50,y:155}, {x:75,y:150}, {x:100,y:100}, {x:50,y:100}], 20)
 * @param polyline {array} a list of point objects in format {x:75,y:150}
 * @param thickness {int} line thickness
 */

var lineAsPolygon = (function () {
    function getOffsets(a, b, thickness) {
        var
            dx = b.x - a.x,
            dy = b.y - a.y,
            len = Math.sqrt(dx * dx + dy * dy),
            scale = thickness / (2 * len)
        ;
        return {
            x: -scale * dy,
            y:  scale * dx
        };
    }

    function getIntersection(a1, b1, a2, b2) {
        // directional constants
        var
            k1 = (b1.y - a1.y) / (b1.x - a1.x),
            k2 = (b2.y - a2.y) / (b2.x - a2.x),
            x, y,
            m1, m2
        ;

        // if the directional constants are equal, the lines are parallel
        if (k1 === k2) {
            return;
        }

        // y offset constants for both lines
        m1 = a1.y - k1 * a1.x;
        m2 = a2.y - k2 * a2.x;

        // compute x
        x = (m1 - m2) / (k2 - k1);

        // use y = k * x + m to get y coordinate
        y = k1 * x + m1;

        return {x: x, y: y}
    }

    function _backup(points, thickness) {
        var
            off,
            poly = [],
            isFirst, isLast,
            prevA, prevB,
            interA, interB,
            p0a, p1a, p0b, p1b
        ;

        for (var i = 0, il = points.length - 1; i < il; i++) {
            isFirst = !i;
            isLast = (i === points.length - 2);

            off = getOffsets(points[i], points[i+1], thickness);
            /*
            if (off.x > thickness)
                off.x = thickness
            if (off.y > thickness)
                off.y = thickness*/

            p0a = { x:points[i  ].x + off.x, y:points[i  ].y + off.y };
            p1a = { x:points[i+1].x + off.x, y:points[i+1].y + off.y };
            p0b = { x:points[i  ].x - off.x, y:points[i  ].y - off.y };
            p1b = { x:points[i+1].x - off.x, y:points[i+1].y - off.y };

            if (!isFirst) {
                if (interA = getIntersection(prevA[0], prevA[1], p0a, p1a)) {
                    poly.unshift(interA);
                }
                if (interB = getIntersection(prevB[0], prevB[1], p0b, p1b)) {
                    poly.push(interB);
                }
            }

            if (isFirst) {
                poly.unshift(p0a);
                poly.push(p0b);
            }

            if (isLast) {
                poly.unshift(p1a);
                poly.push(p1b);
            }

            if (!isLast) {
                prevA = [p0a, p1a];
                prevB = [p0b, p1b];
            }
        }

        return poly;
    }

    return function (points, thickness) {
        var
            off,
            poly = [],
            isFirst, isLast,
            prevA, prevB,
            interA, interB,
            p0a, p1a, p0b, p1b
        ;

        for (var i = 0, il = points.length - 1; i < il; i++) {
            isFirst = !i;
            isLast = (i === points.length - 2);

            off = getOffsets(points[i], points[i+1], thickness);

            p0a = { x:points[i  ].x + off.x, y:points[i  ].y + off.y };
            p1a = { x:points[i+1].x + off.x, y:points[i+1].y + off.y };
            p0b = { x:points[i  ].x - off.x, y:points[i  ].y - off.y };
            p1b = { x:points[i+1].x - off.x, y:points[i+1].y - off.y };


            poly.unshift(p0a);
            poly.push(p0b);

            poly.unshift(p1a);
            poly.push(p1b);
        }

        return poly;
    }
}());
