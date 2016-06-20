#!/bin/bash
sudo avrprog2 --mcu atmega32 --frequency 8000000 --fuses w:CO,D9 --flash w:$1
