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
import confluence.components 1.0
import "../components/"

Window {
    id: root

    MusicInformationSheet {
        id: musicInformationSheet
    }

    MediaScanInfo {
        x: 765
        currentPath: musicEngine.pluginProperties.musicModel.currentScanPath
    }

    bladeComponent: MediaWindowBlade {
        id: musicWindowBlade
        parent: root
        visible: true
        z: 1
        actionList: [viewAction, sortByAction]

        resources: [
            // standard actions shared by all views
            ConfluenceAction {
                id: viewAction
                text: qsTr("VIEW")
                options: [qsTr("LIST"), qsTr("BIG LIST"), qsTr("THUMBNAIL"), qsTr("PIC THUMBS"), qsTr("IMAGE WRAP")]
                onActivated: musicWindowBlade.viewChanged()
            },
            ConfluenceAction {
                id: sortByAction
                text: qsTr("SORT BY")
                options: [qsTr("NAME"), qsTr("SIZE"), qsTr("DATE")]
                onActivated: musicEngine.pluginProperties.musicModel.sort(viewLoader.item.rootIndex, currentOption())
            }]

        function viewChanged() {
            var viewType = viewAction.currentOption()
            if (viewType == "THUMBNAIL" || viewType == "PIC THUMBS") {
                viewLoader.sourceComponent = thumbnailView
                viewLoader.item.hidePreview = viewType == "PIC THUMBS"
            } else if (viewType == "LIST" || viewType == "BIG LIST") {
                viewLoader.sourceComponent = listView
                viewLoader.item.hidePreview = viewType == "BIG LIST"
            }
        }

        onClosed: if (root.visible) viewLoader.forceActiveFocus()
    }

    Component {
        id: thumbnailView
        MediaThumbnailView {
            engineName: musicEngine.name
            engineModel: musicEngine.pluginProperties.musicModel
            onItemTriggered: avPlayer.playForeground(itemData)
        }
    }

    Component {
        id: listView
        MediaListView {
            engineName: musicEngine.name
            engineModel: musicEngine.pluginProperties.musicModel
            onItemTriggered: avPlayer.playForeground(itemData)
        }
    }

    Loader {
        id: viewLoader
        focus: true
    }

    Component.onCompleted: {
        musicEngine.visualElement = root;
        musicEngine.pluginProperties.musicModel.setThemeResourcePath(themeResourcePath);

        // FIXME: restore from settings
        viewLoader.sourceComponent = listView
        viewLoader.item.engineName = musicEngine.name
        viewLoader.item.engineModel = musicEngine.pluginProperties.musicModel
        viewLoader.item.informationSheet = musicInformationSheet
    }

    Keys.onRightPressed: { blade.open(); blade.forceActiveFocus() }
}

