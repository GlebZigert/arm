import QtQuick 2.11

MouseArea { // whole image
    z: 1e9-1
    //propagateComposedEvents: true
    enabled: adminMode
    acceptedButtons: Qt.LeftButton | (adminMode ? Qt.RightButton : 0)
    anchors.fill: parent
    onPressed: {
        if (mouse.button === Qt.LeftButton) {
            mouse.accepted = currentAnchor >= 0
            if (-1 === currentAnchor)
                currentAnchor = -2 // drag map
        } else
            mouse.accepted = true
    }

    //onClicked: mouse.button === Qt.RightButton ? addPoint(mouse.x, mouse.y) : mouse.accepted = false

    onPositionChanged: {
        if (!currentItem)
            return

        if (isPoly()) {
            console.log('MP:', mouse.x, mouse.y)
            moveAnchor(mouse.x, mouse.y)
        } else if (currentAnchor === 8)
            rotate(mouse.x, mouse.y)
        else if (currentAnchor >= 0)
            scaleShape(mouse.x, mouse.y)
        arrangeAnchors()
    }

    onReleased: {
        //mouse.accepted = false
        mouse.button === Qt.RightButton ? addPoint(mouse.x, mouse.y) : mouse.accepted = false
        currentAnchor = -1
    }

    function lineClicked(mx, my) {
        var i, j,
            yes,
            item,
            p // points
        for (i = 0; i < currentMap.shapes.count; i++) {
            item = currentMap.shapes.get(i)
            if ('polyline' === item.type) {
                console.log(item.data)
                p = item.data.split(/,| /).map(function (v) {return parseInt(v)})
                for (j = 0; j < p.length - 3; j += 2) {
                    //yes = checkPoint({x: p[j], y: p[j+1]}, {x: mx, y: my}, {x: p[j+2], y: p[j+3]})
                    yes = pDistance(mx, my, p[j], p[j+1], p[j+2], p[j+3])
                    console.log(mx, my, p[j], p[j+1], p[j+2], p[j+3], yes)

                }


            }
        }
    }

    // https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
    function pDistance(x, y, x1, y1, x2, y2) {
      var A = x - x1;
      var B = y - y1;
      var C = x2 - x1;
      var D = y2 - y1;

      var dot = A * C + B * D;
      var len_sq = C * C + D * D;
      var param = -1;
      if (len_sq !== 0) //in case of 0 length line
          param = dot / len_sq;

      var xx, yy;

      if (param < 0) {
        xx = x1;
        yy = y1;
      } else if (param > 1) {
        xx = x2;
        yy = y2;
      } else {
        xx = x1 + param * C;
        yy = y1 + param * D;
      }

      var dx = x - xx,
          dy = y - yy
      return Math.sqrt(dx * dx + dy * dy);
    }

}
