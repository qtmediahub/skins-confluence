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
import confluence.components 1.0

Window {
    id: root

    focalWidget: forecastPanel

    anchors.fill: parent

    property string city: "Munich"

    function fahrenheit2celsius(f) {
        return ((f-32)*5/9.0).toFixed(0);
    }

    function showCast(name) {
        city=name;
        weather.opacity=1.0;
    }

    function fullWeekDay(name) {
        var map = {
            "Mon" : qsTr("MONDAY"),
            "Tue" : qsTr("TUESDAY"),
            "Wed" : qsTr("WEDNESDAY"),
            "Thu" : qsTr("THURSDAY"),
            "Fri" : qsTr("FRIDAY"),
            "Sat" : qsTr("SATURDAY"),
            "Sun" : qsTr("SUNDAY"),
    };
        return map[name];
    }

    function mapIcon(name) {
        var i = name.lastIndexOf("/")+1;
        var sn = themeResourcePath+"/media/weathericons/"+name.substr(i, name.length-i-4)+".png";
        return sn;
    }

    function stripLast5(string) {
        return (string.substr(0, string.length-5))
    }

    bladeComponent: Blade {
        parent: root
        bladeWidth: banner.x + banner.width + 50
        bladePixmap: themeResourcePath + "/media/HomeBlade.png"

        hoverEnabled: true
        onEntered: open();
        onExited: close()

        content: Column {
            anchors.fill: parent
            anchors.topMargin: 50
            anchors.leftMargin: closedBladePeek + 5
            anchors.rightMargin: 5

            Image {
                id: banner
                source: themeResourcePath + "/media/Confluence_Logo.png"
                anchors.bottomMargin: 10
            }

            ConfluenceListView {
                id: listView
                anchors { top: banner.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }

                focus: true
                clip: true
                model: cityList
                delegate: Item {
                    id: delegate
                    width: listView.width
                    height: thistext.height + 8
                    Image {
                        anchors.fill: parent;
                        source: themeResourcePath + "/media/" + (ListView.isCurrentItem ? "MenuItemFO.png" : "MenuItemNF.png");
                    }
                    Text {
                        id: thistext
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        font.pointSize: 16
                        text: name
                    }
                    MouseArea {
                        anchors.fill: parent;
                        hoverEnabled: true
                        onEntered:
                            ListView.view.currentIndex = index
                        onClicked:
                            showCast(name)
                    }
                    Keys.onReturnPressed: {
                        showCast(name)
                        event.accepted = true
                    }
                }
            }
        }
    }

    Row {
        id: weather
        anchors.centerIn: parent
        spacing: 60

        Panel {
            width: root.width/2.0 - weather.spacing*2
            height: root.height/1.3

            Item {
                id: currentWeather
                anchors.fill: parent

                Column {
                    anchors.fill: parent
                    anchors.margins: 30
                    spacing: 5

                    ConfluenceText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("CURRENT TEMP")
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
                        text: weatherModel.count > 0 ? "Last Updated - " + stripLast5(weatherModel.get(0).current_date_time) : ""
                    }

                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width/1.3
                        height: 220
                        Text {
                            id: weatherDegree
                            color: "white"
                            font.pointSize: 64
                            text: weatherMeasurements.count > 0 ? weatherMeasurements.get(0).temp_c : "0"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                        }

                        ConfluenceText {
                            text: qsTr("°C")
                            anchors.verticalCenter: weatherDegree.top
                            anchors.left: weatherDegree.right; anchors.leftMargin: 10
                        }

                        Image {
                            id: weatherIcon
                            width: 120
                            height: width
                            smooth: true
                            asynchronous: true
                            source: weatherMeasurements.count > 0 ? mapIcon(weatherMeasurements.get(0).icon) : ""
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
            }
        }

        Panel {
            id: forecastPanel
            width: root.width/2.0 - weather.spacing*2
            height: root.height/1.3

            Column {
                anchors.fill: parent
                spacing: 40

                ConfluenceText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("WEATHER FORECAST")
                }

                ListView {
                    id: forecastListView
                    height: 500
                    width: parent.width
                    clip: true
                    model: weatherForecast
                    delegate:
                        Item {
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
                            text: weatherForecast.count > 0 && weatherForecast.get(index) ? fullWeekDay(weatherForecast.get(index).day_of_week) : ""
                        }

                        Text {
                            id: hightemptext
                            anchors.top: dayofweek.bottom
                            smooth: true
                            font.pointSize: 20
                            color: "grey"
                            text: qsTr("High: ")
                        }
                        ConfluenceText {
                            id: hightempvalue
                            anchors.top: dayofweek.bottom
                            anchors.left: hightemptext.right
                            font.weight: Font.Normal
                            text: weatherForecast.count > 0 && weatherForecast.get(index) ? root.fahrenheit2celsius(weatherForecast.get(index).high_f) + " °C" : ""
                        }

                        Text {
                            id: lowtemptext
                            anchors.top: dayofweek.bottom
                            anchors.left: hightempvalue.right; anchors.leftMargin: 25
                            smooth: true
                            font.pointSize: 20
                            color: "grey"
                            text: qsTr("Low: ")
                        }
                        ConfluenceText {
                            anchors.left: lowtemptext.right;
                            anchors.top: dayofweek.bottom
                            font.weight: Font.Normal
                            text: weatherForecast.count > 0 && weatherForecast.get(index) ? root.fahrenheit2celsius(weatherForecast.get(index).low_f)  + " °C" : ""
                        }

                        ConfluenceText {
                            id: condition
                            anchors.top: hightemptext.bottom
                            font.weight: Font.Normal
                            text: weatherForecast.count > 0 && weatherForecast.get(index) ? weatherForecast.get(index).condition : ""
                        }

                        Image {
                            width: parent.height/1.5
                            height: width
                            smooth: true
                            asynchronous: true
                            source: weatherForecast.count > 0 && weatherForecast.get(index) ? mapIcon(weatherForecast.get(index).icon) : ""
                            anchors.right: parent.right
                            anchors.bottom: condition.bottom
                        }
                    }
                }
            }
        }

        Behavior on opacity { PropertyAnimation { duration: 500 } }
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
        ListElement { name: "Bangalore" }
        ListElement { name: "Bangkok" }
        ListElement { name: "Beijing" }
        ListElement { name: "Berlin" }
        ListElement { name: "Bogota" }
        ListElement { name: "Boston" }
        ListElement { name: "Cape Town" }
        ListElement { name: "Casablanca" }
        ListElement { name: "Durban" }
        ListElement { name: "Helsinki" }
        ListElement { name: "Juneau" }
        ListElement { name: "Landshut" }
        ListElement { name: "Lhasa" }
        ListElement { name: "Lima" }
        ListElement { name: "London" }
        ListElement { name: "Manila" }
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
