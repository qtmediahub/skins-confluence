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
import QtMobility.location 1.1
import confluence.components 1.0

Window {
    id: root
    anchors.fill: parent
    maximizable: true

    Panel {
        id: panel
        anchors.centerIn: parent;
        decorateFrame: !root.maximized
        anchors.fill: parent

        Map {
            id: map
            anchors.fill: parent
            plugin : Plugin {
                name : "nokia"
            }
            mapType: Map.StreetMap
            //mapType: Map.SatelliteMapDay

        }

        MouseArea {
            anchors.fill: parent

            property bool mouseDown : false
            property int lastX : -1
            property int lastY : -1

            onPressed : {
                mouseDown = true
                lastX = mouse.x
                lastY = mouse.y
            }
            onReleased : {
                mouseDown = false
            }


            onPositionChanged: {
                if (mouseDown) {
                    var dx = mouse.x - lastX
                    var dy = mouse.y - lastY
                    map.pan(-dx, -dy)
                    lastX = mouse.x
                    lastY = mouse.y
                }
            }
        }
    }

    Engine { name: qsTr("Ovi Maps"); role: "maps"; visualElement: root; visualElementProperties: [] }
}
