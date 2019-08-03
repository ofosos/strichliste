#!/usr/bin/env python
# -*- conding: utf-8 -*-

import csv
from datetime import datetime
import json
import locale
import os
import re
import shutil
import subprocess
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
        return locale.format_string("%.2f", self._price)

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
        return locale.format_string("%.2f", self._price)

    price = Property(str, getPrice, setPrice)

    def getSum(self):
        return locale.format_string("%.2f", self._price)

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
            ps = subprocess.run(['./tagutil.py', '--quiet'], capture_output=True)
            mat = re.match(r'^([0-9]+)', ps.stdout)
            if mat:
                uid = int(mat.group(0))
        finally:
            self._cart.rfidDone(uid)


class UidService(QObject):
    uidmap = {}

    def __init__(self):
        super(UidService, self).__init__()
        self.load()

    def load(self):
        with open("uidmap.json", "r") as f:
            jtxt = f.read()
            m = json.loads(jtxt)
            self.uidmap = m

    def checkpoint(self):
        shutil.move("uidmap.json", "uidmap.old.json")
        with open("uidmap.json", "w") as f:
            jtxt = json.dumps(self.uidmap)
            f.write(jtxt)

    @Slot(int, result=bool)
    def isValid(self, uid):
        return self.uidmap.get(str(uid), None) is not None

    @Slot(int, result=bool)
    def isAdmin(self, uid):
        return (self.uidmap.get(str(uid)) is not None and
                self.uidmap[str(uid)]["admin"] is True)

    @Slot(int, str)
    def addMapping(self, uid, name):
        if self.uidmap.get(str(uid), None) is None:
            self.uidmap[str(uid)] = {"name": name, "admin": False}
            self.checkpoint()

    @Slot(int)
    def addAdmin(self, uid):
        self.uidmap[str(uid)]["admin"] = True
        self.checkpoint()


class LogEntry:
    def __init__(self, uid, name, price, quantity, dt):
        self.uid = int(uid)
        self.name = name
        self.price = float(price)
        self.quantity = int(quantity)
        self.dt = dt


class Logbook(QObject):
    def __init__(self):
        super(Logbook, self).__init__()

    def writeToDisk(self, entry):
        fname = self.currentName()
        with open(fname, "a") as f:
            f.write(f"{entry.uid};{entry.name};"
                    f"{entry.price};{entry.quantity};"
                    f"{entry.dt.isoformat()}\n")

    def logEntry(self, uid, name, price, quantity):
        now = datetime.now()
        entry = LogEntry(uid, name, price, quantity, now)
        self.writeToDisk(entry)

    def currentName(self):
        now = datetime.now()
        month = now.month
        year = now.year
        fname = "log-{}-{:02}.csv".format(year, month)
        return fname

    def loadCurrentData(self):
        entries = []
        fname = self.currentName()
        try:
            with open(fname, "r") as f:
                reader = csv.reader(f, delimiter=';')
                for uids, name, prices, quantitys, dts in reader:
                    uid = int(uids)
                    price = float(prices)
                    quantity = float(quantitys)
                    dt = datetime.fromisoformat(dts)
                    entry = LogEntry(uid, name, price, quantity, dt)
                    entries.append(entry)
        except FileNotFoundError:
            pass
        return entries

    @Slot(int, result=str)
    def getSum(self, uid):
        uid = int(uid)
        ret = 0
        for entry in self.loadCurrentData():
            if entry.uid == uid:
                ret += entry.price * entry.quantity

        print("getSum: uid={} ret={}".format(uid, ret))
        return locale.format_string("%.2f", ret)


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
            self.log.logEntry(uid, item.name,
                              locale.atof(item.price),
                              item.quantity)

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
    uidentered = Signal()
    success = False

    requestEndResetModel = Signal()

    _clearOnRfid = False

    @Slot()
    def callEndResetModel(self):
        self.endResetModel()

    def clear(self):
        self.items = []
        self.requestEndResetModel.emit()
        self.cleared.emit()
        self.totalChanged.emit()

    @Slot()
    def fetchUid(self):
        self._clearOnRfid = False
        self.beginResetModel()
        worker = RFIDThread(self)
        self.threadpool.start(worker)

    @Slot()
    def startTransaction(self):
        self._clearOnRfid = True
        self.beginResetModel()
        worker = RFIDThread(self)
        self.threadpool.start(worker)

    def rfidDone(self, result):
        if self._clearOnRfid:
            if result is not None:
                self.logCart(result)
                self._success = True
            else:
                self._success = False
            self.clear()
        else:
            if result is not None:
                self._lastUid = result
                self.uidentered.emit()
                self._success = True
            else:
                self._success = False

    @Slot(str, int, str)
    def addStuff(self, name, quantity, price):
        _price = locale.atof(price)
        ci = None
        for item in self.items:
            if item.name == name and item.price == _price:
                ci = item

        if ci is None:
            ci = CartItem(name, quantity, _price)
            self.items.append(ci)
        else:
            ci.quantity = 2
        self.totalChanged.emit()
        print("Cart total: {}".format(self.total))
        
    totalChanged = Signal()

    @Property(int, notify=uidentered)
    def uid(self):
        return self._lastUid

    @Property(bool)
    def success(self):
        return self._success

    def getTotal(self):
        tot = 0.0
        for item in self.items:
            su = item._price * item._quantity
            tot += su

        return locale.format_string("%.2f", tot)

    total = Property(str, getTotal, notify=totalChanged)


if __name__ == '__main__':

    # get our data

    file = open("pricelist.json", "r")
    drinks = file.read()
    data = json.loads(drinks)

    drinks = DrinkList()

    for item in data:
        drink = Drink(item['name'],
                      item['price'])
        drinks.items.append(drink)

    cart = Cart()

    uidmap = UidService()

    app = QGuiApplication(sys.argv)
    font = QFont("Helvetica", 16)
    app.setFont(font)
    view = QQuickView()
    view.width = 800
    view.height = 600
    view.setResizeMode(QQuickView.SizeRootObjectToView)

    # Expose the data to the Qml code
    ctx = view.rootContext()
    ctx.setContextProperty("drinks", drinks)
    ctx.setContextProperty("cart", cart)
    ctx.setContextProperty("logbook", cart.log)
    ctx.setContextProperty("uidmap", uidmap)

    qml_file = os.path.join(os.path.dirname(__file__), "view.qml")
    view.setSource(QUrl.fromLocalFile(os.path.abspath(qml_file)))

    # Show the window
    if view.status() == QQuickView.Error:
        print("QtQuick Error")
        sys.exit(-1)
    view.showFullScreen()

    app.exec_()
