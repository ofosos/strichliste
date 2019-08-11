import QtQuick 2.0
import QtQuick.Controls 2.4

Rectangle {
  height: 45
  color: "transparent"

  anchors {
    right: parent.right
    left: parent.left
  }

  Text {
    id: textQuant
    text: quantity
    width: 30

    anchors {
      left: parent.left
      leftMargin: 10
      verticalCenter: parent.verticalCenter
    }
  }

  Text {
    id: textName
    text: name

    anchors {
      left: textQuant.right
      leftMargin: 10
      verticalCenter: parent.verticalCenter
    }
  }

  Text {
    text: qsTr("%1 €").arg(price)

    anchors {
      right: parent.right
      rightMargin: 10
      verticalCenter: parent.verticalCenter
    }
  }
}