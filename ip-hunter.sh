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
REVERSE=$(dig -x $IP +short)
echo -e "${BLUE}[Reverse DNS]${RESET}"
echo "$REVERSE"
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
    IPINFO_DATA=$(curl -s https://ipinfo.io/$IP?token=$IPINFO_TOKEN)
    echo "$IPINFO_DATA" | jq '.org, .country'
    ORG=$(echo "$IPINFO_DATA" | jq -r '.org')
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
# CENSYS API (Platform)
# =====================
if [ ! -z "$CENSYS_API_TOKEN" ]; then
    echo -e "${BLUE}[Censys Platform]${RESET}"
    curl -s \
    -H "Authorization: Bearer $CENSYS_API_TOKEN" \
    https://platform.censys.io/api/v1/hosts/$IP | jq '.result.autonomous_system.name'
    echo ""
fi

# =====================
# Smart Classification v2.0
# =====================

echo -e "${MAGENTA}[Assessment v2.0]${RESET}"

SCORE=0

# Extract SSL CN
SSL_CN=$(echo "$SSL" | sed -n 's/.*CN=\([^,]*\).*/\1/p')

# Check SSL existence
if [ ! -z "$SSL_CN" ]; then
    SCORE=$((SCORE+25))
fi

# Check if SSL CN looks generic cloud
if echo "$SSL_CN" | grep -qi "googleusercontent\|amazonaws\|azure\|cloudfront"; then
    SCORE=$((SCORE-10))
else
    if [ ! -z "$SSL_CN" ]; then
        SCORE=$((SCORE+20))
    fi
fi

# Domain resolution check
if [ ! -z "$SSL_CN" ]; then
    RESOLVED_IP=$(dig +short $SSL_CN | tail -n1)
    if [ "$RESOLVED_IP" == "$IP" ]; then
        SCORE=$((SCORE+20))
        DOMAIN_MATCH="Yes"
    else
        DOMAIN_MATCH="No"
    fi
fi

# ASN cloud detection
if echo "$ORG" | grep -qi "google\|amazon\|microsoft\|azure\|digitalocean\|ovh"; then
    SCORE=$((SCORE-10))
fi

# Reverse DNS generic cloud
if echo "$REVERSE" | grep -qi "googleusercontent\|amazonaws\|azure"; then
    SCORE=$((SCORE-10))
fi

# security.txt
if [ "$SEC" == "200" ]; then
    SCORE=$((SCORE+10))
fi

# HTTP Title exists
if [ ! -z "$TITLE" ]; then
    SCORE=$((SCORE+5))
fi

echo "Confidence Score: $SCORE / 100"
echo ""

if [ $SCORE -ge 80 ]; then
    echo -e "${GREEN}🟢 Strong Organization-Owned Asset"
elif [ $SCORE -ge 50 ]; then
    echo -e "${YELLOW}🟡 Likely Organization-Owned (Cloud Hosted)"
elif [ $SCORE -ge 30 ]; then
    echo -e "\e[33m🟠 Needs Manual Verification"
else
    echo -e "${RED}🔴 Likely Random / Unverified VM"
fi
