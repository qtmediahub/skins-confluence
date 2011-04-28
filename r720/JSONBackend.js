.pragma library

function serverCall(url, data, dataReadyFunction) {
    var i = 0
    for (var key in data)
    {
        if (i === 0) {
            url += "?" + key + "=" + data[key];
        } else {
            url += "&" + key+ "=" + data[key];
        }
        i++
    }

    var xhr = new XMLHttpRequest();
    console.log("HTTP GET to " + url);
    xhr.open("GET", url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.DONE) {
            //print(xhr.responseText);

            if(xhr.responseText !== "") {
                var data = JSON.parse(xhr.responseText);
                return dataReadyFunction(data)
            } else {
                return dataReadyFunction(0)
            }
        }
    }
    xhr.send();
}
