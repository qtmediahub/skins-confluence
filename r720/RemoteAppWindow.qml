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

Window {
    id: root

    Loader {
        id: loader;
        anchors.centerIn: parent
    }

    Column {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Image {
            id: sourceNameEntry
            width: 500
            anchors.horizontalCenter: parent.horizontalCenter
            source: themeResourcePath + "/media/" + (sourceNameEntryMouseArea.containsMouse || sourceNameInput.activeFocus ? "MenuItemFO.png" : "MenuItemNF.png");

            TextInput {
                id: sourceNameInput
                anchors.centerIn: parent
                text: "http://gitorious.org/qtmediahub/qtmediahub/blobs/raw/master/hub/skins/confluence/remote/RemoteApp.qml" // "http://tinyurl.com/remoteapp-qml" 
                color: "white"
                font.pointSize: 15
            }

            MouseArea {
                id: sourceNameEntryMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sourceNameInput.forceActiveFocus()
            }
        }

        Button {
            text: qsTr("Reload")
            focus: true
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                backend.clearComponentCache()
                loader.source = ""
                loader.source = sourceNameInput.text
            }
        }
    }

    Engine { name: qsTr("RemoteApp"); role: "remoteApp"; visualElement: root }
}
