import QtQuick 2.0
import QtQuick.Controls 2.4

Button {
  height: 60
  background: Rectangle {color: parent.down ? "#4F8CC1" : "#2F6CA1"}

  anchors {
    right: parent.right
    rightMargin: 10
    left: parent.left
    leftMargin: 10
  }

  Text {
    text: name
    color: "#FFF"

    anchors {
      left: parent.left
      leftMargin: 30
      verticalCenter: parent.verticalCenter
    }
  }

  Text {
    text: price + " €"
    color: "#FFF"

    anchors {
      right: parent.right
      rightMargin: 30
      verticalCenter: parent.verticalCenter
    }
  }

    onClicked: {
            cart.addStuff(name, 1, price)
          }

          }