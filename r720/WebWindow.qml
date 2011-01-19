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
import QtWebKit 1.0
import confluence.r720.components 1.0
import "./components/keymapping.js" as KeyMapping
import Qt.labs.Mx 1.0 as MxComponents

//TODO:
//Suspend loading of page until animation is complete
//Deactive page (flash) when no longer visible

Window {
    id: root
    focalWidget: webView

    maximizable: true

    property alias url: webView.url
    property string initialUrl: defaultUrl
    property string defaultUrl: "http://www.google.com"

    function loadPage(url) {
        webView.url = url
        webViewport.contentY = 0

        confluence.show(root)
    }

    Keys.onPressed:
        if ((event.key == Qt.Key_Down) && (event.modifiers & Qt.ShiftModifier))
            urlBar.forceActiveFocus()
        else if(KeyMapping.actionMapsToKey(KeyMapping.qmhactions.back, event))
            webviewPopup.activeFocus ? webView.forceActiveFocus() : event.accepted = false

    Panel {
        id: panel
        anchors.centerIn: parent;
        decorateFrame: !root.maximized
        Flickable {
            id: webViewport
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection:  Flickable.VerticalFlick
            property int webviewMargin: 100
            width: root.maximized ? confluence.width : confluence.width - webviewMargin
            height: root.maximized ? confluence.height : confluence.height - webviewMargin
            contentWidth: webView.width; 
            contentHeight: webView.height
            WebView {
                id: webView
                url: defaultUrl
                focus: true
                settings.sansSerifFontFamily : "DejaVu Sans"
                settings.javaEnabled: config.isEnabled("wk-java", false)
                settings.javascriptCanAccessClipboard: config.isEnabled("wk-js-clipboard", false)
                settings.javascriptCanOpenWindows: config.isEnabled("wk-js-windows", false)
                settings.javascriptEnabled: config.isEnabled("wk-js", true)
                settings.linksIncludedInFocusChain: config.isEnabled("wk-focus-links", true)
                settings.localContentCanAccessRemoteUrls: config.isEnabled("wk-local-acc-remote", true)
                settings.localStorageDatabaseEnabled: config.isEnabled("wk-local-store", true)
                settings.offlineStorageDatabaseEnabled: config.isEnabled("wk-offline-store", true)
                settings.offlineWebApplicationCacheEnabled: config.isEnabled("wk-web-app-cache", true)
                settings.printElementBackgrounds: config.isEnabled("wk-print-bg", false)
                settings.privateBrowsingEnabled: config.isEnabled("wk-private", false)
                settings.zoomTextOnly: config.isEnabled("wk-zoom-text", false)
                settings.pluginsEnabled: config.isEnabled("wk-plugins", false)
                settings.autoLoadImages: config.isEnabled("wk-auto-load-images", true)

                opacity: progress == 1 ? 1 : 0.5
                preferredWidth: webViewport.width
                //Need a default/initial value in excess of what I eventually require
                //or we see unintialized pixmap in the Flickable
                preferredHeight: confluence.height

                Behavior on opacity {
                    NumberAnimation{}
                }

                Component.onCompleted: frontend.applyWebViewFocusFix(webView) // https://bugs.webkit.org/show_bug.cgi?id=51094
            }

            Behavior on width {
                NumberAnimation { duration: confluence.standardAnimationDuration; easing.type: confluence.standardEasingCurve }
            }

            Behavior on height {
                NumberAnimation { duration: confluence.standardAnimationDuration; easing.type: confluence.standardEasingCurve }
            }
        }

        BusyIndicator {
            anchors.centerIn: webViewport
            on: webView.progress != 1
        }

    }

    FocusScope {
        id: webviewPopup
        z:10
        anchors { horizontalCenter: parent.horizontalCenter }
        y: -height
        width: childrenRect.width; height: childrenRect.height

        states: State {
            name: "visible"
            when: webviewPopup.activeFocus
            PropertyChanges {
                target: webviewPopup
                y: 0
            }
            PropertyChanges {
                target: urlEntry
                text: webView.url ? webView.url : urlEntry.defaultText
            }
        }

        Behavior on y {
            NumberAnimation {}
        }

        ConfluenceFlipable {
            id: flippable
            width: urlBar.width; height: urlBar.height

            front:
                Panel {
                id: urlBar

                onFocusChanged: {
                    urlBar.focus ? urlEntry.forceActiveFocus() : undefined
                }

                ConfluenceText {
                    id: inputLabel
                    text: "url:"
                }
                MxComponents.Entry {
                    id: urlEntry
                    property string defaultText: "http://"
                    text: defaultText
                    width: confluence.width/2
                    anchors { left: inputLabel.right; verticalCenter: inputLabel.verticalCenter }
                    hint: "url"
                    leftIconSource: generalResourcePath + "/mx-images/edit-find.png"
                    onLeftIconClicked: {
                        flippable.show(googleBar)
                    }
                    rightIconSource: generalResourcePath + "/mx-images/edit-clear.png"
                    onRightIconClicked: text=defaultText
                    onEnterPressed: {
                        webView.url = text
                        webView.forceActiveFocus()
                    }
                    Connections {
                        target: webView
                        onLoadFinished:
                            urlEntry.text = webView.url
                    }
                }
            }
            back: Panel {
                id: googleBar
                anchors.fill: parent

                onFocusChanged:
                    googleBar.focus ? googleEntry.forceActiveFocus() : undefined

                ConfluenceText {
                    id: googleLabel
                    text: "google:"
                }
                MxComponents.Entry {
                    id: googleEntry
                    anchors { left: googleLabel.right; verticalCenter: googleLabel.verticalCenter; right: parent.right }
                    hint: "Search..."
                    leftIconSource: generalResourcePath + "/mx-images/edit-clear.png"
                    onLeftIconClicked: {
                        flippable.show(urlBar)
                    }
                    rightIconSource: generalResourcePath + "/mx-images/edit-clear.png"
                    onRightIconClicked: text=""
                    onEnterPressed: {
                        webView.url = "http://www.google.com/search?q=" + text
                        webView.forceActiveFocus()
                    }
                }
            }
        }
    }

    //FIXME: need to explicitly disable when background
    //Or web content continues to play in background
    //onVisibleChanged:
    //    webView.url = visible ? initialUrl : ""
    onVisibleChanged:
        webView.url != initialUrl ? webView.url = initialUrl : undefined

    Component.onCompleted:
        //Conditional on plugins (read flash) being enabled
        config.isEnabled("wk-plugins", false)
        ? Qt.createQmlObject('\
                             import confluence.r720.components 1.0; \
                             Engine { name: qsTr("Youtube"); \
                                      role: "youtube"; \
                                      visualElement: root; \
                                      visualElementProperties: ["initialUrl", "http://www.youtube.com/xl"] }',
                             root,
                             null)
        : undefined

    //Fixme: Enable when functional
    //Engine { name: qsTr("Tv Clicker"); role: "tv-clicker"; visualElement: root; visualElementProperties: ["url", "http://tv.clicker.com/"] }
    Engine { name: qsTr("Web"); role: "web"; visualElement: root; visualElementProperties: ["initialUrl", defaultUrl] }
    Engine { name: qsTr("Store"); role: "ovi-store"; visualElement: root; visualElementProperties: ["initialUrl", "http://store.ovi.com/"] }
    Engine { name: qsTr("Maps"); role: "google-maps"; visualElement: root; visualElementProperties: ["initialUrl", generalResourcePath + "/Google\ Maps/Nokia.html"] }
}
