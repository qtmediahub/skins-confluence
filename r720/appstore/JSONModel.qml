import QtQuick 1.1
import "JSONBackend.js" as JSONBackend

ListModel {
    id: contentModel

    property string url: ""
    property variant data
    property string status: "empty"

    function refresh() {
        status = "loading"
        clear();
        JSONBackend.serverCall(url, data, function(data) {
            for (var i = 0; i < data.length; i++) {
                var entry = data[i];
                append(entry);
            }
            status = "ready"
        })
    }
}
