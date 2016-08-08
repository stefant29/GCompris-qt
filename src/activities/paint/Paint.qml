/* GCompris - paint.qml
 *
 * Copyright (C) 2016 Toncu Stefan <stefan.toncu29@gmail.com>
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
import QtQuick 2.2
import GCompris 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.0
import "../../core"
import "paint.js" as Activity
import "qrc:/gcompris/src/core/core.js" as Core

// TODO1: undo/redo

// TODO2: (optional): Shape creator: press on the canvas to draw lines; at the end, press on the starting point to create a shape

ActivityBase {
    id: activity

    onStart: focus = true
    onStop: {}

    pageComponent: Rectangle {
        id: background
        anchors.fill: parent
        color: "lightblue"
        signal start
        signal stop

        Component.onCompleted: {
            activity.start.connect(start)
            activity.stop.connect(stop)
        }

        property bool started: false

        // When the width / height is changed, paint the last image on the canvas
        onWidthChanged: {
            if (items.background.started) {
                items.widthHeightChanged = true
                Activity.initLevel()
            }
        }
        onHeightChanged:  {
            if (items.background.started) {
                items.widthHeightChanged = true
                Activity.initLevel()
            }
        }

        File {
            id: file
            onError: console.error("File error: " + msg);
        }


        SaveToFilePrompt {
            id: saveToFilePrompt
            z: -1

            onYes: {
                Activity.saveToFile(true)
                if (main.x == 0)
                    load.opacity = 0
                activity.home()
            }
            onNo:  {
                if (main.x == 0)
                    load.opacity = 0
                activity.home()
            }
            onCancel: {
                saveToFilePrompt.z = -1
                saveToFilePrompt.opacity = 0
                main.opacity = 1
            }
        }

        SaveToFilePrompt {
            id: saveToFilePrompt2
            z: -1

            onYes: {
                cancel()
                Activity.saveToFile(true)
                Activity.initLevel()
            }
            onNo:  {
                cancel()
                Activity.initLevel()
            }
            onCancel: {
                saveToFilePrompt2.z = -1
                saveToFilePrompt2.opacity = 0
                main.opacity = 1
            }
        }

        // Add here the QML items you need to access in javascript
        QtObject {
            id: items
            property Item main: activity.main
            property alias background: background
            property alias bar: bar
            property alias bonus: bonus
            property alias canvas: canvas

            property int sizeS: 2
            property color paintColor
            property string toolSelected: "pencil"
            property alias colorTools: colorTools
            property alias rightPannel: rightPannel
            property var urlImage
            property bool next: false
            property bool next2: false
            property bool loadSavedImage: false
            property alias file: file
            property bool initSave: false
            property alias parser: parser
            property alias gridView2: gridView2
            property bool mainAnimationOnX: true
            property bool undoRedo: false
            property int index: 0
            property string patternType: "dot.jpg"
            property bool nothingChanged: true
            property string lastUrl
            property bool widthHeightChanged: false
        }

        JsonParser {
            id: parser
            onError: console.error("Paint: Error parsing JSON: " + msg);
        }

        onStart: { Activity.start(items) }
        onStop: { Activity.stop() }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Bar {
            id: bar
            content: BarEnumContent { value: help | home | reload }
            onHelpClicked: {
                displayDialog(dialogHelp)
            }
            onHomeClicked: {
                if (!items.nothingChanged) {
                    saveToFilePrompt.text = "Do you want to save your painting?"
                    main.opacity = 0.5
                    saveToFilePrompt.opacity = 1
                    saveToFilePrompt.z = 200
                } else {
                    if (main.x == 0)
                        load.opacity = 0
                    activity.home()
                }
            }
            onReloadClicked: {
                if (!items.nothingChanged) {
                    saveToFilePrompt2.text = "Do you want to save your painting before reseting the board?"
                    main.opacity = 0.5
                    saveToFilePrompt2.opacity = 1
                    saveToFilePrompt2.z = 200
                } else {
                    Activity.initLevel()
                }
            }
        }

        Bonus {
            id: bonus
            Component.onCompleted: win.connect(Activity.nextLevel)
        }

        Keys.onPressed: {
            if (event.key == Qt.Key_Escape) {
                if (main.x == 0)
                    load.opacity = 0
            }
        }

        function hideExpandedTools () {
            selectSize.z = -1
            selectSize.opacity = 0

            selectBrush.z = -1
            selectBrush.opacity = 0

            // hide the inputTextFrame
            inputTextFrame.opacity = 0
            inputTextFrame.z = -1
            inputText.text = ""
        }

//        function changeSelectedCoord(object) {
//            var modified = object.mapToItem(background,object.x,object.y)
//            selected.x = modified.x - 1
//            selected.y = object.y + 9 + colorTools.height + colorTools.anchors.margins  // + 9 because of the margins (10)
//        }

        Rectangle {
            id: main
            width: parent.width
            height: parent.height

            color: "lightblue"


            Behavior on x {
                enabled: items.mainAnimationOnX
                NumberAnimation {
                    target: main
                    property: "x"
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
//                PropertyAction {
//                    target: main; property: "opacity"; value: main.x == - background.width ? 0 : 1
//                }
            }

            Behavior on y {
                NumberAnimation {
                    target: main
                    property: "y"
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
            }


//            Rectangle {
//                id: selected
//                color: "#ffb3ff"
//                z: rightPannelFrame.z
//                width: 50; height: 50
//                opacity: 0.8
//            }

            Rectangle {
                id: inputTextFrame
                color: background.color
                width: inputText.width + okButton.width + inputText.height + 10
                height: inputText.height * 1.1
                anchors.centerIn: parent
                radius: height / 2
                z: 1000
                opacity: 0

                TextField {
                    id: inputText
                    anchors.left: parent.left
                    anchors.leftMargin: height / 1.9
                    anchors.verticalCenter: parent.verticalCenter
                    height: 50
                    width: 300
                    placeholderText: qsTr("Type here")
                    font.pointSize: 32
                }

                //ok button
                Image {
                    id: okButton
                    source:"qrc:/gcompris/src/core/resource/bar_ok.svg"
                    sourceSize.height: inputText.height
                    fillMode: Image.PreserveAspectFit
                    anchors.left: inputText.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: inputText.verticalCenter

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        enabled: inputTextFrame.opacity == 1 ? true : false
                        onClicked: {
                            onBoardText.text = inputText.text
                            // hide the inputTextFrame
                            inputTextFrame.opacity = 0
                            inputTextFrame.z = -1

                            // show the text
                            onBoardText.opacity = 1
                            onBoardText.z = 100

                            onBoardText.x = area.realMouseX
                            onBoardText.y = area.realMouseY - onBoardText.height * 0.8

                            // start the movement
                            moveOnBoardText.start()
                        }
                    }
                }
            }


            Rectangle {
                id: canvasBackground
                z: 1
                anchors.fill: parent
                anchors.margins: 8

                color: "green"

                Canvas {
                    id: canvas
                    anchors.fill: parent

                    property real lastX
                    property real lastY


                    // for brush2
                    property var lastPoint
                    property var currentPoint

                    property var ctx
                    property string url: ""

                    Text {
                        id: onBoardText
                        text: ""
                        color: items.paintColor
                        font.family: "sans-serif"
                        // font.pointSize: (ApplicationSettings.baseFontSize + 32) * ApplicationInfo.fontRatio
                        font.pointSize: 100
                        z: -1
                        opacity: 0
                    }


                    function clearCanvas() {
                        // clear all drawings from the board
                        var ctx = getContext('2d')
                        ctx.beginPath()
                        ctx.clearRect(0, 0, canvasBackground.width, canvasBackground.height);

                        paintWhite()
                        canvas.ctx.strokeStyle = "#ffffff"
                    }

                    function paintWhite() {
                        print("painted canvas in white")
                        canvas.ctx = getContext("2d")
                        canvas.ctx.fillStyle = "#ffffff"
                        canvas.ctx.beginPath()
                        canvas.ctx.moveTo(0, 0)
                        canvas.ctx.lineTo(background.width, 0)
                        canvas.ctx.lineTo(background.width, background.height)
                        canvas.ctx.lineTo(0, background.height)
                        canvas.ctx.closePath()
                        canvas.ctx.fill()
                    }

                    onImageLoaded: {
                        // load images from files
                        if (canvas.url != "") {
                            print("url != vid ")
                            canvas.clearCanvas()

                            if (items.loadSavedImage) {
                                canvas.ctx.drawImage(canvas.url, 0, 0, canvas.width, canvas.height)
                            } else {
                                canvas.ctx.drawImage(canvas.url, canvas.width / 2 - canvas.height / 2, 0, canvas.height, canvas.height)
                            }

                            // mark the loadSavedImage as finished
                            items.loadSavedImage = false
                            requestPaint()
                            items.toolSelected = ""
                            print("requestPaint onImageLoaded from FILE      " + items.toolSelected)
                            items.lastUrl = canvas.url
                            unloadImage(canvas.url)
                            items.mainAnimationOnX = true
                            canvas.url = ""

                          // undo and redo
                        } else if (items.undoRedo) {
                            ctx.drawImage(items.urlImage,0,0)
                            requestPaint()
                            print("requestPaint onImageLoaded UNDO REDO ")
                            items.lastUrl = canvas.url
                            unloadImage(items.urlImage)
                            items.undoRedo = false
                        }
                    }

                    function resetShape () {
                        area.currentShape.rotationn = 0
                        area.currentShape.x = 0
                        area.currentShape.y = 0
                        area.currentShape.width = 0
                        area.currentShape.height = 0
                        area.endX = 0
                        area.endY = 0
                        canvas.lastX = 0
                        canvas.lastY = 0
                    }

                    function midPointBtw(p1, p2) {
                      return {
                        x: p1.x + (p2.x - p1.x) / 2,
                        y: p1.y + (p2.y - p1.y) / 2
                      };
                    }

                    function distanceBetween(point1, point2) {
                        return Math.sqrt(Math.pow(point2.x - point1.x, 2) + Math.pow(point2.y - point1.y, 2));
                    }

                    function angleBetween(point1, point2) {
                        return Math.atan2( point2.x - point1.x, point2.y - point1.y );
                    }

                    function getRandomInt(min, max) {
                      return Math.floor(Math.random() * (max - min + 1)) + min;
                    }

                    onPaint: {

                        canvas.ctx = getContext('2d')
                        canvas.ctx.strokeStyle = items.toolSelected == "eraser" ? "#ffffff" :
                                                 items.toolSelected == "pattern" ? ctx.createPattern(Activity.url + items.patternType, 'repeat') :
                                                 items.toolSelected == "brush4" ? "black" :
                                                                                         items.paintColor

                        // remove the shadow effect
                        canvas.ctx.shadowColor = 'rgba(0,0,0,0)'
                        canvas.ctx.shadowBlur = 0
                        canvas.ctx.shadowOffsetX = 0
                        canvas.ctx.shadowOffsetY = 0

//                        print("items.toool         -------------             ",items.toolSelected)
                        if (items.toolSelected == "pencil" || items.toolSelected == "eraser") {
                            canvas.ctx.lineWidth = items.toolSelected == "eraser" ? items.sizeS * 4 : items.sizeS
                            canvas.ctx.lineCap = 'round'
                            canvas.ctx.lineJoin = 'round'

                            canvas.ctx.beginPath()
                            ctx.moveTo(lastX, lastY)
                            lastX = area.mouseX
                            lastY = area.mouseY
                            ctx.lineTo(lastX, lastY)
                            ctx.stroke()
                        } else if (items.toolSelected == "rectangle" || items.toolSelected == "lineShift") {
                            var itemm = area.currentShape
//                            canvas.ctx = getContext("2d")
                            canvas.ctx.fillStyle = items.paintColor
                            canvas.ctx.beginPath()
                            canvas.ctx.moveTo(itemm.x,itemm.y)
                            canvas.ctx.lineTo(itemm.x + itemm.width,itemm.y)
                            canvas.ctx.lineTo(itemm.x + itemm.width,itemm.y + itemm.height)
                            canvas.ctx.lineTo(itemm.x,itemm.y + itemm.height)
                            canvas.ctx.closePath()
                            canvas.ctx.fill()
                            resetShape()
                        } else if (items.toolSelected == "circle") {
                            var itemm = area.currentShape
                            canvas.ctx = canvas.getContext('2d')

                            canvas.ctx.beginPath();
                            canvas.ctx.arc(itemm.x + itemm.width / 2, itemm.y + itemm.width / 2,
                                           itemm.width / 2, 0, 2 * Math.PI, false);
                            canvas.ctx.fillStyle = items.paintColor
                            canvas.ctx.fill();
                            resetShape()
                        } else if (items.toolSelected == "line") {
                            var itemm = area.currentShape
                            canvas.ctx.fillStyle = items.paintColor
                            canvas.ctx.beginPath()

                            var angleRad = (360 - area.currentShape.rotationn) * Math.PI / 180

                            var auxX = items.sizeS * Math.sin(angleRad)
                            var auxY = items.sizeS * Math.cos(angleRad)

                            canvas.ctx.moveTo(itemm.x,itemm.y)
                            canvas.ctx.lineTo(area.endX,area.endY)
                            canvas.ctx.lineTo(area.endX + auxX,area.endY + auxY)
                            canvas.ctx.lineTo(itemm.x + auxX,itemm.y + auxY)
                            canvas.ctx.closePath()
                            canvas.ctx.fill()

                            resetShape()
                        } else if (items.toolSelected == "fill") {
                            canvas.ctx.fillStyle = items.paintColor
                            canvas.ctx.beginPath()
                            canvas.ctx.moveTo(0, 0)
                            canvas.ctx.lineTo(background.width, 0)
                            canvas.ctx.lineTo(background.width, background.height)
                            canvas.ctx.lineTo(0, background.height)
                            canvas.ctx.closePath()
                            canvas.ctx.fill()
                        } else if (items.toolSelected == "text") {
                            canvas.ctx.fillStyle = items.paintColor
//                            canvas.ctx.font = "" + onBoardText.fontSize + "px " + GCSingletonFontLoader.fontLoader.name
                            canvas.ctx.font = "100pt sans-serif"
                            canvas.ctx.fillText(onBoardText.text,area.realMouseX,area.realMouseY)
                            onBoardText.text = ""
                        } else if (items.toolSelected == "tools" ) {
                            canvas.ctx.lineWidth = items.sizeS
                            ctx.lineJoin = ctx.lineCap = 'round'

                            var p1 = Activity.points[0]
                            var p2 = Activity.points[1]

                            if (!p1 || !p2)
                                return

                            ctx.beginPath()
                            ctx.moveTo(p1.x, p1.y)

                            for (var i = 1, len = Activity.points.length; i < len; i++) {
                              var midPoint = midPointBtw(p1, p2)
                              ctx.quadraticCurveTo(p1.x, p1.y, midPoint.x, midPoint.y)
                              p1 = Activity.points[i]
                              p2 = Activity.points[i+1]
                            }
                            ctx.lineTo(p1.x, p1.y)
                            ctx.stroke()
                        } else if (items.toolSelected == "brush2" ) {
                            ctx.lineJoin = ctx.lineCap = 'round'

                            var dist = distanceBetween(lastPoint, currentPoint)
                            var angle = angleBetween(lastPoint, currentPoint)

                            for (var i = 0; i < dist; i++) {
                                var xx = lastPoint.x + (Math.sin(angle) * i) - 25;
                                var yy = lastPoint.y + (Math.cos(angle) * i) - 25;
                                ctx.drawImage(Activity.url + "brush2.png", xx, yy, items.sizeS * 5, items.sizeS * 10);
                            }

                            lastPoint = {x: currentPoint.x, y: currentPoint.y}
                        } else if (items.toolSelected == "pattern" ) {
                            ctx.lineWidth = items.sizeS * 5
                            ctx.lineJoin = ctx.lineCap = 'round'

                            var p1 = Activity.points[0]
                            var p2 = Activity.points[1]

                            if (!p1 || !p2)
                                return

                            ctx.beginPath()
                            ctx.moveTo(p1.x, p1.y)

                            for (var i = 1, len = Activity.points.length; i < len; i++) {
                              var midPoint = midPointBtw(p1, p2);
                              ctx.quadraticCurveTo(p1.x, p1.y, midPoint.x, midPoint.y);
                              p1 = Activity.points[i];
                              p2 = Activity.points[i+1];
                            }
                            ctx.lineTo(p1.x, p1.y);
                            ctx.stroke();
                        } else if (items.toolSelected == "spray" ) {
                            ctx.lineWidth = items.sizeS * 5
                            ctx.lineJoin = ctx.lineCap = 'round'
                            ctx.moveTo(canvas.lastX, canvas.lastY)
                            ctx.fillStyle = items.paintColor

                            for (var i = 50; i--; i >= 0) {
                                var radius = items.sizeS * 5;
                                var offsetX = getRandomInt(-radius, radius);
                                var offsetY = getRandomInt(-radius, radius);
                                ctx.fillRect(canvas.lastX + offsetX, canvas.lastY + offsetY, 1, 1);
                            }
                        } else if (items.toolSelected == "brush3" ) {
                            ctx.lineWidth = items.sizeS * 1.2
                            ctx.lineJoin = ctx.lineCap = 'round';

                            ctx.beginPath();

                            ctx.globalAlpha = 1;
                            ctx.moveTo(lastPoint.x, lastPoint.y);
                            ctx.lineTo(canvas.lastX, canvas.lastY);
                            ctx.stroke();

                            ctx.moveTo(lastPoint.x - 3, lastPoint.y - 3);
                            ctx.lineTo(canvas.lastX - 3, canvas.lastY - 3);
                            ctx.stroke();

                            ctx.moveTo(lastPoint.x - 2, lastPoint.y - 2);
                            ctx.lineTo(canvas.lastX - 2, canvas.lastY - 2);
                            ctx.stroke();

                            ctx.moveTo(lastPoint.x + 2, lastPoint.y + 2);
                            ctx.lineTo(canvas.lastX + 2, canvas.lastY + 2);
                            ctx.stroke();

                            ctx.moveTo(lastPoint.x + 3, lastPoint.y + 3);
                            ctx.lineTo(canvas.lastX + 3, canvas.lastY + 3);
                            ctx.stroke();

                            lastPoint = { x: canvas.lastX, y: canvas.lastY };

                        } else if (items.toolSelected == "brush4"){
                            ctx.lineJoin = ctx.lineCap = 'round'
                            ctx.fillStyle = items.paintColor
                            ctx.lineWidth = items.sizeS / 4
                            for (var i = 0; i < Activity.points.length; i++) {
                              ctx.beginPath();
                              ctx.arc(Activity.points[i].x, Activity.points[i].y, 5 * items.sizeS, 0, Math.PI * 2, false);
                              ctx.fill();
                              ctx.stroke();
                            }
                        } else if (items.toolSelected == "brush5"){
                            ctx.lineJoin = ctx.lineCap = 'round';
                            ctx.lineWidth = 1

                            var p1 = Activity.connectedPoints[0]
                            var p2 = Activity.connectedPoints[1]

                            if (!p1 || !p2)
                                return

                            ctx.beginPath()
                            ctx.moveTo(p1.x, p1.y)

                            for (var i = 1, len = Activity.connectedPoints.length; i < len; i++) {
                              var midPoint = midPointBtw(p1, p2)
                              ctx.quadraticCurveTo(p1.x, p1.y, midPoint.x, midPoint.y)
                              p1 = Activity.connectedPoints[i]
                              p2 = Activity.connectedPoints[i+1]
                            }
                            ctx.lineTo(p1.x, p1.y)
                            ctx.stroke()

                            for (var i = 0; i < Activity.connectedPoints.length; i++) {
                              var dx = Activity.connectedPoints[i].x - Activity.connectedPoints[Activity.connectedPoints.length-1].x;
                              var dy = Activity.connectedPoints[i].y - Activity.connectedPoints[Activity.connectedPoints.length-1].y;
                              var d = dx * dx + dy * dy;

                              if (d < 1000) {
                                ctx.beginPath();
                                ctx.strokeStyle = 'rgba(0,0,0,0.8)';
                                ctx.moveTo( Activity.connectedPoints[Activity.connectedPoints.length-1].x + (dx * 0.1),
                                           Activity.connectedPoints[Activity.connectedPoints.length-1].y + (dy * 0.1));
                                ctx.lineTo( Activity.connectedPoints[i].x - (dx * 0.1),
                                           Activity.connectedPoints[i].y - (dy * 0.1));
                                ctx.stroke();
                              }
                            }
                        } else if (items.toolSelected == "reset"){
                            items.toolSelected = "pencil"
                            items.paintColor = colors[0]
                        } else {
                            print("tool not known, resetting to Pencil")
                            items.toolSelected = "pencil"
                        }
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent


                        hoverEnabled: false
                        property var mappedMouse: mapToItem(parent,mouseX,mouseY)
                        property var currentShape: items.toolSelected == "circle" ? circle : rectangle
                        property var originalX
                        property var originalY
                        property real endX
                        property real endY

                        Timer {
                            id: moveOnBoardText
                            interval: 1
                            repeat: true
                            running: false
                            triggeredOnStart: {
                                onBoardText.x = area.realMouseX
                                onBoardText.y = area.realMouseY - onBoardText.height * 0.8
                            }
                        }

                        property real realMouseX: mouseX
                        property real realMouseY: mouseY

                        onPressed: {

                            if (items.nothingChanged)
                                items.nothingChanged = false

                            background.hideExpandedTools()
                            mappedMouse = mapToItem(parent,mouseX,mouseY)

                            print("tools: ",items.toolSelected)

                            if (items.toolSelected == "rectangle" || items.toolSelected == "circle" || items.toolSelected == "lineShift") {
                                // set the origin coordinates for current shape
                                currentShape.x = mapToItem(parent,mouseX,mouseY).x
                                currentShape.y = mapToItem(parent,mouseX,mouseY).y

                                originalX = currentShape.x
                                originalY = currentShape.y

                                // set the current color for the current shape
                                currentShape.color = items.paintColor
                            } else if (items.toolSelected == "line") {
                                // set the origin coordinates for current shape
                                currentShape.x = mapToItem(parent,mouseX,mouseY).x
                                currentShape.y = mapToItem(parent,mouseX,mouseY).y

                                originalX = currentShape.x
                                originalY = currentShape.y

                                currentShape.height = items.sizeS

                                // set the current color for the current shape
                                currentShape.color = items.paintColor
                            } else if (items.toolSelected == "text") {
                                canvas.lastX = mouseX
                                canvas.lastY = mouseY
                            } else if (items.toolSelected == "tools") {
                                Activity.points.push({x: mouseX, y: mouseY})
                            } else if (items.toolSelected == "brush2") {
                                canvas.currentPoint = { x: mouseX, y: mouseY }
                                canvas.lastPoint = { x: mouseX, y: mouseY }
                            } else if (items.toolSelected == "pattern") {
                                canvas.ctx.strokeStyle = "#ffffff"  // very important!
                                canvas.lastX = mouseX
                                canvas.lastY = mouseY
                                Activity.points.push({x: mouseX, y: mouseY})
                            } else if (items.toolSelected == "spray" ) {
                                canvas.lastX = mouseX
                                canvas.lastY = mouseY
                            } else if (items.toolSelected == "eraser") {
                                canvas.lastX = mouseX
                                canvas.lastY = mouseY
                                canvas.ctx.strokeStyle = "#ffefff"
                                // enable the hover so the points will be closer one to the other
                                area.hoverEnabled = true
                            } else if (items.toolSelected == "pencil"){
                                canvas.lastX = mouseX
                                canvas.lastY = mouseY
                                // enable the hover so the points will be closer one to the other
//                                area.hoverEnabled = true
//                                canvas.ctx.lineCap = 'butt'
//                                canvas.ctx.lineJoin = 'bevel'
                            } else if (items.toolSelected == "brush3"){
                                canvas.lastX = mouseX
                                canvas.lastY = mouseY
                                canvas.lastPoint = { x: mouseX, y: mouseY }
                            } else if (items.toolSelected == "brush4"){
                                canvas.ctx.strokeStyle = "#ffefff"
                                Activity.points.push({x: mouseX, y: mouseY})
                            } else if (items.toolSelected == "brush5"){
                                Activity.connectedPoints.push({x: mouseX, y: mouseY})
                            } else if (items.toolSelected == "blur"){
                                canvas.lastX = mouseX
                                canvas.lastY = mouseY
                            } else {
                                canvas.lastX = mouseX
                                canvas.lastY = mouseY
                                print("ON Pressed - tool not known? ")
                            }
                        }

                        onReleased: {

                            // for line tool
                            mappedMouse = mapToItem(parent,mouseX,mouseY)
                            area.endX = mappedMouse.x
                            area.endY = mappedMouse.y

                            /////////  reset text elements
                            // hide the text
                            onBoardText.opacity = 0
                            onBoardText.z = -1

                            // stop the text following the cursor
                            if (moveOnBoardText.running)
                                moveOnBoardText.stop()

                            // disable hover
                            area.hoverEnabled = false
                            /////////  reset text elements

                            if (items.toolSelected == "rectangle" || items.toolSelected == "circle" ||
                                    items.toolSelected == "line" ||  items.toolSelected == "lineShift") {
                                // paint the rectangle/circle
                                canvas.requestPaint()
                            }

                            if (items.toolSelected == "text" && onBoardText.text != "")
                                canvas.requestPaint()

                            if (items.toolSelected == "tools" ||
                                    items.toolSelected == "pattern" ||
                                    items.toolSelected == "brush4")
                                Activity.points = []

                            if (items.toolSelected == "brush5")
                                Activity.connectedPoints = []


                            // push the state of the current board on UNDO stack
                            items.urlImage = canvas.toDataURL()
                            items.lastUrl = items.urlImage
                            Activity.undo = Activity.undo.concat(items.urlImage)

                            if (Activity.redo.length != 0) {
                                print("     reset  redo")
                                Activity.redo = []
                            }

                            if (items.toolSelected != "circle" &&
                                    items.toolSelected != "rectangle" &&
                                    items.toolSelected != "line" &&
                                    items.toolSelected != "lineShift")
                                items.next = true
                            else items.next = false

                            print("undo:   " + Activity.undo.length + "  redo:  " + Activity.redo.length)

                            area.hoverEnabled = false
                        }

                        onPositionChanged: {
                            /*
                            var ctx = canvas.getContext('2d')
                            ctx.lineWidth = 4
                            ctx.strokeStyle = "red"
                            ctx.beginPath()
                            ctx.moveTo(canvas.lastX, canvas.lastY)
                            canvas.lastX = area.mouseX
                            canvas.lastY = area.mouseY
                            ctx.lineTo(canvas.lastX, canvas.lastY)
                            ctx.stroke()

                            canvas.requestPaint()

                            */

                            if (items.toolSelected == "pencil" || items.toolSelected == "eraser") {
                                canvas.requestPaint()
                            } else if (items.toolSelected == "rectangle") {
//                                currentShape.width = mappedMouse.x - currentShape.x
//                                currentShape.height = mappedMouse.y - currentShape.y
                                mappedMouse = mapToItem(parent,mouseX,mouseY)
                                var width = mappedMouse.x - area.originalX
                                var height = mappedMouse.y - area.originalY

                                if (Math.abs(width) > Math.abs(height)) {
                                    if (width < 0) {
                                        currentShape.x = area.originalX + width
                                        currentShape.y = area.originalY
                                    }
                                    if (height < 0)
                                        currentShape.y = area.originalY + height

                                    currentShape.width = Math.abs(width)
                                    currentShape.height = Math.abs(height)
                                } else {
                                    if (height < 0) {
                                        currentShape.x = area.originalX
                                        currentShape.y = area.originalY + height
                                    }
                                    if (width < 0)
                                        currentShape.x = area.originalX + width

                                    currentShape.height = Math.abs(height)
                                    currentShape.width = Math.abs(width)
                                }
//                                print(currentShape.height + "   " + currentShape.width)
                            } else if (items.toolSelected == "circle") {
                                mappedMouse = mapToItem(parent,mouseX,mouseY)
                                var width = mappedMouse.x - area.originalX
                                var height = mappedMouse.y - area.originalY

                                if (height < 0 && width < 0) {
                                    currentShape.x = area.originalX - currentShape.width
                                    currentShape.y = area.originalY - currentShape.height
                                } else if (height < 0) {
                                    currentShape.x = area.originalX
                                    currentShape.y = area.originalY - currentShape.height
                                } else if (width < 0) {
                                    currentShape.x = area.originalX - currentShape.width
                                    currentShape.y = area.originalY
                                } else {
                                    currentShape.x = area.originalX
                                    currentShape.y = area.originalY
                                }

                                currentShape.height = currentShape.width = Math.max(Math.abs(width), Math.abs(height))
                            } else if (items.toolSelected == "line") {
                                mappedMouse = mapToItem(parent,mouseX,mouseY)
                                var width = mappedMouse.x - area.originalX
                                var height = mappedMouse.y - area.originalY

                                var distance = Math.sqrt( Math.pow(width,2) + Math.pow(height,2) )

                                var p1x = area.originalX
                                var p1y = area.originalY

                                var p2x = area.originalX + 200
                                var p2y = area.originalY

                                var p3x = mappedMouse.x
                                var p3y = mappedMouse.y

                                var p12 = Math.sqrt(Math.pow((p1x - p2x),2) + Math.pow((p1y - p2y),2))
                                var p23 = Math.sqrt(Math.pow((p2x - p3x),2) + Math.pow((p2y - p3y),2))
                                var p31 = Math.sqrt(Math.pow((p3x - p1x),2) + Math.pow((p3y - p1y),2))

                                var angleRad = Math.acos((p12 * p12 + p31 * p31 - p23 * p23) / (2 * p12 * p31))
                                var angleDegrees

                                if (height < 0) {
                                    angleDegrees = angleRad * 180 / Math.PI
//                                    print("===========================>  angleDegrees ", angleDegrees)
                                } else {
                                    angleDegrees = 360 - angleRad * 180 / Math.PI
//                                    print("===========================>  angleDegrees ", angleDegrees)
                                }

                                currentShape.rotationn = 360 - angleDegrees
                                currentShape.width = distance
//                                print(currentShape.height + "   " + currentShape.width)
                            } else if (items.toolSelected == "lineShift") {
                                mappedMouse = mapToItem(parent,mouseX,mouseY)
                                var width = mappedMouse.x - area.originalX
                                var height = mappedMouse.y - area.originalY

                                if (Math.abs(width) > Math.abs(height)) {
                                    if (height < 0)
                                        currentShape.y = area.originalY
                                    if (width < 0) {
                                        currentShape.x = area.originalX + width
                                        currentShape.y = area.originalY
                                    }
                                    currentShape.width = Math.abs(width)
                                    currentShape.height = items.sizeS
                                } else {
                                    if (width < 0)
                                        currentShape.x = area.originalX
                                    if (height < 0) {
                                        currentShape.x = area.originalX
                                        currentShape.y = area.originalY + height
                                    }
                                    currentShape.height = Math.abs(height)
                                    currentShape.width = items.sizeS
                                }
//                                print(currentShape.height + "   " + currentShape.width)
                            } else if (items.toolSelected == "tools") {
                                Activity.points.push({ x: mouseX, y: mouseY })
                                canvas.requestPaint()
                            } else if (items.toolSelected == "brush2") {
                                canvas.currentPoint = { x: mouseX, y: mouseY }
                                canvas.requestPaint()
                            } else if (items.toolSelected == "pattern") {
                                Activity.points.push({x: mouseX, y: mouseY})
                                canvas.requestPaint()
                            } else if (items.toolSelected == "spray" ) {
                                canvas.lastX = mouseX
                                canvas.lastY = mouseY
                                canvas.requestPaint()
                            } else if (items.toolSelected == "brush3" ) {
                                canvas.requestPaint()
                                canvas.lastX = mouseX
                                canvas.lastY = mouseY
                            } else if(items.toolSelected == "brush4" ) {
                                Activity.points.push({x: mouseX, y: mouseY})
                                canvas.requestPaint()
                            } else if(items.toolSelected == "brush5" ) {
                                Activity.connectedPoints.push({x: mouseX, y: mouseY})
                                canvas.requestPaint()
                            } else if (items.toolSelected == "blur") {
                                var ctx = canvas.getContext('2d')
                                ctx.lineJoin = ctx.lineCap = 'round';
                                canvas.ctx.shadowBlur = 10
                                canvas.ctx.shadowColor = items.paintColor
                                ctx.lineWidth = items.sizeS
                                ctx.strokeStyle = items.paintColor
                                ctx.beginPath()
                                ctx.moveTo(canvas.lastX, canvas.lastY)
                                canvas.lastX = area.mouseX
                                canvas.lastY = area.mouseY
                                ctx.lineTo(canvas.lastX, canvas.lastY)
                                ctx.stroke()

                                canvas.requestPaint()
                            }
                        }

                        onClicked: {
                            if (items.toolSelected == "fill") {
                                canvas.requestPaint()
                                print("requestPaint FILL  ")
                            }
                        }
                    }

                    Rectangle {
                        id: rectangle
                        color: items.paintColor
                        enabled: items.toolSelected == "rectangle" || items.toolSelected == "line"|| items.toolSelected == "lineShift"
                        opacity: items.toolSelected == "rectangle" || items.toolSelected == "line"|| items.toolSelected == "lineShift" ? 1 : 0

                        property real rotationn: 0

                        transform: Rotation {
                            id: rotationRect
                            origin.x: 0
                            origin.y: 0
                            angle: rectangle.rotationn
                        }
                    }

                    Rectangle {
                        id: circle
                        radius: width / 2
                        color: items.paintColor
                        enabled: items.toolSelected == "circle"
                        opacity: items.toolSelected == "circle" ? 1 : 0
                        property real rotationn: 0
                    }
                }
            }

            Rectangle {
                id: colorTools
                color: background.color
                height: flow.height + flow.anchors.margins * 2
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                    margins: 0
                }
                z: 2

                Flow {
                    id: flow
                    anchors {
                        left: parent.left
                        top: parent.top
                        right: parent.right
                        margins: 8
                    }

                    spacing: 5

                    // colors in left panel
                    Repeater {
                        id: colorRepeater
                        model: Activity.colors

                        Rectangle {
                            id: root
                            radius: width / 2
                            width: dim - 5 > 50 ?
                                       dim - 5 < 70 ?
                                           dim - 5 : 70 :  60
                            height: width
                            color: modelData
                            property real dim: (background.width - 16) / Activity.colors.length
                            property bool active: items.paintColor === color
                            border.color: active? "#595959" : "#f2f2f2"
                            border.width: 3

                            MouseArea {
                                anchors.fill :parent
                                onDoubleClicked: {
                                    print("choose a color: ")
                                    items.index = index
                                    colorDialog.visible = true
                                }
                                onClicked: {
                                    print("root.width: ",root.width)
                                    root.active = true
                                    items.paintColor = root.color

                                    for (var i = 0; i < colorRepeater.count; i++)
                                        if (i != index)
                                            colorRepeater.itemAt(i).active = false

                                    background.hideExpandedTools()
                                    if (color == "#c2c2d6") {
                                        print("choose a color: ")
                                        items.index = index
                                        colorDialog.visible = true
                                    } else {
                                        items.paintColor = color
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: selectSize
                height: row.height * 1.1
                width: row.width * 1.2

                x: rightPannelFrame.x - width
                y: rightPannelFrame.y - height / 2 + sizeTool.height * 1.5 +
                   rightPannel.spacing * 2 + rightPannel.anchors.topMargin

                radius: width * 0.05
                opacity: 0

                z: 100
                color: "lightblue"

                Row {
                    id: row
                    height: 90

                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 10

                    Thickness { lineSize: 0.15 }
                    Thickness { lineSize: 0.3 }
                    Thickness { lineSize: 0.45 }
                    Thickness { lineSize: 0.6 }
                }
            }

            Rectangle {
                id: selectBrush
                height: row2.height * 1.15
                width: row2.width * 1.05

                x: rightPannelFrame.x - width
                y: rightPannelFrame.y - height / 2 + eraser.height * 3.5 +
                   rightPannel.spacing * 2 + rightPannel.anchors.topMargin

                radius: width * 0.02
                opacity: 0

                z: 100
                color: "lightblue"

                Row {
                    id: row2
                    height: 60

                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 10

                    ToolItem { id: pencil; name: "pencil" }
                    ToolItem {
                        name: "dot"
//                        source:  Activity.url + "dot.jpg"
                        opacity: items.toolSelected == "pattern" && items.patternType == "dot.jpg"  ? 1 : 0.6
                        onClick: {
                            items.toolSelected = "pattern"
                            items.patternType = "dot.jpg"
                        }
                    }
                    ToolItem {
                        name: "pattern2"
//                        source:  Activity.url + "pattern2.png"
                        opacity: items.toolSelected == "pattern" && items.patternType == "pattern2.png"  ? 1 : 0.6
                        onClick: {
                            items.toolSelected = "pattern"
                            items.patternType = "pattern2.png"
                        }
                    }

                    ToolItem { name: "tools"  }
                    ToolItem { name: "brush2" }
                    ToolItem { name: "spray"  }
                    ToolItem { name: "brush3" }
                    ToolItem { name: "brush4" }
                    ToolItem { name: "brush5" }
                    ToolItem { name: "blur"   }
                }
            }

            // tools from the right panel
            Rectangle {
                id: rightPannelFrame
                width: rightPannel.width + rightPannel.anchors.margins * 2
                anchors {
                    right: parent.right
                    top: colorTools.bottom
                    bottom: parent.bottom
                    margins: 0
                }
                z: 3
                color: background.color

                Column {
                    id: rightPannel
                    anchors {
                        right: parent.right
                        top: parent.top
                        margins: 8
                    }

                    spacing: 5

                    // eraser tool
                    Image {
                        id: eraser
                        width: 48; height: 48
                        source: Activity.url + "eraser.svg"
                        opacity: items.toolSelected == "eraser" ? 1 : 0.6

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                items.toolSelected = "eraser"
                                background.hideExpandedTools()
                            }
                        }
                    }

                    property alias sizeTool: sizeTool

                    // select size
                    Image {
                        id: sizeTool
                        width: 48; height: 48
                        source: Activity.url + "size.PNG"
                        opacity: 0.6

                        MouseArea {
                            id: toolArea
                            anchors.fill: parent
                            onClicked: {
                                if (selectSize.opacity == 0) {
                                    sizeTool.opacity = 1
                                    selectSize.opacity = 0.9
                                    selectSize.z = 100
                                }
                                else {
                                    selectSize.opacity = 0
                                    selectSize.z = -1
                                    sizeTool.opacity = 0.6
                                }
                                selectBrush.opacity = 0
                                selectBrush.z = -1
                            }
                        }
                    }


                    ToolItem { name: "fill"; width: 48; height: 48 }

                    /*
                    ToolItem { id: brushSelector; name: items.toolSelected; width: 48; height: 48
                        onClick: {
                            if ( selectBrush.opacity == 0) {
                                selectBrush.opacity = 0.9
                                selectBrush.z = 100
                            } else {
                                selectBrush.opacity = 0
                                selectBrush.z = -1
                            }
                            selectSize.opacity = 0
                            selectSize.z = -1
                        }
                    }
                    */

                    Image {
                        id: brushSelector2
                        width: 48; height: 48
                        source: Activity.url + "pencil.svg"
                        opacity: 0.6

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if ( selectBrush.opacity == 0) {
                                    selectBrush.opacity = 0.9
                                    selectBrush.z = 100
                                } else {
                                    selectBrush.opacity = 0
                                    selectBrush.z = -1
                                }
                                selectSize.opacity = 0
                                selectSize.z = -1
                            }
                        }
                    }

                    // draw a circle
                    Rectangle {
                        width: 48; height: 48
                        radius: width / 2
                        color: items.toolSelected == "circle" ? items.paintColor : "white"
                        border.color: "black"
                        border.width: 2
                        opacity: items.toolSelected == "circle" ? 1 : 0.6

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                items.toolSelected = "circle"
                                background.hideExpandedTools()
                            }
                        }
                    }

                    // draw a rectangle
                    Rectangle { // border of the rectangle
                        width: 48; height: 48
                        color: "transparent"
                        opacity: items.toolSelected == "rectangle" ? 1 : 0.6

                        Rectangle { // actual rectangle
                            width: 42; height: 27
                            border.color: "black"
                            border.width: 2
                            color: items.toolSelected == "rectangle" ? items.paintColor : "white"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                items.toolSelected = "rectangle"
                                background.hideExpandedTools()
                            }
                        }
                    }

                    // draw a line
                    Rectangle { // border of the line
                        width: 48; height: 48
                        color: "transparent"
                        opacity: items.toolSelected == "line" ? 1 : 0.6

                        Rectangle { // actual line
                            width: 42; height: 10
                            rotation: -30
                            border.color: "black"
                            border.width: 2
                            color: items.toolSelected == "line" ? items.paintColor : "grey"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                items.toolSelected = "line"
                                background.hideExpandedTools()
                            }
                        }
                    }

                    // draw a line
                    Rectangle { // border of the line
                        width: 48; height: 48
                        color: "transparent"
                        opacity: items.toolSelected == "lineShift" ? 1 : 0.6

                        Rectangle { // actual line
                            width: 42; height: 10
                            border.color: "black"
                            border.width: 2
                            color: items.toolSelected == "lineShift" ? items.paintColor : "grey"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                items.toolSelected = "lineShift"
                                background.hideExpandedTools()
                            }
                        }
                    }

                    // write text
                    Rectangle { // background of text
                        width: 48; height: 48
                        color: "transparent"
                        opacity: items.toolSelected == "text" ? 1 : 0.6

                        GCText { // text
                            text: "A"
                            color: items.toolSelected == "text" ? items.paintColor : "grey"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                items.toolSelected = "text"
                                background.hideExpandedTools()

                                // enable the text to follow the cursor movement
                                area.hoverEnabled = true

                                // make visible the inputTextFrame
                                inputTextFrame.opacity = 1
                                inputTextFrame.z = 1000

                                // restore input text to ""
                                inputText.text = ""
                            }
                        }
                    }

                    // undo button
                    Image {
                        id: undoButton
                        sourceSize.width: 48
                        sourceSize.height: 48
                        width: 48; height: 48
                        source: Activity.url + "back.svg"
                        opacity: 0.6

                        MouseArea {
                            anchors.fill: parent
                            onPressed: undoButton.opacity = 1
                            onReleased: undoButton.opacity = 0.6
                            onClicked: {
                                background.hideExpandedTools()

                                if (Activity.undo.length > 0 && items.next ||
                                        Activity.undo.length > 1 && items.next == false) {
                                    items.undoRedo = true

                                    //                            if (Activity.undo[Activity.undo.length - 1] == items.urlImage) {
                                    //                            if (Activity.redo.length == 0) {
                                    if (items.next) {
                                        print("items.next: ",items.next)
                                        Activity.redo = Activity.redo.concat(Activity.undo.pop())
                                    }

                                    items.next = false
                                    items.next2 = true

                                    // pop the last image saved from "undo" array
                                    items.urlImage = Activity.undo.pop()

                                    // load the image in the canvas
                                    canvas.loadImage(items.urlImage)

                                    // save the image into the "redo" array
                                    Activity.redo = Activity.redo.concat(items.urlImage)

                                    print("undo:   " + Activity.undo.length + "  redo:  " + Activity.redo.length + "              undo Pressed")
                                }
                            }
                        }
                    }

                    // redo button
                    Image {
                        id: redoButton
                        sourceSize.width: 48
                        sourceSize.height: 48
                        width: 48; height: 48
                        source: Activity.url + "forward.svg"
                        opacity: 0.6

                        MouseArea {
                            anchors.fill: parent
                            onPressed: redoButton.opacity = 1
                            onReleased: redoButton.opacity = 0.6
                            onClicked: {
                                background.hideExpandedTools()

                                if (Activity.redo.length > 0) {
                                    items.undoRedo = true

                                    if (items.next2) {
                                        print("=======items.next: ",items.next)
                                        Activity.undo = Activity.undo.concat(Activity.redo.pop())
                                    }


                                    items.next = true
                                    items.next2 = false

                                    items.urlImage = Activity.redo.pop()

                                    canvas.loadImage(items.urlImage)
                                    Activity.undo = Activity.undo.concat(items.urlImage)

                                    print("undo:   " + Activity.undo.length + "  redo:  " + Activity.redo.length + "              redo Pressed")
                                }
                            }
                        }
                    }

                    // load button
                    Image {
                        id: loadButton
                        sourceSize.width: 48
                        sourceSize.height: 48
                        width: 48; height: 48
                        source: Activity.url + "load.svg"
                        opacity: 0.6

                        MouseArea {
                            anchors.fill: parent
                            onPressed: loadButton.opacity = 1
                            onReleased: loadButton.opacity = 0.6
                            onClicked: {
                                if (load.opacity == 0)
                                    load.opacity = 1

                                background.hideExpandedTools()

                                // mark the pencil as the default tool
                                items.toolSelected = "pencil"

                                // move the main screen to right
                                main.x = background.width
                                print("background.width: ",background.width)
                                print("main.x: ", main.x)
                                print("load pressed")
                            }
                        }
                    }

                    // save button
                    Image {
                        id: saveButton
                        sourceSize.width: 48
                        sourceSize.height: 48
                        width: 48; height: 48
                        source: Activity.url + "save.svg"
                        opacity: 0.6

                        MouseArea {
                            anchors.fill: parent
                            onPressed: saveButton.opacity = 1
                            onReleased: saveButton.opacity = 0.6
                            onClicked: Activity.saveToFile(true)
                        }
                    }
                }
            }
        }

        // load images screen
        Rectangle {
            id: load
            color: "lightblue"
            width: background.width
            height: background.height
            opacity: 0
            z: 5

            anchors {
                top: main.top
                right: main.left
            }

            GridView {
                id: gridView
                anchors.fill: parent
                cellWidth: (background.width - exitButton.width) / 2 * slider1.value; cellHeight: cellWidth
                model: Activity.loadImagesSource

                delegate: Item {
                    width: gridView.cellWidth
                    height: gridView.cellHeight
                    property alias loadImage: loadImage
                    Image {
                        id: loadImage
                        source: modelData
                        anchors.centerIn: parent
                        sourceSize.width: parent.width * 0.7
                        sourceSize.height: parent.height * 0.7
                        width: parent.width * 0.9
                        height: parent.height * 0.9
                        mirror: false
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                canvas.url = loadImage.source
                                canvas.loadImage(loadImage.source)

                                main.x = 0
                            }
                        }
                    }
                }
            }

            Behavior on x {
                NumberAnimation {
                    target: load
                    property: "x"
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
            }


            Behavior on y {
                NumberAnimation {
                    target: load
                    property: "y"
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
            }

            GCButtonCancel {
                id: exitButton
                onClose: {
                    print("onClose")
                    items.mainAnimationOnX = true
                    main.x = 0
                }
            }

            Image {
                id: switchToSavedPaintings
                source: "qrc:/gcompris/src/activities/paint/paint.svg"
                anchors.right: parent.right
                anchors.top: exitButton.bottom
                smooth: true
                sourceSize.width: 60 * ApplicationInfo.ratio
                anchors.margins: 10

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (loadSavedPainting.opacity == 0)
                            loadSavedPainting.opacity = 1

                        items.mainAnimationOnX = false

                        // move down the loadPaintings screen
                        main.y = main.height

                        loadSavedPainting.anchors.left =  load.left

                        // change the images sources from "saved images" to "load images"
                        items.loadSavedImage = true
                    }
                }
            }


            Slider {
                id: slider1
                minimumValue: 0.3
                value: 0.65
                height: parent.height * 0.5
                width: 60

                opacity: 1
                enabled: true

                anchors.right: parent.right
                anchors.rightMargin: switchToSavedPaintings.width / 2 - 10
                anchors.top: switchToSavedPaintings.bottom

                orientation: Qt.Vertical

                style: SliderStyle {
                        handle: Rectangle {
                            height: 80
                            width: height
                            radius: width / 2
                            color: "lightblue"
                        }

                        groove: Rectangle {
                            implicitHeight: slider1.width
                            implicitWidth: slider1.height
                            radius: height / 2
                            border.color: "#6699ff"
                            color: "#99bbff"

                            Rectangle {
                                height: parent.height
                                width: styleData.handlePosition
                                implicitHeight: 100
                                implicitWidth: 6
                                radius: height/2
                                color: "#4d88ff"
                            }
                        }
                    }
            }
        }

        // load screen 2
        Rectangle {
            id: loadSavedPainting
            color: "lightblue"
            width: background.width
            height: background.height
            opacity: 0
            z: 100

            anchors {
                bottom: main.top
                left: load.left
            }

            GCText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: - rightFrame.width / 2
                fontSize: largeSize
                text: "No paintings saved"
                opacity: gridView2.count == 0
            }

            GridView {
                id: gridView2
                anchors.fill: parent
                cellWidth: (main.width - sizeOfImages.width) * slider.value; cellHeight: main.height * slider.value
                flow: GridView.FlowTopToBottom
                z: 1

                delegate: Rectangle {
                    width: gridView2.cellWidth
                    height: gridView2.cellHeight
                    color: "transparent"

                    Image {
                        id: loadImage2
                        source: modelData.url
                        anchors.centerIn: parent
                        sourceSize.width: parent.width
                        sourceSize.height: parent.height
                        width: parent.width * 0.9
                        height: parent.height * 0.9

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                loadSavedPainting.anchors.left =  main.left

                                canvas.url = loadImage2.source
                                canvas.loadImage(loadImage2.source)

                                main.x = 0
                                main.y = 0
                            }
                        }

                        GCButtonCancel {
                            anchors.right: undefined
                            anchors.left: parent.left
                            sourceSize.width: 40 * ApplicationInfo.ratio

                            onClose: {
                                Activity.dataset.splice(index,1)
                                gridView2.model = Activity.dataset
                                Activity.saveToFile(false)
                            }
                        }
                    }
                }
            }

            Behavior on x { NumberAnimation { target: loadSavedPainting; property: "x"; duration: 800; easing.type: Easing.InOutQuad } }

            Behavior on y { NumberAnimation { target: loadSavedPainting; property: "y"; duration: 800; easing.type: Easing.InOutQuad } }


            Rectangle {
                id: rightFrame
                width: sizeOfImages.width + sizeOfImages.anchors.margins * 2
                color: background.color
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                z: 2

                Image {
                    id: sizeOfImages
                    source: "qrc:/gcompris/src/activities/paint/paint.svg"
                    anchors.right: parent.right
                    anchors.top: parent.top
                    smooth: true
                    sourceSize.width: 60 * ApplicationInfo.ratio
                    anchors.margins: 10

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            items.mainAnimationOnX = true

                            // move down the loadPaintings screen
                            main.y = 0

                            // change the images sources from "saved images" to "load images"
                            items.loadSavedImage = false
                        }
                    }
                }

                Slider {
                    id: slider
                    minimumValue: 0.3
                    value: 0.65
                    height: parent.height * 0.5
                    width: 60

                    opacity: 1
                    enabled: true

                    anchors.right: parent.right
                    anchors.rightMargin: sizeOfImages.width / 2 - 10
                    anchors.top: sizeOfImages.bottom

                    orientation: Qt.Vertical

                    style: SliderStyle {
                        handle: Rectangle {
                            height: 80
                            width: height
                            radius: width / 2
                            color: "lightblue"
                        }

                        groove: Rectangle {
                            implicitHeight: slider.width
                            implicitWidth: slider.height
                            radius: height / 2
                            border.color: "#6699ff"
                            color: "#99bbff"

                            Rectangle {
                                height: parent.height
                                width: styleData.handlePosition
                                implicitHeight: 100
                                implicitWidth: 6
                                radius: height/2
                                color: "#4d88ff"
                            }
                        }
                    }
                }
            }
        }

        ColorDialog {
            id: colorDialog
            title: "Please choose a color"
            visible: false

            onAccepted: {
                colorRepeater.itemAt(items.index).color = colorDialog.color
                items.paintColor = colorDialog.color

                //   if you want to save the custom colors for the next session;
                //     update the array from js
                // Activity.colors[items.index] = items.paintColor
                //     then add it to the saved file containing the paintings
                console.log("You chose: " + colorDialog.color)
            }
            onRejected: {
                console.log("Canceled")
            }
        }
    }
}
