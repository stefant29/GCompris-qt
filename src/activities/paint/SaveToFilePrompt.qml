import QtQuick 2.1
import "paint.js" as Activity
import "../../core"

Rectangle {
    id: saveToFilePrompt
    width: parent.width * 0.6
    height: parent.height * 0.6
    radius: height / 30
    color: "#b3b3cc"
    opacity: 0
    anchors.centerIn: parent

    property string text

    signal yes
    signal no
    signal cancel

    GCText {
        text: saveToFilePrompt.text
        width: parent.width
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: - (yes.anchors.bottomMargin + yes.height) / 2
            horizontalCenter: parent.horizontalCenter
        }
    }

    Rectangle {
        id: yes
        color: "#ffe6cc"
        width: parent.width * 3 / 10
        height: parent.height / 6
        radius: height / 2
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height / 10
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: - (width + (parent.width / 2 - width * 1.5) / 2)
        }

        GCText {
            text: "YES"
            anchors.centerIn: parent
        }

        MouseArea {
            id: mouseArea1
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                saveToFilePrompt.yes()
            }

            states: State {
                name: "scaled"; when: mouseArea1.containsMouse
                PropertyChanges {
                    target: yes
                    scale: 1.1
               }
            }

            transitions: Transition {
                NumberAnimation { properties: "scale"; easing.type: Easing.OutCubic }
            }
        }
    }

    Rectangle {
        id: no
        color: "#ff6666"
        width: parent.width * 3 / 10
        height: parent.height / 6
        radius: height / 2
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height / 10
            horizontalCenter: parent.horizontalCenter
        }

        GCText {
            text: "NO"
            anchors.centerIn: parent
        }

        MouseArea {
            id: mouseArea2
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                saveToFilePrompt.no()
            }

            states: State {
                name: "scaled"; when: mouseArea2.containsMouse
                PropertyChanges {
                    target: no
                    scale: 1.1
               }
            }

            transitions: Transition {
                NumberAnimation { properties: "scale"; easing.type: Easing.OutCubic }
            }
        }
    }

    Rectangle {
        id: cancel
        color: "#ccff99"
        width: parent.width * 3 / 10
        height: parent.height / 6
        radius: height / 2
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height / 10
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: width + (parent.width / 2 - width * 1.5) / 2
        }

        GCText {
            text: "Cancel"
            anchors.centerIn: parent
        }

        MouseArea {
            id: mouseArea3
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                saveToFilePrompt.cancel()
            }

            states: State {
                name: "scaled"; when: mouseArea3.containsMouse
                PropertyChanges {
                    target: cancel
                    scale: 1.1
               }
            }

            transitions: Transition {
                NumberAnimation { properties: "scale"; easing.type: Easing.OutCubic }
            }
        }
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Backspace) {
            print("pressed backspace")
        }
    }
}
