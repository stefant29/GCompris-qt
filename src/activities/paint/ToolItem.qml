import QtQuick 2.1
import "paint.js" as Activity

Image {
    id: button
    width: 60; height: 60
    source: Activity.url + name + ".svg"
    opacity: items.toolSelected == name ? 1 : 0.6

    property string name
    signal click

    MouseArea {
        anchors.fill: parent
        onClicked: {
            items.toolSelected = name
            background.hideExpandedTools()

            // make the hover over the canvas false
            area.hoverEnabled = false

            click()
        }
    }
}
