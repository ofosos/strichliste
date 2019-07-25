import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.VirtualKeyboard 2.1

Rectangle {
    id: window
    width: 800
    height: 600
    color: "#184e7d"

    Image {
        width: 100; height: 100
        fillMode: Image.PreserveAspectFit
        source: "images/logo.png"
        anchors.right: parent.right
        anchors.top: parent.top
    }

    
    StackView {
        id: stack
        initialItem: opener
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
                    width: 200
                    anchors {
                        left: parent.left
                    }

                    Button {
                        text: qsTr("Drinks")
                        onClicked: {
                            stack.push(page1)
                        }
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                    }

                    Button {
                        text: qsTr("Workshop fee")
                        onClicked: {
                            cart.addStuff("Pauschale Mitglied", 1, 3.0)
                        }
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                    }

                    Button {
                        text: qsTr("Donate for material")
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        onClicked: {
                            stack.push(donation)
                        }
                    }

                    Button {
                        text: qsTr("My Account")
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                    }

                }}

        }
        Component {

            id: page1
            Item{
                GridView {
                    anchors.fill: parent

                    cellWidth: 200; cellHeight: 50
                    focus: true
                    model: drinks

                    delegate: Item {
                        width: 200
                        height: 50

                        Rectangle {
                            width: 190;
                            height: 40;
                            color: "lightsteelblue"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Button {
                            anchors.fill: parent
                            
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                id: textName
                                text: name
                            }
                            Text {
                                anchors.left: textName.right
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: price + "€"
                            }
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
                    text: "Check out " + cart.total + "€"
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
                Rectangle {
                    width: 600
                    color: "lightsteelblue"
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                    }

                    GridView {
                        anchors.fill: parent

                        cellWidth: 600; cellHeight: 50
                        focus: true
                        model: cart

                        highlight: Rectangle {
                            width: 600;
                            height: 40;
                            color: "white"
                            anchors {
                                leftMargin: 5
                            }
                        }

                        delegate: Rectangle {
                            width: 590; height: 50
                            color: "transparent"

                            Text {
                                id: textQuant
                                text: quantity
                                width: 50
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                            Text {
                                anchors {
                                    left: textQuant.right
                                    leftMargin: 10
                                    verticalCenter: parent.verticalCenter
                                }
                                id: textName
                                text: name
                            }

                            Text {
                                anchors {
                                    right: parent.right
                                    rightMargin: 20
                                    verticalCenter: parent.verticalCenter
                                }
                                text: price + "€"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    parent.GridView.view.currentIndex = index
                                }

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
                    text: "Check out " + cart.total + "€"
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
                Rectangle {
                    id: tagText
                    width: 400
                    height: 400
                    color: "transparent"
                    Text {
                        id: insertTag
                        text: "Please insert tag"
                        color: "lightsteelblue"
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                    Image {
                        width: 300; height: 300
                        fillMode: Image.PreserveAspectFit
                        source: "images/rfid.png"

                        anchors {
                            top: insertTag.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: tagText.bottom
                    color: "lightsteelblue"
                    id: successText
                    text: "Success!"
                    visible: false
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: tagText.bottom
                    color: "red"
                    id: failureText
                    text: "Fehler!"
                    visible: false
                }
                
            }
        }

        Component {
            id: donation

            Rectangle {
                color: "#184e7d"

                Text {
                    id: amountTxt
                    text: qsTr("Amount:")
                    color: "lightsteelblue"
                    anchors {
                        left: parent.left
                        top: parent.top
                        leftMargin: 10
                        topMargin: 10
                    }
                }
                
                TextField {
                    id: amountField
                    anchors {
                        left: amountTxt.right
                        leftMargin: 10
                    }
                    placeholderText: qsTr("Enter amount")
                }

                Button {
                    text: qsTr("Donate")
                    onClicked: {
                        var amtTxt = amountField.text
                        var amt = parseFloat(amtTxt)
                        cart.addStuff(qsTr("Donation for material"), 1, amt)
                        stack.pop()
                    }
                    anchors {
                        left: amountField.right
                        leftMargin: 10
                    }
                }

                InputPanel {
                    id: inputPanel
                    y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                Button {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    text: qsTr("Back")
                    onClicked: {
                        stack.pop()
                    }
                }
            }
        }


    }
}
