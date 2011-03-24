import QtQuick 1.1
import "components/"
import ActionMapper 1.0
import "components/"

FocusScope {

    property alias urlBar: urlBar
    property alias googleBar: googleBar

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
            Entry {
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

                Keys.onPressed:
                    if (actionmap.eventMatch(event, ActionMapper.Enter)) {
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
            Entry {
                id: googleEntry
                anchors { left: googleLabel.right; verticalCenter: googleLabel.verticalCenter; right: parent.right }
                hint: "Search..."
                leftIconSource: generalResourcePath + "/mx-images/edit-clear.png"
                onLeftIconClicked: {
                    flippable.show(urlBar)
                }
                rightIconSource: generalResourcePath + "/mx-images/edit-clear.png"
                onRightIconClicked: text=""
                Keys.onPressed:
                    if (actionmap.eventMatch(event, ActionMapper.Enter)) {
                    webView.url = "http://www.google.com/search?q=" + text
                    webView.forceActiveFocus()
                }
            }
        }
    }
}
