/* GCompris - parachute.js
 *
 *   Copyright (C) 2015 Rajdeep Kaur <rajdeep1994@gmail.com>
 *
 *    Authors:
 *    Bruno Coudoin <bruno.coudoin@gcompris.net> (GTK+ version)
 *    Rajdeep kaur <rajdeep51994@gmail.com> (Qt Quick port)
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

.pragma library
.import QtQuick 2.0 as Quick
.import GCompris 1.0 as GCompris
.import "qrc:/gcompris/src/core/core.js" as Core

var currentLevel = 0
var numberOfLevel = 4
var items
var checkPressed = false
var pressed
var Oneclick
var winlose
var loseflag = false
var minitux = "minitux.svg"
var minituxette = "minituxette.svg"
var parachutetux = "parachute.svg"
var planeWithtux = "tuxplane.svg"
var planeWithouttux = "tuxwithoutplane.svg"
var tuxImageStatus = 1
var flagoutboundry = 0
var flaginboundry = 0
var edgeflag = 0
var tuxfallingblock = false
var velocityY = [80, 90, 90, 90]
var velocityX = 18

function start(items_) {
    items = items_
    currentLevel = 0
    initLevel()
}

function stop() {
    items.loop.stop()
    items.loopcloud.restart()
    items.animationboat.stop()
}

function initLevel() {
    if(loseflag == false) {
       items.bar.level = currentLevel + 1
    }

    if(items.bar.level===1) {
        items.instruction.visible = true
    }
    else {
        items.instruction.visible = false
    }

    checkPressed = false
    winlose = false
    Oneclick = false
    pressed = false
    loseflag = false
    items.helicopter.source = "qrc:/gcompris/src/activities/parachute/resource/" +  planeWithtux
    items.helicopter.visible = true
    items.touch.visible = false
    tuxImageStatus = 0
    flagoutboundry = 0
    flaginboundry = 0
    edgeflag = 0
    items.tux.state = "rest"
    items.random = Math.random();
    items.tux.y = 0
    items.tux.x = 0
    tuxfallingblock = false
    items.ok.visible = false
    items.loop.restart()
    items.tuxX.restart()
    items.loopcloud.restart()
    items.animationboat.restart()
}

function onLose() {
    items.loop.stop()
    items.loopcloud.stop()
    items.animationboat.stop()
    items.tuxX.stop()
    items.bonus.bad("lion")
    items.tux.x = -items.helicopter.width
    items.tux.y = 0
    tuxImageStatus = 0
    items.tuximage.visible = false
    items.tuximage.source = "qrc:/gcompris/src/activities/parachute/resource/" + minitux
    checkPressed = false
    winlose = false
    Oneclick = false
    pressed = false
    loseflag = true
    initLevel()
}

function onWin() {
    items.loop.stop()
    items.loopcloud.stop()
    items.animationboat.stop()
    items.tuxX.stop()
    items.tuximage.visible = false
    checkPressed = false
    winlose = false
    Oneclick = false
    pressed = false
    items.bonus.good("lion");
    items.tux.x = -items.helicopter.width
    items.tux.y = 0
    items.ok.visible = true
    items.tuximage.source = "qrc:/gcompris/src/activities/parachute/resource/" + minitux
}

function nextLevel() {
    if(numberOfLevel <= ++currentLevel ) {
        currentLevel = 0
    }
    onReset();
    initLevel();
}

function previousLevel() {
    if(--currentLevel < 0) {
        currentLevel = numberOfLevel - 1
    }
    onReset();
    initLevel();
}

function onReset() {
    if(items.bar.level === 1 && tuxImageStatus === 1){
        items.instructiontwo.visible = false
    }
    items.tux.state = "finished"
    items.loop.stop()
    items.loopcloud.stop()
    items.animationboat.stop()
    items.tuxX.stop()
    tuxImageStatus = 0
    items.tuximage.visible = false
    items.tuximage.source = "qrc:/gcompris/src/activities/parachute/resource/" + minitux
    checkPressed = false
    winlose = false
    Oneclick = false
    pressed = false
    loseflag = true
    tuxfallingblock = false
    items.tux.x = -items.helicopter.width
    items.tux.y = 0
    initLevel()

}

function steps() {
    switch(items.bar.level) {
        case 1: return 0.6;
        case 2: return 0.7;
        case 3: return 0.8;
        case 4: return 0.85;
    }
}

function steps1() {
    switch(items.bar.level) {
        case 1: return 0.30;
        case 2: return 0.40;
        case 3: return 0.50;
        case 4: return 0.60;
    }
}

function cloudanimation() {
    return items.random
}

function xsteps(){
    if(items.random < 0.5) {
        return 2;
    } else {
        return -0.25;
    }
}
