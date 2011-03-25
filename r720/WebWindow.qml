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
import QtWebKit 1.0
import ActionMapper 1.0
import "components/"

//TODO:
//Suspend loading of page until animation is complete
//Deactive page (flash) when no longer visible

Window {
    id: root
    focalWidget: webView

    maximizable: true

    property string enabledBrowserShortcuts
    property variant webviewPopup
    property alias url: webView.url
    property string initialUrl: defaultUrl
    property string defaultUrl: "http://www.google.com"

    function loadPage(url) {
        webView.url = url
        webViewport.contentY = 0

        confluence.show(root)
    }

    bladeComponent: MediaWindowBlade {
        parent: root
        visible: true

        actionList: [
            ConfluenceAction {
                text: qsTr("Reload")
                onTriggered: {
                    webView.reload.trigger()
                    close()
                }
            }
        ]
    }

    Keys.enabled: enabledBrowserShortcuts == ""

    Keys.onPressed:
        if (actionmap.eventMatch(event, ActionMapper.Up))
            webViewport.contentY = Math.max(0, webViewport.contentY - 10)
        else if (actionmap.eventMatch(event, ActionMapper.Down))
            webViewport.contentY = Math.min(webViewport.contentHeight - height, webViewport.contentY + 10)
        else if (actionmap.eventMatch(event, ActionMapper.Menu))
            webviewPopup.activeFocus ? webView.forceActiveFocus() : event.accepted = false
        else if (actionmap.eventMatch(event, ActionMapper.Right))
            webviewPopup.urlBar.forceActiveFocus()

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
                ConfluenceAnimation { }
            }

            Behavior on height {
                ConfluenceAnimation { }
            }
        }

        BusyIndicator {
            anchors.centerIn: webViewport
            on: webView.progress != 1
        }

    }

    //FIXME: need to explicitly disable when background
    //Or web content continues to play in background
    //onVisibleChanged:
    //    webView.url = visible ? initialUrl : ""
    onVisibleChanged:
        webView.url != initialUrl ? webView.url = initialUrl : undefined
    onInitialUrlChanged:
        enabledBrowserShortcuts = ""

    Component.onCompleted: {
        //Conditional on plugins (read flash) being enabled
        config.isEnabled("wk-plugins", false)
        ? Qt.createQmlObject('\
                             import "components/"; \
                             Engine { name: qsTr("Youtube"); \
                                      role: "youtube"; \
                                      visualElement: root; \
                                      visualElementProperties: ["initialUrl", "http://www.youtube.com/xl"] }',
                             root,
                             null)
        : undefined

        var popupLoader = Qt.createComponent("WebPopup.qml");
        if (popupLoader.status == Component.Ready) {
            webviewPopup = popupLoader.createObject(root)
        } else if (popupLoader.status == Component.Error) {
            backend.log(popupLoader.errorString())
        }
    }

    //Fixme: Enable when functional
    //Engine { name: qsTr("Tv Clicker"); role: "tv-clicker"; visualElement: root; visualElementProperties: ["url", "http://tv.clicker.com/"] }
    Engine { name: qsTr("Web"); role: "web"; visualElement: root; visualElementProperties: ["initialUrl", defaultUrl] }
    Engine { name: qsTr("Maps"); role: "google-maps"; visualElement: root; visualElementProperties: ["initialUrl", generalResourcePath + "/googlemaps/Nokia.html", "enabledBrowserShortcuts", "false"] }
}
