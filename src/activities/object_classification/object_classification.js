/* GCompris - object_classification.js
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
.pragma library
.import QtQuick 2.0 as Quick

var currentLevel
var numberOfLevel
var items
var url

function start(items_,url_,levelcount_) {
    items = items_
    url = url_
    numberOfLevel = levelcount_
    currentLevel = 1
    items.score.currentSubLevel = 0
    initLevel()
}

function stop() {
}

function initLevel() {
    items.bar.level = currentLevel
    var filename = url + "board" + "/" + "board" + currentLevel + "_0.qml"
    items.dataset.source = filename
    items.score.currentSubLevel = 0
    items.score.numberOfSubLevels = items.dataset.item.tab.length
}

function nextLevel() {
    if(numberOfLevel < ++currentLevel ) {
        currentLevel = 1
        items.score.currentSubLevel = 0
    }
    initLevel();
}

function previousLevel() {
    if(--currentLevel < 1) {
        currentLevel = numberOfLevel
        items.score.currentSubLevel = 0
    }
    initLevel();
}
