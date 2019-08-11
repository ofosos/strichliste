import QtQuick 2.0
import QtQuick.Controls 2.4

Button {
  height: 100
  width: 185
  background: Rectangle {color: parent.down ? "#4F8CC1" : "#2F6CA1"}

  Item {
    height: 60

    anchors.centerIn: parent

    Text {
      id: nameTxt
      text: name
      color: "#FFF"

      anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter
      }
    }

    Text {
      text: qsTr("%1 €").arg(price)
      color: "#FFF"

      anchors {
        bottom: parent.bottom

        horizontalCenter: parent.horizontalCenter
      }
    }
  }

  onClicked: {
    cart.addStuff(name, 1, price)
  }

}