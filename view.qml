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

    property string uid: "00"
    
    StackView {
        id: stack
        initialItem: opener
        anchors.fill: parent
    }

    Component {
        id: opener
        Item {

            Button {
                text: qsTr("Cart")
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                onClicked: {
                    stack.push(page2.createObject(stack))
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
                        stack.push(page1.createObject(stack))
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
                        stack.push(donation.createObject(stack))
                    }
                }

                Button {
                    text: qsTr("My Account")
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    onClicked: {
                        stack.push(account.createObject(stack))
                    }
                }

                Button {
                    text: qsTr("Add UID")
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    onClicked: {
                        stack.push(adduid.createObject(stack))
                    }
                }

                Button {
                    text: qsTr("Add admin")
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    onClicked: {
                        stack.push(adminuid.createObject(stack))
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
                    stack.push(rfidpage.createObject(stack))
                    cart.startTransaction()
                }
            }
            Button {
                id: btnSwitchToCart
                anchors.left: btnCheckOut1.right
                anchors.bottom: parent.bottom
                text: "Cart"
                onClicked: {
                    stack.push(page2.createObject(stack))
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
                    stack.push(rfidpage.createObject(stack))
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
                    delay(5000, function(){ stack.clear();
                                            stack.push(opener.createObject(stack))})
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
                inputMethodHints: Qt.ImhFormattedNumbersOnly
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
                    cart.addStuff(qsTr("Donation for material"), 1, amtTxt)
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
            Rectangle {
                width: 400
                height: 400
                color: "transparent"
                Text {
                    id: insertTag2
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
                        top: insertTag2.bottom
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
        id: accountDisplay

        Rectangle {
            color: "#184e7d"

            Text {
                id: amountSpentTxt
                text: qsTr("Spent this month:")
                color: "lightsteelblue"
                anchors {
                    left: parent.left
                    top: parent.top
                    leftMargin: 10
                    topMargin: 10
                }
            }

            Text {
                id: valueTxt
                text: logbook.getSum(cart.uid)
                color: "lightsteelblue"
                anchors {
                    left: amountSpentTxt.right
                    top: parent.top
                    leftMargin: 10
                    topMargin: 10
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
                    stack.pop()
                    stack.push(adduid2.createObject(stack))
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
                    text: "Please insert ADMIN tag"
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
                    text: "Failure!"
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
                    text: "Please enter name of new tag"
                    color: "lightsteelblue"
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                TextField {
                    id: enterNameInput
                    text: "Name..."
                    anchors {
                        top: enterName.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: insertTag3
                    text: "Please insert new user tag"
                    color: "lightsteelblue"
                    anchors {
                        top: enterNameInput.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }

                Text {
                    id: adduidSuccess
                    text: "Success!"
                    color: "lightsteelblue"
                    visible: false
                    anchors {
                        top: insertTag3.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: adduidFailure
                    text: "Failure!"
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
                    text: "Please insert existing ADMIN tag"
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
                    text: "Success!"
                    color: "lightsteelblue"
                    visible: false
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: adminuidFailure
                    text: "Success!"
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
                    text: "Please insert new ADMIN tag"
                    color: "lightsteelblue"
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: adminuid2Success
                    text: "Success!"
                    color: "lightsteelblue"
                    visible: false
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Text {
                    id: adminuid2Failure
                    text: "Success!"
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
