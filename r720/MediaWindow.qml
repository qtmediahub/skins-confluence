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

import Qt.labs.shaders 1.0
import Qt.labs.shaders.effects 1.0

Window {
    id: mediaWindow

    focalWidget: viewLoader

    signal itemActivated(variant mediaItem)
    signal itemSelected(variant mediaItem)
    property alias view: viewLoader.item
    property variant mediaEngine
    property Item informationSheet
    property string mediaWindowName: "genericMediaWindow"
    property alias mediaScanPath: mediaScanInfo.currentPath

    function play() {
        var currentItemData = view.currentItem.itemdata
        avPlayer.playForeground(currentItemData, Playlist.Replace, (currentItemData.type == "File") ? Playlist.Flat : Playlist.Recursive);
    }

    function setCurrentView(viewType) {
        var rootIndex
        view ? rootIndex = view.rootIndex : undefined
        if (viewType == qsTr("BIG GRID") || viewType == qsTr("GRID")) {
            viewLoader.changeView(thumbnailView)
            view.hidePreview = viewType == qsTr("BIG GRID")
        } else if (viewType == qsTr("LIST") || viewType == qsTr("BIG LIST")) {
            viewLoader.changeView(listView)
            view.hidePreview = viewType == qsTr("BIG LIST")
        } else if (viewType == qsTr("POSTER")) {
            viewLoader.changeView(posterView)
            view.setPathStyle("linearZoom")
        } else if (viewType == qsTr("AMPHI")) {
            viewLoader.changeView(posterView)
            view.setPathStyle("amphitheatreZoom")
        } else if (viewType == qsTr("CAROUSEL")) {
            viewLoader.changeView(posterView)
            view.setPathStyle("carousel")
        } else if (viewType == qsTr("FLOW")) {
            viewLoader.changeView(posterView)
            view.setPathStyle("coverFlood")
        } else {
            //Default in case we remove their stored preference
            viewLoader.changeView(posterView)
            view.setPathStyle("POSTER")
        }

        blade.viewAction.currentOptionIndex = blade.viewAction.options.indexOf(viewType)
        runtime.config.setValue(mediaWindow.mediaWindowName + "-currentview", viewType)
        view.rootIndex = rootIndex
        view.selectFirstItem()
    }

    function setGroupBy(attribute) {
        var index = blade.groupByAction.options.indexOf(attribute)
        blade.groupByAction.currentOptionIndex = index
        runtime.config.setValue(mediaWindow.mediaWindowName + "-group-by", attribute)
        mediaEngine.model.groupBy(index)
    }

    onItemSelected:
        waveLayer.visible = false

    onItemActivated: {
        if (!confluence.shroomfluence)
            return
        waveAnim.stop()
        var scenePos = confluence.mapFromItem(mediaItem.parent, mediaItem.x + mediaItem.width/2, mediaItem.y + mediaItem.height/2)
        waveLayer.waveOriginX = scenePos.x/confluence.width
        waveLayer.waveOriginY = scenePos.y/confluence.height
        waveLayer.visible = true
        waveAnim.start()
    }

    function visibleTransitionFinished() {
        if (mediaEngine.model.rowCount() < 1) 
            confluence.showModal(addMediaSourceDialog)
    }

    ShaderEffectSource {
        id: viewSource
        sourceItem: view
        live: false
        hideSource: true
    }

    RadialWaveEffect {
        id: waveLayer
        visible: false
        anchors.fill: parent;
        source: viewSource

        wave: 0.0
        waveOriginX: 0.5
        waveOriginY: 0.5
        waveWidth: 0.01

        NumberAnimation on wave {
            id: waveAnim
            running: waveLayer.visible
            easing.type: "InQuad"
            from: 0.0000; to: 1.0000;
            duration: 2500
        }
    }

    Connections {
        target: addMediaSourceDialog
        onRejected: if (mediaEngine.model.rowCount() < 1) confluence.show(mainBlade)
    }

    MediaScanInfo {
        id: mediaScanInfo
        currentPath: mediaEngine.model.currentScanPath
    }

    bladeComponent: MediaWindowBlade {
        property alias viewAction: viewAction
        property alias groupByAction: groupByAction

        parent: mediaWindow
        visible: true
        defaultBladeActionIndex: 1

        actionList: [
            ConfluenceAction {
                id: rootAction
                text: qsTr("Go to root")
                onTriggered: view.rootIndex = undefined
            },
            ConfluenceAction {
                id: viewAction
                text: qsTr("VIEW")
                options: [qsTr("LIST"), qsTr("BIG LIST"), qsTr("GRID"), qsTr("BIG GRID"), qsTr("POSTER"), qsTr("AMPHI"), qsTr("CAROUSEL"), qsTr("FLOW")]
                onTriggered: mediaWindow.setCurrentView(currentOption)
                enabled: options.length > 1
            },
            ConfluenceAction {
                id: sortByAction
                text: qsTr("SORT BY")
                options: [qsTr("NAME"), qsTr("SIZE"), qsTr("DATE")]
                onTriggered: mediaEngine.model.sort(view.rootIndex, currentOption)
                enabled: options.length > 1
            },
            ConfluenceAction {
                id: groupByAction
                text: qsTr("GROUP BY")
                options: mediaEngine.model.groupByOptions ? mediaEngine.model.groupByOptions() : ["None"]
                onTriggered: mediaWindow.setGroupBy(currentOption)
                enabled: options.length > 1
            },
            ConfluenceAction {
                id: addNewSourceAction
                text: qsTr("Add New Source")
                onTriggered: confluence.showModal(addMediaSourceDialog)
            },
            ConfluenceAction {
                id: removeAction
                text: qsTr("Remove Source")
                onTriggered: mediaEngine.model.removeSearchPath(view.currentIndex)
                enabled: !!view.currentItem && view.currentItem.itemdata.type == "SearchPath"
            },
            ConfluenceAction {
                id: rescanAction;
                text: qsTr("Rescan Source");
                onTriggered: mediaEngine.model.rescan(view.currentIndex)
                enabled: !!view.currentItem && view.currentItem.itemdata.type == "SearchPath"
            },
            ConfluenceAction {
                id: playAction;
                text: qsTr("Play");
                onTriggered: root.play()
            },
            ConfluenceAction {
                id: informationAction
                text: qsTr("Show Info")
                onTriggered: viewLoader.item.showInformationSheet()
                enabled: !!view.currentItem && view.currentItem.itemdata.type == "File"
            }
        ]
    }

    Component {
        id: thumbnailView
        MediaThumbnailView {
            engineName: mediaEngine.name
            engineModel: mediaEngine.model
            informationSheet: mediaWindow.informationSheet
        }
    }

    Component {
        id: listView
        MediaListView {
            engineName: mediaEngine.name
            engineModel: mediaEngine.model
            informationSheet: mediaWindow.informationSheet
        }
    }

    Component {
        id: posterView
        MediaPosterView {
            engineName: mediaEngine.name
            engineModel: mediaEngine.model
            informationSheet: mediaWindow.informationSheet
        }
    }

    ViewLoader {
        id: viewLoader
        focus: true
        anchors.fill: parent
    }

    AddMediaSourceDialog {
        id: addMediaSourceDialog
        focalWidget: viewLoader
        engineModel: root.mediaEngine.model
        title: qsTr("Add %1 source").arg(root.mediaEngine.name)
    }

    Component.onCompleted: {
        setCurrentView(runtime.config.value(mediaWindow.mediaWindowName + "-currentview", "POSTER"))
        setGroupBy(runtime.config.value(mediaWindow.mediaWindowName + "-group-by", "None"))
    }
}
