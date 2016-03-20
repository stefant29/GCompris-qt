/* GCompris - parachute.qml
 *
 * Copyright (C) 2015 Rajdeep Kaur <rajdeep51994@gmail.com>
 *
 * Authors:
 *   Bruno Coudoin <bruno.coudoin@gcompris.net> (GTK+ version)
 *   Rajdeep kaur<rajdeep51994@gmail.com> (Qt Quick port)
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
import GCompris 1.0
import QtGraphicalEffects 1.0
import "../../core"
import "qrc:/gcompris/src/core/core.js" as Core
import "parachute.js" as Activity

ActivityBase {
    id: activity

    property real velocityX
    property real velocityY
    
    property string dataSetUrl: "qrc:/gcompris/src/activities/parachute/resource/"
    
    onStart: focus = true
    onStop: {}

    pageComponent: Image {

        id: background
        source: activity.dataSetUrl + "back.svg"
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: parent.width
        anchors.fill: parent

        signal start
        signal stop

        Component.onCompleted: {
            activity.start.connect(start)
            activity.stop.connect(stop)
        }
        
        onStart: {  }
        onStop: { Activity.stop() }

        // Add here the QML items you need to access in javascript
        QtObject {
            id: items
            property Item main : activity.main
            property alias background: background
            property alias animationheli: animationheli
            property alias animationcloud: animationcloud
            property alias bar: bar
            property alias bonus: bonus
            property alias animationboat: animationboat
            property alias keyunable: keyunable
            property alias ok: ok
            property alias loop: loop
            property alias loopcloud: loopcloud
            property alias tuxX: tuxX
            property alias touch: touch
            property alias tux: tux
            property alias tuximage: tuximage
            property alias helicopter: helicopter
            property real  velocityY: velocityY
            property real  random
            property real  downstep

        }

        IntroMessage {
            id:message
            onIntroDone: {
                Activity.start(items)
            }

            intro: [
                qsTr("The red boat moves in the water from left to right."),
                qsTr("Penguin Tux falls off from the plane, to land on the boat safely. "),
                qsTr("The purpose of the game is to determine the exact time when"
                     + "he should fall off from the plane, in order to safely get to the boat. "),
                qsTr("Tux also carries a parachute, that lets him prevent free fall under gravity, that is dangerous."
                     +"Tux falls off when the player left clicks on the plane."),
                qsTr("His speed can be controlled by the player by pressing UP and DOWN arrow keys,"
                     + "such that Tux is saved from falling in water. "),
                qsTr("Help Tux save his life!"+"Otherwise he will die")
            ]
            z: 20

            anchors {
                top: parent.top
                topMargin: 10
                right: parent.right
                rightMargin: 5
                left: parent.left
                leftMargin: 5
            }
        }

        Image {
            source: activity.dataSetUrl + "foreground.svg"
            anchors.bottom: parent.bottom
            sourceSize.width: parent.width

        }

        GCText {
            id: keyunable
            anchors.centerIn: parent
            fontSize: largeSize
            visible: false
            text: qsTr("Control fall speed with up and down arrow keys")
        }


        Image {
            id: helicopter
            source:activity.dataSetUrl + "tuxplane.svg"
            property variant size_levels: [6, 4, 11, 7]
            sourceSize.width: background.width / size_levels[bar.level]
            sourceSize.height: background.height / size_levels[bar.level]
            MouseArea {
                id: mousei
                hoverEnabled: true
                anchors.fill: parent
                onClicked: {
                    if((Activity.Oneclick === false)&&(Activity.tuxfallingblock ===false)) {
                        tuximage.visible = true
                        tux.y = helicopter.y
                        tuxX.stop()
                        helicopter.source = activity.dataSetUrl + Activity.planeWithouttux
                        /*     activity.audioEffects.play(activity.dataSetUrl+"youcannot.wav");
                            sound file is not supporting in linux please do remove it before the merge */
                        Activity.flagoutboundry = 1
                        Activity.tuxImageStatus = 1
                        Activity.flaginboundry  = 1
                        Activity.Oneclick = true;
                        velocityX = Activity.velocityX
                        velocityY = (items.bar.level === 1 ? 30 : items.bar.level === 2 ? 40 : items.bar.level === 3 ? 55 : items.bar.level === 4 ? 80 : 12 )
                        tux.state = "Released"
                    }
                }

            }
            SequentialAnimation {
                id: loop
                loops: Animation.Infinite
                PropertyAnimation {
                    id: animationheli
                    target: helicopter
                    properties: "x"
                    from: -helicopter.width
                    to: background.width
                    duration: (bar.level === 1 ? 20000 : bar.level === 2 ? 16000 : bar.level === 3 ? 12000 : bar.level === 4 ? 10000 : 9000)
                    easing.type: Easing.Linear
                }
            }

            onXChanged: {
                if(Activity.tuxImageStatus === 1 || Activity.tuxImageStatus === 2){
                    if(helicopter.x > (background.width - helicopter.width/2)) {
                        helicopter.visible = false
                    }
                }
            }
        }


        Item {
            id: tux
            width: tuximage.width
            height: tuximage.height
            x: -helicopter.width
            state:"rest"
            Rectangle {
                id: tuximagehover
                width: tuximage.width
                height: tuximage.height
                visible: false
                border.width: 7
                radius: 20
                border.color: "#A80000"
                color: "#500000"
                opacity: 90
            }
            Image {
                id: tuximage
                source: activity.dataSetUrl + Activity.minitux
                visible: false
                property variant size_levels: [8, 8, 9, 7]
                sourceSize.width: background.width / size_levels[bar.level]
                sourceSize.height: background.height / size_levels[bar.level]
                MouseArea {
                    id: tuxmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if(Activity.tuxImageStatus === 1) {
                            if(tuximagehover.visible === true) {
                                tuximagehover.visible = false
                            }
                            tux.state = "Released1"
                            keyunable.visible = true
                            tuximage.source = activity.dataSetUrl + Activity.parachutetux
                            Activity.tuxImageStatus = 2
                            touch.enabled = true
                            items.downstep = (bar.level === 1 ? 0.09 : bar.level === 2 ? 0.1 : bar.level === 3 ? 0.12 : bar.level === 4 ? 0.13 : 9000)

                        }
                    }
                    onEntered: {
                        if(Activity.tuxImageStatus === 1) {
                            tuximagehover.visible = true
                        }
                    }
                    onExited: {
                        tuximagehover.visible = false
                    }
                }
            }

            onYChanged: {
                if( (tux.y > background.height/1.5)&& Activity.tuxImageStatus === 1 ) {
                    activity.audioEffects.play(activity.dataSetUrl + "bubble.wav" )
                    tux.state = "finished"
                    touch.enabled = false
                    Activity.tuxImageStatus = 0
                    Activity.onLose()
                    items.keyunable.visible = false
                }

                if((tux.y>background.height/1.5 && Activity.tuxImageStatus === 2) && ((tux.x>boat.x) && (tux.x<boat.x+boat.width))){
                    tux.state = "finished"
                    touch.enabled = false
                    Activity.tuxImageStatus = 0
                    Activity.tuxfallingblock = true
                    Activity.onWin()
                    items.keyunable.visible = false
                }

                else if((tux.y>background.height/1.5 && Activity.tuxImageStatus === 2) && ((tux.x<boat.x)||(tux.x>boat.x+boat.width))){
                    activity.audioEffects.play(activity.dataSetUrl + "bubble.wav" )
                    tux.state = "finished"
                    touch.enabled = false
                    Activity.tuxImageStatus = 0
                    Activity.onLose()
                    items.keyunable.visible = false
                }

            }

            onXChanged: {
                if(( Activity.flaginboundry === 1 || Activity.flaginboundry === 2)&&(Activity.flagoutboundry === 1||Activity.flagoutboundry)) {

                    if(tux.x > (background.width-tux.width/2)&&(Activity.flagoutboundry!=2)) {
                        Activity.flagoutboundry = 2
                        tux.state = "backedge"
                        velocityX = 500
                        tux.state = "relaxatintal"
                    }


                    if((Activity.flagoutboundry === 2)&&(tux.x <(tux.width/2))) {
                        Activity.flagoutboundry = 1
                        tux.visible = true;
                        velocityX = Activity.velocityX
                        if(Activity.tuxImageStatus ===1) {
                            tux.state="Released"
                        }  else if(Activity.tuxImageStatus === 2) {
                            tux.state="Released1"
                        }
                    }

                    if((tux.x < 0&&Activity.flagoutboundry!=2&&Activity.flaginboundry!=2)) {
                        Activity.flaginboundry = 2
                        tux.state = "initaledge"
                        velocityX = 500
                        tux.state = "relaxatback"
                    }

                    if((Activity.flaginboundry === 2) && (tux.x > background.width-(tux.width/1.5))&&(Activity.flagoutboundry!=2)) {
                        Activity.flaginboundry = 1;
                        tux.visible = true;
                        velocityX = Activity.velocityX
                        if(Activity.tuxImageStatus ===1) {
                            tux.state = "Released"
                        } else if(Activity.tuxImageStatus === 2) {
                            tux.state = "Released1"
                        }
                    }

                }

            }


            SequentialAnimation {
                id: tuxX
                loops: Animation.Infinite
                PropertyAnimation {
                    target: tux
                    properties: "x"
                    from: -helicopter.width
                    to: background.width
                    duration: (bar.level === 1 ? 20000 : bar.level === 2 ? 16000 : bar.level === 3 ? 12000 : bar.level === 4 ? 10000 : 9000)
                }
            }

            states: [
                State{
                    name:"rest"
                    PropertyChanges {
                        target: tux
                        y:helicopter.y


                    }
                },

                State {
                    name: "UpPressed"
                    PropertyChanges {
                        target: tux
                        y:(tux.y + .02)
                        x:(tux.x + Activity.xsteps())
                    }

                },
                State {
                    name: "DownPressed"
                    PropertyChanges {
                        target: tux
                        y:(tux.y + items.downstep)
                        x:(tux.x + Activity.xsteps())
                    }
                },
                State {
                    name: "Released"
                    PropertyChanges {
                        target:tux
                        y:(tux.y + Activity.steps())
                        x:(tux.x + Activity.xsteps())
                    }

                },
                State{
                    name:"Released1"
                    PropertyChanges {
                        target: tux
                        y:(tux.y + Activity.steps1())
                        x:(tux.x + Activity.xsteps() )
                    }

                },

                State {
                    name: "finished"
                    PropertyChanges {
                        target: tux
                    }
                },

                State {
                    name:"backedge"
                    PropertyChanges {
                        target: tux
                        visible:false
                        y:tux.y
                        x:tux.x-10
                    }
                },

                State {
                    name: "relaxatintal"
                    PropertyChanges {
                        target: tux
                        visible:false
                        y:tux.y
                        x:tux.width/3
                    }
                },

                State {
                    name: "initaledge"
                    PropertyChanges {
                        target: tux
                        visible:false
                        y:tux.y
                        x:tux.x-10
                    }
                },

                State {
                    name: "relaxatback"
                    PropertyChanges {
                        target: tux
                        visible:false
                        y:tux.y
                        x:background.width-(tux.width/2)
                    }
                }


            ]

            transitions: [
                Transition {
                    from: "backedge"
                    to: "relaxatintal"
                    NumberAnimation { properties:"x"; duration:10   }

                },
                Transition {
                    from: "initaledge"
                    to: "relaxatback"
                    NumberAnimation { properties:"x"; duration:10   }

                }
            ]

            Behavior on x {
                SmoothedAnimation { velocity: Activity.velocityX  }
            }
            Behavior on y {
                id:soomthvelocityy
                SmoothedAnimation { velocity: Activity.velocityY[bar.level-1] }
            }


        }

        Keys.onReleased: {
            if(Activity.tuxImageStatus === 1 && Activity.flagoutboundry != 2 && Activity.flaginboundry != 2) {
                velocityY = Activity.velocityY[bar.level-1]
                tux.state = "Released"

            } else if(Activity.tuxImageStatus === 2 && Activity.flagoutboundry != 2 && Activity.flaginboundry != 2) {
                velocityY = Activity.velocityY[bar.level-1]
                tux.state = "Released1"
            }

        }

        Keys.onUpPressed: {
            if(Activity.tuxImageStatus === 2 && Activity.flagoutboundry !=2 && Activity.flaginboundry != 2) {
                tux.state = "UpPressed"
                velocityY = velocityY/2
            }
        }

        Keys.onDownPressed: {

            if(Activity.tuxImageStatus === 2 && Activity.flagoutboundry != 2 && Activity.flaginboundry != 2) {
                tux.state = "DownPressed"
                velocityY = velocityY*0.2
                items.downstep = items.downstep + 0.02
            }


        }

        MultiPointTouchArea {
            id:touch
            anchors.fill:parent
            enabled:false
            touchPoints: [ TouchPoint { id: point1 } ]
            onPressed:  {
                if( Activity.flagoutboundry != 2 && Activity.flaginboundry != 2) {
                    if(Activity.tuxImageStatus === 2) {
                        if(point1.y < tux.y ) {
                            tux.state = "UpPressed"
                            velocityY = velocityY/2
                        }
                        else {
                            tux.state = "DownPressed"
                            velocityY = velocityY*0.8
                            items.downstep = items.downstep + 0.8
                        }
                    }
                }

            }
            onReleased: {
                if( Activity.flagoutboundry != 2 && Activity.flaginboundry != 2) {
                    if(Activity.tuxImageStatus === 1) {
                        velocityY = Activity.velocityY[bar.level-1]
                        tux.state = "Released"

                    } else if(Activity.tuxImageStatus === 2) {
                        velocityY = Activity.velocityY[bar.level-1]
                        tux.state = "Released1"
                    }

                }
            }
        }

        Item {
            id: cloudmotion
            width: cloud.width
            height: height.height

            Image {
                id: cloud
                source: activity.dataSetUrl + "cloud.svg"
                y: background.height/7
                property variant size_levels: [8, 9, 9.6, 10]
                sourceSize.width: background.width / size_levels[bar.level]
                sourceSize.height: background.height / size_levels[bar.level]
            }
            SequentialAnimation {
                id:loopcloud
                loops: Animation.Infinite
                PropertyAnimation {
                    id: animationcloud
                    target: cloudmotion
                    properties: "x"
                    from:items.random > 0.5 ?  background.width : -cloud.width
                    to:animationcloud.from === background.width ? -cloud.width : background.width
                    duration: (bar.level === 1 ? 19000 : bar.level === 2 ? 15000 : bar.level === 3 ? 11000 : bar.level === 4 ? 9000 : 9000)
                    easing.type: Easing.Linear
                }
            }
        }

        Item{
            id:boatmotion
            Image {
                id: boat
                property variant widthboat:[4,4.5,5,3]
                source: activity.dataSetUrl + "fishingboat.svg"
                y: background.height/1.3
                sourceSize.width: background.width/widthboat[bar.level-1]
                sourceSize.height: background.height/4

                PropertyAnimation {
                    id: animationboat
                    target: boat
                    properties: "x"
                    from: -boat.width
                    to: background.width * 0.5
                    duration: (bar.level === 1 ? 24000 : bar.level === 2 ? 20500 : bar.level === 3 ? 19000 : bar.level === 4 ? 17000 : 9000)
                    easing.type: Easing.Linear
                    onRunningChanged: {
                        boat.x = Qt.binding(function() { return animationboat.to })
                        if(boat.x < animationboat.to ){
                            boatmotion.state = "yless"
                        }
                        else {
                            boatmotion.state = "normal"
                        }
                    }
                }


            }
            states:[
                State {
                    name: "yless"
                    PropertyChanges {
                        target:boat
                        y:boat.y-0.1
                    }
                },
                State {
                    name: "normal"
                    PropertyChanges {
                        target:boat


                    }
                }
            ]
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
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

        BarButton {
            id: ok
            source: "qrc:/gcompris/src/core/resource/bar_ok.svg";
            sourceSize.width: 75 * ApplicationInfo.ratio
            visible: false
            anchors.right: background.right
            onClicked: {
                Activity.loseflag = true
                Activity.nextLevel()
            }
        }

        Bonus {
            id: bonus
            onWin: ok.visible = true
        }

    }

}

