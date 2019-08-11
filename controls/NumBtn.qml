import QtQuick 2.0
import QtQuick.Controls 2.4

Button {
  property string number
  property TextField field

  background: Rectangle {color: parent.down ? "#4F8CC1" : "#2F6CA1"}
  width: 80
  height: 80

  Text {
    id: btnText
    color: "#ffffff"
    text: number
    horizontalAlignment: Text.AlignHCenter
    font.pointSize: 24

    anchors {
      centerIn: parent
    }
  }

  onClicked: {
    field.insert(field.text.length, number)
  }
}