# 💀 IP-HUNTER
### Validate whether an IP likely belongs to a reportable organization or just cloud infra.

> Built for bug bounty hunters who verify ownership **before** reporting.

---

## 👁 What is IP-HUNTER?

IP-HUNTER is a reconnaissance utility that analyzes an IP address and determines whether it likely belongs to:

- 🟢 A real organization (potentially reportable)
- 🟡 Cloud-hosted infrastructure (needs domain correlation)
- 🔴 Random / unverified VM

It automates ownership intelligence using:

- WHOIS
- Reverse DNS
- SSL certificate inspection
- HTTP title fetching
- security.txt detection
- ASN lookup (ipinfo)
- Shodan API
- Censys API

Built in pure Bash. Lightweight. Fast. Recon-focused.

---

## ⚡ Why This Tool Exists

Most hunters exploit first and ask ownership later.

That’s how reports get rejected.

IP-HUNTER helps you:

✔ Avoid reporting random cloud VMs  
✔ Verify if IP maps to scoped asset  
✔ Detect cloud vs dedicated infra  
✔ Improve report credibility  

---

## 📦 Requirements

Install required dependencies:

```bash
sudo apt install whois dnsutils curl jq openssl
