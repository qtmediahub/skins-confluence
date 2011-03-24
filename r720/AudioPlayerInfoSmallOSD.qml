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
import "util.js" as Util
import Playlist 1.0

Item {
    id: root

    property variant media

    width: childrenRect.width
    height: childrenRect.height
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.bottomMargin: -childrenRect.height
    anchors.rightMargin: 20

    Row {
        spacing: 20

        Column {
            spacing: 10
            anchors.bottom: parent.bottom

            // TODO should all use real MetaData from our database
            Text {
                text: media.playbackRate == 0 ? qsTr("Now Paused") : qsTr("Now Playing")
                color: "steelblue"
                font.bold: true
                font.pointSize: 16
                anchors.right: parent.right
            }
            Text {
                text: media.metaData.albumArtist ? media.metaData.albumArtist : qsTr("Unknown Artist")
                color: "white"
                font.bold: true
                font.pointSize: 18
                anchors.right: parent.right
            }
            Text {
                text: media.metaData.albumTitle ? media.metaData.albumTitle : qsTr("Unknown Album")
                color: "white"
                font.pointSize: 16
                anchors.right: parent.right
            }
            Text {
                text: media.metaData.title ? media.metaData.title : qsTr("Unknown Title")
                color: "white"
                font.bold: true
                font.pointSize: 20
                anchors.right: parent.right
            }
            Text {
                text: Util.ms2string(media.position) + " / " + Util.ms2string(media.duration)
                color: "white"
                font.pointSize: 16
                anchors.right: parent.right
            }
        }

        BorderImage {
            id: thumbnailBorder
            source: themeResourcePath + "/media/" + "ThumbBorder.png"
            border.left: 10; border.top: 10
            border.right: 10; border.bottom: 10
            width: 256
            height: 256

            Image {
                id: thumbnail
                source: media.currentIndex ? playlist.data(media.currentIndex, Playlist.PreviewUrlRole) : themeResourcePath + "/media/DefaultAlbumCover.png"
                anchors.fill: parent
                anchors.margins: 6

                Image {
                    id: glassOverlay
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width*0.7
                    height: parent.height*0.6
                    source: themeResourcePath + "/media/" + "GlassOverlay.png"
                }
            }
        }
    }

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: root.anchors
                bottomMargin: anchors.rightMargin
            }
        }
    ]

    transitions: [
        Transition {
            ConfluenceAnimation { property: "bottomMargin" }
        }
    ]
}
