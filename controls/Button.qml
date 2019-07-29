import QtQuick 2.0
import QtQuick.Controls 2.4

Button {
  property string title
  property url iconPath
  property int buttonWidth: 70

  background: Rectangle {color: parent.down ? "#4F8CC1" : "#2F6CA1"}
  width: buttonWidth
  height: 70

  Text {
    color: "#ffffff"
    text: title
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
  }

  Image {
    width: 50; height: 50
    fillMode: Image.PreserveAspectFit
    source: iconPath
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
  }
}