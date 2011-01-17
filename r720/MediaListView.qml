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

Item {
    id: root

    property variant engineName
    property variant engineModel
    property variant informationSheet
    property bool hidePreview: false
    property alias rootIndex: sourcesListView.rootIndex
    property alias currentItem: sourcesListView.currentItem
    property alias currentIndex: sourcesListView.currentIndex

    signal itemActivated(variant itemData)

    anchors.fill: parent

    ContextMenu {
        id: contextMenu
        title: qsTr("Actions")
        ConfluenceAction { id: playAction; text: qsTr("Play"); onTriggered: avPlayer.playForeground(sourcesListView.currentItem.itemdata); }
        ConfluenceAction { id: rootAction; text: qsTr("Go to root"); onTriggered: sourcesListView.rootIndex = undefined; }
        ConfluenceAction { id: removeAction; text: qsTr("Remove"); onTriggered: engineModel.removeSearchPath(sourcesListView.currentIndex)
                           enabled: sourcesListView.currentItem.itemdata.type == "SearchPath" }
        ConfluenceAction { id: informationAction; text: qsTr("Show Information"); onTriggered: root.showInformationSheet()
                           enabled: sourcesListView.currentItem.itemdata.type == "File" } 
        ConfluenceAction { id: rescanAction; text: qsTr("Rescan this item"); onTriggered: engineModel.rescan(sourcesListView.currentIndex)
                           enabled: sourcesListView.currentItem.itemdata.type == "SearchPath" } 
        ConfluenceAction { id: addSourceAction; text: qsTr("Add Source Path"); onTriggered: confluence.showModal(addMediaSourceDialog) }

        model: [playAction, rootAction, removeAction, informationAction, rescanAction, addSourceAction]
    }

    function showInformationSheet() {
        if (!informationSheet)
            return
        confluence.showModal(informationSheet)
        informationSheet.currentItem = sourcesListView.currentItem
    }

    Image {
        id: reflectionImage
        source: themeResourcePath + "/media/ContentPanel4.png"
        width: parent.width
        anchors.bottom: parent.bottom
        sourceSize.height: 0.2 * parent.height
    }

    Panel {
        id: sourcesPanel
        x: root.width*0.1
        y: root.height*0.05
        width: root.hidePreview ? root.width*0.8 : root.width*0.5
        height: root.height*0.9

        TreeView {
            id: sourcesListView

            anchors.fill: parent;
            treeModel: engineModel
            clip: true
            focus: true
            onActivated: {
                if (currentItem.itemdata.type == "AddNewSource")
                    confluence.showModal(addMediaSourceDialog)
                else {
                    root.itemActivated(currentItem.itemdata)
                }
            }
            onRightClicked: {
                var scenePos = sourcesPanel.mapToItem(null, mouseX, mouseY)
                confluence.showContextMenu(contextMenu, scenePos.x, scenePos.y)
            }
            Keys.onPressed: {
                var itemType = sourcesListView.currentItem.itemdata.type
                if (itemType == "SearchPath") {
                    if (event.key == Qt.Key_Delete) {
                        treeModel.removeSearchPath(currentIndex)
                        event.accepted = true
                    }
                }
            }
        }
    }

    ImageCrossFader {
        id: sourcesArt
        anchors.left: sourcesPanel.right
        anchors.leftMargin: 65
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.bottom: sourcesPanel.bottom
        anchors.bottomMargin: confluence.height/6
        anchors.top: sourcesPanel.top
        clip:  true
        opacity: root.hidePreview ? 0 : 1
        source: sourcesListView.currentItem ? sourcesListView.currentItem.itemdata.previewUrl : ""
    }

    AddMediaSourceDialog {
        focalWidget: sourcesListView

        id: addMediaSourceDialog
        engineModel: root.engineModel
        title: qsTr("Add %1 source").arg(root.engineName)
        opacity: 0
    }
}

