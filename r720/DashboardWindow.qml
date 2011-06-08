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
import Qt.labs.particles 1.0
import ActionMapper 1.0
import File 1.0

import "components/"

Window {
    id: root

    property Item activatedItem: grid
    focalWidget: grid

    onVisibleChanged:
        if (visible && !db.populated)
            db.populateDashboard()

    Keys.onPressed: {
        var action = runtime.actionmap.mapKeyEventToAction(event)
        if (action == ActionMapper.Enter) {
            activate(grid.focusItem())
            event.accepted = true
        } else if (action == ActionMapper.Menu) {
            if (activatedItem != grid) {
                deactivate()
                event.accepted = true
            } else {
                event.accepted = false
            }
        }
    }

    function activate(item) {
        activatedItem = item
        item.parent = root
        item.anchors.centerIn = item.parent
    }

    function deactivate() {
        //FIXME: have to reset anchors
        //or someone appears to shortcut their setting above
        //This crashes the app though
        //activatedItem.anchors.centerIn = undefined
        if (activatedItem != grid)
            activatedItem.parent = grid
        activatedItem = grid
    }

    File {
        id: db
        property bool populated: false

        function populateDashboard() {
            var list = db.findQmlModules(generalResourcePath + "/widgets")
            for(var i = 0; i < list.length; ++i) {
                var panel = panelComponent.createObject(grid)

                var widget = Qt.createComponent(list[i])
                if(widget.status == Component.Ready)
                    widget.createObject(panel.contentItem)
                else if(widget.status == Component.Error)
                    console.log(widget.errorString())
            }
            populated = true
            grid.focusLowerItem()
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: root.blade.closedBladePeek

        Component {
            id: panelComponent
            Item {
                id: currentItem

                property bool running: root.visible && currentItem.activeFocus
                property alias contentItem: panel.contentItem

                width: panel.width; height: panel.height

                Timer {
                    interval: 250; running: currentItem.running; repeat: true
                    onTriggered: {
                        crowningParticles.burst(250)
                        netherParticles.burst(250)
                    }
                }

                Particles {
                    id: crowningParticles
                    x: parent.width/2.0
                    width: 1
                    height: 1
                    source: themeResourcePath + "/particle2.png"
                    lifeSpan: 500
                    count: currentItem.running ? 20 : 0
                    angle: 0
                    scale: 0.5
                    opacity:  0.5
                    angleDeviation: 360
                    velocity: 250
                    velocityDeviation: 500
                }

                Particles {
                    id: netherParticles
                    x: parent.width/2.0
                    y: parent.height
                    width: 1
                    height: 1
                    source: themeResourcePath + "/particle2.png"
                    lifeSpan: 500
                    count: currentItem.running ? 20 : 0
                    angle: 180
                    scale: 0.5
                    opacity:  0.5
                    angleDeviation: 360
                    velocity: 250
                    velocityDeviation: 500
                }

                Panel {
                    id: panel;
                    movable: true;
                    onFrameClicked: grid.setFocusItem(currentItem)
                    onFrameDoubleClicked: root.activate(currentItem)
                }
            }
        }
    }

    ButtonList {
        id: grid
        scale: 0.6 // magic value by experimentation
        anchors.centerIn: parent

        onActivity:
            root.deactivate()
    }
}
