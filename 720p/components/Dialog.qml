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

Item {
    id: root
    width: 640
    height: 480
    x: confluence.width/2 - width/2
    y: confluence.height/2 - height/2

    property alias title : titleBarText.text
    property alias content : content.children
    signal accept
    signal reject

    function close() {
        opacity = 0;
    }
        
    MouseArea {
        parent: confluence
        anchors.fill: parent
    }

    BorderImage {
        id: panel
        source: themeResourcePath + "/media/OverlayWindowBackground.png"
        border { top: 20; left: 20; bottom: 20; right: 20; }
        anchors.fill: parent
    }

    Item {
        id: content
        anchors.top: glassTitleBar.bottom
        anchors.bottom: panel.bottom
        anchors.left: panel.left;
        anchors.right: panel.right
        anchors.leftMargin : panel.border.left
        anchors.bottomMargin : panel.border.bottom
        anchors.rightMargin : panel.border.right
    }

    Image {
        id: glassTitleBar
        source: themeResourcePath + "/media/GlassTitleBar.png"
        anchors.top: panel.top
        width: panel.width
    }

    Text {
        id: titleBarText
        parent: glassTitleBar
        anchors.horizontalCenter: glassTitleBar.horizontalCenter
        anchors.top: glassTitleBar.top
        color: "white"
        text: "Default dialog title"
        font.bold: true
        font.pointSize: 14
    }

    Image {
        id: closeButton
        source: themeResourcePath + "/media/" + (closeButtonMouseArea.pressed ? "WindowCloseButton-focus.png" : "WindowCloseButton.png")
        anchors.top: panel.top
        anchors.right: panel.right
        anchors { rightMargin: 40; topMargin: 5; }
        MouseArea {
            id: closeButtonMouseArea
            anchors.fill: parent;

            onClicked: root.reject();
        }
    }
}

