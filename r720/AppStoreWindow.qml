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
import "appstore/"
import "appstore/JSONBackend.js" as JSONBackend
import ActionMapper 1.0

Window {
    id: root

    anchors.fill: parent

    function showAppStore() {
        appStoreListView.state = "visible"
        appStoreListView.focus = true
    }

    function hideAppStore() {
        appStoreListView.state = ""
        appGrid.focus = true
    }

    function closeApp() {
        appLoader.source = ""
    }

    AppStoreGrid {
        id: appGrid

        model: appStoreListView.appStore.apps

        anchors.fill: parent
        anchors.margins: 100

        onLaunchApp: {
            if (appExec == "__appStore")
                showAppStore();
            else
                appLoader.source = appPath + "/" + appExec
        }

        focus: true
    }

    AppStoreServerListView {
        id: appStoreListView
        state: ""
        anchors.fill: parent

        onAppInstallationStarted: hideAppStore()
    }

    Panel {
        id: app

        property bool active : appLoader.status == Loader.Ready

        width: parent.width*0.5
        height: parent.height*0.8
        anchors.centerIn: parent
        opacity: active ? 1 : 0
        clip: true

        Loader {
            id: appLoader
            anchors.fill: parent
        }

        Behavior on opacity {
            NumberAnimation {}
        }
    }

    Button {
        id: exitApp
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        opacity: (app.active || appStoreListView.state == "visible") ? 1 : 0
        text: qsTr("Exit")
        onClicked: app.active ? closeApp() : (appStoreListView.state == "visible" ? hideAppStore() : showAppStore())

        Behavior on opacity {
            NumberAnimation {}
        }
    }

    Keys.onPressed: {
        if (runtime.actionMapper.mapKeyEventToAction(event) == ActionMapper.Menu) {
            event.accepted = true
            if (appStoreListView.state == "visible")
                hideAppStore();
            else if (app.active)
                closeApp();
            else
                event.accepted = false;
        }
    }
}
