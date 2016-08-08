import QtQuick 2.1

Rectangle {
    id: frame
    color: items.sizeS == Math.floor(lineSize * 15) ? "#ffff66" : "#ffffb3"
    width: 30
    height: 80
    radius: width * 0.35
    border.color: "#cccc00"
    border.width: 2
    opacity: items.sizeS == Math.floor(lineSize * 15) ? 1 : 0.7

    anchors.verticalCenter: parent.verticalCenter

    property real lineSize: 0.5

    Rectangle {
        id: thickness
        color: "blue"
        radius: width * 0.35
        width: parent.width * frame.lineSize
        height: parent.height *  0.9
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }


    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            background.hideExpandedTools()
            items.sizeS = parent.lineSize * 15
            print("frame.lineSize " + Math.floor(frame.lineSize * 15))
            print("items.sizeS: " + items.sizeS)
        }

        states: State {
            name: "scaled"; when: mouseArea.containsMouse
            PropertyChanges {
                target: frame
                opacity: 1
                scale: 1.2
           }
        }

        transitions: Transition {
            NumberAnimation { properties: "scale"; easing.type: Easing.OutCubic }
        }
    }
}
