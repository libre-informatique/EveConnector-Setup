# EveConnector-Setup
MS Windows installer for EveConnector

## What is it ?

EveConnector-Setup is a MS Windows installer for EveConnector.

The installer follows these steps :

1. Install Node.js
2. Install the EveConnector modules (with npm)
  * eve-connector
  * node-windows
3. Install and run EveConnector as a Windows service
4. Install WinUSB generic drivers for some devices:
  * TSP700II Star Microtronics thermal printer
  * Lemur Boca Systems thermal printer
  * SCD122U Star Microtronics display

## How to compile it ?  

Compile the script setup2.iss with Inno Setup Compiler

## How to use it ?

You can lauch the installer and follow the Wizard steps with the following optional options :

* /VERYSILENT
* /PROXY=myproxy:myport
