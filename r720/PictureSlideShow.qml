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

import QtQuick 1.0
import ModelIndexIterator 1.0
import confluence.r720.components 1.0
import Playlist 1.0
import ActionMapper 1.0

FocusScope {
    id: root

    property bool running : false
    property variant currentIndex : 0
    property int interval : 3000

    function showItem(item) {
        showIndex(imagePlayList.add(item, Playlist.Replace, Playlist.Flat))
    }

    function showIndex(idx) {
        root.currentIndex = idx

        imageCrossFader.source = imagePlayList.data(root.currentIndex, Playlist.FilePathRole)
    }

    function next() {
        showIndex(imagePlayList.playNextIndex(root.currentIndex));
    }

    function previous() {
        showIndex(imagePlayList.playPreviousIndex(root.currentIndex));
    }

    function close() {
        root.state = ""
    }

    x: parent.width
    y: parent.height
    width: 0
    height: 0
    visible: false
    opacity: 0

    MouseArea {
        id: consumer
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button == Qt.LeftButton)
                root.next()
            else
                root.previous()

            mouse.accepted = true;
        }
    }

    Keys.onPressed: {
        if (actionmap.eventMatch(event, ActionMapper.Menu))
            root.close()
        else if (actionmap.eventMatch(event, ActionMapper.Context))
            root.running = !root.running
        else if (actionmap.eventMatch(event, ActionMapper.Left))
            root.previous()
        else if (actionmap.eventMatch(event, ActionMapper.Right))
            root.next()
    }

    Timer {
        id: timer
        running: root.running
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

    ImageCrossFader {
        id: imageCrossFader
        fillMode: Image.PreserveAspectCrop
        anchors.fill: parent
    }

    Image {
        id: backToViewButton
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: -backToViewButton.width
        state: root.visible ? "visible" : ""
        source: themeResourcePath + "/media/" + (mr.containsMouse ? "HomeIcon-Focus" : "HomeIcon") + ".png"

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: backToViewButton.anchors
                    margins: 20
                }
            }
        ]

        transitions: [
            Transition {
                ConfluenceAnimation { property: "margins"; }
            }
        ]

        MouseArea {
            id: mr
            hoverEnabled: true
            anchors.fill: parent

            onClicked: {
                root.close();
                mouse.accepted = true;
            }
        }
    }

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: root
                visible: true
                opacity: 1
                x: 0
                y: 0
                width: parent.width
                height: parent.height
            }
        }
    ]

    transitions: [
        Transition {
            to: ""
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; duration: transitionDuration; easing.type: confluence.standardEasingCurve }
                    NumberAnimation { properties: "x,y,width,height"; duration: transitionDuration; easing.type: confluence.standardEasingCurve }
                }
                PropertyAction { target: root; property: "visible"; value: false }
                ScriptAction { script: parent.focalWidget.forceActiveFocus(); }
            }
        },
        Transition {
            from: ""
            to: "visible"
            SequentialAnimation {
                PropertyAction { target: root; property: "anchors.horizontalCenterOffset"; value: 0 }
                PropertyAction { target: root; property: "visible"; value: true }
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; duration: transitionDuration; easing.type: confluence.standardEasingCurve }
                    NumberAnimation { properties: "x,y,width,height"; duration: transitionDuration; easing.type: confluence.standardEasingCurve }
                }
            }
        }
    ]
}

