/****************************************************************************

This file is part of the QtMediaHub project on http://www.gitorious.org.

Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).*
All rights reserved.

Contact:  Nokia Corporation (qt-info@nokia.com)**

You may use this file under the terms of the BSD license as follows:

"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of Nokia Corporation and its Subsidiary(-ies) nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."

****************************************************************************/

import QtQuick 1.1
import "components/"
import Playlist 1.0
import ActionMapper 1.0

FocusScope {
    id: root

    property bool running : false
    property variant currentModelIndex : 0
    property int interval : 3000

    signal closed()

    function setModelIndex(modelIndex) {
        var idx = imagePlayList.add(modelIndex, Playlist.Replace, Playlist.Flat)
        showModelIndex(idx)
    }

    function showModelIndex(modelIndex) {
        root.currentModelIndex = modelIndex
        listView.currentIndex = imagePlayList.row(modelIndex)
    }

    function next() {
        showModelIndex(imagePlayList.playNextIndex(root.currentModelIndex));
    }

    function previous() {
        showModelIndex(imagePlayList.playPreviousIndex(root.currentModelIndex));
    }

    function close() {
        root.state = ""
        root.closed();
    }

    anchors.top: parent.top
    anchors.left: parent.left
    height: parent.height
    width: parent.width
    opacity: 0
    scale: 1
    anchors.topMargin: -height

    states:  [
        State {
            name: "visible"
            PropertyChanges {
                target: root
                opacity: 1
                scale: 1
            }
            PropertyChanges {
                target: root.anchors
                topMargin: 0
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation {
                properties: "opacity, scale, topMargin"
                duration: confluence.standardAnimationDuration
                easing.type: confluence.standardEasingCurve
            }
        }
    ]

    Keys.onPressed: {
        if (actionmap.eventMatch(event, ActionMapper.Menu) || actionmap.eventMatch(event, ActionMapper.Enter)) {
            root.running = false
            root.close()
        } else if (actionmap.eventMatch(event, ActionMapper.Context)) {
            root.running = !root.running
        } else if (actionmap.eventMatch(event, ActionMapper.Left)) {
            root.running = false
            root.previous()
        } else if (actionmap.eventMatch(event, ActionMapper.Right)) {
            root.running = false
            root.next()
        }
    }

    Timer {
        id: timer
        running: root.running && Qt.application.isActive
        repeat: true
        interval: root.interval
        triggeredOnStart: true
        onTriggered: root.next()
    }

    Playlist {
        id: imagePlayList
        playMode: Playlist.Normal
    }

    Rectangle {
        id: blackout
        color: "black"
        anchors.fill: parent
    }

    ListView {
        id: listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        snapMode: ListView.SnapToItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: 1000
        model: imagePlayList
        delegate: Item {
            width: listView.width
            height: listView.height
            Image {
                id: image
                cache: false
                fillMode: Image.PreserveAspectFit
                sourceSize.width: imageThumbnail.width > imageThumbnail.height ? parent.width : 0
                sourceSize.height: imageThumbnail.width <= imageThumbnail.height ? parent.height : 0
                anchors.fill: parent
                source: filePath
                asynchronous: true
            }
            Image {
                id: imageThumbnail
                cache: false
                anchors.fill: image
                fillMode: Image.PreserveAspectFit
                visible: image.status != Image.Ready
                source: previewUrl
            }
        }

        MouseArea {
            id: consumer
            anchors.fill: parent
            onClicked: {
                root.close()
                mouse.accepted = true;
            }
        }
    }
}

