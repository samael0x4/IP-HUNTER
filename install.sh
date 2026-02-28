#!/bin/bash

echo "[*] Installing IP-HUNTER..."

chmod +x ip-hunter.sh
sudo cp ip-hunter.sh /usr/local/bin/ip-hunter

echo "[+] Installation complete."
echo "[+] Run: ip-hunter <IP>"
