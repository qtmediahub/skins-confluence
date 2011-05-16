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
import "../components/"
import "JSONBackend.js" as JSONBackend
import ActionMapper 1.0

FocusScope {
    id: root

//    property string server: "http://ed.europe.nokia.com:8080"
    property string server:  "http://munich-gw.trolltech.de:8080"
    property bool serverOnline: true
    property string serverReason
    property bool loggedIn:  false
    property alias appStore: appStore

    signal appInstallationStarted()

    opacity:  0
    scale: 0

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: root
                opacity: 1
                scale: 1
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; duration: transitionDuration; easing.type: confluence.standardEasingCurve }
                    NumberAnimation { property: "scale"; duration: transitionDuration; easing.type: confluence.standardEasingCurve }
                }
            }
        },
        Transition {
            to: "visible"
            ScriptAction { script: refresh() }
        }
    ]


    function checkServer() {
        var url = server + "/hello"
        var data = {"platform" : "QTMEDIAHUB", "version" : "1.0.0"}
        JSONBackend.serverCall(url, data, function(data) {
            if (data !== 0) {
                if(data.status == "ok") {
                    serverOnline = true
                } else if (data.status == "maintenance") {
                    serverOnline = false
                    serverReason = "maintenance"
                }
            } else {
                serverOnline = false
                serverReason = "unknown"
            }
        })
    }

    function categorySelected(category) {
        appModel.categoryid = category;
        appModel.refresh();
    }

    function installApp(id) {
        var url = server + "/appdownload"
        var data = {"id" :  id, "imei" : "112163001487801"}

        JSONBackend.serverCall(url, data, function(data) {
            if (data !== 0) {
                if(data.status == "ok") {
                    console.log("status: ok for " + id)
                    console.log("download url: " + data.url)
                    appStore.installApp("name", id, data.url)
                    root.appInstallationStarted()
                }
            }
        })
    }

    function deleteApp(id) {
        appStore.deleteApp("name", id, true);
    }

    function refresh() {
        categoriesModel.refresh();
        categoryListView.model = categoriesModel;
        appModel.refresh();
        appListView.model = appModel;
    }

    Component.onCompleted: refresh()

    AppStore {
        id: appStore

        onInstallAppFinished: console.log("install finished: " + userId + " - " + appUuid);
        onInstallAppProgress: console.log("install progress: " + userId + " - " + appUuid + " - " + progress);
        onInstallAppFailed: console.log("install failed: " + userId + " - " + appUuid + " - " + error);
    }

    JSONModel {
        id: categoriesModel
        url: server + "/listcategories"
    }

    JSONModel {
        id: appModel

        property string filter: ""
        property int categoryid: -1

        url: server + "/listapps"
        data: categoryid >= 0 ? { "filter" : filter , "category_id" : categoryid} : { "filter" : filter}
    }

    ConfluenceText {
        id: serverStatus
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Normal
        text: qsTr("Server status: ") + (serverOnline ? qsTr("online") : qsTr("offline"))
    }

    ConfluenceText {
        id: loginStatus
        anchors.top: serverStatus.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Normal
        text: qsTr("Account: ") + (loggedIn ? qsTr("logged in") : qsTr("not logged in"))
    }

    Row {
        id: mainLayout
        spacing: 60
        anchors.centerIn: parent

        Panel {
            width: root.width/2.0 - mainLayout.spacing*2
            height: root.height/1.3

            ConfluenceListView {
                id: categoryListView

                anchors.fill: parent
                clip: true
                model: 0
                opacity: activeFocus ? 1.0 : 0.3

                function gainFocus() {
                    appListView.focus = false
                    categoryListView.focus = true
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    on: categoriesModel.status == "loading"
                }

                delegate: Item {
                    id: delegateItem
                    width: parent.width
                    height: 70
                    Image {
                        anchors.fill: parent;
                        source: themeResourcePath + "/media/" + (delegateItem.ListView.isCurrentItem ? "MenuItemFO.png" : "MenuItemNF.png");
                    }
                    Image {
                        id: iconImage
                        source: server + "/categoryicon?id=" + id
                        smooth: true
                        height: 64
                        width: height
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: categoryName
                        anchors.left: iconImage.right
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        font.pointSize: 16
                        text: name
                    }
                    MouseArea {
                        anchors.fill: parent;
                        hoverEnabled: true
                        onEntered: delegateItem.ListView.view.currentIndex = index
                        onClicked: categorySelected(id)
                    }
                    Keys.onReturnPressed: {
                        categorySelected(id)
                        event.accepted = true
                    }
                }

                Keys.onPressed:
                    if (runtime.actionmap.eventMatch(event, ActionMapper.Left) || runtime.actionmap.eventMatch(event, ActionMapper.Right)) {
                        appListView.gainFocus()
                    }

                MouseArea {
                    anchors.fill: parent;
                    hoverEnabled: true
                    onEntered: categoryListView.gainFocus()
                }

                Behavior on opacity {
                    NumberAnimation {}
                }
            }
        }

        Panel {
            width: root.width/2.0 - mainLayout.spacing*2
            height: root.height/1.3

            ConfluenceListView {
                id: appListView

                anchors.fill: parent
                focus: true
                clip: true
                model: 0
                opacity: activeFocus ? 1.0 : 0.3

                function gainFocus() {
                    appListView.focus = true
                    categoryListView.focus = false
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    on: appModel.status == "loading"
                }

                delegate: Item {
                    id: delegateItem
                    width: parent.width
                    height: 70

                    Image {
                        anchors.fill: parent;
                        source: themeResourcePath + "/media/" + (delegateItem.ListView.isCurrentItem ? "MenuItemFO.png" : "MenuItemNF.png");
                    }
                    Image {
                        id: appIcon
                        source: server + "/appicon?id=" + id
                        smooth: true
                        height: 64
                        width: height
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: appName
                        anchors.left: appIcon.right
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        font.pointSize: 16
                        text: name
                    }

                    Column {
                        anchors.right: parent.right
                        anchors.rightMargin: appListView.scrollbarItem.width
                        height: parent.height

                        Rating {
                            rating: model.rating
                        }
                        Text {
                            id: appPrice
                            color: "white"
                            font.pointSize: 16
                            text: price + " €";
                        }
                    }

                    function activated() {
                        if (!loggedIn) {
                            loginDialog.open()
                            loginDialog.focus = true
                        } else if (appStore.localInstaller()) {
                            installDialog.id = id;
                            installDialog.question = qsTr("Really install ") + model.name
                            installDialog.open();
                            installDialog.focus = true;
                        } else {
                            errorDialog.message = qsTr("No local Installer found")
                            errorDialog.open()
                            errorDialog.focus = true;
                        }
                    }

                    MouseArea {
                        anchors.fill: parent;
                        hoverEnabled: true
                        onEntered: delegateItem.ListView.view.currentIndex = index
                        onClicked: activated()
                    }
                    Keys.onPressed: {
                        if (runtime.actionmap.eventMatch(event, ActionMapper.Enter))
                            activated()
                    }
                }

                Keys.onPressed:
                    if (runtime.actionmap.eventMatch(event, ActionMapper.Left) || runtime.actionmap.eventMatch(event, ActionMapper.Right)) {
                        categoryListView.gainFocus()
                    }

                MouseArea {
                    anchors.fill: parent;
                    hoverEnabled: true
                    onEntered: appListView.gainFocus()
                }

                Behavior on opacity {
                    NumberAnimation {}
                }
            }
        }
    }

    AppStoreLogin {
        id: loginDialog
        onAccepted: {
            var url = server + "/login"
            var data = {"username" : username, "password" : password, "imei" : "112163001487801"}
            JSONBackend.serverCall(url, data, function(data) {
                                       if (data !== 0) {
                                           if(data.status == "ok") {
                                               root.loggedIn = true
                                           } else {
                                               root.loggedIn = false
                                           }
                                       }
                                   })
        }
        onClosed: appListView.focus = true
    }

    AppStoreDialog {
        id: installDialog

        property string id

        title: qsTr("Installation")
        question: qsTr("Really install application")

        onAccepted: {
            installApp(id);
            id = ""
        }
        onRejected:  id = ""
        onClosed: appListView.focus = true
    }

    Dialog {
        id: errorDialog

        title: qsTr("Error")

        property alias message : messageLabel.text

        Column {
            spacing: 5
            width: 620

            Text {
                id: messageLabel
                width: parent.width
                text: ""
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "steelblue"
            }

            Button {
                id: okButton
                text: qsTr("OK")
                focus: true
                onClicked: errorDialog.accept()
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        onClosed: appListView.focus = true
    }

    Behavior on opacity { PropertyAnimation { duration: 500 } }
}
