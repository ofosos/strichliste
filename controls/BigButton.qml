import QtQuick 2.0
import QtQuick.Controls 2.4

Button {
  property string title
  property url iconPath

  background: Rectangle {color: parent.down ? "#4F8CC1" : "#2F6CA1"}

  anchors {
    topMargin: 10
    bottomMargin: 10
    leftMargin: 10
    rightMargin: 10
  }

  Item {
    width: 80
    height: 120
    anchors.centerIn: parent

    Image {
    width: 80
    height: 80
    fillMode: Image.PreserveAspectFit
    source: iconPath

    anchors {
      horizontalCenter: parent.horizontalCenter
      top: parent.top
    }
    }

    Text {
    text: title
    color: "#FFFFFF"

    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
    }
    }
  }
}