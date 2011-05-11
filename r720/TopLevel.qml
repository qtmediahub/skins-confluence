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
import "./components/uiconstants.js" as UIConstants
import "./components/cursor.js" as Cursor
import ActionMapper 1.0
import "util.js" as Util
import QMHPlugin 1.0
import "rootmenumodelitem.js" as RootMenuModelItem

FocusScope {
    id: confluence

    property real scalingCorrection: confluence.width == 1280 ? 1.0 : confluence.width/1280

    property string generalResourcePath: runtime.backend.resourcePath
    property string themeResourcePath: runtime.skin.path + "/3rdparty/skin.confluence"

    //FIXME: QML const equivalent?
    property int standardEasingCurve: Easing.InQuad
    property int standardAnimationDuration: 350

    property int standardHighlightRangeMode: ListView.NoHighlightRange
    property int standardHighlightMoveDuration: 400

    property bool standardItemViewWraps: true

    property variant selectedEngine
    property variant selectedElement
    property variant avPlayer
    property variant browserWindow
    property variant ticker
    property variant weatherWindow
    property variant systemInfoWindow
    property variant aboutWindow

    property variant musicEngine
    property variant videoEngine

    property variant rootMenuModel: ListModel { }

    anchors.fill: parent
    focus: true
    clip: true

    function resetFocus() {
        state = ""
        mainBlade.rootMenu.forceActiveFocus()
    }

    // obj has {name, role, visualElement, activationProperties, engine}
    // FIXME: Remove role, it's primarily for the background images
    function addToRootMenu(obj, activationHandler) {
        rootMenuModel.append(obj)
        RootMenuModelItem.activationHandlers[rootMenuModel.count-1] = activationHandler
    }

    function setActiveEngine(index) {
        var engine = rootMenuModel.get(index)
        var oldEngine = selectedEngine

        selectedEngine = engine
        selectedElement = engine.visualElement

        if (oldEngine != engine) {
            if (RootMenuModelItem.activationHandlers[index])
                RootMenuModelItem.activationHandlers[index].call(engine)
        }
        show(selectedElement)
    }

    function show(element) {
        !!selectedElement && selectedElement != element ? selectedElement.state = "" : undefined

        if (element == mainBlade) {
            state = ""
        } else if(element == avPlayer) {
            if(!avPlayer.hasMedia) {
                if (typeof runtime.videoEngine != "undefined")
                    show(runtime.videoEngine.visualElement)
                else if (typeof runtime.musicEngine != "undefined")
                    show(runtime.musicEngine.visualElement)
            } else {
                show(transparentVideoOverlay)
            }
        } else if (element == transparentVideoOverlay) {
            selectedElement = transparentVideoOverlay
            state = "showingSelectedElementMaximized"
        } else {
            selectedElement = element
            state = "showingSelectedElement"
        }
    }

    function showContextMenu(item, x, y) {
        showModal(item)
        item.x = x
        item.y = y
    }

    function showModal(item) {
        mouseGrabber.opacity = 0.9 // FIXME: this should probably become a confluence state
        var currentFocusedItem = runtime.utils.focusItem();
        var onClosedHandler = function() {
            mouseGrabber.opacity = 0;
            if (currentFocusedItem)
                currentFocusedItem.forceActiveFocus()
            item.closed.disconnect(onClosedHandler)
        }
        item.closed.connect(onClosedHandler)
        item.parent = confluence // ## restore parent?
        item.z = UIConstants.screenZValues.diplomaticImmunity
        item.open()
        item.forceActiveFocus()
    }

    function showFullScreen(item) {
        item.z = background.z + 2
        item.parent = confluence
        item.opacity = 1
        item.forceActiveFocus()
    }

    states: [
        State {
            name:  ""
            StateChangeScript { name: "focusMainBlade"; script: mainBlade.forceActiveFocus() }
            PropertyChanges { target: ticker; state: "visible" }
        },
        State {
            name: "showingSelectedElement"
            PropertyChanges { target: mainBlade; state: "hidden" }
            PropertyChanges { target: avPlayer; state: "hidden" }
            PropertyChanges { target: dateTimeHeader; expanded: true; showDate: false }
            PropertyChanges { target: weatherHeader; expanded: false }
            PropertyChanges { target: homeHeader; expanded: true }
            PropertyChanges { target: currentContextHeader; expanded: true }
            PropertyChanges { target: ticker; state: "" }
            PropertyChanges { target: selectedElement; state: "visible" }
            PropertyChanges { target: avPlayer; state: "background" }
        },
        State {
            name: "showingSelectedElementMaximized"
            extend: "showingSelectedElement"
            PropertyChanges { target: selectedElement; state: "maximized" }
            PropertyChanges { target: avPlayer; state: selectedElement == transparentVideoOverlay ? "maximized" : "hidden" }
            PropertyChanges { target: dateTimeHeader; expanded: false; showDate: false }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: ""
        },
        Transition {
            from: "*"
            to: "showingSelectedElement"
            SequentialAnimation {
                // Move things out
                ParallelAnimation {
                }
                // Move things in
                ParallelAnimation {
                    PropertyAction { target: selectedElement; property: "state"; value: "visible" }
                }
            }
        }
    ]

    Keys.onPressed: {
        if (runtime.actionmap.eventMatch(event, ActionMapper.Menu)) {
            if(selectedElement && selectedElement.maximized)
                selectedElement.maximized = false
            else
                show(mainBlade)
        } else if (event.key == Qt.Key_F12) {
            selectedElement
                    && selectedElement.maximizable
                    && state == "showingSelectedElement"
                    ? selectedElement.maximized = true
                    : undefined
        } else if (event.key == Qt.Key_F11) {
            show(aboutWindow)
        } else if (event.key == Qt.Key_F10) {
            show(systemInfoWindow)
        } else if (runtime.actionmap.eventMatch(event, ActionMapper.ContextualUp)) {
            avPlayer.increaseVolume()
        } else if (runtime.actionmap.eventMatch(event, ActionMapper.ContextualDown)) {
            avPlayer.decreaseVolume()
        } else if (runtime.actionmap.eventMatch(event, ActionMapper.MediaPlayPause)) {
            avPlayer.togglePlayPause()
        }
    }

    function createQmlObjectFromFile(file, properties) {
        var qmlComponent = Qt.createComponent(file)
        if (qmlComponent.status == Component.Ready) {
            return qmlComponent.createObject(confluence, properties ? properties : {})
        }
        runtime.backend.log(qmlComponent.errorString())
        return null
    }

    Component.onCompleted: {
        Cursor.initialize()

        runtime.backend.loadEngines()
        var engineNames = runtime.backend.loadedEngineNames()

        if (engineNames.indexOf("appstore") != -1) {
            var appStoreWindow = createQmlObjectFromFile("AppStoreWindow.qml")
            confluence.addToRootMenu(new RootMenuModelItem.RootMenuModelItem(qsTr("App Store"), QMHPlugin.Store, appStoreWindow))
        }

        if (engineNames.indexOf("music") != -1) {
            musicEngine = runtime.backend.engine("music")
            var musicWindow = createQmlObjectFromFile("MusicWindow.qml", { mediaEngine: musicEngine });
            confluence.addToRootMenu(new RootMenuModelItem.RootMenuModelItem(qsTr("Music"), QMHPlugin.Music, musicWindow, musicEngine))
        }

        if (engineNames.indexOf("video") != -1) {
            videoEngine = runtime.backend.engine("video")
            var videoWindow = createQmlObjectFromFile("VideoWindow.qml", { mediaEngine: videoEngine });
            confluence.addToRootMenu(new RootMenuModelItem.RootMenuModelItem(qsTr("Video"), QMHPlugin.Video, videoWindow, videoEngine))
        }

        if (engineNames.indexOf("picture") != -1) {
            var pictureEngine = runtime.backend.engine("picture")
            var pictureWindow = createQmlObjectFromFile("PictureWindow.qml", { mediaEngine: pictureEngine });
            confluence.addToRootMenu(new RootMenuModelItem.RootMenuModelItem(qsTr("Picture"), QMHPlugin.Picture, pictureWindow, pictureEngine))
        }

        avPlayer = createQmlObjectFromFile("AVPlayer.qml")
        if (avPlayer) {
            // FIXME: nothing to get video-path during runtime, yet
            avPlayer.state = "background"
        } else {
            avPlayer = dummyItem
        }

        var dashboardWindow = createQmlObjectFromFile("DashboardWindow.qml")
        confluence.addToRootMenu(new RootMenuModelItem.RootMenuModelItem(qsTr("Dashboard"), QMHPlugin.Dashboard, dashboardWindow))

        browserWindow = createQmlObjectFromFile("WebWindow.qml")
        confluence.addToRootMenu(new RootMenuModelItem.RootMenuModelItem(qsTr("Web"), QMHPlugin.Web, browserWindow), function() { this.visualElement.initialUrl = "http://www.google.com" })
        confluence.addToRootMenu(new RootMenuModelItem.RootMenuModelItem(qsTr("Google Maps"), QMHPlugin.Map, browserWindow), function() { this.visualElement.initialUrl = confluence.generalResourcePath + "/googlemaps/Nokia.html"; this.visualElement.enableBrowserShortcuts = false })
        if (runtime.config.isEnabled("wk-plugins", false))
            confluence.addToRootMenu(new RootMenuModelItem.RootMenuModelItem(qsTr("Youtube"), QMHPlugin.Application, browserWindow), function() { this.visualElement.initialUrl = "http://www.youtube.com/xl"})

        weatherWindow = createQmlObjectFromFile("WeatherWindow.qml")
        confluence.addToRootMenu(new RootMenuModelItem.RootMenuModelItem(qsTr("Weather"), QMHPlugin.Weather, weatherWindow))

        var remoteAppWindow = createQmlObjectFromFile("RemoteAppWindow.qml")
        confluence.addToRootMenu(new RootMenuModelItem.RootMenuModelItem(qsTr("RemoteApp"), QMHPlugin.Application, remoteAppWindow))

        systemInfoWindow = createQmlObjectFromFile("SystemInfoWindow.qml")

        var mapsWindow = createQmlObjectFromFile("MapsWindow.qml")
        confluence.addToRootMenu(new RootMenuModelItem.RootMenuModelItem(qsTr("Ovi Maps"), QMHPlugin.Map, mapsWindow))

        ticker = createQmlObjectFromFile("Ticker.qml")
        if (ticker) {
            ticker.z = UIConstants.screenZValues.header
            ticker.state = "visible"
        } else {
            ticker = dummyItem
        }

        createQmlObjectFromFile("ScreenSaver.qml")
        aboutWindow = createQmlObjectFromFile("AboutWindow.qml")
        createQmlObjectFromFile("SystemScreenSaverControl.qml")
    }

    // dummyItem useful to avoid error ouput on component loader failures
    Item {
        id: dummyItem
        visible: false
    }

    Background {
        id: background
        anchors.fill: parent;
        visible: !avPlayer.playing
    }

    MainBlade { 
        id: mainBlade;
        state: "open"
        focus: true
    }

    Header {
        id: homeHeader
        atRight : false
        expanded: false

        z: currentContextHeader.z + 1
        width: homeImage.width + 80
        Image {
            id: homeImage
            x: 40
            sourceSize { width: height; height: homeHeader.height-4; }
            source: themeResourcePath + "/media/HomeIcon.png"
        }
        MouseArea { anchors.fill: parent; onClicked: confluence.show(mainBlade) }
    }

    Header {
        id: currentContextHeader
        atRight: false
        expanded: false

        width: contextText.width + homeHeader.width + 25
        ConfluenceText {
            id: contextText 
            anchors { right: parent.right; rightMargin: 25; verticalCenter: parent.verticalCenter }
            text: selectedEngine ? selectedEngine.name : ""; color: "white"
        }
    }

    WeatherHeader {
        id: weatherHeader

        width: content.width + dateTimeHeader.width + 50
        city: weatherWindow.city

        MouseArea {
            anchors.fill: parent
            onClicked: confluence.show(weatherWindow)
        }
    }

    DateTimeHeader {
        id: dateTimeHeader
        expanded: true
        showDate: true
    }

    Rectangle {
        id: mouseGrabber
        color: "black"
        anchors.fill: parent;
        z: UIConstants.screenZValues.mouseGrabber
        opacity: 0

        Behavior on opacity {
            NumberAnimation { }
        }

        MouseArea {
            anchors.fill: parent;
            hoverEnabled: true
        }
    }

    Window {
        id: transparentVideoOverlay
        overlay: true
        onFocusChanged:
            activeFocus ? avPlayer.forceActiveFocus() : undefined
    }

    DeviceDialog {
        id: deviceDialog
    }


    Connections {
        target: runtime.deviceManager
        onDeviceAdded: {
            var d = runtime.deviceManager.getDeviceByPath(device)
            if (d.isPartition) {
                deviceDialog.device = d
                d.mount();
                confluence.showModal(deviceDialog)
            }
        }
        onDeviceRemoved: {
            deviceDialog.close()
        }
    }
}

