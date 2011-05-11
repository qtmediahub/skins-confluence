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
import Qt.labs.shaders 1.0
import Qt.labs.shaders.effects 1.0

Item {
    id: root

    anchors.fill: parent

    onWidthChanged: {
        curtain.animated = false
        settleTimer.start()
    }

    function reset() {
        loader.item.resetFocus()
    }

    Timer {
        id: splashDelay
        interval: runtime.config.value("splash-lead-time", 500)
        onTriggered:
            loader.source = "TopLevel.qml"
    }

    Timer {
        id: settleTimer
        interval: 1
        onTriggered:
            curtain.animated = true
    }

    Image {
        id: splash
        anchors.fill: parent
        smooth: true
        fillMode: Image.PreserveAspectFit
        source: "../3rdparty/splash/splash.jpg"
    }

    CurtainEffect {
        id: curtain
        property bool animated: false
        z: 100
        anchors.fill: splash
        bottomWidth: topWidth
        topWidth: parent.width
        source: ShaderEffectSource { sourceItem: splash; hideSource: true }

        Behavior on topWidth {
            enabled: curtain.animated
            SequentialAnimation {
                PropertyAnimation { duration: 1000 }
                PauseAnimation { duration: 2000 }
                ScriptAction { script: curtain.destroy() }
            }
        }

        Behavior on bottomWidth {
            enabled: curtain.animated
            SpringAnimation { easing.type: Easing.OutElastic; velocity: 1500; mass: 1.5; spring: 0.5; damping: 0.15}
        }

        SequentialAnimation on topWidth {
            id: topWidthAnim
            loops: 1
            running: false

            NumberAnimation { to: root.width - 50; duration: 700 }
            PauseAnimation { duration: 500 }
            NumberAnimation { to: root.width + 50; duration: 700 }
            PauseAnimation { duration: 500 }
            ScriptAction { script: curtain.topWidth = 0; }
        }

    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            reset()
            topWidthAnim.running = true
        }
    }

    Component.onCompleted:
        splashDelay.start()
}
