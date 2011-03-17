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
import "components/"
import "JSONBackend.js" as JSONBackend

FocusScope {
    id: root

    opacity:  0
    scale: 0

    signal appInstallationStarted()

    states: [
        State {
            name: ""
        },
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
        }
    ]

    property string server: "http://ed.europe.nokia.com:8080"
    property bool serverOnline: true
    property string serverReason
    property bool loggedIn:  false

    function checkServer() {
        var url = server + "/hello"
        var data = {"platform" : "KRAK", "version" : "1.0.0"}
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
        if (!loggedIn) {
            loginDialog.open()
        } else {
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
    }

    function deleteApp(id) {
        appStore.deleteApp("name", id, true);
    }

    Component.onCompleted: {
        categoriesModel.refresh();
        listView.model = categoriesModel;
        appModel.refresh();
        appListView.model = appModel;
    }

    AppStore {
        id: appStore
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
        text: "Server status: " + (serverOnline ? "online" : "offline")
    }

    ConfluenceText {
        id: loginStatus
        anchors.top: serverStatus.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Normal
        text: "Account: " + (loggedIn ? "logged in" : "not logged in")
    }

    Row {
        id: mainLayout
        spacing: 60
        anchors.centerIn: parent

        Panel {
            width: root.width/2.0 - mainLayout.spacing*2
            height: root.height/1.3

            ConfluenceListView {
                id: listView
                anchors.fill: parent

                scrollbar: false
                focus: true
                clip: true
                model: 0

                BusyIndicator {
                    anchors.centerIn:  parent
                    on: categoriesModel.status == "loading"
                }

                delegate: Item {
                    width: listView.width
                    height: 70
                    Image {
                        anchors.fill: parent;
                        source: themeResourcePath + "/media/" + (ListView.isCurrentItem ? "MenuItemFO.png" : "MenuItemNF.png");
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
                        onEntered:
                            ListView.view.currentIndex = index
                        onClicked: categorySelected(id)
                    }
                    Keys.onReturnPressed: {
                        categorySelected(id)
                        event.accepted = true
                    }
                }
            }
        }

        Panel {
            width: root.width/2.0 - mainLayout.spacing*2
            height: root.height/1.3

            ConfluenceListView {
                id: appListView
                anchors.fill: parent

                scrollbar: false
                focus: true
                clip: true
                model: 0

                BusyIndicator {
                    anchors.centerIn:  parent
                    on: appModel.status == "loading"
                }

                delegate: Item {
                    width: listView.width
                    height: 70
                    Image {
                        anchors.fill: parent;
                        source: themeResourcePath + "/media/" + (ListView.isCurrentItem ? "MenuItemFO.png" : "MenuItemNF.png");
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

                    MouseArea {
                        anchors.fill: parent;
                        hoverEnabled: true
                        onEntered:
                            ListView.view.currentIndex = index
                        onClicked: {
                            installDialog.id = id;
                            installDialog.question = "Really install " + model.name
                            installDialog.open();
                        }
                    }
                    Keys.onReturnPressed: {
                        installDialog.id = id;
                        installDialog.question = "Really install " + model.name
                        installDialog.open();
                        event.accepted = true
                    }
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
    }

    AppStoreDialog {
        id: installDialog

        property string id

        title: "Installation"
        question: "Really install application"

        onAccepted: {
            installApp(id)
            id = ""
        }
        onRejected:  id = ""
    }

    Behavior on opacity { PropertyAnimation { duration: 500 } }
}
