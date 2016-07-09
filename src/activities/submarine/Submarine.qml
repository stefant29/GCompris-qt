/* GCompris - submarine.qml
 *
 * Copyright (C) 2016 RAJDEEP KAUR <rajdeep.kaur@kde.org>
 *
 * Authors:
 *   Bruno Coudoin (bruno.coudoin@gcompris.net) (GTK+ version)
 *   RAJDEEP KAUR <rajdeep.kaur@kde.org> (Qt Quick port)
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.1
import QtQuick 2.3
import Box2D 2.0
import QtGraphicalEffects 1.0
import "../../core"
import "submarine.js" as Activity

ActivityBase {
    id: activity

    onStart: focus = true
    onStop: {}

    property string url: "qrc:/gcompris/src/activities/submarine/resource/"

    pageComponent: Image {
        id: background
        anchors.fill: parent
        source: url + "background.svg"
        signal start
        signal stop

        Component.onCompleted: {
            activity.start.connect(start)
            activity.stop.connect(stop)
        }

        // Add here the QML items you need to access in javascript
        QtObject {
            id: items
            property Item main: activity.main
            property alias background: background
            property alias bar: bar
            property alias bonus: bonus
            property var submarineCategory: Fixture.Category1
            property var crownCategory: Fixture.Category2
            property var whaleCategory: Fixture.Category3
            property var upperGatefixerCategory: Fixture.Category4
            property var lowerGatefixerCategory: Fixture.Category5

        }

        IntroMessage {
            id: message
            anchors {
                top: parent.top
                topMargin: 10
                right: parent.right
                rightMargin: 5
                left: parent.left
                leftMargin: 5
            }
            z: 100
            onIntroDone: {

            }
            intro: [
                qsTr(""),
                qsTr(""),
                qsTr(""),
            ]
        }

        onStart: { Activity.start(items) }
        onStop: { Activity.stop() }

        World {
            id: pysicalworld
            running: false
            gravity: Qt.point(0,0)
            autoClearForces: false
        }

        Item {
            id: submarine

            Image {
                id: submarineImage
                source: url + "submarine.png"
                width: background.width/9
                height: background.height/9

                function showimage() {
                    visible = true
                }

                function hideimage() {
                    visible = false
                }
            }

            Image {
                id: brokensubmarineImage
                source: url + "submarine-broken.png"
                visible: false

                function show() {
                    visible = true
                }

                function hide() {
                    visible = false
                }
            }

            Body {
                id: submarinebody
                target: submarine
                bodyType: Body.Dynamic
                fixedRotation: true
                linearDamping: 0
                fixtures : Box {
                    id: sumbmarinefixer
                    categories: items.submarineCategory
                    collidesWith: items.crowCategory | items.whaleCategory
                    density: 1
                    friction: 0
                    restitution: 0

                }
            }

        }

       Rectangle {
            id: upperGate
            width: background.width/18
            height: background.height - background.height/4 - background.height/3
            y: -2
            color: "#848484"
            border.color: "black"
            border.width: 3
            anchors.right:background.right

            Body{
                id: upperGatebody
                target: upperGate
                bodyType: Body.Static
                sleepingAllowed: true
                fixedRotation: true
                linearDamping: 0

                fixtures: Box {
                    id: upperGatefixer
                    categories: items.upperGatefixerCategory
                    collidesWith: items.submarineCategory
                    density: 1
                    friction: 0
                    restitution: 0
                }

            }

        }

        Rectangle {
            id: lowergate
            width: background.width/18
            height: upperGate.height- subSchematImage.height/1.4
            y: upperGate.height+3
            color: "#848484"
            border.color: "black"
            border.width: 3
            anchors.right:background.right
            Body{
                id: lowerGatebody
                target: upperGate
                bodyType: Body.Static
                sleepingAllowed: true
                fixedRotation: true
                linearDamping: 0

                fixtures: Box {
                    id: lowerGatefixer
                    categories: items.lowerGatefixerCategory
                    collidesWith: items.submarineCategory
                    density: 1
                    friction: 0
                    restitution: 0
                }

            }

        }

        Item {
            id: subSchemaItems

            Image {
                id:subSchematImage
                source: url + "sub_schema.svg"
                width: background.width/1.3
                height: background.height/4
                x: background.width/9
                y: background.height/1.5
            }
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Image {
            id: crown
            source: url + "crown.png"
            z: 1
            //width: background.width/12
            //height: background.height/12
            Body {
                id: crownbody
                target: crown
                bodyType: Body.Static
                sleepingAllowed: true
                fixedRotation: true
                linearDamping: 0

                fixtures: Box {
                    id: crownfixer
                    categories: items.crownCategory
                    collidesWith: items.submarineCategory
                    density: 1
                    friction: 0
                    restitution: 0
                }
            }
        }

        Image {
            id: whale
            source: url + "whale.png"
            z: 1
            //width: background.width/12
            //height: background.height/12
            function imagechange() {
                whale.source = url + "whale_hit.png"
            }

            Body {
                id: whalebody
                target: whale
                bodyType: Body.Static
                sleepingAllowed: true
                fixedRotation: true
                linearDamping: 0

                fixtures: Box {
                    id: whalefixer
                    categories: items.whaleCategory
                    collidesWith: items.submarineCategory
                    density: 1
                    friction: 0
                    restitution: 0
                }
            }
        }



        Bar {
            id: bar
            content: BarEnumContent { value: help | home | level }
            onHelpClicked: {
                displayDialog(dialogHelp)
            }
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: activity.home()
        }

        Bonus {
            id: bonus
            Component.onCompleted: win.connect(Activity.nextLevel)
        }
    }

}
