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
import "uiconstants.js" as UIConstants
import ActionMapper 1.0

FocusScope {
    id: root
    width: blade.width + blade.x
    height: parent.height
    z: UIConstants.windowZValues.blade

    clip: true

    property bool hoverEnabled: false
    signal entered
    signal exited
    signal clicked
    signal opened
    signal closed
    signal hidden

    property int closedBladePeek: 30

    property alias bladeVisibleWidth: blade.visibleWidth
    property alias bladeWidth: blade.width
    property alias bladePixmap: bladePixmap.source
    property alias bladeX: blade.x
    default property alias content: content.children
    //pixmap specific offset (pixmap alpha!)
    property int bladeRightMargin: 30

    function open() {
        if (content.children.length > 0) {
            root.state = "open"
            root.forceActiveFocus()
        } else {
            confluence.state = "showingRootBlade"
        }
    }
    function close() {
        state = "closed"
    }
    function hide() {
        state = "hidden"
    }

    state:  "closed"

    states: [
        State {
            name: "closed"
            PropertyChanges {
                target: blade
                visibleWidth: root.closedBladePeek
            }
            StateChangeScript { script: root.closed() }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: blade
                visibleWidth: 0
            }
            StateChangeScript { script: root.hidden() }
        },
        State {
            name: "open"
            PropertyChanges {
                target: blade
                visibleWidth: width
            }
            StateChangeScript { script: root.opened() }
        }
    ]

    Keys.onPressed:
        actionmap.eventMatch(event, ActionMapper.Back)
        || actionmap.eventMatch(event, ActionMapper.Left)
        || actionmap.eventMatch(event, ActionMapper.Right)
        ? root.close()
        : undefined

    onClosed: !!root.parent.focalWidget && root.parent.focalWidget.visible ? root.parent.focalWidget.forceActiveFocus() : undefined

    Item {
        id: blade
        x: -width + visibleWidth
        property int visibleWidth
        clip: true
        height: parent.height
        Image {
            id: bladePixmap
            anchors.right: blade.right
            anchors.fill:  parent
        }
        MouseArea {
            hoverEnabled: root.hoverEnabled
            anchors.fill: parent
            onPressed: root.clicked()
            onEntered: root.entered()
            onExited: root.exited()

            // The content has to be a child of the enclosing MouseArea. This is required
            // because if it were a sibling then the enclosing MouseArea would receive a 
            // exited when it enters the content's MouseArea
            Item {
                id: content
                focus: true
                anchors { right: parent.right; rightMargin: bladeRightMargin }
                width: parent.width; height: parent.height
            }
        }
        Behavior on x {
            NumberAnimation { duration: confluence.standardAnimationDuration; easing.type: confluence.standardEasingCurve }
        }
    }
}

