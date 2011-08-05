import QtQuick 1.0
import "../../../skins/confluence/r720" as ConfluenceResources

ConfluenceResources.AudioVisualisation {
    running: true
    width: parent.width; height: parent.height
    ConfluenceResources.AboutWindow { state: "visible" }
}
