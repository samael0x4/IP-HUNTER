#!/bin/bash

# ==============================
# IP-HUNTER v2.0
# Smarter Ownership Intelligence
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
echo -e "        ${CYAN}IP-HUNTER v2.0${RESET}"
echo -e "        ${YELLOW}by samael0x4${RESET}"
echo ""

if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: ip-hunter <IP>${RESET}"
    exit 1
fi

IP=$1
echo -e "${CYAN}[+] Target IP:${RESET} $IP"
echo ""

# =====================
# WHOIS (Safe Mode)
# =====================
echo -e "${BLUE}[WHOIS]${RESET}"
WHOIS_DATA=$(whois $IP 2>/dev/null | grep -E "OrgName|Organization|NetRange" | head -n 5)
echo "${WHOIS_DATA:-WHOIS lookup failed or blocked}"
echo ""

# =====================
# Reverse DNS
# =====================
REVERSE=$(dig -x $IP +short)
echo -e "${BLUE}[Reverse DNS]${RESET}"
echo "${REVERSE:-No reverse DNS}"
echo ""

# =====================
# SSL Certificate
# =====================
echo -e "${BLUE}[SSL Certificate]${RESET}"
SSL=$(echo | openssl s_client -connect $IP:443 2>/dev/null | openssl x509 -noout -subject 2>/dev/null)
echo "${SSL:-No SSL certificate}"
echo ""

SSL_CN=$(echo "$SSL" | sed -n 's/.*CN=\([^,]*\).*/\1/p')

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
# IPINFO
# =====================
if [ ! -z "$IPINFO_TOKEN" ]; then
    echo -e "${BLUE}[ipinfo.io]${RESET}"
    IPINFO_DATA=$(curl -s https://ipinfo.io/$IP?token=$IPINFO_TOKEN)
    ORG=$(echo "$IPINFO_DATA" | jq -r '.org')
    COUNTRY=$(echo "$IPINFO_DATA" | jq -r '.country')
    echo "ASN/Org: $ORG"
    echo "Country: $COUNTRY"
    echo ""
fi

# =====================
# Assessment v2.0
# =====================

echo -e "${MAGENTA}[Ownership Intelligence]${RESET}"
echo ""

SCORE=0
CLOUD_PROVIDER=""
DOMAIN_MATCH="No"

# =========================
# Detect Hosting Provider
# =========================
if echo "$ORG" | grep -qi "google"; then CLOUD_PROVIDER="Google Cloud"; fi
if echo "$ORG" | grep -qi "amazon"; then CLOUD_PROVIDER="Amazon AWS"; fi
if echo "$ORG" | grep -qi "microsoft"; then CLOUD_PROVIDER="Microsoft Azure"; fi
if echo "$ORG" | grep -qi "oracle"; then CLOUD_PROVIDER="Oracle Cloud"; fi
if echo "$ORG" | grep -qi "digitalocean"; then CLOUD_PROVIDER="DigitalOcean"; fi

# =========================
# Ownership Breakdown
# =========================
echo -e "${CYAN}🧠 Ownership Breakdown${RESET}"
echo ""

# Hosting Layer
echo -e "${BLUE}☁ Hosting Layer${RESET}"

if [ ! -z "$ORG" ]; then
    echo "ASN/Org = $ORG"
fi

if [ ! -z "$REVERSE" ]; then
    echo "Reverse DNS = $REVERSE"
fi

if [ ! -z "$CLOUD_PROVIDER" ]; then
    echo -e "→ Infrastructure hosted on ${YELLOW}$CLOUD_PROVIDER${RESET}"
    SCORE=$((SCORE-10))
fi

echo ""

# =========================
# Domain Attribution
# =========================
echo -e "${BLUE}🌐 Domain Attribution${RESET}"

if [ ! -z "$SSL_CN" ]; then
    echo "SSL CN = $SSL_CN"
    SCORE=$((SCORE+25))

    RESOLVED_IPS=$(dig +short $SSL_CN)

    if echo "$RESOLVED_IPS" | grep -q "$IP"; then
        DOMAIN_MATCH="Yes"
        SCORE=$((SCORE+25))
        echo -e "${GREEN}✔ Domain resolves to target IP${RESET}"
        echo "→ Likely organization-managed instance"
    else
        echo -e "${YELLOW}⚠ Domain does not resolve to target IP${RESET}"
    fi

    # Generic cloud certificate penalty
    if echo "$SSL_CN" | grep -qi "googleusercontent\|amazonaws\|cloudfront"; then
        SCORE=$((SCORE-15))
    else
        SCORE=$((SCORE+20))
    fi
else
    echo "No SSL domain detected"
fi

echo ""

# =========================
# Additional Signals
# =========================

# Reverse DNS cloud penalty
if echo "$REVERSE" | grep -qi "googleusercontent\|amazonaws\|azure"; then
    SCORE=$((SCORE-10))
fi

# security.txt bonus
if [ "$SEC" == "200" ]; then
    SCORE=$((SCORE+10))
fi

# Title bonus
if [ ! -z "$TITLE" ]; then
    SCORE=$((SCORE+5))
fi

# Prevent negative score
if [ $SCORE -lt 0 ]; then
    SCORE=0
fi

echo -e "${MAGENTA}📊 Confidence Score:${RESET} $SCORE / 100"
echo ""

# =========================
# Final Classification
# =========================
if [ $SCORE -ge 80 ]; then
    echo -e "${GREEN}🟢 Strong Organization-Owned Asset${RESET}"
elif [ $SCORE -ge 55 ]; then
    echo -e "${YELLOW}🟡 Likely Organization-Owned (Cloud Hosted)${RESET}"
elif [ $SCORE -ge 35 ]; then
    echo -e "\e[33m🟠 Needs Manual Verification${RESET}"
else
    echo -e "${RED}🔴 Likely Random / Unverified VM${RESET}"
fi
