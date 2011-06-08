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
import DirModel 1.0
import ActionMapper 1.0
import QMHPlugin 1.0

Dialog {
    id: root

    property variant device

    property list<QtObject> actionList: [
        ConfluenceAction {
            id: musicAction
            text: qsTr("MUSIC")
            options: [qsTr("off"), qsTr("on")]
        },
        ConfluenceAction {
            id: videoAction
            text: qsTr("VIDEO")
            options: [qsTr("off"), qsTr("on")]
        },
        ConfluenceAction {
            id: pictureAction
            text: qsTr("PICTURE")
            options: [qsTr("off"), qsTr("on")]
        }]

    title: device && device.label != "" ? device.label : qsTr("DEVICE")
    onOpened: listView.focus = true

    Column {
        spacing: 30
        width: 620
        Text {
            id: browseLabel
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("SELECT MEDIA TYPE ON DEVICE")
            color: "steelblue"
        }

        ActionListView {
            id: listView
            focus: true
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height - browseLabel.height - buttonBox.height
            model: root.actionList

            Keys.onPressed: {
                var action = runtime.actionMapper.mapKeyEventToAction(event)
                if (action == ActionMapper.Left || action == ActionMapper.Right) {
                    buttonBox.focus = true
                    event.accepted = true
                }
            }
        }

        DialogButtonBox {
            id: buttonBox
            anchors.horizontalCenter: parent.horizontalCenter
            onAccepted: {
                if (musicAction.currentOptionIndex) {
                    var engine = runtime.backend.engine("music")
                    if (engine)
                        engine.model.addSearchPath(device.mountPoint, root.device.label);
                }
                if (videoAction.currentOptionIndex) {
                    var engine = runtime.backend.engine("video")
                    if (engine)
                        engine.model.addSearchPath(device.mountPoint, root.device.label);
                }
                if (pictureAction.currentOptionIndex) {
                    var engine = runtime.backend.engine("picture")
                    if (engine)
                        engine.model.addSearchPath(device.mountPoint, root.device.label);
                }

                root.accept()
            }
            onRejected: {
                root.reject()
            }

            Keys.onPressed: {
                var action = runtime.actionMapper.mapKeyEventToAction(event)
                if (action == ActionMapper.Up || action == ActionMapper.Down || action == ActionMapper.Left || action == ActionMapper.Right) {
                    listView.focus = true
                    event.accepted = true
                }
            }
        }
    }
}
