import QtQuick 1.1

import Qt.labs.shaders 1.0
import Qt.labs.shaders.effects 1.0

Item {
    property variant sourceSurface: parent

    function ripple(mediaItem) {
        waveAnim.stop()
        var scenePos = confluence.mapFromItem(mediaItem.parent, mediaItem.x + mediaItem.width/2, mediaItem.y + mediaItem.height/2)
        waveLayer.waveOriginX = scenePos.x/sourceSurface.width
        waveLayer.waveOriginY = scenePos.y/sourceSurface.height
        waveLayer.visible = true
        waveAnim.start()
    }

    function stop() {
        waveLayer.visible = false
    }

    ShaderEffectSource {
        id: viewSource
        sourceItem: sourceSurface
        live: true
        hideSource: false
    }

    RadialWaveEffect {
        id: waveLayer
        visible: false
        width: sourceSurface.width; height: sourceSurface.height
        source: viewSource

        wave: 0.0
        waveOriginX: 0.5
        waveOriginY: 0.5
        waveWidth: 0.01

        NumberAnimation on wave {
            id: waveAnim
            running: waveLayer.visible
            easing.type: "InQuad"
            from: 0.0000; to: 1.0000;
            duration: 2500
        }
    }
}
