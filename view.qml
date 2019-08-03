import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.VirtualKeyboard 2.1
import "controls" as MyControls

Rectangle {
  id: window
  width: 800
  height: 480
  color: "#184e7d"

  // Logo
  Image {
    width: 100; height: 100
    fillMode: Image.PreserveAspectFit
    source: "images/logo.png"
    anchors.left: parent.left
    anchors.top: parent.top
  }

  property string uid: "00"

  MyControls.Button {
    id: backButton
    title: qsTr("Back")
    iconPath: "images/back.png"

    anchors {
      right: parent.right
      top: parent.top
    }

    onClicked: {
      stack.pop()
    }
  }

  // cart button
  MyControls.Button {
    id: cartButton
    title: qsTr("Cart")
    iconPath: "images/cart.png"

    anchors {
      right: backButton.left
      top: parent.top
    }

    onClicked: {
      stack.push(cartPage.createObject(stack))
    }
  }

  // price text
  Text {
    id: price
    text: qsTr("%1 €").arg(cart.total)
    color: "#FFF"
    font.pointSize: 24

    anchors {
      verticalCenter: cartButton.verticalCenter
      horizontalCenter: parent.horizontalCenter
    }
  }

  /** ===============================
            frame components
      ============================== */
  // for switching frames
  StackView {
    id: stack
    initialItem: opener
    anchors {
      top: parent.top
      topMargin: 110
      left: parent.left
      right: parent.right
      bottom: parent.bottom
    }
  }

  /** ===========================
             opener menu
      =========================== */
  Component {
    id: opener

    Item {
      anchors.fill: parent

      MyControls.BigButton {
        id: drinkButton
        title: qsTr("Drinks")
        iconPath: "images/drinks.png"

        anchors {
          top: parent.top
          left: parent.horizontalCenter
          bottom: parent.verticalCenter
          right: parent.right
        }

        onClicked: {
          stack.push(drinkPage.createObject(stack))
        }
      }

      MyControls.BigButton {
        id: feeButton
        title: qsTr("Workshop fee")
        iconPath: "images/fee.png"

        anchors {
          top: parent.top
          left: parent.left
          bottom: parent.verticalCenter
          right: parent.horizontalCenter
        }

        onClicked: {
          cart.addStuff(qsTr("Day fee member"), 1, dayFee)
        }
      }

      MyControls.BigButton {
        id: donateButton
        title: qsTr("Donate for material")
        iconPath: "images/donate.png"
        background: Rectangle {color: donateButton.down ? "#4F8CC1" : "#2F6CA1"}

        anchors {
          top: parent.verticalCenter
          left: parent.left
          bottom: parent.bottom
          right: parent.horizontalCenter
        }

        onClicked: {
          stack.push(donation.createObject(stack))
        }
      }

      MyControls.BigButton {
        id: accountButton
        title: qsTr("My Account")
        iconPath: "images/account.png"

        anchors {
          top: parent.verticalCenter
          left: parent.horizontalCenter
          bottom: parent.bottom
          right: parent.right
        }

        onClicked: {
          stack.push(account.createObject(stack))
        }
      }
    }
  }

  /** ===========================
             drinks menu
      =========================== */
  Component {
    id: drinkPage

    Item {
      ListView {
        spacing: 10
        anchors.fill: parent
        focus: true
        model: drinks

        delegate: MyControls.Drink {}
      }
    }
  }

  /** ===========================
             cart page
      =========================== */
  Component {
    id: cartPage

    Item {

      MyControls.Button {
        id: payButton
        width: 150
        height: 120
        title: qsTr("Check out\n%1 €").arg(cart.total)
        iconPath: "images/pay.png"

        anchors {
          top: parent.top
          topMargin: 0
          right: parent.right
        }

        onClicked: {
          stack.push(rfidpage.createObject(stack))
          cart.startTransaction()
        }
      }

      MyControls.Button {
        id: delButton
        width: 150

        title: qsTr("Remove")
        iconPath: "images/trash.png"

        anchors {
          top: payButton.bottom
          topMargin: 10
          right: parent.right
        }
      }

      Rectangle {
        color: "#FFF"
        anchors {
          top: parent.top
          bottom: parent.bottom
          right: payButton.left
          rightMargin: 10
          left: parent.left
        }

        ListView {
          id: cartView

          anchors.fill: parent
          anchors.topMargin: 10
          spacing: 0
          focus: true

          model: cart

          delegate: MyControls.Product {}
        }
      }

    }
  }

  /** ===========================
         rfid page for checkout
      =========================== */
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
          delay(5000, function(){ stack.clear(); stack.push(opener.createObject(stack))})
        }
      }

      MyControls.RFID {
        id: tagText
      }

      Text {
        id: successText
        text: qsTr("Success")
        visible: false
        color: "#FFF"
        font.pointSize: 24

        anchors {
          horizontalCenter: parent.horizontalCenter
          top: tagText.bottom
        }
      }

      Text {
        id: failureText
        color: "red"
        font.pointSize: 24
        text: qsTr("Failure!")
        visible: false

        anchors {
          horizontalCenter: parent.horizontalCenter
          top: tagText.bottom
        }
      }
    }
  }

  /** ===========================
             donation page
      =========================== */
  Component {
    id: donation

    Item {
      anchors.fill: parent

      Column {
        spacing: 30
        anchors {
          left: parent.left
          right: parent.horizontalCenter
          top: parent.top
          bottom: parent.bottom
        }

        Text {
          id: amountTxt

          text: qsTr("Amount")
          font.pointSize:24
          color: "#FFF"

          anchors.horizontalCenter: parent.horizontalCenter
        }

        TextField {
          id: amountField
          width: 200
          font.pointSize: 24

          inputMethodHints: Qt.ImhFormattedNumbersOnly
          placeholderText: qsTr("Enter amount")

          anchors.horizontalCenter: parent.horizontalCenter
        }

        MyControls.Button {
          title: qsTr("Donate")
          iconPath: "images/donate.png"
          anchors.horizontalCenter: parent.horizontalCenter
          width: 200

          onClicked: {
            var amtTxt = amountField.text
            cart.addStuff(qsTr("Donation for material"), 1, amtTxt)
            stack.pop()
          }
        }
      }

      InputPanel {
        id: inputPanel
        y: parent.y

        anchors {
          left: parent.horizontalCenter
          right: parent.right
        }
      }
    }
  }

  /** ===========================
          my account rfid page
      =========================== */
  Component {
    id: account

    Item {
      Component.onCompleted: {
        cart.uidentered.connect(checkAccount)
        cart.fetchUid()
      }

      function checkAccount () {
        if (cart.success) {
          stack.pop()
          stack.push(accountDisplay.createObject(stack))
        } else {
          stack.pop()
        }

        cart.uidentered.disconnect(checkAccount)
      }

      MyControls.RFID {}

    }
  }

  /** ===========================
          my account page
      =========================== */
  Component {
    id: accountDisplay
    Item {
    Column {
      spacing: 30

      anchors {
        left: parent.left
        right: parent.right
        verticalCenter: parent.verticalCenter
      }

      Text {
        id: amountSpentTxt
        text: qsTr("Spent this month")
        color: "#FFF"
        font.pointSize: 24

        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        id: valueTxt
        text: qsTr("%1 €").arg(logbook.getSum(cart.uid))
        color: "#FFF"
        font.pointSize: 24

        anchors.horizontalCenter: parent.horizontalCenter
      }
    }

    MyControls.Button {
      id: uidButton
      buttonWidth: 190
      title: qsTr("Add UID")

      anchors {
        right: parent.right
        top: parent.top
      }

      onClicked: {
        stack.push(adduid.createObject(stack))
      }
    }

    MyControls.Button {
      id: addAdminButton
      buttonWidth: 190
      title: qsTr("Add admin")

      anchors {
        right: parent.right
        top: uidButton.bottom
      }

      onClicked: {
        stack.push(adminuid.createObject(stack))
      }
    }
    }
  }

    Component {
        id: adduid

        Item {
            Timer {
                id: timerauthuid
            }

            function delay(delayTime, cb) {
                timerauthuid.interval = delayTime;
                timerauthuid.repeat = false;
                timerauthuid.triggered.connect(cb);
                timerauthuid.start();
            }
            Component.onCompleted: {
                cart.uidentered.connect(goUid)
                cart.fetchUid()
            }

            function goUid () {
                if (uidmap.isAdmin(cart.uid)) {
                    delay(2000, function () {
                      stack.pop()
                      stack.push(adduid2.createObject(stack))
                    })
                } else {
                    authFailure.visible = true
                    delay(3000, function () {
                        authFailure.visible = false
                        stack.pop()
                    })
                }
                cart.uidentered.disconnect(goUid)
            }
            Rectangle {
                width: 400
                height: 400
                color: "transparent"
                Text {
                    id: insertTag2
                    text: qsTr("Please insert ADMIN tag")
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
                        top: insertTag2.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: authFailure
                    text: qsTr("Failure!")
                    color: "red"
                    visible: false
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    Component {
        id: adduid2

        Item {
            Timer {
                id: timeradduid
            }

            function delay(delayTime, cb) {
                timeradduid.interval = delayTime;
                timeradduid.repeat = false;
                timeradduid.triggered.connect(cb);
                timeradduid.start();
            }
            Component.onCompleted: {
                cart.uidentered.connect(checkAdmin)
                cart.fetchUid()
            }

            function checkAdmin () {
                if (cart.success) {
                    uidmap.addMapping(cart.uid, enterNameInput.text)
                    adduidSuccess.visible = true
                    delay(2000, function () {
                        stack.pop()
                    })
                } else {
                    adduidFailure.visible = true
                    delay(2000, function () {
                        adduidFailure.visible = false
                        stack.pop()
                    })

                }
                cart.uidentered.disconnect(checkAdmin)
            }
            Rectangle {
                width: 400
                height: 400
                color: "transparent"
                Text {
                    id: enterName
                    text: qsTr("Please enter name of new tag")
                    color: "lightsteelblue"
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                TextField {
                    id: enterNameInput
                    placeholderText: qsTr("Name...")
                    anchors {
                        top: enterName.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: insertTag3
                    text: qsTr("Please insert new user tag")
                    color: "lightsteelblue"
                    anchors {
                        top: enterNameInput.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }

                Text {
                    id: adduidSuccess
                    text: qsTr("Success!")
                    color: "lightsteelblue"
                    visible: false
                    anchors {
                        top: insertTag3.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: adduidFailure
                    text: qsTr("Failure!")
                    color: "red"
                    visible: false
                    anchors {
                        top: insertTag3.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
            }

            InputPanel {
                id: inputPanel
                y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
                anchors.left: parent.left
                anchors.right: parent.right
            }

        }
    }

    Component {
        id: adminuid

        Item {
            Timer {
                id: timeradminuid
            }

            function delay(delayTime, cb) {
                timeradminuid.interval = delayTime;
                timeradminuid.repeat = false;
                timeradminuid.triggered.connect(cb);
                timeradminuid.start();
            }
            Component.onCompleted: {
                cart.uidentered.connect(processAdmin)
                cart.fetchUid()
            }

            function processAdmin () {
                if (cart.success && uidmap.isAdmin(cart.uid)) {
                    adminuidSuccess.visible = true
                    delay(1500, function () {
                        stack.pop()
                        stack.push(adminuid2.createObject(stack))
                    })
                } else {
                    adminuidFailure.visible = true
                    delay(2000, function () {
                        adminuidFailure.visible = false
                        stack.pop()
                    })

                }
                cart.uidentered.disconnect(processAdmin)
            }
            Rectangle {
                width: 400
                height: 400
                color: "transparent"
                Text {
                    id: insertTag4
                    text: qsTr("Please insert existing ADMIN tag")
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
                        top: insertTag4.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: adminuidSuccess
                    text: qsTr("Success!")
                    color: "lightsteelblue"
                    visible: false
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: adminuidFailure
                    text: qsTr("Success!")
                    color: "lightsteelblue"
                    visible: false
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
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
    Component {
        id: adminuid2

        Item {
            property bool running: false
            Timer {
                id: timeradminuid2
            }

            function delay(delayTime, cb) {
                timeradminuid2.interval = delayTime;
                timeradminuid2.repeat = false;
                timeradminuid2.triggered.connect(cb);
                timeradminuid2.start();
            }
            Component.onCompleted: {
                cart.uidentered.connect(enterNewAdmin)
                cart.fetchUid()

                running = true
            }

            function enterNewAdmin () {
                if (cart.success) {
                    uidmap.addAdmin(cart.uid)
                    adminuid2Success.visible = true
                    delay(1500, function () {
                        stack.pop()
                    })
                } else {
                    adduidFailure.visible = true
                    delay(1500, function () {
                        adminuid2Failure.visible = false
                        stack.pop()
                    })

                }
                cart.uidentered.disconnect(enterNewAdmin)
            }
            Rectangle {
                width: 400
                height: 400
                color: "transparent"
                Text {
                    id: insertTag5
                    text: qsTr("Please insert new ADMIN tag")
                    color: "lightsteelblue"
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: adminuid2Success
                    text: qsTr("Success!")
                    color: "lightsteelblue"
                    visible: false
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: adminuid2Failure
                    text: qsTr("Success!")
                    color: "lightsteelblue"
                    visible: false
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }

                Image {
                    width: 300; height: 300
                    fillMode: Image.PreserveAspectFit
                    source: "images/rfid.png"

                    anchors {
                        top: insertTag5.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
            }
        }
    }

}
