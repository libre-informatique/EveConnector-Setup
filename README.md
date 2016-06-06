# EveConnector-Setup
MS Windows installer for EveConnector

## What is it ?

EveConnector-Setup is a MS Windows installer for EveConnector.

The installer follows these steps :

1. Install Node.js
2. Install the EveConnector modules (with npm)
  * [eve-connector](https://github.com/libre-informatique/EveConnector)
  * [node-windows](https://github.com/coreybutler/node-windows)
3. Install and run EveConnector as a Windows service
4. Install WinUSB generic drivers for some devices:
  * TSP700II Star Microtronics thermal printer
  * Lemur Boca Systems thermal printer
  * SCD122U Star Microtronics display

## How to compile it ?  

Compile the script setup2.iss with [Inno Setup Compiler](https://www.kymoto.org/products/inno-script-studio)

## How to use it ?

You can launch the installer with the following optional parameters :

* `/VERYSILENT` (disables the installation wizard windows, no user interaction)
* `/PROXY=myproxy:myport` (proxy settings for npm)

More available parameters here : http://www.jrsoftware.org/ishelp/index.php?topic=setupcmdline
