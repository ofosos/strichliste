# What is it?

Prototype for a Strichliste. `run.sh` is my janky startup file.
QtQuick app for logging drinks consumption digitally. RFID not yet
integrated.

Dependencies: Qt 5.11, Python 3.6

# Run with PyCharm

Steps:

- To run it in PyCharm create a virtual env with pySide 5.11.x.
- Add "QT_IM_MODULE=qtvirtualkeyboard" under Enviroment variables of start configuration
- run "strichliste.py"

# Run on Debian/Ubuntu (Desktop)

Install QtQuick and the module:

```
$ sudo apt install python3-pyqt5.qtquick qml-module-qtquick-controls2 qml-module-qtquick-virtualkeyboard qml-module-qtquick-window2 qml-module-qtquick2 qtdeclarative5-qtquick2-plugin
$ sudo apt install qttools5-dev-tools qt5-default
$ pip install --index-url=https://download.qt.io/official_releases/QtForPython/ pyside2 --trusted-host download.qt.io
```

Export `QT_IM_MODULE=qtvirtualkeyboard` and call `./strichliste.py`.

# Run on Raspbian (Buster)

Install Python `dateutil` and `pi-rc522`.

```
$ sudo apt install python3-dateutil
$ sudo pip3 install pi-rc522
```

Install QtQuick.

```
$ sudo apt install qml-module-qtquick-controls2 qml-module-qtquick-virtualkeyboard qml-module-qtquick-window2 qml-module-qtquick2 qtvirtualkeyboard-plugin qml-module-qtquick-virtualkeyboard qml-module-qtquick-layouts qml-module-qt-labs-folderlistmodel
$ sudo apt install python3-pyside2*
```

Call `run.sh`.

# Update translations

Create `i18n/base.ts`.

```
lupdate view.qml -ts i18n/base.ts
```

Copy base.ts to a language file and translate via linguist.

```
cp i18n/base.ts i18n/view_de.ts
linguist i18n/view_de.ts
```

Create run-time translation files by running `lrelease`.

```
lrelease i18n/*.ts
```

# Copyright

See LICENSE.txt for copying information.

Copyright 2019, Mark Meyer (mark@ofosos.org)

Copyright 2019, Felix Garbe (info@felix-garbe.be)
