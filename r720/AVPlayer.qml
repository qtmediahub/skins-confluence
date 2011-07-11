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
import RpcConnection 1.0
import "./components/uiconstants.js" as UIConstants
import MediaModel 1.0

//This serves to isolate import failures if QtMultimedia is not present
FocusScope {
    id: root

    property bool hasMedia: !!mediaItem && mediaItem.source != ""
    property bool playing: hasMedia && mediaItem.playing

    property variant musicEngine : runtime.backend.engine("music")
    property variant videoEngine : runtime.backend.engine("video")

    QtObject {
        id: d
        property bool queuedShow: false
        property bool seeking: false
    }

    function showOSD() {
        if (root.state == "maximized") {
            controlOSD.state = "visible";
        }
    }

    function showVolumeOSD() {
        volumeOSD.state = "visible";
        volumeOSDTimer.restart();
    }

    function play(itemdata, role, depth) {
        if (itemdata != null) {
            playlist.currentIndex = playlist.add(itemdata, role ? role : Playlist.Replace, depth ? depth : Playlist.Recursive)
            playIndex(playlist.currentIndex)
        }
    }

    function playForeground(itemdata, role, depth) { // this now gets uri...
        d.queuedShow = true
        root.play(itemdata, role, depth);
    }

    function playBackground(item, role, depth) {
        root.state = "background";
        root.play(item, role, depth);
    }

    function playNext() {
        playIndex(playlist.next())
    }

    function playPrevious() {
        playIndex(playlist.previous())
    }

    function playIndex(idx) {
        playlist.currentIndex = idx
        mediaItem.stop();
        mediaItem.playbackRate = 1
        mediaItem.source = mediaItem.getMetaData("uri", "file://")
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

    function seekForward() {
        d.seeking = true
        osdInfoTimer.start()
        mediaItem.position += 1000
    }

    function seekBackward() {
        d.seeking = true
        osdInfoTimer.start()
        mediaItem.position -= 1000
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

    function handlePendingShow() {
        d.queuedShow = false
        confluence.show(root)
    }

    Connections {
        target: mediaItem
        onPlayingChanged:
            if (playing && d.queuedShow)
                handlePendingShow()

        onStatusChanged:
            if (d.queuedShow && mediaItem.status == Video.Buffered)
                handlePendingShow()
    }

    // RPC requests
    Connections {
        target: runtime.mediaPlayerRpc
        onStopRequested: root.stop()
        onPauseRequested: root.pause()
        onResumeRequested: root.resume()
        onTogglePlayPauseRequested: root.togglePlayPause()
        onNextRequested: root.playNext()
        onPreviousRequested: root.playPrevious()
        onVolumeUpRequested: root.increaseVolume()
        onVolumeDownRequested: root.decreaseVolume()
        onPlayRemoteSourceRequested: { root.playForeground(uri); mediaItem.seek(position) }
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
            StateChangeScript {
                name: "targetsListFocus"
                script: targetsList.forceActiveFocus()
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

    Keys.onMenuPressed:
        root.state == "targets" ? root.state = "maximized" : confluence.state = ""
    Keys.onEnterPressed:  togglePlayPause()
    Keys.onContext1Pressed: showOSD()
    Keys.onUpPressed: playPrevious()
    Keys.onDownPressed: playNext()
    Keys.onLeftPressed: seekBackward()
    Keys.onRightPressed: seekForward()


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
        interval: runtime.config.value("osd-timeout", 3000)
        running: controlOSD.state == "visible"

        repeat: false
        onTriggered: controlOSD.close()
    }

    Timer {
        id: volumeOSDTimer
        interval: runtime.config.value("osd-timeout", 3000)
        running: volumeOSD.state == "visible"

        repeat: false
        onTriggered: volumeOSD.state = ""
    }

    Timer {
        id: osdInfoTimer
        interval: runtime.config.value("osd-timeout", 3000)

        repeat: false
        onTriggered: d.seeking = false
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

        volume: runtime.config.value("media-volume", 0.1)

        property string thumbnail: getThumbnail()
        property string artist: getMetaData("artist", qsTr("Unknown Artist"))
        property string album: getMetaData("album", qsTr("Unknown Album"))
        property string title: getMetaData("title", qsTr("Unknown Title"))
        property string track: getMetaData("track", "")

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

        function getMetaData(role, defaultValue) {
            return playlist.data(playlist.currentIndex, role) || defaultValue
        }

        function getThumbnail() {
            if (playlist.currentIndex != -1) {
                var thumbnail = playlist.data(playlist.currentIndex, "previewUrl")
                if (thumbnail != "")
                    return thumbnail;
            }
            return hasVideo ? themeResourcePath + "/media/DefaultVideo.png" : themeResourcePath + "/media/DefaultAudio.png";
        }

        function seek(pos) {
            _seekPos = pos
        }

        onPositionChanged: {
            audioVisualisationPlaceholder.metronomTick()
        }

        onVolumeChanged:
            runtime.config.setValue("media-volume", mediaItem.volume)

        function togglePlayPause() {
            if (!mediaItem.playing || mediaItem.paused) {
                mediaItem.play()
            } else {
                mediaItem.pause()
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
        onPlayNext: root.playNext()
        onPlayPrevious: root.playPrevious()
        onSeekBackward: root.seekBackward();
        onSeekForward: root.seekForward();
        onShowTargets: root.state = "targets"
    }

    AVPlayerInfoOSD {
        id: infoOSD
        media: mediaItem
        state: mediaItem.hasVideo && (mediaItem.paused || d.seeking) && root.state == "maximized" ? "visible" : ""
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

    MediaModel {
        id: videoModel
        mediaType: "video"
        structure: "title"
    }

    Dialog {
        id: videoListDialog
        width: parent.width/1.5
        height: parent.height/1.5
        title: qsTr("Videos")
        opacity: 0

        ConfluenceListView {
            id: videoListPanel

            anchors.fill: parent;
            model: videoModel
            clip: true
            focus: true;
            onActivated: {
                root.play(currentItem.itemdata.modelIndex, Playlist.Replace, Playlist.Flat)
                videoListDialog.close()
            }
        }

        Keys.onMenuPressed: videoListDialog.close()
        Keys.onUpPressed: {}
        Keys.onDownPressed: {}
    }

    MediaModel {
        id: musicModel
        mediaType: "music"
        structure: "artist|album|title"
    }

    Dialog {
        id: musicListDialog
        width: parent.width/1.5
        height: parent.height/1.5
        title: qsTr("Music")
        opacity: 0

        ConfluenceListView {
            id: musicListPanel

            anchors.fill: parent;
            model: musicModel
            clip: true
            focus: true;
            onActivated: {
                root.play(currentItem.itemdata.modelIndex, Playlist.Replace, Playlist.Flat)
                videoListDialog.close()
            }
        }

        Keys.onMenuPressed: musicListDialog.close()
        Keys.onUpPressed: {}
        Keys.onDownPressed: {}
    }

    Dialog {
        id: playListDialog
        width: parent.width/1.5
        height: parent.height/1.5
        title: qsTr("Playlist")
        opacity: 0

        ConfluenceListView {
            id: playListPanel
            anchors.fill: parent
            model: playlist

            onActivated: {
                root.playIndex(currentIndex)
                playListDialog.close()
            }

            Keys.onMenuPressed: playListDialog.close()
            Keys.onUpPressed: {}
            Keys.onDownPressed: {}
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
        model: runtime.backend.targetsModel
        opacity: 0

        delegate: Item {
            id: delegateItem
            width: ListView.view.width
            height: sourceText.height + 8

            function action() {
                rpcClient.send(model.address, model.port, mediaItem.source, mediaItem.position)
            }

            Image {
                id: backgroundImage
                anchors.fill: parent;
                source: themeResourcePath + "/media/" + (delegateItem.ListView.isCurrentItem ? "MenuItemFO.png" : "MenuItemNF.png");
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
                onEntered: delegateItem.ListView.view.currentIndex = index
                onClicked: delegateItem.action()
            }

            Keys.onEnterPressed: delegateItem.action()
        }

        Keys.onMenuPressed: mediaItem.forceActiveFocus()
        Keys.onLeftPressed: {}
        Keys.onRightPressed: {}
        Keys.onUpPressed: {}
        Keys.onDownPressed: {}
    }
}

