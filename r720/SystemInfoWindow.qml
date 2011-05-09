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
import QtMobility.systeminfo 1.1
import "components/"
import File 1.0
import ActionMapper 1.0

Window {
    id: root

    Keys.onPressed:
        if (runtime.actionmap.eventMatch(event, ActionMapper.Up))
            infoViewport.contentY = Math.max(0, infoViewport.contentY - 20)
        else if (runtime.actionmap.eventMatch(event, ActionMapper.Down))
            infoViewport.contentY = Math.min(infoViewport.contentHeight - height, infoViewport.contentY + 20)

    NetworkInfo {
        id: networkInfo
        mode: NetworkInfo.EthernetMode
    }

    File {
        id: fileProbe
    }

    Panel {
        anchors.centerIn: parent;

        Flickable {
            id: infoViewport
            flickableDirection: Flickable.VerticalFlick
            contentWidth: textFlow.width
            contentHeight: textFlow.height
            width: textFlow.width
            height: confluence.height - 200
            Flow {
                id: textFlow
                width: confluence.width - 100
                flow: Flow.TopToBottom
                ConfluenceText { id: heading; font.pointSize: 26; text: "System Information"; horizontalAlignment: Qt.AlignHCenter; width: parent.width; font.weight: Font.Bold }
                Item { width: heading.width; height: heading.height }
                ConfluenceText { text: "Network Information"; horizontalAlignment: Qt.AlignHCenter; width: parent.width; font.weight: Font.Bold }
                ConfluenceText { text: "Mac address: " + networkInfo.macAddress }
                ConfluenceText { text: "Network status: " + networkInfo.networkStatus }
                ConfluenceText { text: "Network name: " + networkInfo.networkName }
                ConfluenceText { text: "Network signal strength: " + networkInfo.networkSignalStrength }
                //ConfluenceText { text: "cpu: " + fileProbe.readAllLines("/proc/cpuinfo") }
                Item { width: heading.width; height: heading.height }
                ConfluenceText { text: "CPU Information"; horizontalAlignment: Qt.AlignHCenter; width: parent.width; font.weight: Font.Bold }

                Repeater {
                    model: fileProbe.readAllLines("/proc/cpuinfo")
                    ConfluenceText { font.pointSize: 12; text: modelData; wrapMode: Text.WordWrap; width: textFlow.width }
                }
            }
        }
    }
}
