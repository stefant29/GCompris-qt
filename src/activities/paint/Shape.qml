import QtQuick 2.1

Item {
    id: shape
    property string shape
    property string color: "black"

    Rectangle {
        id: rectangle
        color: shape.color
        width: parent.width
        height: parent.height
        enabled: parent.shape == "rectangle"
        opacity: parent.shape == "rectangle" ? 1 : 0
    }

    Rectangle {
        id: circle
        radius: width / 2
        color: shape.color
        width: parent.width
        height: parent.width
        enabled: parent.shape == "circle"
        opacity: parent.shape == "circle" ? 1 : 0
    }

    // creates a triangle, but works only with qt quick 2.7
/*    Path {
        startX: 0; startY: 0
        PathSvg { path: "L 150 50 L 100 150 z" }
    }
*/

}
