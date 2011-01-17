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
import QtMultimediaKit 1.1
import confluence.r720.components 1.0
import Playlist 1.0

//This serves to isolate import failures if QtMultimedia is not present
FocusScope {
    id: root

    property bool hasMedia: !!mediaItem && mediaItem.source != ""
    property bool playing: hasMedia && mediaItem.playing

    anchors.fill: parent

    Keys.onPressed: {
        if (event.key == Qt.Key_Escape) {
            if (controlOSD.state != "visible") {
                showOSD();
                event.accepted = true;
            } else {
                //Have to explicitly not accept in order to propagate
                event.accepted = false
            }
        } else if (event.key == Qt.Key_Up) {
            playIndex(playlist.playPreviousIndex(mediaItem.currentIndex));
        } else if (event.key == Qt.Key_Down) {
            playIndex(playlist.playNextIndex(mediaItem.currentIndex));
        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onPositionChanged: showOSD();
        onClicked: root.state == "maximized" ? mediaItem.togglePlayPause() : undefined;
    }

    Timer {
        id: osdTimer
        interval: 3000
        running: controlOSD.state == "visible"

        repeat: false
        onTriggered: controlOSD.state = ""
    }

    Timer {
        id: volumeOSDTimer
        interval: 800
        running: volumeOSD.state == "visible"

        repeat: false
        onTriggered: volumeOSD.state = ""
    }

    Rectangle {
        id: backgroundFiller
        anchors.fill: parent
        color: "black"
    }

    Row {
        id: volumeOSD

        states:
            State {
                name: "visible"
                PropertyChanges {
                    target: volumeOSD.anchors
                    topMargin: 50
                }
            }

        transitions:
            Transition {
                NumberAnimation { property: "topMargin"; duration: confluence.standardAnimationDuration; easing.type: confluence.standardEasingCurve }
            }

        z: background.z + 2

        anchors { right: parent.right; rightMargin: 80; top: parent.top; topMargin: -volumeOSD.height; }

        Image {
            id: volumeImage
            source: themeResourcePath + "/media/VolumeIcon.png"
        }

        ProgressBar {
            anchors.verticalCenter: volumeImage.verticalCenter
            width: confluence.width/10
            mProgress: mediaItem.volume
        }
    }

    Video {
        id: mediaItem

        volume: config.value("media-volume", 0.1)

        property variant currentIndex

        anchors.fill: parent

        onPositionChanged: {
            audioVisualisationPlaceholder.metronomTick()
        }

        onVolumeChanged:
            config.setValue("media-volume", mediaItem.volume)

        function togglePlayPause() {
            if (Math.abs(mediaItem.playbackRate) != 1) {
                mediaItem.play()
                mediaItem.playbackRate = 1
            } else {
                if (!mediaItem.playing || mediaItem.paused) {
                    mediaItem.play()
                    mediaItem.playbackRate = 1
                } else {
                    mediaItem.pause()
                    mediaItem.playbackRate = 1
                }
            }
        }
    }

    AudioVisualisation {
        id: audioVisualisationPlaceholder
        anchors.fill: parent
        visible: !mediaItem.hasVideo
        running: visible && !mediaItem.paused && mediaItem.playing
    }

    AVPlayerControlOSD {
        id: controlOSD
        media: mediaItem
        onActivity:
            osdTimer.restart();

        onShowVideoMenu: showDialog(videoListDialog)
        onShowMusicMenu: showDialog(musicListDialog)
        onPlayNext: playIndex(playlist.playNextIndex(mediaItem.currentIndex));
        onPlayPrevious: playIndex(playlist.playPreviousIndex(mediaItem.currentIndex));
    }

    AVPlayerInfoOSD {
        id: infoOSD
        media: mediaItem
        state: mediaItem.hasVideo && (mediaItem.paused || mediaItem.playbackRate != 1) && root.state == "maximized" ? "visible" : ""
    }

    AudioPlayerInfoSmallOSD {
        id: audioInfoSmallOSD
        media: mediaItem
        state: !mediaItem.hasVideo && mediaItem.playing && root.state != "maximized" ? "visible" : ""
    }

    AudioPlayerInfoBigOSD {
        id: audioInfoBigOSD
        media: mediaItem
        state: !mediaItem.hasVideo && mediaItem.playing && root.state == "maximized" ? "visible" : ""
    }

    Image {
        id: backToHomeButton
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: -backToHomeButton.width
        state: root.state == "maximized" ? "visible" : ""
        source:  themeResourcePath + "/media/" + (mr.containsMouse ? "HomeIcon-Focus" : "HomeIcon") + ".png"

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: backToHomeButton.anchors
                    margins: 20
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { property: "margins"; duration: confluence.standardAnimationDuration; easing.type: confluence.standardEasingCurve }
            }
        ]

        MouseArea {
            id: mr
            hoverEnabled: true
            anchors.fill: parent

            onClicked: {
                confluence.show(mainBlade) // # Evil
            }
        }
    }

    Dialog {
        id: videoListDialog
        width: parent.width/1.5
        height: parent.height/1.5
        title: qsTr("Videos")
        opacity: 0

        MediaSimpleListView {
            id: videoListPanel
            anchors.fill: parent
            engineName: videoEngine.name
            engineModel: videoEngine.pluginProperties.videoModel

            onItemTriggered: {
                root.play(itemData)
                videoListDialog.close()
            }
        }
    }

    Dialog {
        id: musicListDialog
        width: parent.width/1.5
        height: parent.height/1.5
        title: qsTr("Music")
        opacity: 0

        MediaSimpleListView {
            id: musicListPanel
            anchors.fill: parent
            engineName: musicEngine.name
            engineModel: musicEngine.pluginProperties.musicModel

            onItemTriggered: {
                root.play(itemData)
                musicListDialog.close()
            }
        }
    }

    states: [
        State {
            name: "background"
            PropertyChanges {
                target: root
                opacity: 1
                z: 0
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: root
                opacity: 0
                z: -1
            }
        },
        State {
            name: "maximized"
            PropertyChanges {
                target: root
                opacity: 1
                z: 5000
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation { property: "opacity"; duration: confluence.standardAnimationDuration; easing.type: confluence.standardEasingCurve }
            PropertyAnimation { target: controlOSD; property: "state"; to: "" }
            PropertyAnimation { target: infoOSD; property: "state"; to: "" }
        }
    ]

    function showOSD() {
        if (root.state == "maximized") {
            controlOSD.state = "visible";
        }
    }

    function showVolumeOSD() {
        volumeOSD.state = "visible";
        volumeOSDTimer.restart();
    }

    function play(item) {
        if(item == null) {
            mediaItem.play()
        } else {
            mediaItem.currentIndex = playlist.index(playlist.add(item.mediaInfo, Playlist.Replace, Playlist.Recursive))
            playIndex(mediaItem.currentIndex)
        }
    }

    function playForeground(item) {
        root.play(item);
        confluence.show(this)
    }

    function playBackground(item) {
        root.state = "background";
        root.play(item);
    }

    function playIndex(idx) {
        mediaItem.stop();
        mediaItem.currentIndex = idx
        mediaItem.source = playlist.data(idx, Playlist.FilePathRole)
        mediaItem.play();
    }

    function increaseVolume() {
        mediaItem.volume = (mediaItem.volume + 0.02 > 1) ? 1.0 : mediaItem.volume + 0.02
        showVolumeOSD();
    }

    function decreaseVolume() {
        mediaItem.volume = (mediaItem.volume - 0.02 < 0) ? 0.0 : mediaItem.volume - 0.02
        showVolumeOSD();
    }

    function togglePlayPause() {
        mediaItem.togglePlayPause()
    }

    function showDialog(item) {
        var onClosedHandler = function() {
            mediaItem.forceActiveFocus()
            item.closed.disconnect(onClosedHandler)
        }
        item.closed.connect(onClosedHandler)
        item.open()
        item.forceActiveFocus()
    }
}
