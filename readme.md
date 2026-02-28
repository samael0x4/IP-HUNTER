# 💀 IP-HUNTER v2.0
### Smarter IP → Organization Attribution for Bug Bounty Hunters

![Bash](https://img.shields.io/badge/Bash-Shell-green?style=for-the-badge&logo=gnu-bash)
![Recon Tool](https://img.shields.io/badge/Category-Recon-red?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

---

## 🎯 What is IP-HUNTER?

IP-HUNTER is a reconnaissance tool that helps determine whether an IP address likely belongs to a reportable organization or is just cloud infrastructure.

Built to reduce false reports and improve ownership validation in bug bounty hunting.

---

## 🚀 What’s New in v2.0

- 🧠 Smart ownership scoring engine (0–100 confidence)
- ☁ Automatic cloud provider detection
- 🔎 SSL domain extraction
- 🌐 Domain → IP resolution check
- 📊 Clear classification output
- 🛡 Better handling of cloud-hosted assets


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
Make the installer executable:
```
chmod +x install.sh
```
Run the installer:
```
./install.sh
```
After installation, you can run IP-HUNTER globally from anywhere:
```
ip-hunter <IP>
```

---

## 👩‍💻 Author
by `samael0x4` & `ALVIRA PARVEEN`  
🔗 [LinkedIn](https://www.linkedin.com/in/alvira-parveen-78022536b)  
🌐 [GitHub](https://github.com/Alvira-Parveen)

---
