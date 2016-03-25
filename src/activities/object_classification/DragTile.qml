/* GCompris - DragTile.qml
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
import GCompris 1.0

import "object_classification.js" as Activity

Item {
    id: root
    property var key
    property string source
    property var ht
    property var wd
    property var heightImage
    property var widthImage

    width: wd
    height: ht

    MouseArea {
        id: mouseArea

        width: parent.width
        height: parent.height

        drag.target: tile

        onReleased:{ parent = tile.Drag.target !== null ? tile.Drag.target : root;
            if(parent === tile.Drag.target)
                items.score.currentSubLevel++;
            if (score.currentSubLevel == score.numberOfSubLevels){
                items.bonus.good("flower");
                Activity.nextLevel();
            }
        }

        Image {
            id: tile

            width: root.widthImage
            height: root.heightImage
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            source: root.source

            Drag.keys: [ key ]
            Drag.active: mouseArea.drag.active
            Drag.hotSpot.x: tile.width / 2
            Drag.hotSpot.y: tile.height / 2

            states: State {
                when: mouseArea.drag.active
                ParentChange { target: tile; parent: root }
                AnchorChanges { target: tile; anchors.verticalCenter: undefined; anchors.horizontalCenter: undefined }
            }

        }
    }
}

