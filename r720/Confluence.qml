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
import confluence.r720.components 1.0
import "./components/uiconstants.js" as UIConstants
import "./components/cursor.js" as Cursor
import ActionMapper 1.0

FocusScope {
    id: confluence

    property real scalingCorrection: confluence.width == 1280 ? 1.0 : confluence.width/1280

    property string generalResourcePath: backend.resourcePath
    property string themeResourcePath: backend.skinPath + "/confluence/3rdparty/skin.confluence"

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

    height: 720; width: 1280
    focus: true
    clip: true

    states: [
        State {
            name:  ""
            StateChangeScript { name: "focusMainBlade"; script: mainBlade.forceActiveFocus() }
        },
        State {
            name: "showingSelectedElement"
            PropertyChanges { target: mainBlade; state: "hidden" }
            PropertyChanges { target: avPlayer; state: "hidden" }
            PropertyChanges { target: ticker; expanded: false }
            PropertyChanges { target: dateTimeHeader; expanded: true; showDate: false }
            PropertyChanges { target: weatherHeader; expanded: false }
            PropertyChanges { target: homeHeader; expanded: true }
            PropertyChanges { target: currentContextHeader; expanded: true }
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
        if (actionmap.eventMatch(event, ActionMapper.Menu)) {
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
        } else if (actionmap.eventMatch(event, ActionMapper.ContextualUp)) {
            avPlayer.increaseVolume()
        } else if (actionmap.eventMatch(event, ActionMapper.ContextualDown)) {
            avPlayer.decreaseVolume()
        } else if (actionmap.eventMatch(event, ActionMapper.MediaPlayPause)) {
            avPlayer.togglePlayPause()
        }
    }

    //FIXME: function failing here simply skips rest of init, wish they had exceptions
    Component.onCompleted: {
        Cursor.initialize()

        !!musicEngine && musicEngine && musicEngine.pluginProperties.model.setThemeResourcePath(themeResourcePath + "/media/"); // ## Shouldn't be here
        var qmlComponent = Qt.createComponent("MusicWindow.qml")
        if (!!musicEngine
                && qmlComponent.status == Component.Ready) {
            qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error)
            backend.log(qmlComponent.errorString())

        qmlComponent = Qt.createComponent("MediaWindowActionMap.qml")
        if (!!musicEngine
                && qmlComponent.status == Component.Ready) {
            musicEngine.actionMap = qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error)
            backend.log(qmlComponent.errorString())

        //FIXME: function failing here simply skips rest of init, wish they had exceptions
        !!videoEngine && videoEngine.pluginProperties.model.setThemeResourcePath(themeResourcePath + "/media/"); // ## Shouldn't be here
        qmlComponent = Qt.createComponent("VideoWindow.qml")
        if (!!videoEngine
                && qmlComponent.status == Component.Ready) {
            qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error)
            backend.log(qmlComponent.errorString())

        qmlComponent = Qt.createComponent("MediaWindowActionMap.qml")
        if (!!videoEngine
                && qmlComponent.status == Component.Ready) {
            videoEngine.actionMap = qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error)
            backend.log(qmlComponent.errorString())

        !!pictureEngine && pictureEngine.pluginProperties.model.setThemeResourcePath(themeResourcePath + "/media/"); // ## Shouldn't be here
        qmlComponent = Qt.createComponent("PictureWindow.qml")
        if (!!pictureEngine
                && qmlComponent.status == Component.Ready) {
            var pictureWindow = qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error)
            backend.log(qmlComponent.errorString())

        qmlComponent = Qt.createComponent("MediaWindowActionMap.qml")
        if (!!pictureEngine
                && qmlComponent.status == Component.Ready) {
            pictureEngine.actionMap = qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error)
            backend.log(qmlComponent.errorString())

        qmlComponent = Qt.createComponent("AVPlayer.qml");
        if (qmlComponent.status == Component.Ready) {
            avPlayer = qmlComponent.createObject(confluence)
            // FIXME: nothing to get video-path during runtime, yet
            avPlayer.state = "background"
        } else if (qmlComponent.status == Component.Error) {
            backend.log(qmlComponent.errorString())
            avPlayer = dummyItem
        }

        qmlComponent = Qt.createComponent("DashboardWindow.qml");
        if (qmlComponent.status == Component.Ready) {
            var dashboard = qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error) {
            backend.log(qmlComponent.errorString())
        }

        //No webkit
        qmlComponent = Qt.createComponent("WebWindow.qml");
        if (qmlComponent.status == Component.Ready) {
            browserWindow = qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error) {
            backend.log(qmlComponent.errorString())
        }

        //No XML patterns
        qmlComponent = Qt.createComponent("WeatherWindow.qml");
        if (qmlComponent.status == Component.Ready) {
            weatherWindow = qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error) {
            backend.log(qmlComponent.errorString())
        }

        qmlComponent = Qt.createComponent("Ticker.qml");
        if (qmlComponent.status == Component.Ready) {
            ticker = qmlComponent.createObject(confluence)
            ticker.z = UIConstants.screenZValues.header
            ticker.expanded = true;
        } else if (qmlComponent.status == Component.Error) {
            backend.log(qmlComponent.errorString())
            ticker = dummyItem
        }

        qmlComponent = Qt.createComponent("RemoteAppWindow.qml");
        if (qmlComponent.status == Component.Ready) {
            var remoteAppWindow = qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error) {
            backend.log(qmlComponent.errorString())
        }

        qmlComponent = Qt.createComponent("SystemInfoWindow.qml");
        if (qmlComponent.status == Component.Ready) {
            systemInfoWindow = qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error) {
            backend.log(qmlComponent.errorString())
        }

        qmlComponent = Qt.createComponent("MapsWindow.qml");
        if (qmlComponent.status == Component.Ready) {
            var maps = qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error) {
            backend.log(qmlComponent.errorString())
        }

        qmlComponent = Qt.createComponent("AppStoreWindow.qml");
        if (qmlComponent.status == Component.Ready) {
            var appStore = qmlComponent.createObject(confluence)
        } else if (qmlComponent.status == Component.Error) {
            backend.log(qmlComponent.errorString())
        }

        //Why would you ever want to do this from QML!
        //One property API FTW
        qmlComponent = Qt.createComponent("SystemScreenSaverControl.qml");
        if (qmlComponent.status == Component.Ready) {
            var screensaver = qmlComponent.createObject(confluence)
            !!screensaver ? screensaver.screenSaverDelayed = true : undefined
        } else if (qmlComponent.status == Component.Error) {
            backend.log(qmlComponent.errorString())
        }
    }

    function resetFocus() {
        mainBlade.rootMenu.forceActiveFocus()
    }

    function setActiveEngine(engine)
    {
        var oldEngine = selectedEngine

        selectedEngine = engine
        selectedElement = engine.visualElement

        if(oldEngine != engine)
        {
            //Don't reset the properties
            //on already selected item
            var elementProperties = engine.visualElementProperties
            for(var i = 0; i + 2 <= elementProperties.length; i += 2)
                selectedElement[elementProperties[i]] = elementProperties[i+1]
        }
        show(selectedElement)
    }

    function show(element)
    {
        !!selectedElement && selectedElement != element ? selectedElement.state = "" : undefined

        if (element == mainBlade) {
            state = ""
        } else if(element == avPlayer) {
            if(!avPlayer.hasMedia) {
                show(videoEngine.visualElement)
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
        var currentFocusedItem = frontend.focusItem();
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
        MouseArea { anchors.fill: parent; onClicked: confluence.state = "" }
    }

    Header {
        id: currentContextHeader
        atRight: false
        expanded: false

        width: contextText.width + homeHeader.width + 25
        Text { 
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


    AboutWindow { id: aboutWindow }

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

    ScreenSaver {}
}

