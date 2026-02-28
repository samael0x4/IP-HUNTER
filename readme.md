![Shell Script](https://img.shields.io/badge/Bash-Shell_Script-green?style=for-the-badge&logo=gnu-bash)
![Recon Tool](https://img.shields.io/badge/Category-Recon_Tool-red?style=for-the-badge)
![Bug Bounty](https://img.shields.io/badge/Bug_Bounty-Ownership_Intelligence-black?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

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
```

## 🔐 Clone & Configuration
```
git clone https://github.com/samael0x4/IP-HUNTER.git
cd IP-HUNTER
```
Copy config template:
```
cp config.conf.example config.conf
```

Edit config.conf and add your API keys:
```
IPINFO_TOKEN="your_token"
SHODAN_API_KEY="your_key"
CENSYS_API_TOKEN="your_api_token"
```
## 🚀 Installation
```
chmod +x ip-hunter.sh
```
Install globally:
```
sudo mv ip-hunter.sh /usr/local/bin/ip-hunter
```

Now you can run from any directory:
```
ip-hunter <IP>
```

## 🧪 Usage 
```
./ip-hunter.sh 1.1.1.1
```
```
Or if installed globally:
ip-hunter 1.1.1.1
```

---

## 👩‍💻 Author
by `samael0x4` & `ALVIRA PARVEEN`  
🔗 [LinkedIn](https://www.linkedin.com/in/alvira-parveen-78022536b)  
🌐 [GitHub](https://github.com/Alvira-Parveen)

---
