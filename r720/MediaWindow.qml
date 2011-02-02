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
import Playlist 1.0

Window {
    id: mediaWindow

    focalWidget: viewLoader
    property Engine mediaEngine
    property Item informationSheet
    property string mediaWindowName: "genericMediaWindow"
    property alias mediaScanPath: mediaScanInfo.currentPath

    function play() {
        var currentItemData = viewLoader.item.currentItem.itemdata
        avPlayer.playForeground(currentItemData, Playlist.Replace, (currentItemData.type == "File") ? Playlist.Flat : Playlist.Recursive);
    }

    function setCurrentView(viewType) {
        var rootIndex
        viewLoader.item ? rootIndex = viewLoader.item.rootIndex : undefined
        if (viewType == qsTr("BIG GRID") || viewType == qsTr("GRID")) {
            viewLoader.changeView(thumbnailView)
            viewLoader.item.hidePreview = viewType == qsTr("BIG GRID")
        } else if (viewType == qsTr("LIST") || viewType == qsTr("BIG LIST")) {
            viewLoader.changeView(listView)
            viewLoader.item.hidePreview = viewType == qsTr("BIG LIST")
        } else if (viewType == qsTr("POSTER")) {
            viewLoader.changeView(posterView)
            viewLoader.item.setPathStyle("linearZoom")
        } else if (viewType == qsTr("AMPHI")) {
            viewLoader.changeView(posterView)
            viewLoader.item.setPathStyle("amphitheatreZoom")
        } else if (viewType == qsTr("CAROUSEL")) {
            viewLoader.changeView(posterView)
            viewLoader.item.setPathStyle("carousel")
        } else if (viewType == qsTr("FLOW")) {
            viewLoader.changeView(posterView)
            viewLoader.item.setPathStyle("coverFlood")
        } else {
            //Default in case we remove their stored preference
            viewLoader.changeView(posterView)
            viewLoader.item.setPathStyle("coverFlood")
        }

        blade.viewAction.currentOptionIndex = blade.viewAction.options.indexOf(viewType)
        config.setValue(mediaWindow.mediaWindowName + "-currentview", viewType)
        viewLoader.item.rootIndex = rootIndex
    }

    function itemActivated(item) {
        console.log("Activated: " + item)
    }

    MediaScanInfo {
        id: mediaScanInfo
        currentPath: mediaEngine.pluginProperties.model.currentScanPath
    }

    bladeComponent: MediaWindowBlade {
        parent: mediaWindow
        visible: true
        property alias viewAction: viewAction

        actionList: [
            ConfluenceAction {
                id: viewAction
                text: qsTr("VIEW")
                options: [qsTr("LIST"), qsTr("BIG LIST"), qsTr("GRID"), qsTr("BIG GRID"), qsTr("POSTER"), qsTr("AMPHI"), qsTr("CAROUSEL"), qsTr("FLOW")]
                onTriggered: mediaWindow.setCurrentView(currentOption)
            },
            ConfluenceAction {
                id: sortByAction
                text: qsTr("SORT BY")
                options: [qsTr("NAME"), qsTr("SIZE"), qsTr("DATE")]
                onTriggered: mediaEngine.pluginProperties.model.sort(viewLoader.item.rootIndex, currentOption)
            } ]
    }

    Component {
        id: thumbnailView
        MediaThumbnailView {
            engineName: mediaEngine.name
            engineModel: mediaEngine.pluginProperties.model
            informationSheet: mediaWindow.informationSheet
        }
    }

    Component {
        id: listView
        MediaListView {
            engineName: mediaEngine.name
            engineModel: mediaEngine.pluginProperties.model
            informationSheet: mediaWindow.informationSheet
        }
    }

    Component {
        id: posterView
        MediaPosterView {
            engineName: mediaEngine.name
            engineModel: mediaEngine.pluginProperties.model
            informationSheet: mediaWindow.informationSheet
        }
    }

    ViewLoader {
        id: viewLoader
        focus: true
        anchors.fill: parent
    }

    Component.onCompleted: {
        mediaEngine.visualElement = mediaWindow;
        setCurrentView(config.value(mediaWindow.mediaWindowName + "-currentview", "POSTER"))
    }
}