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
import QtMultimediaKit 1.1
import "components/"
import Playlist 1.0
import ActionMapper 1.0
import RpcConnection 1.0
import "./components/uiconstants.js" as UIConstants

//This serves to isolate import failures if QtMultimedia is not present
FocusScope {
    id: root

    property bool hasMedia: !!mediaItem && mediaItem.source != ""
    property bool playing: hasMedia && mediaItem.playing

    function showOSD() {
        if (root.state == "maximized") {
            controlOSD.state = "visible";
        }
    }

    function showVolumeOSD() {
        volumeOSD.state = "visible";
        volumeOSDTimer.restart();
    }

    function play(item, role, depth) {
        if(item != null) {
            mediaItem.currentIndex = playlist.add(item, role ? role : Playlist.Replace, depth ? depth : Playlist.Recursive)
            playIndex(mediaItem.currentIndex)
        }
    }

    function playForeground(item, role, depth) {
        root.play(item, role, depth);
        confluence.show(this)
    }

    function playBackground(item, role, depth) {
        root.state = "background";
        root.play(item, role, depth);
    }

    function playNext() {
        playIndex(playlist.playNextIndex(mediaItem.currentIndex));
    }

    function playPrevious() {
        playIndex(playlist.playPreviousIndex(mediaItem.currentIndex));
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

    function stop() {
        mediaItem.stop();
    }

    function pause() {
        mediaItem.pause()
        mediaItem.playbackRate = 1
    }

    function resume() {
        mediaItem.play()
        mediaItem.playbackRate = 1
    }

    function togglePlayPause() {
        mediaItem.togglePlayPause()
    }

    function increasePlaybackRate()
    {
        if (mediaItem.playbackRate <= 1)
            mediaItem.playbackRate = 2
        else if (mediaItem.playbackRate != 16)
            mediaItem.playbackRate *= 2
    }

    function decreasePlaybackRate()
    {
        if (mediaItem.playbackRate >= 1)
            mediaItem.playbackRate = -2
        else if (mediaItem.playbackRate != -16)
            mediaItem.playbackRate *= 2
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

    // RPC requests
    Connections {
        target: mediaPlayerHelper
        onStopRequested: root.stop()
        onPauseRequested: root.pause()
        onResumeRequested: root.resume()
        onTogglePlayPauseRequested: root.togglePlayPause()
        onNextRequested: root.playNext()
        onPreviousRequested: root.playPrevious()
        onVolumeUpRequested: root.increaseVolume()
        onVolumeDownRequested: root.decreaseVolume()
        onPlayRemoteSourceRequested: { root.playForeground(mediaPlayerHelper.mediaInfo); mediaItem.seek(position) }
    }

    anchors.fill: parent

    states: [
        State {
            name: "background"
            PropertyChanges {
                target: root
                opacity: 1
                z: hasMedia && playing ? UIConstants.screenZValues.background : UIConstants.screenZValues.hidden
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: root
                opacity: 0
                z: UIConstants.screenZValues.hidden
            }
        },
        State {
            name: "maximized"
            PropertyChanges {
                target: root
                opacity: 1
                z: UIConstants.screenZValues.window
            }
        },
        State {
            name: "targets"
            PropertyChanges {
                target: root
                opacity: 1
                z: 5000
            }
            PropertyChanges {
                target: targetsList
                opacity: 1
            }
            PropertyChanges {
                target: targetsText
                opacity: 1
            }
            PropertyChanges {
                target: mediaItem
                width: root.width/2.0
                height: root.height/2.0
                x: 0
                y: root.height/2.0 - mediaItem.height/2.0
            }
        }
    ]

    transitions: [
        Transition {
            ConfluenceAnimation { properties: "opacity,x,y,width,height"; }
            PropertyAnimation { target: controlOSD; property: "state"; to: "" }
            PropertyAnimation { target: infoOSD; property: "state"; to: "" }
        }
    ]

    Keys.onPressed: {
        if (actionmap.eventMatch(event, ActionMapper.Menu))
            if (root.state == "targets")
                root.state = "maximized"
            else
                confluence.state = ""
        else if (actionmap.eventMatch(event, ActionMapper.Enter))
            togglePlayPause()
        else if (actionmap.eventMatch(event, ActionMapper.Context))
            showOSD()
        else if (actionmap.eventMatch(event, ActionMapper.Up))
            playPrevious();
        else if (actionmap.eventMatch(event, ActionMapper.Down))
            playNext();
        else if (actionmap.eventMatch(event, ActionMapper.Right))
            increasePlaybackRate();
        else if (actionmap.eventMatch(event, ActionMapper.Left))
            decreasePlaybackRate();
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        property int lastX : 0

        onPositionChanged: {
            if (root.state == "maximized" && pressed && lastX - mouseX  > 100)
                root.state = "targets"
            else if (root.state == "targets" && pressed && mouseX - lastX > 100)
                root.state = "maximized"
            else
                showOSD();
        }
        onClicked: root.state == "maximized" && controlOSD.state != "visible" ? showOSD() : undefined;
        onPressed: lastX = mouseX
    }

    Playlist {
        id: playlist
        playMode: Playlist.Normal
    }

    Timer {
        id: osdTimer
        interval: config.value("osd-timeout", 3000)
        running: controlOSD.state == "visible"

        repeat: false
        onTriggered: controlOSD.state = ""
    }

    Timer {
        id: volumeOSDTimer
        interval: config.value("osd-timeout", 3000)
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
                NumberAnimation { property: "topMargin" }
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

        x: 0
        y: 0
        width: root.width
        height: root.height

        property int _seekPos : -1

        onSeekableChanged : {
            if (seekable && _seekPos != -1) {
                position = _seekPos
                _seekPos = -1
            }
        }

        function seek(pos) {
            _seekPos = pos
        }

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

        onStatusChanged: {
            if (status == Video.EndOfMedia)
                playNext();
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
        onActivity: osdTimer.restart();

        onShowPlayList: showDialog(playListDialog);
        onShowVideoMenu: showDialog(videoListDialog);
        onShowMusicMenu: showDialog(musicListDialog);
        onStop: mediaItem.stop();
        onPlayNext: playIndex(playlist.playNextIndex(mediaItem.currentIndex));
        onPlayPrevious: playIndex(playlist.playPreviousIndex(mediaItem.currentIndex));
        onSeekBackward: decreasePlaybackRate();
        onSeekForward: increasePlaybackRate();
        onShowTargets: root.state = "targets"
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

        width: homeBackdrop.width; height: homeBackdrop.height

        anchors { bottom: parent.bottom; left: parent.left; margins: -backToHomeButton.width }
        state: root.state == "maximized" || root.state == "targets" ? "visible" : ""

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: backToHomeButton.anchors
                    margins: 0
                }
            }
        ]

        transitions: [
            Transition {
                ConfluenceAnimation { property: "margins" }
            }
        ]

        Image {
            id: homeBackdrop
            opacity: 0.1
            anchors.centerIn: parent
            source:  themeResourcePath + "/media/radialgradient60.png"
        }
        Image {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -1
            source:  themeResourcePath + "/media/" + (mr.containsMouse ? "HomeIcon-Focus" : "HomeIcon") + ".png"
        }

        MouseArea {
            id: mr
            hoverEnabled: true
            anchors.fill: parent

            onClicked: root.state == "targets" ? root.state = "maximized" : confluence.show(mainBlade)
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
            engineModel: videoEngine.pluginProperties.model

            onItemTriggered: {
                root.play(itemData.mediaInfo, Playlist.Replace, Playlist.Flat)
                videoListDialog.close()
            }
        }

        Keys.onPressed: {
            if (actionmap.eventMatch(event, ActionMapper.Menu))
                videoListDialog.close()
            else if (actionmap.eventMatch(event, ActionMapper.Up) || actionmap.eventMatch(event, ActionMapper.Down))
                event.accepted = true
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
            engineModel: musicEngine.pluginProperties.model

            onItemTriggered: {
                root.play(itemData.mediaInfo, Playlist.Replace, Playlist.Flat)
                musicListDialog.close()
            }
        }

        Keys.onPressed: {
            if (actionmap.eventMatch(event, ActionMapper.Menu))
                musicListDialog.close()
            else if (actionmap.eventMatch(event, ActionMapper.Up) || actionmap.eventMatch(event, ActionMapper.Down))
                event.accepted = true
        }
    }

    Dialog {
        id: playListDialog
        width: parent.width/1.5
        height: parent.height/1.5
        title: qsTr("Playlist")
        opacity: 0

        MediaSimpleListView {
            id: playListPanel
            anchors.fill: parent
            engineName: qsTr("Playlist")
            engineModel: playlist

            onItemTriggered: {
                root.playIndex(playlist.indexFromMediaInfo(itemData.mediaInfo))
                playListDialog.close()
            }

            Keys.onPressed: {
                if (actionmap.eventMatch(event, ActionMapper.Menu))
                    playListDialog.close()
                else if (actionmap.eventMatch(event, ActionMapper.Up) || actionmap.eventMatch(event, ActionMapper.Down))
                    event.accepted = true
            }
        }
    }

    ConfluenceText {
        id: targetsText
        text: qsTr("Send current Movie to Device")
        opacity: 0
        anchors.horizontalCenter: mediaItem.horizontalCenter
        anchors.bottom: mediaItem.top
        anchors.bottomMargin: 50
    }

    RpcConnection {
        id: rpcClient
        property string source
        property int position

        onClientConnected: {
            rpcClient.call("qmhmediaplayer.playRemoteSource", source, position)
            disconnectFromHost();
        }

        function send(ip, port, src, pos) {
            source = src
            position = pos
            connectToHost(ip, port);
        }
    }

    ConfluenceListView {
        id: targetsList
        width: root.width - mediaItem.width - 50
        height: root.height-100
        anchors.centerIn: undefined
        anchors.left: mediaItem.right
        anchors.leftMargin: 25
        anchors.verticalCenter: mediaItem.verticalCenter
        model: backend.targetsModel
        opacity: 0

        delegate: Item {
            width: ListView.view.width
            height: sourceText.height + 8
            Image {
                id: backgroundImage
                anchors.fill: parent;
                source: themeResourcePath + "/media/" + (ListView.isCurrentItem ? "MenuItemFO.png" : "MenuItemNF.png");
            }
            Text {
                id: sourceText
                anchors.verticalCenter: parent.verticalCenter
                z: 1 // ensure it is above the background
                text: model.display
                font.pointSize: 16
                font.weight: Font.Light
                color: "white"
            }

            MouseArea {
                anchors.fill: parent;
                hoverEnabled: true
                onEntered: ListView.view.currentIndex = index
                onClicked: rpcClient.send(model.address, model.port, mediaItem.source, mediaItem.position)
            }
        }
    }
}

