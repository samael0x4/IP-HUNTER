#!/bin/bash

# ==============================
# IP-HUNTER
# Validate IP → Organization
# ==============================

source config.conf 2>/dev/null

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
RESET="\e[0m"

clear
echo -e "${RED}"
echo "██╗██████╗      ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ "
echo "██║██╔══██╗     ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗"
echo "██║██████╔╝     ███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝"
echo "██║██╔═══╝      ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗"
echo "██║██║          ██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║"
echo "╚═╝╚═╝          ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝"
echo ""
echo -e "        ${CYAN}IP-HUNTER${RESET}  |  Validate IP → Organization Mapping"
echo -e "        ${YELLOW}by samael0x4${RESET}"
echo -e "${RESET}"

if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: ./ip-hunter.sh <IP>${RESET}"
    exit 1
fi

IP=$1

echo -e "${CYAN}[+] Target IP:${RESET} $IP"
echo ""

# =====================
# WHOIS
# =====================
echo -e "${BLUE}[WHOIS]${RESET}"
whois $IP | grep -E "OrgName|Organization|NetRange" | head -n 5
echo ""

# =====================
# Reverse DNS
# =====================
echo -e "${BLUE}[Reverse DNS]${RESET}"
dig -x $IP +short
echo ""

# =====================
# SSL Certificate
# =====================
echo -e "${BLUE}[SSL Certificate]${RESET}"
SSL=$(echo | openssl s_client -connect $IP:443 2>/dev/null | openssl x509 -noout -subject 2>/dev/null)
echo "$SSL"
echo ""

# =====================
# HTTP Title
# =====================
echo -e "${BLUE}[HTTP Title]${RESET}"
TITLE=$(curl -s --max-time 5 http://$IP | grep -i "<title>" | head -n1 | sed -e 's/<[^>]*>//g')
echo "${TITLE:-No Title Found}"
echo ""

# =====================
# security.txt
# =====================
echo -e "${BLUE}[security.txt]${RESET}"
SEC=$(curl -s -o /dev/null -w "%{http_code}" http://$IP/.well-known/security.txt)
if [ "$SEC" == "200" ]; then
    echo "Found"
else
    echo "Not Found"
fi
echo ""

# =====================
# IPINFO API
# =====================
if [ ! -z "$IPINFO_TOKEN" ]; then
    echo -e "${BLUE}[ipinfo.io]${RESET}"
    curl -s https://ipinfo.io/$IP?token=$IPINFO_TOKEN | jq '.org, .country'
    echo ""
fi

# =====================
# SHODAN API
# =====================
if [ ! -z "$SHODAN_API_KEY" ]; then
    echo -e "${BLUE}[Shodan]${RESET}"
    curl -s "https://api.shodan.io/shodan/host/$IP?key=$SHODAN_API_KEY" | jq '.org, .ports'
    echo ""
fi

# =====================
# CENSYS API
# =====================
if [ ! -z "$CENSYS_API_ID" ]; then
    echo -e "${BLUE}[Censys]${RESET}"
    curl -s -u "$CENSYS_API_ID:$CENSYS_API_SECRET" \
    https://search.censys.io/api/v2/hosts/$IP | jq '.result.autonomous_system.name'
    echo ""
fi

# =====================
# Basic Classification
# =====================
echo -e "${MAGENTA}[Assessment]${RESET}"

ORG=$(whois $IP | grep -i "Organization" | head -n1)

if echo "$ORG" | grep -qi "google\|amazon\|microsoft\|azure\|digitalocean\|ovh"; then
    echo -e "${YELLOW}⚠ Cloud Hosted Infrastructure"
else
    echo -e "${GREEN}🟢 Potentially Reportable (Verify Domain Scope)"
fi
