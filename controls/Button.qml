import QtQuick 2.0
import QtQuick.Controls 2.4

Button {
  property string title
  property url iconPath
  property int buttonWidth: 90

  background: Rectangle {color: parent.down ? "#4F8CC1" : "#2F6CA1"}
  width: buttonWidth
  height: 90

  anchors {
    topMargin: 10
    rightMargin: 10
  }

  Text {
    id: btnText
    color: "#ffffff"
    text: title
    horizontalAlignment: Text.AlignHCenter

    anchors {
      bottom: parent.bottom
      bottomMargin: 10
      horizontalCenter: parent.horizontalCenter
    }
  }

  Image {
    height: 40
    fillMode: Image.PreserveAspectFit
    source: iconPath

    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: btnText.top
      bottomMargin: 0
    }
  }
}