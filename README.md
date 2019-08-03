# What is it?

Prototype for a Strichliste. `run.sh` is my janky startup file.
QtQuick app for logging drinks consumption digitally. RFID not yet
integrated.

# Run with PyCharm

Steps:

- To run it in PyCharm create a virtual env with pySide 5.11.x.
- Add "QT_IM_MODULE=qtvirtualkeyboard" under Enviroment variables of start configuration
- run "strichliste.py"

# Run on Debian/Ubuntu (Desktop)

Install QtQuick and the module:

```
sudo apt install python3-pyqt5.qtquick qml-module-qtquick-controls2 qml-module-qtquick-virtualkeyboard qml-module-qtquick-window2 qml-module-qtquick2 qtdeclarative5-qtquick2-plugin
pip install --index-url=https://download.qt.io/official_releases/QtForPython/ pyside2 --trusted-host download.qt.io
```

Export `QT_IM_MODULE=qtvirtualkeyboard` and call `./strichliste.py`.

# Copyright

See LICENSE.txt for copying information.

Copyright 2019, Mark Meyer (mark@ofosos.org)

Copyright 2019, Felix Garbe (info@felix-garbe.be)
