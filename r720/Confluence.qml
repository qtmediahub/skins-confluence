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
import confluence.r720.components 1.0
import "./components/uiconstants.js" as UIConstants
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
    property variant musicWindow
    property variant videoWindow
    property variant qtcube
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
            StateChangeScript {
                name: "focusMainBlade"
                script: mainBlade.forceActiveFocus()
            }
        },
        State {
            name: "showingSelectedElement"
            PropertyChanges {
                target: mainBlade
                state: "hidden"
            }
            PropertyChanges {
                target: qtcube
                x: confluence.width
                visible: true
            }
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
            NumberAnimation { targets: [qtcube]; properties: "x,y"; easing.type: confluence.standardEasingCurve; duration: confluence.standardAnimationDuration }
        },
        Transition {
            from: "*"
            to: "showingSelectedElement"
            SequentialAnimation {
                // Move things out
                ParallelAnimation {
                    NumberAnimation { target: qtcube; properties: "x,y"; easing.type: confluence.standardEasingCurve; duration: confluence.standardAnimationDuration }
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
            handleBackout()
        } else if (event.key == Qt.Key_F12) {
            selectedElement
                    && state == "showingSelectedElement"
                    && selectedElement.maximizable
                    && (selectedElement.maximized = true);
        } else if (event.key == Qt.Key_F11) {
            show(aboutWindow)
        } else if (event.key == Qt.Key_F10) {
            show(systemInfoWindow)
        } else if (actionmap.eventMatch(event, ActionMapper.ContextualUp)) {
            avPlayer.increaseVolume()
        } else if (actionmap.eventMatch(event, ActionMapper.ContextualDown)) {
            avPlayer.decreaseVolume()
        } else if (event.key == Qt.Key_Space) {
            avPlayer.togglePlayPause()
        }
    }

    //FIXME: function failing here simply skips rest of init, wish they had exceptions
    Component.onCompleted: {
        //Create items which may or may not be present
        var customCursorLoader = Qt.createComponent("./components/Cursor.qml")
        if (customCursorLoader.status == Component.Ready)
            customCursorLoader.createObject(confluence)
        else if (customCursorLoader.status == Component.Error)
            backend.log(customCursorLoader.errorString())

        !!musicEngine && musicEngine && musicEngine.pluginProperties.model.setThemeResourcePath(themeResourcePath + "/media/"); // ## Shouldn't be here
        var musicWindowLoader = Qt.createComponent("MusicWindow.qml")
        if (!!musicEngine
                && musicWindowLoader.status == Component.Ready) {
            musicWindow = musicWindowLoader.createObject(confluence)
        } else if (musicWindowLoader.status == Component.Error)
            backend.log(musicWindowLoader.errorString())

        //FIXME: function failing here simply skips rest of init, wish they had exceptions
        !!videoEngine && videoEngine.pluginProperties.model.setThemeResourcePath(themeResourcePath + "/media/"); // ## Shouldn't be here
        var videoWindowLoader = Qt.createComponent("VideoWindow.qml")
        if (!!videoEngine
                && videoWindowLoader.status == Component.Ready) {
            videoWindow = videoWindowLoader.createObject(confluence)
        } else if (videoWindowLoader.status == Component.Error)
            backend.log(videoWindowLoader.errorString())

        !!pictureEngine && pictureEngine.pluginProperties.model.setThemeResourcePath(themeResourcePath + "/media/"); // ## Shouldn't be here
        var pictureWindowLoader = Qt.createComponent("PictureWindow.qml")
        if (!!pictureEngine
                && pictureWindowLoader.status == Component.Ready) {
            var pictureWindow = pictureWindowLoader.createObject(confluence)
        } else if (pictureWindowLoader.status == Component.Error)
            backend.log(pictureWindowLoader.errorString())

        var avPlayerComponent = Qt.createComponent("AVPlayer.qml");
        if (avPlayerComponent.status == Component.Ready) {
            avPlayer = avPlayerComponent.createObject(confluence)
            // FIXME: nothing to get video-path during runtime, yet
            avPlayer.state = "background"
        } else if (avPlayerComponent.status == Component.Error) {
            backend.log(avPlayerComponent.errorString())
            avPlayer = dummyItem
        }

        var dashboardLoader = Qt.createComponent("DashboardWindow.qml");
        if (dashboardLoader.status == Component.Ready) {
            var dashboard = dashboardLoader.createObject(confluence)
        } else if (dashboardLoader.status == Component.Error) {
            backend.log(dashboardLoader.errorString())
        }

        //No webkit
        var webLoader = Qt.createComponent("WebWindow.qml");
        if (webLoader.status == Component.Ready) {
            browserWindow = webLoader.createObject(confluence)
        } else if (webLoader.status == Component.Error) {
            backend.log(webLoader.errorString())
        }

        //No XML patterns
        var weatherLoader = Qt.createComponent("WeatherWindow.qml");
        if (weatherLoader.status == Component.Ready) {
            weatherWindow = weatherLoader.createObject(confluence)
        } else if (weatherLoader.status == Component.Error) {
            backend.log(weatherLoader.errorString())
        }

        var tickerLoader = Qt.createComponent("Ticker.qml");
        if (tickerLoader.status == Component.Ready) {
            ticker = tickerLoader.createObject(confluence)
            ticker.z = UIConstants.screenZValues.header
            ticker.expanded = true;
        } else if (tickerLoader.status == Component.Error) {
            backend.log(tickerLoader.errorString())
            ticker = dummyItem
        }

        //no qt3d
        var qtCubeLoader = Qt.createComponent(generalResourcePath + "/misc/cube/cube.qml")
        if (qtCubeLoader.status == Component.Ready) {
            qtcube = qtCubeLoader.createObject(confluence)
            qtcube.anchors.top = confluence.top
            qtcube.z = UIConstants.screenZValues.header
            qtcube.visible = true
            Qt.createQmlObject("import QtQuick 1.0; Binding { target: qtcube; property: 'x'; value: confluence.width - qtcube.width }", qtcube)
        } else if (qtCubeLoader.status == Component.Error) {
            backend.log(qtCubeLoader.errorString())
            qtcube = dummyItem
        }

        var remoteAppLoader = Qt.createComponent("RemoteAppWindow.qml");
        if (remoteAppLoader.status == Component.Ready) {
            var remoteAppWindow = remoteAppLoader.createObject(confluence)
        } else if (remoteAppLoader.status == Component.Error) {
            backend.log(remoteAppLoader.errorString())
        }

        var systemInfoLoader = Qt.createComponent("SystemInfoWindow.qml");
        if (systemInfoLoader.status == Component.Ready) {
            systemInfoWindow = systemInfoLoader.createObject(confluence)
        } else if (systemInfoLoader.status == Component.Error) {
            backend.log(systemInfoLoader.errorString())
        }

        var mapsLoader = Qt.createComponent("MapsWindow.qml");
        if (mapsLoader.status == Component.Ready) {
            var maps = mapsLoader.createObject(confluence)
        } else if (mapsLoader.status == Component.Error) {
            backend.log(mapsLoader.errorString())
        }

        //Why would you ever want to do this from QML!
        //One property API FTW
        var screensaverLoader = Qt.createComponent("SystemScreenSaverControl.qml");
        if (screensaverLoader.status == Component.Ready) {
            var screensaver = screensaverLoader.createObject(confluence)
            !!screensaver ? screensaver.screenSaverDelayed = true : undefined
        } else if (screensaverLoader.status == Component.Error) {
            backend.log(screensaverLoader.errorString())
        }
    }

    function resetFocus() {
        mainBlade.rootMenu.forceActiveFocus()
    }

    function handleBackout()
    {
        if(selectedElement && selectedElement.maximized)
            selectedElement.maximized = false
        else if(confluence.state == "" && avPlayer.playing)
            show(transparentVideoOverlay)
        else if(confluence.state == "" && !!selectedElement)
            show(selectedElement)
        else
            show(mainBlade)
    }

    function setActiveEngine(engine)
    {
        if(selectedEngine != engine)
        {
            selectedEngine = engine
            selectedElement = engine.visualElement
            var elementProperties = engine.visualElementProperties
            for(var i = 0; i + 2 <= elementProperties.length; i += 2)
                selectedElement[elementProperties[i]] = elementProperties[i+1]
        }
        show(selectedElement)
    }

    function show(element)
    {
        if (element == mainBlade) {
            state = ""
        } else if(element == avPlayer) {
            if(!avPlayer.hasMedia) {
                show(videoWindow)
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
            MouseArea { anchors.fill: parent; onClicked: confluence.state = "" }
        }
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

