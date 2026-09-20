# 🛡️ Open2FA (Garmin Connect IQ)

> **100% Free & Open-Source TOTP Authenticator for Garmin Smartwatches.**  
> *Because basic digital security should never be paywalled.*

---

## ⚡ Why Open2FA?

Many 2FA/authenticator apps on the Garmin Connect IQ store are marketed as "free", only to lock features behind subscriptions, trials, or third-party payment gateways (KiezelPay). 

**Open2FA is 100% Free (as in freedom and as in beer).**
- **No subscriptions**
- **No paywalls or premium tiers**
- **No ads**
- **No internet required** (the app requests ZERO network permissions; keys and TOTP codes never leave your watch)
- **Open source under the MIT License**

---

## ✨ Features

- **Quick & Easy Setup (`otpauth://` URI support)**: Simply paste a standard `otpauth://totp/Issuer:Account?secret=...` URI directly into the secret field, and Open2FA will automatically parse the account label, secret key, digit count, algorithm, and period!
- **Up to 15 Accounts**: Store and easily switch between all your essential 2FA accounts (Google, GitHub, AWS, Microsoft, Discord, banking, etc.).
- **Readable TOTP Formatting**: 6-digit codes are displayed as `123 456` and 8-digit codes as `1234 5678` for quick, effortless reading.
- **Visual Countdown**:
  - Full circular arc on round watches, bottom progress bar on square watches, and secondary display support on Instinct series.
  - Color-coded urgency: 🟢 **Green** (>10s) ➔ 🟡 **Yellow** (5–10s) ➔ 🔴 **Red** (<5s).
- **Full Touch & Button Navigation**:
  - Touchscreen: Swipe Up/Down or Left/Right to flip between accounts; tap to cycle.
  - Physical Buttons: Use Up/Down and Select buttons.
- **Glance View Support**:
  - Live glance display on supported watches showing the active account, current code, and shrinking countdown timer.
- **Supported Algorithms**:
  - TOTP SHA-1 and SHA-256.
  - Configurable 6, 7, 8, 9, or 10 digits.
  - Configurable time steps (default 30s).
  - Handles Base32 secrets with spaces, hyphens, and mixed casing.

---

## ⌚ Supported Devices

Open2FA supports all Garmin watches running Connect IQ 3.1.0 or higher, including:

* **fēnix series**: **fēnix 9** (43mm, 47mm, 51mm AMOLED & Pro models), fēnix 8 (43mm, 47mm, 51mm AMOLED & Solar), fēnix E, Enduro 3, fēnix 7 / 7S / 7X (Standard, Pro, Solar), fēnix 6 / 6S / 6X Pro, fēnix 5 / 5 Plus.
* **Epix series**: Epix 2, Epix Pro (42mm, 47mm, 51mm).
* **Forerunner series**: FR 165, FR 255 / 255S, FR 265 / 265S, FR 955, FR 965, FR 55, FR 245, FR 745, FR 945 / 945LTE.
* **Venu & Vívoactive series**: Venu 2 / 2S / 2 Plus, Venu 3 / 3S, Venu Sq 2, vívoactive 4 / 4S, vívoactive 5.
* **Instinct & Specialty**: Instinct 2 / 2S / 2X / Crossover, Descent G1 / Mk2 / Mk3, MARQ series (Gen 1 & Gen 2), D2 series, Approach S70.

---

## 🚀 Installation

### Option 1: USB Sideload (Immediate, No Store Required)
1. Build `Open2FA.prg` using the Connect IQ SDK or download it from [GitHub Releases](../../releases).
2. Connect your Garmin watch to your computer with its USB cable.
3. In your file manager, open the Garmin storage drive and navigate to `GARMIN/APPS/`.
4. Copy `Open2FA.prg` into `GARMIN/APPS/`.
5. Safely eject/unplug your watch. Open2FA will immediately appear in your Glance / Widget list!

### Option 2: Connect IQ Store
* Download directly via the Garmin Connect IQ app on your phone once published.

---

## ⚙️ Configuration

1. Open the **Garmin Connect** app on your phone (or **Garmin Express** on PC/Mac).
2. Go to **Device Settings** ➔ **Activities & Apps** (or **Glances**) ➔ **Open2FA** ➔ **Settings**.
3. Enable an account slot (e.g. `Account #1 enabled`).
4. In the **Secret** field, you can either:
   - **Paste the full `otpauth://` URI**:  
     `otpauth://totp/GitHub:octocat?secret=JBSWY3DPEHPK3PXP&issuer=GitHub`  
     *(Open2FA will automatically extract name, secret, digits, algorithm, and period)*.
   - **Or manually enter**:
     - Label (e.g., `GitHub`)
     - Base32 Secret (e.g., `JBSWY3DPEHPK3PXP` or `JBSW-Y3DP-EHPK-3PXP`)
     - Algorithm, Digits, and Period.
5. Save settings. Your watch updates immediately!

---

## 🔒 Security & Privacy

* **Zero Network Access**: Open2FA has no internet permissions. It cannot send or receive any data over the network.
* **On-Device Cryptography**: All TOTP hashes (HMAC-SHA1 / HMAC-SHA256) are calculated strictly on the watch's processor.
* **Encrypted Storage**: Secrets are stored in Garmin's secure application storage on your local watch hardware.

---

## 🛠️ Building from Source

### Prerequisites
- Java JDK 17+
- Garmin Connect IQ SDK 7.x+ (or SDK Manager CLI)
- A Garmin developer signing key (`developer_key.der`)

### Quick Build
```bash
# 1. Generate developer key (if you don't already have one)
openssl genrsa -out developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt

# 2. Compile Open2FA
monkeyc -f monkey.jungle -o bin/Open2FA.prg -y developer_key.der

# 3. Compile Unit Tests
monkeyc -t -f monkey.jungle -o bin/Open2FATests.prg -y developer_key.der
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).  
Originally based on `otpauth-ciq` by Oleksiy Voronin, revamped and modernized for the Garmin community.
