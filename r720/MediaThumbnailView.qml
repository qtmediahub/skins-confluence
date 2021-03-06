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

Item {
    id: root
    property variant mediaModel
    property bool hidePreview: false
    property alias currentIndex: sourcesListView.currentIndex
    property alias currentItem: sourcesListView.currentItem

    anchors.fill: parent

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

        ConfluenceGridView {
            id: sourcesListView

            anchors.fill: parent;
            model: mediaModel
            clip: true
            focus: true;
            onCurrentItemChanged:
                mediaWindow.itemSelected(currentItem)
            onActivated: {
                mediaWindow.itemActivated(currentItem)
            }
            Keys.onPressed: {
                if (sourcesListView.currentItem) {
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
    }

    ImageCrossFader {
        id: sourcesArt
        anchors.left: sourcesPanel.right
        anchors.leftMargin: 65
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.bottom: sourcesPanel.bottom
        anchors.bottomMargin: 30
        anchors.top: sourcesPanel.top
        centerAnchors: false
        clip:  true
        opacity: root.hidePreview ? 0 : 1
        source: sourcesListView.currentItem && sourcesListView.currentItem.itemdata.previewUrl ? sourcesListView.currentItem.itemdata.previewUrl : themeResourcePath + "/media/Fanart_Fallback_Music_Small.jpg"
    }
}

