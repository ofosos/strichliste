import QtQuick 2.0
import QtQuick.Controls 2.4

Item {
  width: 400
  height: 280

  anchors {
    horizontalCenter: parent.horizontalCenter
    verticalCenter: parent.verticalCenter
  }

  Text {
    id: insertTag
    text: qsTr("Please insert tag")
    color: "#FFF"

    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
    }
  }

  Image {
    width: 250; height: 250
    fillMode: Image.PreserveAspectFit
    source: "../images/rfid.png"

    anchors {
      top: insertTag.bottom
      horizontalCenter: parent.horizontalCenter
    }
  }
}