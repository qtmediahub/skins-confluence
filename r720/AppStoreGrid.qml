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
import AppStore 1.0
import "components/"
import "JSONBackend.js" as JSONBackend
import ActionMapper 1.0

GridView {
    id: root

    clip: true
    cellWidth: 150
    cellHeight: cellWidth

    signal launchApp(string appPath, string appExec)

    delegate : Item {
        id: delegateItem

        width: GridView.view.cellWidth
        height: GridView.view.cellHeight

        scale: GridView.isCurrentItem ? 1.5 : 0.8
        smooth: true

        function triggerItem() {
            root.launchApp(model.modelData.path, model.modelData.exec)
        }

        Image {
            id: iconImage
            anchors.fill: parent
            anchors.margins: 40
            source: model.modelData.exec == "__appStore" ? themeResourcePath + "/media/DefaultAddon.png" : model.modelData.path + "/" + model.modelData.icon
        }

        ConfluenceText {
            anchors.top: iconImage.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
            text: model.modelData.name
        }

        MouseArea {
            anchors.fill: parent
            onClicked: triggerItem()
            hoverEnabled: true
            onEntered: GridView.view.currentIndex = index
        }

        Keys.onPressed: {
            if (actionmap.eventMatch(event, ActionMapper.Enter)) {
                triggerItem()
            }
        }

        Behavior on scale {
            NumberAnimation {}
        }
    }

    ScrollBar {
        id: verticalScrollbar
        flickable: root
    }
}
