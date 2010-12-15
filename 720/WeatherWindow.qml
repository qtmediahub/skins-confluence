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
import "../components"

Window {
    id: root

    property string city: "Munich"

    function fahrenheit2celsius(f) {
        return ((f-32)*5/9.0).toFixed(0);
    }

    Row {
        id: weather
        anchors.centerIn: parent
        spacing: 60
        Panel {
            id: dialog1

            FocusScope {
                width: 480
                height: 600
                id: currentWeather

                Column {
                    anchors.fill: parent
                    anchors.margins: 30
                    spacing: 5
                    ConfluenceText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "CURRENT TEMP"
                    }

                    ConfluenceText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: weatherModel.count > 0 ? weatherModel.get(0).city : ""
                    }

                    Text {
                        color: "grey"
                        font.pointSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: weatherModel.count > 0 ? "Last Updated - " + weatherModel.get(0).current_date_time : ""
                    }

                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width/1.3
                        height: 220
                        Text {
                            id: weatherDegree
                            color: "white"
                            font.pointSize: 64
                            font.bold: true
                            text: weatherMeasurements.count > 0 ? weatherMeasurements.get(0).temp_c : "0"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                        }

                        ConfluenceText {
                            text: "°C"
                            anchors.verticalCenter: weatherDegree.top
                            anchors.left: weatherDegree.right; anchors.leftMargin: 10
                        }

                        Image {
                            id: weatherIcon
                            width: 120
                            height: width
                            smooth: true
                            asynchronous: true
                            source: weatherMeasurements.count > 0 ? "http://www.google.com" + weatherMeasurements.get(0).icon : ""
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    ConfluenceText {
                        height: 100
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: weatherMeasurements.count > 0 ? weatherMeasurements.get(0).condition : ""
                    }

                    ConfluenceText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: weatherMeasurements.count > 0 ? weatherMeasurements.get(0).humidity : ""
                    }
                    ConfluenceText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: weatherMeasurements.count > 0 ? weatherMeasurements.get(0).wind_condition : ""
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        cityListView.state = ""
                        weather.opacity=0.5
                    }
                }
            }
        }

        Panel {
            id: dialog0

            Column {
                anchors.centerIn: parent
                width: 480
                height: 600
                anchors.margins: 40
                spacing: 40

                ConfluenceText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "WEATHER FORECAST"
                }

                ListView {
                    id: forecastListView
                    height: 500
                    width: parent.width
                    clip: true
                    model: weatherForecast
                    delegate: Item {
                        height: 120
                        width: forecastListView.width

                        Rectangle {
                            id: sep
                            width: forecastListView.width
                            height: 4
                            radius: 2
                            color: "#40FFFFFF"
                            anchors.topMargin: 5
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        ConfluenceText {
                            id: dayofweek
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: sep.bottom; anchors.topMargin: 8
                            text: weatherForecast.count > 0 && weatherForecast.get(index) ? weatherForecast.get(index).day_of_week : ""
                        }
                        ConfluenceText {
                            id: hightemp
                            anchors.top: dayofweek.bottom
                            text: weatherForecast.count > 0 && weatherForecast.get(index) ? "High: " + root.fahrenheit2celsius(weatherForecast.get(index).high_f) + " °C" : ""
                        }

                        ConfluenceText {
                            anchors.left: hightemp.right; anchors.leftMargin: 25
                            anchors.top: dayofweek.bottom
                            text: weatherForecast.count > 0 && weatherForecast.get(index) ? "Low: " + root.fahrenheit2celsius(weatherForecast.get(index).low_f)  + " °C" : ""
                        }
                        ConfluenceText {
                            id: condition
                            anchors.top: hightemp.bottom
                            text: weatherForecast.count > 0 && weatherForecast.get(index) ? weatherForecast.get(index).condition : ""
                        }
                        Image {
                            width: parent.height/1.5
                            height: width
                            smooth: true
                            asynchronous: true
                            source: weatherForecast.count > 0 && weatherForecast.get(index)  ? "http://www.google.com" + weatherForecast.get(index).icon : ""
                            anchors.right: parent.right
                            anchors.bottom: condition.bottom
                        }
                    }
                }
            }
        }

        Behavior on opacity { PropertyAnimation { duration: 500 } }
    }

    Panel {
        id: cityListView
        width: 400
        height: 600
        x: (root.width-width)/2
        y: (root.height-height)/2
        state: "hide"

        ListView {
            anchors.margins: 30
            anchors.fill: parent
            model: cityList
            delegate: ConfluenceText {
                text: name
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        city=name
                        weather.opacity=1.0
                        cityListView.state = "hide"
                    }
                }
            }
        }

        states: State {
             name: "hide"
             PropertyChanges { target: cityListView; x:-cityListView.width; opacity: 0 }
        }

        transitions: Transition {
            PropertyAnimation { properties: "x,opacity"; duration: 1000; easing.type: Easing.OutBack }
        }
    }


    XmlListModel {
        id: weatherModel
        source: "http://www.google.com/ig/api?weather=" + city
        query: "/xml_api_reply/weather/forecast_information"

        //forecast information
        XmlRole { name: "city"; query: "city/@data/string()" }
        XmlRole { name: "forecast_date"; query: "forecast_date/@data/string()" }
        XmlRole { name: "current_date_time"; query: "current_date_time/@data/string()" }
    }

    XmlListModel {
        id: weatherMeasurements
        source: "http://www.google.com/ig/api?weather=" + city
        query: "/xml_api_reply/weather/current_conditions"

        //current condition
        XmlRole { name: "condition"; query: "condition/@data/string()" }
        XmlRole { name: "temp_c"; query: "temp_c/@data/string()" }
        XmlRole { name: "humidity"; query: "humidity/@data/string()" }
        XmlRole { name: "icon"; query: "icon/@data/string()" }
        XmlRole { name: "wind_condition"; query: "wind_condition/@data/string()" }

    }

    XmlListModel {
        id: weatherForecast
        source: "http://www.google.com/ig/api?weather=" + city
        query: "/xml_api_reply/weather/forecast_conditions"

        XmlRole { name: "day_of_week"; query: "day_of_week/@data/string()" }
        XmlRole { name: "low_f"; query: "low/@data/string()" }
        XmlRole { name: "high_f"; query: "high/@data/string()" }
        XmlRole { name: "icon"; query: "icon/@data/string()" }
        XmlRole { name: "condition"; query: "condition/@data/string()" }

    }

    ListModel {
        id: cityList
        ListElement { name: "Atlanta" }
        ListElement { name: "Bangkok" }
        ListElement { name: "Beijing" }
        ListElement { name: "Berlin" }
        ListElement { name: "Bogota" }
        ListElement { name: "Boston" }
        ListElement { name: "Cape Town" }
        ListElement { name: "Casablanca" }
        ListElement { name: "Helsinki" }
        ListElement { name: "Juneau" }
        ListElement { name: "Landshut" }
        ListElement { name: "Lhasa" }
        ListElement { name: "Lima" }
        ListElement { name: "London" }
        ListElement { name: "Munich" }
        ListElement { name: "Moscow" }
        ListElement { name: "New York" }
        ListElement { name: "Nuuk" }
        ListElement { name: "Paris" }
        ListElement { name: "Rome" }
        ListElement { name: "San Francisco" }
        ListElement { name: "Sydney" }
        ListElement { name: "Timbuktu" }
        ListElement { name: "Tokyo" }
        ListElement { name: "Ulm" }
        ListElement { name: "Untermarchtal" }
    }

    Engine { name: qsTr("Weather"); role: "weather"; visualElement: root }
}