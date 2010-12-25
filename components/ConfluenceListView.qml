import QtQuick 1.0

ListView {
    id: listView

    ScrollBar {
        id: verticalScrollBar
        flickable: listView
    }
}

