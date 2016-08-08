import QtQuick 2.1

Rectangle {
    id: expand

    property int sizeS

    anchors {
        leftMargin: 10
        left: parent.right
    }

    opacity: 0

    width: 245
    height: 55
    border.color: "black"
    border.width: 4
    color: "black"


    Flow {
        id: group
        width: 230
        height: 50
        anchors.centerIn: parent

        spacing: 10

        Repeater {
            id: repeater
            model: 4
//            anchors.centerIn: parent

            Rectangle {

                width: 50
                height: 50
                color: "grey"

                Rectangle {
                    id: option
                    width: index * 10 + 20
                    height: 50
                    anchors.centerIn: parent
                    color: "green"
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        //code
                        colorTools.z = 0
                        tool.opac = 0
                        expand.sizeS = index + 1
                    }
                }
            }
        }
    }
}
