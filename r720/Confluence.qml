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
import "confluence.js" as Confluence

FocusScope {
    id: confluence

    property real scalingCorrection: confluence.width == 1280 ? 1.0 : confluence.width/1280

    property string generalResourcePath: runtime.backend.resourcePath
    property string themeResourcePath: runtime.skin.path + "/3rdparty/skin.confluence"

    property int standardEasingCurve: Easing.InQuad
    property int standardAnimationDuration: 350

    property int standardHighlightRangeMode: ListView.NoHighlightRange
    property int standardHighlightMoveDuration: 400

    property bool standardItemViewWraps: true

    property variant avPlayer

    property variant rootMenuModel: ListModel { }

    // private
    property variant _browserWindow
    property variant _ticker
    property variant _weatherWindow
    property int _selectedIndex : 0
    property variant _selectedElement

    anchors.fill: parent
    focus: true
    clip: true

    function resetFocus() {
        state = ""
        mainBlade.rootMenu.forceActiveFocus()
    }

    function openLink(link) {
        if (_browserWindow) {
            _browserWindow.loadPage(link)
            confluence.show(_browserWindow)
        } else {
            runtime.backend.openUrlExternally(link)
        }
    }

    function showAboutWindow() {
        var aboutWindow = createQmlObjectFromFile("AboutWindow.qml", { deleteOnClose: true })
        show(aboutWindow)
    }

    function showSystemInfoWindow() {
        var systemInfoWindow = createQmlObjectFromFile("SystemInfoWindow.qml", { deleteOnClose: true })
        show(systemInfoWindow)
    }

    function setBackground(source) {
        background.source = source
    }

    function setActiveEngine(index) {
        var engine = rootMenuModel.get(index)

        if (!engine.visualElement) {
            engine.visualElement = createQmlObjectFromFile(engine.sourceUrl, engine.constructorArgs || {}) || { }
        }

        _selectedElement = engine.visualElement

        if (index != _selectedIndex) {
            if (Confluence.activationHandlers[index])
                Confluence.activationHandlers[index].call(engine.visualElement)
        }

        _selectedIndex = index
        show(_selectedElement)
    }

    function show(element) {
        if (_selectedElement && _selectedElement != element)
            _selectedElement.state = ""

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
            _selectedElement = transparentVideoOverlay
            state = "showingSelectedElementMaximized"
        } else {
            _selectedElement = element
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
            PropertyChanges { target: _ticker; state: "visible" }
        },
        State {
            name: "showingSelectedElement"
            PropertyChanges { target: mainBlade; state: "hidden" }
            PropertyChanges { target: avPlayer; state: "hidden" }
            PropertyChanges { target: dateTimeHeader; expanded: true; showDate: false }
            PropertyChanges { target: weatherHeader; expanded: false }
            PropertyChanges { target: homeHeader; expanded: true }
            PropertyChanges { target: currentContextHeader; expanded: true }
            PropertyChanges { target: _ticker; state: "" }
            PropertyChanges { target: _selectedElement; state: "visible" }
            PropertyChanges { target: avPlayer; state: "background" }
        },
        State {
            name: "showingSelectedElementMaximized"
            extend: "showingSelectedElement"
            PropertyChanges { target: _selectedElement; state: "maximized" }
            PropertyChanges { target: avPlayer; state: _selectedElement == transparentVideoOverlay ? "maximized" : "hidden" }
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
                    PropertyAction { target: _selectedElement; property: "state"; value: "visible" }
                }
            }
        }
    ]

    Keys.onPressed: {
        if (runtime.actionmap.eventMatch(event, ActionMapper.Menu)) {
            if (_selectedElement && _selectedElement.maximized)
                _selectedElement.maximized = false
            else
                show(mainBlade)
        } else if (event.key == Qt.Key_F12) {
            if (_selectedElement && _selectedElement.maximizable && state == "showingSelectedElement")
                _selectedElement.maximized = true
        } else if (event.key == Qt.Key_F11) {
            showAboutWindow()
        } else if (event.key == Qt.Key_F10) {
            showSystemInfoWindow()
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

    function addRootMenuItem(obj, activationHandler) {
        rootMenuModel.append(obj)
        Confluence.activationHandlers[rootMenuModel.count-1] = activationHandler
    }

    function _addRootMenuItem(rootMenuItems) {
        var engineNames = runtime.backend.loadedEngineNames()
        for (var i = 0; i < rootMenuItems.length; i++) {
            var item = rootMenuItems[i]
            if (typeof item.engine != 'undefined') {
                if (engineNames.indexOf(item.engine) == -1)
                    continue
            }

            rootMenuModel.append(item)
            if (item.onActivate)
                Confluence.activationHandlers[rootMenuModel.count-1] = item.onActivate
        }
    }

    Component.onCompleted: {
        Cursor.initialize()

        runtime.backend.loadEngines()

        _browserWindow = createQmlObjectFromFile("WebWindow.qml")
        _weatherWindow = createQmlObjectFromFile("WeatherWindow.qml")

        // ## QML Bug : without background: <something> on the first item background breaks
        var rootMenuItems = [
            { name: qsTr("App Store"), engine: "appstore", role: QMHPlugin.Store, sourceUrl: "AppStoreWindow.qml", background: null }, 
            { name: qsTr("Dashboard"), role: QMHPlugin.Dashboard, sourceUrl: "DashboardWindow.qml", background: "programs.jpg" },
            { name: qsTr("Music"), engine: "music", role: QMHPlugin.Music, sourceUrl: "MusicWindow.qml", background: "music.jpg" },
            { name: qsTr("Picture"), engine: "picture", role: QMHPlugin.Picture, sourceUrl: "PictureWindow.qml", background: "pictures.jpg" },
            { name: qsTr("Video"), engine: "video", role: QMHPlugin.Video, sourceUrl: "VideoWindow.qml", background: "videos.jpg" },
            { name: qsTr("Weather"), role: QMHPlugin.Weather, sourceUrl: "WeatherWindow.qml", visualElement: _weatherWindow, background: "weather.jpg" },
            { name: qsTr("Web"), role: QMHPlugin.Web, sourceUrl: "WebWindow.qml", visualElement: _browserWindow, background: "web.jpg", 
              onActivate: function() { this.initialUrl = "http://www.google.com"; this.enableBrowserShortcuts = true } },
            { name: qsTr("Remote App"), role: QMHPlugin.Application, sourceUrl: "RemoteAppWindow.qml" },
            { name: qsTr("Ovi Maps"), role: QMHPlugin.Map, sourceUrl: "MapsWindow.qml", background: "carta_marina.jpg" },
            { name: qsTr("Google Maps"), role: QMHPlugin.Map, sourceUrl: "WebWindow.qml", visualElement: _browserWindow, background: "carta_marina.jpg", 
              onActivate: function() { this.initialUrl =  generalResourcePath + "/googlemaps/Nokia.html"; this.enableBrowserShortcuts = false } }
        ]

        if (runtime.config.isEnabled("wk-plugins", false)) {
            rootMenuItems.push({ name: qsTr("youtube"), role: QMHPlugin.Application, visualElement: _browserWindow, 
                                 onActivate: function() { this.initialUrl = "http://www.youtube.com/xl" } })
        }

        _addRootMenuItem(rootMenuItems)

        avPlayer = createQmlObjectFromFile("AVPlayer.qml", { state: "background" }) || dummyItem

        _ticker = createQmlObjectFromFile("Ticker.qml", { z: UIConstants.screenZValues.header, state: "visible" })
        if (_ticker) {
            _ticker.linkClicked.connect(confluence.openLink)
        } else {
            _ticker = dummyItem
        }

        createQmlObjectFromFile("ScreenSaver.qml")
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
            text: _selectedIndex < rootMenuModel.count ? rootMenuModel.get(_selectedIndex).name : ""
            color: "white"
        }
    }

    WeatherHeader {
        id: weatherHeader

        width: content.width + dateTimeHeader.width + 50
        city: _weatherWindow.city

        MouseArea {
            anchors.fill: parent
            onClicked: confluence.show(_weatherWindow)
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

