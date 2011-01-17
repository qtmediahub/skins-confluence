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
import confluence.r720.components 1.0

FocusScope {
    id: root

    property variant media

    signal showMusicMenu()
    signal showVideoMenu()
    signal playNext()
    signal playPrevious()
    signal activity()

    width: parent.width
    height: content.height

    BorderImage {
        id: content
        source: themeResourcePath + "/media/MediaInfoBackUpper.png"

        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -content.height

        ButtonList {
            id: buttonList
            wrapping: true
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

            onActivity:
                root.activity()

            PixmapButton { basePixmap: "OSDBookmarksNF"; focusedPixmap: "OSDBookmarksFO" }
            PixmapButton { basePixmap: "OSDAudioNF"; focusedPixmap: "OSDAudioFO"; onClicked: root.showMusicMenu(); }
            PixmapButton { basePixmap: "OSDVideoNF"; focusedPixmap: "OSDVideoFO"; onClicked: root.showVideoMenu(); }
            Item { width: 100; height: 1; }
            PixmapButton { basePixmap: "OSDPrevTrackNF"; focusedPixmap: "OSDPrevTrackFO"; onClicked: root.playPrevious(); }
            PixmapButton { basePixmap: "OSDRewindNF"; focusedPixmap: "OSDRewindFO"; onClicked: root.decreasePlaybackRate() }
            PixmapButton { basePixmap: "OSDStopNF"; focusedPixmap: "OSDStopFO"; onClicked: media.stop();}
            PixmapButton {
                id: playPauseButton
                basePixmap: !media.playing || media.paused ? "OSDPlayNF" : "OSDPauseNF"
                focusedPixmap: !media.playing || media.paused ? "OSDPlayFO" : "OSDPauseFO"
                onClicked: media.togglePlayPause()
            }
            PixmapButton { basePixmap: "OSDForwardNF"; focusedPixmap: "OSDForwardFO"; onClicked: root.increasePlaybackRate() }
            PixmapButton { basePixmap: "OSDNextTrackNF"; focusedPixmap: "OSDNextTrackFO"; onClicked: root.playNext(); }
            Item { width: 100; height: 1; }
            Item { width: playPauseButton.width; height: 1; }
            PixmapButton { basePixmap: "OSDDvdNF"; focusedPixmap: "OSDDvdFO" }
            PixmapButton { basePixmap: "OSDRecordNF"; focusedPixmap: "OSDRecordFO" }
        }
    }

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: content.anchors
                topMargin: -content.height + buttonList.height + buttonList.anchors.bottomMargin
            }
            StateChangeScript {
                script: {
                    buttonList.resetFocus()
                }
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation { property: "topMargin"; duration: confluence.standardAnimationDuration; easing.type: confluence.standardEasingCurve }
        }
    ]

    function increasePlaybackRate()
    {
        if (media.playbackRate <= 1)
            media.playbackRate = 2
        else if (media.playbackRate != 16)
            media.playbackRate *= 2
    }

    function decreasePlaybackRate()
    {
        if (media.playbackRate >= 1)
            media.playbackRate = -2
        else if (media.playbackRate != -16)
            media.playbackRate *= 2
    }
}
