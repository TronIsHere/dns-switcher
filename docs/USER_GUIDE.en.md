# DNS Switcher — User Guide (English)

DNS Switcher is a simple macOS menu-bar style utility that lets you change DNS servers for your Mac without opening System Settings.

## Table of contents

1. [Requirements](#requirements)
2. [Installation](#installation)
3. [First launch](#first-launch)
4. [Main screen overview](#main-screen-overview)
5. [Choosing a network](#choosing-a-network)
6. [DNS presets](#dns-presets)
7. [Custom DNS](#custom-dns)
8. [Saved profiles](#saved-profiles)
9. [Applying and resetting DNS](#applying-and-resetting-dns)
10. [Changing language](#changing-language)
11. [Administrator password](#administrator-password)
12. [Troubleshooting](#troubleshooting)

---

## Requirements

- macOS 14.0 (Sonoma) or later
- An administrator account on your Mac
- A network connection (Wi-Fi or Ethernet)

## Installation

### Download (recommended)

1. Go to [Releases](https://github.com/TronIsHere/dns-switcher/releases/latest).
2. Download **DNS-Switcher-macOS.zip**.
3. Double-click the zip file to extract **DNS Switcher.app**.
4. Drag the app to **Applications**.

### First open (Gatekeeper)

Because the app is distributed outside the Mac App Store and is not Apple-notarized, macOS may block it the first time you open it.

#### "DNS Switcher.app is damaged and can't be opened"

This message is **misleading**. The app is not corrupted. macOS adds a quarantine flag to everything downloaded from the internet and refuses to run unsigned apps, sometimes calling them "damaged."

**Fix (pick one):**

**Option A — Right-click open (easiest)**

1. Right-click **DNS Switcher.app**
2. Choose **Open**
3. Click **Open** in the confirmation dialog

**Option B — Terminal**

```bash
xattr -cr "/Applications/DNS Switcher.app"
```

Then double-click the app normally.

**Option C — System Settings**

Open **System Settings** → **Privacy & Security** → find the blocked app message → **Open Anyway**.

## First launch

When you open DNS Switcher for the first time, you see a welcome screen:

1. **Choose your language** — English or Persian (فارسی).
2. Review the feature summary.
3. Click **Get Started**.

You can change the language later from the main screen.

## Main screen overview

| Section | What it does |
|--------|----------------|
| **Network** | Pick which interface to configure (Wi-Fi, Ethernet, etc.) |
| **Current DNS** | Shows the DNS servers currently in use |
| **DNS Preset** | Quick options: Default, Cloudflare, Google, Quad9, Custom |
| **Saved Profiles** | Your named DNS setups for one-tap reuse |
| **Apply DNS** | Applies the selected preset, profile, or custom servers |
| **Reset to Automatic** | Restores DHCP / router-assigned DNS |

The status banner at the bottom confirms success or shows an error.

## Choosing a network

macOS can have multiple network services. DNS Switcher lists all active services reported by the system.

1. Open the **Network service** menu.
2. Select the connection you use (usually **Wi-Fi** or **Ethernet**).
3. The **Current DNS** card updates to show servers for that interface.

DNS changes apply only to the selected service. If you use both Wi-Fi and Ethernet, switch the service before applying.

## DNS presets

| Preset | Servers | Best for |
|--------|---------|----------|
| **Default** | Automatic (DHCP) | Use your router or ISP DNS |
| **Cloudflare** | `1.1.1.1`, `1.0.0.1` | Speed and privacy |
| **Google** | `8.8.8.8`, `8.8.4.4` | Reliable public DNS |
| **Quad9** | `9.9.9.9`, `149.112.112.112` | Security and malware blocking |
| **Custom** | Your own addresses | Advanced or local DNS |

Click a preset card to select it, then click **Apply DNS**.

Selecting **Default** and applying resets DNS to automatic (same as **Reset to Automatic**).

## Custom DNS

1. Select the **Custom** preset.
2. Enter a **Primary** DNS address (required).
3. Optionally enter a **Secondary** address.
4. Click **Apply DNS**.

Supported formats:

- IPv4 (for example `1.1.1.1`)
- IPv6 (addresses containing `:`)

Invalid addresses are highlighted and the app will not apply until they are corrected.

## Saved profiles

Profiles let you save a name and DNS servers for quick switching.

### Create a profile

1. Set up DNS (preset or custom servers).
2. Click **Save as Profile** (or **Add Profile** in the Saved Profiles section).
3. Enter a name (for example `Work`, `Home`, `Gaming`).
4. Click **Save Profile**.

### Use a profile

Click a saved profile card to select it, then click **Apply DNS**.

### Edit or delete

Open the profile editor from the profile card, update servers or the name, or delete the profile.

## Applying and resetting DNS

### Apply DNS

1. Select network service, preset or profile.
2. Click **Apply DNS**.
3. Enter your Mac administrator password when prompted.
4. Wait for the success message and updated **Current DNS** display.

### Reset to Automatic

Click **Reset to Automatic** to clear manual DNS servers and use DHCP again. You will be asked for your administrator password.

## Changing language

Use the language control in the header (globe icon or language label):

- **English**
- **فارسی** (Persian) — the interface switches to right-to-left layout

Language preference is saved and restored on next launch.

## Administrator password

DNS Switcher changes system network settings. macOS requires administrator approval for every apply or reset action.

- The password prompt is a standard macOS dialog, not entered inside the app.
- If you cancel the prompt, DNS is not changed.
- DNS Switcher does not store your password.

## Troubleshooting

### "Command failed" or permission errors

- Make sure your user account is an administrator.
- Enter the correct password in the macOS prompt.
- Try again after unlocking System Settings.

### DNS did not change

- Confirm you selected the correct **network service** (Wi-Fi vs Ethernet).
- Click **Apply DNS** after changing the preset.
- Open **Terminal** and run: `scutil --dns` to verify system DNS (advanced).

### App won't open / "damaged" message

- The app is not broken. Remove quarantine: `xattr -cr "/Applications/DNS Switcher.app"`
- Or right-click → **Open** the first time.
- Check **System Settings** → **Privacy & Security** for blocked app options.

### Current DNS shows "Automatic" but I set custom DNS

Empty or DHCP-assigned DNS appears as **Automatic**. Apply your preset again on the correct network service.

### Need help or found a bug?

Open an issue on GitHub: [TronIsHere/dns-switcher](https://github.com/TronIsHere/dns-switcher/issues)

---

[Back to README](../README.md) · [راهنمای فارسی](USER_GUIDE.fa.md)
