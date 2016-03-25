/* GCompris
 *
 * Copyright (C) 2015 Bruno Coudoin <bruno.coudoin@gcompris.net>
 *
 * Authors:
 *   Bruno Coudoin <bruno.coudoin@gcompris.net> (GTK+ version)
 *   Pulkit Gupta <pulkitgenius@gmail.com> (Qt Quick port)
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
import QtQuick 2.0

QtObject {
    property string questionText: qsTr("Drag and Drop the shapes to according to their properties.")
    property variant dropBox : [
        {
            "name": "Cuboid",
            "value": "0"
        },
        {
            "name": "Triangle",
            "value": "1"
        }
    ]
    property variant tab : [
        {
            "source": "qrc:/gcompris/src/activities/object_classification/resource/img/triangle.png",
            "value": "1",
            "height": "0.1",
            "width": "0.1"
        },
        {
            "source": "qrc:/gcompris/src/activities/object_classification/resource/img/cuboid.png",
            "value": "0",
            "height": "0.1",
            "width": "0.1"
        },
        {
            "source": "qrc:/gcompris/src/activities/object_classification/resource/img/cuboid.png",
            "value": "0",
            "height": "0.1",
            "width": "0.1"
        },
        {
            "source": "qrc:/gcompris/src/activities/object_classification/resource/img/triangle.png",
            "value": "1",
            "height": "0.1",
            "width": "0.1"
        },
        {
            "source": "qrc:/gcompris/src/activities/object_classification/resource/img/triangle.png",
            "value": "1",
            "height": "0.1",
            "width": "0.1"
        },
        {
            "source": "qrc:/gcompris/src/activities/object_classification/resource/img/cuboid.png",
            "value": "0",
            "height": "0.1",
            "width": "0.1"
        }
    ]
}
