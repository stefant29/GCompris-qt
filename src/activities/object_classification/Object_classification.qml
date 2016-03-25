/* GCompris - object_classification.qml
 *
 * Copyright (C) 2016 Ayush Agrawal <ayushagrawal288@gmail.com>
 *
 * Authors:
 *   Ayush Agrawal <ayushagrawal288@gmail.com>
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
import QtGraphicalEffects 1.0
import GCompris 1.0

import "../../core"
import "object_classification.js" as Activity

ActivityBase {
    id: activity

    property string backgroundImage: "qrc:/gcompris/src/activities/menu/resource/background.svg"
    property int numberOfLevels: 2
    property string url: "qrc:/gcompris/src/activities/object_classification/resource/"

    onStart: focus = true
    onStop: {}

    pageComponent: Image {
        id: background
        anchors.fill: parent
        source: backgroundImage

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
            property alias dataset: dataset
            property alias score: score
        }

        Loader{
            id : dataset
            asynchronous: false
        }

        onStart: { Activity.start(items, url, numberOfLevels) }
        onStop: { Activity.stop() }

        GCText {
            id: questionItem
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            fontSize: largeSize
            width: parent.width * 0.9
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.weight: Font.DemiBold
            style: Text.Outline
            styleColor: "black"
            color: "blue"
            text: dataset.item.questionText
        }

        Rectangle {
            id: draggingpanel
            width: background.width - 2 * 10 * ApplicationInfo.ratio
            height: background.height/5
            anchors.top: questionItem.bottom
            anchors.margins: 10 * ApplicationInfo.ratio
            anchors.left: background.left
            color: "transparent"

            Row {
                id: redSource
                anchors.left: parent.left; anchors.top: parent.top
                anchors.margins: 5
                width: parent.width
                height: parent.height

                Repeater {
                    model: dataset.item.tab.length
                    delegate: DragTile { key: dataset.item.tab[index].value
                        source: dataset.item.tab[index].source
                        wd: redSource.width / dataset.item.tab.length
                        ht: redSource.height
                        widthImage: background.width * dataset.item.tab[index].width
                        heightImage: background.height * dataset.item.tab[index].height
                    }
                }
            }
        }
        Row{
            id: droparea
            anchors.top: draggingpanel.bottom
            anchors.bottom: background.bottom
            anchors.margins: 10 * ApplicationInfo.ratio
            width: background.width - 2 * 10 * ApplicationInfo.ratio
            height: 2 * background.height / 5

            Repeater{
                model: dataset.item.dropBox.length
                delegate:Rectangle{
                    id: dropRectangle
                    height: droparea.height - nameArea.height
                    width: droparea.width / dataset.item.dropBox.length
                    color: "transparent"
                    Rectangle{
                        id: dropGrid
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        color: "transparent"
                        width: 3 * dropRectangle.width / 4
                        height: dropRectangle.height / 2
                        border.width: 5

                        Grid {
                            anchors.fill:parent
                            columns: 2

                            Repeater {
                                id: gridRepeater
                                property int innerindex: index
                                model: 4
                                delegate: DropTile {
                                    key: dataset.item.dropBox[gridRepeater.innerindex].value
                                    widthDropArea: dropGrid.width / 2
                                    heightDropArea: dropGrid.height / 2
                                }
                            }
                        }
                    }

                    GCText{
                        id: nameArea
                        anchors.top: dropGrid.bottom
                        anchors.horizontalCenter: dropGrid.horizontalCenter
                        anchors.margins: 10 * ApplicationInfo.ratio
                        text: dataset.item.dropBox[index].name
                    }
                }
            }




            //            Grid {
            //                id: droparea2
            //                anchors.top: redSource.bottom;
            //                anchors.right: draggingpanel.right
            //                anchors.margins: 10 * ApplicationInfo.ratio
            //                width: 64*3
            //                height: 64*3
            //                opacity: 0.5
            //                columns: 3

            //                Repeater {
            //                    model: 9
            //                    delegate: DropTile { key: index }
            //                }
            //            }

            //            ListView {
            //                id: listView
            //                width: parent.width
            //                height: parent.height
            //                orientation: ListView.Horizontal
            //                property int dragItemIndex: -1

            //                model: dataset.item.tab.length

            //                delegate: Item {
            //                    id: delegateItem
            //                    width: listView.width / dataset.item.tab.length
            //                    height: listView.height

            //                    Rectangle {
            //                        id: dragRect
            //                        width: listView.width / dataset.item.tab.length
            //                        height: listView.height
            //                        anchors.horizontalCenter: parent.horizontalCenter
            //                        anchors.verticalCenter: parent.verticalCenter
            //                        color: "transparent"
            //                        border.color: Qt.darker(color)

            //                        Image{
            //                            id: dragImage
            //                            fillMode: Image.PreserveAspectFit
            //                            source:dataset.item.tab[index].source
            //                            anchors.centerIn: dragRect
            //                            width: background.width * dataset.item.tab[index].width
            //                            height: background.height * dataset.item.tab[index].height

            //                            MouseArea {
            //                                id: mouseArea
            //                                anchors.fill: dragImage
            //                                drag.target: dragImage

            //                                drag.onActiveChanged: {
            //                                    if (mouseArea.drag.active) {
            //                                        listView.dragItemIndex = index;
            //                                    }
            //                                    dragImage.Drag.drop();
            //                                }
            //                            }

            //                            states: [
            //                                State {
            //                                    when: dragImage.Drag.active
            //                                    ParentChange {
            //                                        target: dragImage
            //                                        parent: draggingpanel
            //                                    }

            //                                    AnchorChanges {
            //                                        target: dragImage
            //                                        anchors.horizontalCenter: undefined
            //                                        anchors.verticalCenter: undefined
            //                                    }
            //                                }
            //                            ]

            //                            Drag.active: mouseArea.drag.active
            //                            Drag.hotSpot.x: dragImage.width / 2
            //                            Drag.hotSpot.y: dragImage.height / 2
            //                        }
            //                    }
            //                }
            //            }

            //            Rectangle {
            //                id: droppingpanel
            //                width: background.width - 2 * 10 * ApplicationInfo.ratio
            //                height: background.height/5
            //                anchors.top: draggingpanel.bottom
            //                anchors.margins: 10 * ApplicationInfo.ratio
            //                color: "transparent"
            //                border.width: 2
            //                radius: 1




            //                ListView {
            //                    id: listviewdrop
            //                    width: parent.width
            //                    height: parent.height
            //                    orientation: ListView.Horizontal
            //                    property int dragItemIndex: -1

            //                    model: dataset.item.tab.length

            //                    delegate: Item {
            //                        id: delegateItemdrop
            //                        width: listView.width / dataset.item.tab.length
            //                        height: listView.height

            //                        Rectangle {
            //                            id: dropRect
            //                            width: listView.width / dataset.item.tab.length - (dataset.item.tab.length - 1) * 10 * ApplicationInfo.ratio
            //                            height: listView.height
            //                            anchors.centerIn: parent
            //                            border.width: 5
            //                            anchors.horizontalCenter: parent.horizontalCenter
            //                            anchors.verticalCenter: parent.verticalCenter
            //                            anchors.margins: 10 * ApplicationInfo.ratio
            //                            color: "transparent"
            //                            border.color: Qt.darker(color)
            //                            Rectangle{
            //                                id: dropcircle
            //                                anchors.centerIn: dropRect
            //                                width: parent.width > parent.height ? parent.height / 10 : parent.width / 10
            //                                height: width
            //                                radius: width/2
            //                                border.width: 1
            //                                color: "pink"
            //                                border.color: "red"
            //                            }

            //                            Image{
            //                                id: dropimage
            //                                anchors.centerIn: parent
            //                                fillMode: Image.PreserveAspectFit
            //                                width: background.width * dataset.item.tab[listView.dragItemIndex].width
            //                                height: background.height * dataset.item.tab[listView.dragItemIndex].height

            //                                DropArea {
            //                                    id: dropArea
            //                                    anchors.fill: dropRect

            //                                    onDropped: {
            //                                        if(index == dataset.item.tab[listView.dragItemIndex].value)
            //                                        {
            //                                        drag.accepted = true;
            //                                        dropimage.source = dataset.item.tab[index].source
            //                                            dropimage.width =  background.width * dataset.item.tab[index].width
            //                                            dropimage.height = background.height * dataset.item.tab[index].height
            //                                            dropimage.source = dataset.item.tab[index].source
            //                                            drag.source.destroy();
            //                                                            drop.acceptProposedAction()
            //                                        visualModel.items.move(drag.source.visualIndex, delegateRoot.visualIndex)
            //                                                drag.accept (Qt.CopyAction);
            //                                            listView.dragItemIndex = -1;
            //                                            items.score.currentSubLevel++;
            //                                            if (score.currentSubLevel == score.numberOfSubLevels){
            //                                                items.bonus.good("flower");
            //                                                Activity.nextLevel();

            //                                            }
            //                                        }
            //                                    }
            //                                }


            //                            }
            //                        }
            //                    }
            //                }
            //            }
        }

        Score {
            id: score
            visible: true
        }

        //        Image {
        //            id: ok
        //            visible: score.currentSubLevel == score.numberOfSubLevels
        //            source:"qrc:/gcompris/src/core/resource/bar_ok.svg"
        //            sourceSize.width: score.height * 1.5
        //            fillMode: Image.PreserveAspectFit
        //            anchors.right: score.left
        //            anchors.bottom: parent.bottom
        //            anchors.margins: 25 * ApplicationInfo.ratio
        //            MouseArea {
        //                anchors.fill: parent
        //                onClicked: Activity.nextLevel()
        //            }
        //        }

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

        Bonus {
            id: bonus
        }
    }
}
