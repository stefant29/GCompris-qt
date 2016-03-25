/* GCompris - DropTile.qml
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

DropArea {
    id: dragTarget

    property var key
    property alias dropProxy: dragTarget
    property int widthDropArea
    property int heightDropArea

    width: widthDropArea
    height: heightDropArea
    keys: [ key ]

    Rectangle{
        anchors.fill: parent
        color: "transparent"

        Image {
            id: dropRectangle
            anchors.fill: parent
            states: [
                State {
                    when: dragTarget.dropped
                    PropertyChanges {
                        target: dropRectangle
                    }
                }
            ]
        }
    }
}
