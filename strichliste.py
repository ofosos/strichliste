#!/usr/bin/env python
# -*- conding: utf-8 -*-

from datetime import datetime
import json
import os
import sys

from PySide2.QtCore import Qt, QUrl, QObject, Slot,\
    QAbstractListModel, Property, Signal, QRunnable, QThreadPool
from PySide2.QtGui import QGuiApplication, QFont
from PySide2.QtQuick import QQuickView
from PySide2 import QtCore


class Drink(QObject):
    def __init__(self, name, price):
        super(Drink, self).__init__()
        self._name = name
        self._price = price

    @Property(str)
    def price(self):
        return self._price

    @Property(str)
    def name(self):
        return self._name


class DrinkList(QAbstractListModel):

    items = []

    NameRole = QtCore.Qt.UserRole + 1000
    PriceRole = QtCore.Qt.UserRole + 1001

    def __init__(self):
        super(DrinkList, self).__init__()

    def rowCount(self, parent=None):
        return len(self.items)

    def columnCount(self, parent=None):
        return 2

    def data(self, index, role=QtCore.Qt.DisplayRole):
        row = index.row()
        if 0 <= row < len(self.items):
            if role == QtCore.Qt.DisplayRole:
                return self.items[row].name
            if role == self.NameRole:
                return self.items[row].name
            if role == self.PriceRole:
                return self.items[row].price

    def roleNames(self):
        roles = dict()
        roles[self.NameRole] = b"name"
        roles[self.PriceRole] = b"price"
        return roles

    def flags(self, index):
        return QtCore.Qt.ItemIsEnabled | QtCore.Qt.ItemIsSelectable


class CartItem(QObject):
    _name = 'no-name'

    def __init__(self, name, quantity, price):
        super(CartItem, self).__init__()

        self._name = name
        self._price = price
        self._quantity = quantity

    def setQuantity(self, val):
        self._quantity = val

    def getQuantity(self):
        return self._quantity

    quantity = Property(int, getQuantity, setQuantity)

    def setPrice(self, val):
        self._price = float(val)

    def getPrice(self):
        return "{0:.2f}".format(self._price)

    price = Property(str, getPrice, setPrice)

    def getSum(self):
        return "{0:.2f}".format(self._price * self._quantity)

    sum = Property(str, getSum)

    def getName(self):
        return self._name

    name = Property(str, getName)


class RFIDThread(QRunnable):
    def __init__(self, cart):
        super(RFIDThread, self).__init__()
        self._cart = cart

    @Slot()
    def run(self):
        uid = None
        try:
            uid = int(input("Enter UID: "))
        finally:
            self._cart.rfidDone(uid)


class LogEntry:
    def __init__(self, uid, name, price, quantity, dt):
        self.uid = uid
        self.name = name
        self.price = price
        self.quantity = quantity
        self.dt = dt


class Logbook:

    entries = []

    def writeToDisk(self, entry):
        with open("log.txt", "a") as f:
            f.write(f"{entry.uid};{entry.name};"
                    "{entry.price};{entry.quantity};"
                    "{entry.dt.isoformat()}\n")

    def logEntry(self, uid, name, price, quantity):
        now = datetime.now()
        entry = LogEntry(uid, name, price, quantity, now)
        self.entries.append(entry)
        self.writeToDisk(entry)

    def getSum(uid):
        return 0.0


class Cart(QAbstractListModel):
    threadpool = QThreadPool()
    log = Logbook()

    items = []

    NameRole = QtCore.Qt.UserRole + 1000
    PriceRole = QtCore.Qt.UserRole + 1001
    QuantityRole = QtCore.Qt.UserRole + 1002
    SumRole = QtCore.Qt.UserRole + 1003

    _success = False

    def __init__(self):
        super(Cart, self).__init__()

        self.requestEndResetModel.connect(self.callEndResetModel)

    def rowCount(self, parent=None):
        return len(self.items)

    def columnCount(self, parent=None):
        return 4

    def setData(self, index, role=Qt.EditRole):
        row = index.row()
        if 0 <= row < len(self.items):
            if role == self.QuantityRole:
                self.items[row].quantity = 1  # FIXME

    def logCart(self, uid):
        for item in self.items:
            self.log.logEntry(uid, item.name, item.price, item.quantity)

    def data(self, index, role=QtCore.Qt.DisplayRole):
        row = index.row()
        if 0 <= row < len(self.items):
            if role == QtCore.Qt.DisplayRole:
                return self.items[row].name
            if role == self.NameRole:
                return self.items[row].name
            if role == self.PriceRole:
                return self.items[row].price
            if role == self.QuantityRole:
                return self.items[row].quantity
            if role == self.SumRole:
                return self.items[row].sum

    def roleNames(self):
        roles = dict()
        roles[self.NameRole] = b"name"
        roles[self.PriceRole] = b"price"
        roles[self.QuantityRole] = b"quantity"
        roles[self.SumRole] = b"sum"
        return roles

    def flags(self, index):
        return (QtCore.Qt.ItemIsEnabled |
                QtCore.Qt.ItemIsSelectable |
                QtCore.Qt.ItemIsEditable)

    cleared = Signal()
    success = False

    requestEndResetModel = Signal()

    @Slot()
    def callEndResetModel(self):
        self.endResetModel()

    def clear(self):
        self.items = []
        self.requestEndResetModel.emit()
        self.cleared.emit()
        self.totalChanged.emit()

    @Slot()
    def startTransaction(self):
        self.beginResetModel()
        worker = RFIDThread(self)
        self.threadpool.start(worker)

    def rfidDone(self, result):
        if result is not None:
            self.logCart(result)
            self._success = True
        else:
            self._success = False
        self.clear()

    @Slot(str, int, str)
    def addStuff(self, name, quantity, price):
        ci = None
        for item in self.items:
            if item.name == name:
                ci = item

        if ci is None:
            ci = CartItem(name, quantity, float(price))
            self.items.append(ci)
        else:
            ci.quantity = 2
        self.totalChanged.emit()
        print("Cart total: {}".format(self.total))

    totalChanged = Signal()

    @Property(bool)
    def success(self):
        return self._success

    def getTotal(self):
        tot = 0.0
        for item in self.items:
            su = item._price * item._quantity
            tot += su

        return "{0:.2f}".format(tot)

    total = Property(str, getTotal, notify=totalChanged)


if __name__ == '__main__':

    # get our data

    file = open("pricelist.json", "r")
    drinks = file.read()
    data = json.loads(drinks)

    drinks = DrinkList()

    for item in data:
        drink = Drink(item['name'], item['price'])
        drinks.items.append(drink)

    cart = Cart()

    app = QGuiApplication(sys.argv)
    font = QFont("Helvetica", 16)
    app.setFont(font)
    view = QQuickView()
    view.width = 800
    view.height = 600
    view.setResizeMode(QQuickView.SizeRootObjectToView)

    # Expose the data to the Qml code
    view.rootContext().setContextProperty("drinks", drinks)
    view.rootContext().setContextProperty("cart", cart)

    qml_file = os.path.join(os.path.dirname(__file__), "view.qml")
    view.setSource(QUrl.fromLocalFile(os.path.abspath(qml_file)))

    # Show the window
    if view.status() == QQuickView.Error:
        print("QtQuick Error")
        sys.exit(-1)
    view.show()

    app.exec_()
