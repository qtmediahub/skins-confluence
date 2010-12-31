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
import DirModel 1.0
import "../components/"
import "util.js" as Util

Item {
    id: root
    anchors.fill: parent

    property variant engineName
    property variant engineModel
    property variant informationSheet

    signal itemTriggered(variant itemData)

    BorderImage {
        id: background
        source: themeResourcePath + "/media/ContentPanel2.png"
        anchors.fill: parent
        border.left: 5; border.top: 5
        border.right: 5; border.bottom: 5
    }

    ContextMenu {
        id: contextMenu
        title: qsTr("Actions")
        ConfluenceAction { id: rootAction; text: qsTr("Go to root"); onTriggered: posterView.rootIndex = undefined; }
        ConfluenceAction { id: removeAction; text: qsTr("Remove"); onTriggered: engineModel.removeSearchPath(posterView.currentIndex)
                           enabled: posterView.currentItem.itemdata.type == "SearchPath" }
        ConfluenceAction { id: informationAction; text: qsTr("Show Information"); onTriggered: root.showInformationSheet()
                           enabled: posterView.currentItem.itemdata.type == "File" } 
        ConfluenceAction { id: rescanAction; text: qsTr("Rescan this item"); onTriggered: engineModel.rescan(posterView.currentIndex)
                           enabled: posterView.currentItem.itemdata.type == "SearchPath" } 
        ConfluenceAction { id: addSourceAction; text: qsTr("Add Source Path"); onTriggered: confluence.showModal(addMediaSourceDialog) }

        model: [rootAction, removeAction, informationAction, rescanAction, addSourceAction]
    }

    function showInformationSheet() {
        if (!informationSheet)
            return
        confluence.showModal(informationSheet)
        informationSheet.currentItem = posterView.currentItem
    }

    PosterView {
        id: posterView
        width: parent.width
        height: confluence.height/2.4
        anchors.top: parent.top
        anchors.topMargin: confluence.height/7.2
        anchors.horizontalCenter: parent.horizontalCenter
        clip: true
        focus: true
        posterModel: engineModel

        onActivated: {
            if (currentItem.itemdata.type == "AddNewSource")
                confluence.showModal(addMediaSourceDialog)
            else
                root.itemTriggered(currentItem.itemdata)
        }
        onRightClicked: {
            var scenePos = posterView.mapToItem(null, mouseX, mouseY)
            confluence.showContextMenu(contextMenu, scenePos.x, scenePos.y)
        }
        Keys.onPressed: {
            var itemType = posterView.currentItem.itemdata.type
            if (itemType == "SearchPath") {
                if (event.key == Qt.Key_Delete) {
                    posterModel.removeSearchPath(currentIndex)
                    event.accepted = true
                }
            }
        }
    }

    ConfluenceText {
        anchors.top:  posterView.bottom
        anchors.topMargin: confluence.height/24
        anchors.horizontalCenter: parent.horizontalCenter
        text: posterView.currentItem ? posterView.currentItem.itemdata.display : ""
    }

    ConfluenceText {
        anchors.top:  posterView.bottom
        anchors.topMargin: confluence.height/12
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 15
        font.bold: false
        color: "steelblue"
        text: posterView.currentItem && posterView.currentItem.itemdata.type == "File" ? Util.toHumanReadableBytes(posterView.currentItem.itemdata.fileSize) : ""
    }

    AddMediaSourceDialog {
        id: addMediaSourceDialog
        engineModel: root.engineModel
        title: qsTr("Add %1 source").arg(root.engineName)
        opacity: 0

        onClosed: posterView.forceActiveFocus()
    }
}

