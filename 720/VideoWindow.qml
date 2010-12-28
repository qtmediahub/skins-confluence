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
import "../components/"

Window {
    id: root

    MediaScanInfo {
        x: 765
        currentPath: videoEngine.pluginProperties.videoModel.currentScanPath
    }

    bladeComponent: MediaWindowBlade {
        id: videoWindowBlade
        parent: root
        visible: true
        z: 1
        actionList: [viewAction, sortByAction]

        resources: [
            // standard actions shared by all views
            ConfluenceAction {
                id: viewAction
                text: qsTr("VIEW")
                options: [qsTr("LIST"), qsTr("POSTER"), qsTr("BIG LIST"), qsTr("THUMBNAIL"), qsTr("PIC THUMBS"), qsTr("IMAGE WRAP")]
                onActivated: videoWindowBlade.viewChanged()
            },
            ConfluenceAction {
                id: sortByAction
                text: qsTr("SORT BY")
                options: [qsTr("NAME"), qsTr("SIZE"), qsTr("DATE")]
                onActivated: videoEngine.pluginProperties.videoModel.sort(viewLoader.item.rootIndex, currentOption())
            }]

        function viewChanged() {
            var viewType = viewAction.currentOption()
            if (viewType == "THUMBNAIL" || viewType == "PIC THUMBS") {
                viewLoader.sourceComponent = thumbnailView
                viewLoader.item.hidePreview = viewType == "PIC THUMBS"
            } else if (viewType == "LIST" || viewType == "BIG LIST") {
                viewLoader.sourceComponent = listView
                viewLoader.item.hidePreview = viewType == "BIG LIST"
            } else if (viewType == "POSTER") {
                viewLoader.sourceComponent = posterView
            }
        }
    }

    Component {
        id: thumbnailView
        MediaThumbnailView {
            engineName: videoEngine.name
            engineModel: videoEngine.pluginProperties.videoModel
            onItemTriggered: videoPlayer.playForeground(itemData)
        }
    }

    Component {
        id: listView
        MediaListView {
            engineName: videoEngine.name
            engineModel: videoEngine.pluginProperties.videoModel
            onItemTriggered: videoPlayer.playForeground(itemData)
        }
    }


    Component {
        id: posterView
        MediaPosterView {
            engineName: videoEngine.name
            engineModel: videoEngine.pluginProperties.videoModel
        }
    }

    Loader {
        id: viewLoader
        focus: true
        anchors.fill: parent
        onStatusChanged: {
            if (viewLoader.status == Loader.Error)
                console.log("Error loading component: " + viewLoader.errorString())
        }
    }

    Component.onCompleted: {
        videoEngine.visualElement = root;
        videoEngine.pluginProperties.videoModel.setThemeResourcePath(themeResourcePath);

        // FIXME: restore from settings
        viewLoader.sourceComponent = listView
        viewLoader.item.engineName = videoEngine.name
        viewLoader.item.engineModel = videoEngine.pluginProperties.videoModel
    }

    Keys.onRightPressed: confluence.showBlade(defaultBlade)
}

