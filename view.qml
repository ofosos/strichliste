import QtQuick 2.0
import QtQuick.Controls 2.4


StackView {
    id: stack
    initialItem: opener
    width: 800
    height: 600
    anchors.fill: parent

    Component {
        id: opener
        Item {

            Button {
                text: qsTr("Cart")
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                onClicked: {
                    stack.push(page2)
                }
            }

            Column {
                id: openerCol

                Button {
                    text: qsTr("Drinks")
                    onClicked: {
                        stack.push(page1)
                    }
                }

                Button {
                    text: qsTr("Pauschale")
                    onClicked: {
                        cart.addStuff("Pauschale Mitglied", 1, 3.0)
                    }
                }

                Button {
                    text: qsTr("Materialspende")
                }

                Button {
                    text: qsTr("Status")
                }

            }}

    }
    Component {

        id: page1
        Item{
            GridView {
                anchors.fill: parent

                cellWidth: 100; cellHeight: 50
                focus: true
                model: drinks

                highlight: Rectangle { width: 80; height: 40; color: "lightsteelblue" }

                delegate: Item {
                    width: 100; height: 50

                    Text {
                        id: textName
                        text: name
                    }

                    Text {
                        anchors { left: textName.right }
                        text: price
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // parent.GridView.view.currentIndex = index
                            cart.addStuff(name, 1, price)
                        }

                    }
                }
            }
            Button {
                id: btnCheckOut1
                anchors.bottom: parent.bottom
                text: "Check out " + cart.total + " Eur"
                onClicked: {
                    stack.push(rfidpage)
                    cart.startTransaction()
                }
            }
            Button {
                id: btnSwitchToCart
                anchors.left: btnCheckOut1.right
                anchors.bottom: parent.bottom
                text: "Cart"
                onClicked: {
                    stack.push(page2)
                }
            }
            Button {
                id: btnBackToOpener
                anchors.left: btnSwitchToCart.right
                anchors.bottom: parent.bottom
                text: "Back"
                onClicked: {
                    stack.pop()
                }
            }
        }}

    Component {
        id: page2
        Item {
            GridView {
                anchors.fill: parent

                cellWidth: 100; cellHeight: 50
                focus: true
                model: cart

                highlight: Rectangle { width: 80; height: 40; color: "lightsteelblue" }

                delegate: Item {
                    width: 100; height: 50

                    Text {
                        id: textQuant
                        text: quantity
                    }
                    Text {
                        anchors { left: textQuant.right }
                        id: textName
                        text: name
                    }

                    Text {
                        anchors { left: textName.right }
                        text: price
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            parent.GridView.view.currentIndex = index
                        }

                    }
                }
            }
            Button {
                id: btnBack
                anchors.bottom: parent.bottom
                text: "Back"
                onClicked: { stack.pop() }
            }
            Button {
                id: btnCheckOut2
                anchors.bottom: parent.bottom
                anchors.left: btnBack.right
                text: "Check out " + cart.total + " Eur"
                onClicked: {
                    stack.push(rfidpage)
                    cart.startTransaction()
                }
            }
        }}

    Component {
        id: rfidpage
        Item {
            Timer {
                id: timer
            }

            function delay(delayTime, cb) {
                timer.interval = delayTime;
                timer.repeat = false;
                timer.triggered.connect(cb);
                timer.start();
            }
            Connections {
                target: cart
                onCleared: {
                    failureText.visible = !cart.success
                    successText.visible = cart.success
                    delay(5000, function(){ stack.pop({item: opener}) })
                }
            }
            Text {
                id: tagText
                text: "Please insert tag"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: tagText.bottom

                id: successText
                text: "Success!"
                visible: false
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: tagText.bottom

                id: failureText
                text: "Fehler!"
                visible: false
            }
            
        }
    }

}
