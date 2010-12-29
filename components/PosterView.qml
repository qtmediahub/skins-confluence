import QtQuick 1.0

PathView {
    id: pathView
    property variant posterModel // Not an alias because of QTBUG-16357
    property alias rootIndex : visualDataModel.rootIndex
    property int delegateWidth : 200
    property int delegateHeight : 200
    property variant currentItem // QTBUG-16347

    signal clicked(string filePath)

    function currentModelIndex() {
        return visualDataModel.modelIndex(currentIndex);
    }

    model : visualDataModel
    pathItemCount: (width+2*delegateWidth)/delegateWidth
    preferredHighlightBegin : 0.5
    preferredHighlightEnd : 0.5

    path: Path {
        startX: -pathView.delegateWidth; startY: pathView.height/2.0
        PathAttribute { name: "scale"; value: 1 }
        PathAttribute { name: "z"; value: 1 }
        PathAttribute { name: "opacity"; value: 0.2 }
        PathLine { x: pathView.width/2.5; y: pathView.height/2.0 }
        PathAttribute { name: "scale"; value: 1.0 }
        PathLine { x: pathView.width/2.0; y: pathView.height/2.0 }
        PathAttribute { name: "scale"; value: 1.5 }
        PathAttribute { name: "z"; value: 2 }
        PathAttribute { name: "opacity"; value: 1.0 }
        PathLine { x: pathView.width/1.5; y: pathView.height/2.0 }
        PathAttribute { name: "scale"; value: 1.0 }
        PathLine { x: pathView.width+pathView.delegateWidth; y: pathView.height/2.0 }
        PathAttribute { name: "scale"; value: 1 }
        PathAttribute { name: "z"; value: 1 }
        PathAttribute { name: "opacity"; value: 0.2 }
    }

    VisualDataModel {
        id: visualDataModel
        delegate : PosterViewDelegate { }
        Component.onCompleted: {
            model = pathView.posterModel // Workaround for QTBUG-16357
            var oldRootIndex = rootIndex
            rootIndex = modelIndex(0)
            rootIndex = oldRootIndex // Workaround for QTBUG-16365
        }
    }

    Keys.onRightPressed: pathView.incrementCurrentIndex()
    Keys.onLeftPressed: pathView.decrementCurrentIndex()
}

