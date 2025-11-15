# ADB WiFi - Visual Step-by-Step

## Overview Diagram

```
┌─────────────────┐                                    ┌──────────────────┐
│   YOUR PC       │◄──────── USB Cable (Initial) ────►│   YOUR PHONE     │
│                 │                                    │                  │
│ $ adb connect   │                                    │ USB Debugging: ON│
│ 192.168.1.100   │                                    │                  │
│                 │                                    │                  │
└─────────────────┘                                    └──────────────────┘
         ▲                                                      │
         │                                                      │
         └──────────── WiFi (After Setup!) ────────────────────┘
         
              192.168.1.100:5555
```

---

## Step-by-Step Visual Guide

### STEP 1️⃣: Enable USB Debugging

```
PHONE SCREEN:

Settings
  ▼
About Phone
  ▼
Build Number ◄── TAP 7 TIMES! (keep tapping)
  ▼
"You are now a developer!"
  ▼
← Go back to Settings
  ▼
Developer Options (NEW!)
  ▼
USB Debugging: ◉ ON

✅ DONE - Needs to be done ONCE per phone
```

---

### STEP 2️⃣: Connect with USB Cable

```
PHONE:                          PC TERMINAL:
┌──────────────┐               $ adb devices
│ [USB Cable]  │────►          
└──────────────┘               List of attached devices
                               emulator-5554          device
PHONE SCREEN:                  AB123456               device
                               ▲
"Allow USB debugging?"         Your phone
[Allow] [Deny]
   ▼ (tap Allow)
   ✅

$ adb devices again:
AB123456               device    ✅
```

---

### STEP 3️⃣: Find Phone's WiFi IP

```
PHONE SCREEN:                  PC TERMINAL:
                               
Settings                       (Alternative method:)
  ▼
WiFi                           $ adb shell ip addr show wlan0
  ▼
[Your WiFi] (long press)       inet 192.168.1.100/24 ...
  ▼                               ▲
Manage/Details                     This is your IP!
  ▼
IP address: 192.168.1.100 ◄─── WRITE THIS DOWN!
```

---

### STEP 4️⃣: Enable WiFi ADB (USB Still Connected!)

```
PC TERMINAL:

$ adb tcpip 5555

Output:
restarting in TCP mode port: 5555

✅ NOW YOU CAN UNPLUG USB! 🔌
```

---

### STEP 5️⃣: Connect via WiFi

```
PHONE:                          PC TERMINAL:

🔌 USB unplugged               $ adb connect 192.168.1.100:5555
                               
📶 Connected to WiFi           connected to 192.168.1.100:5555

PHONE SCREEN:
(might show a prompt)
"Allow wireless debugging?"
[Allow]

$ adb devices

192.168.1.100:5555    device    ✅ CONNECTED via WiFi!
```

---

### STEP 6️⃣: View Logs in Real-Time

```
PC TERMINAL:

$ adb logcat -s XenoWrapper:*


PHONE:                          PC TERMINAL OUTPUT:
Open Winlator                   I XenoWrapper: ExynosTools logging initialized
                                I XenoWrapper: bc_emulate: Initializing BC...
Launch Game                     I XenoWrapper: bc_emulate: ✓ BC4 pipeline...
                                D XenoWrapper: Block calculation - blocks...
Watch the game                  I XenoWrapper: Decoding texture 1024x1024...
                                I XenoWrapper: ✓ Successfully decompressed...
                                
✅ LOGS APPEARING IN REAL-TIME!
```

---

## Command Reference Chart

```
╔════════════════════════════════════════════════════════╗
║             ADB WiFi Command Cheatsheet                ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║ INITIAL SETUP (Do once):                              ║
║ ────────────────────────                              ║
║ adb tcpip 5555                                        ║
║ (Unplug USB after this)                               ║
║ adb connect 192.168.1.100:5555                        ║
║                                                        ║
║ DAILY USE:                                            ║
║ ──────────                                            ║
║ adb connect 192.168.1.100:5555      # Reconnect      ║
║ adb logcat -s XenoWrapper:*          # View logs      ║
║ adb devices                          # Check status   ║
║                                                        ║
║ USEFUL:                                               ║
║ ────────                                              ║
║ adb logcat -c                        # Clear logs     ║
║ adb logcat -s XenoWrapper:* > log.txt # Save logs    ║
║ adb disconnect                       # Stop WiFi      ║
║                                                        ║
║ TROUBLESHOOT:                                         ║
║ ──────────────                                        ║
║ adb devices -l                       # List all       ║
║ adb reconnect                        # Force reconnect║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

---

## Network Diagram

```
                    WiFi Network
                  192.168.1.0/24
                  ═══════════════════════════
                  ║                         ║
                ┌─────────────────┐    ┌─────────────────┐
                │   WiFi Router   │    │                 │
                │  (192.168.1.1)  │    │    PC            │
                └────────┬────────┘    │  192.168.1.50    │
                         ║             │ $ adb connect    │
                         ║             │  192.168.1.100   │
                         ║             │ $ adb logcat    │
                         ║             └─────────────────┘
                         ║                     ▲
                         ║                     │
                   Port 5555 TCP               │
                    (ADB WiFi)                 │
                         ║                     │
                         ║◄────────────────────┘
                    PHONE
                192.168.1.100
               (Winlator running)
```

---

## Troubleshooting Decision Tree

```
"adb connect doesn't work"
│
├─ Check IP address correct?
│  │
│  ├─ NO ► Go to phone Settings → WiFi → Details → Get IP
│  │
│  └─ YES ► Continue
│
├─ Same WiFi network?
│  │
│  ├─ NO ► Connect both to same WiFi
│  │
│  └─ YES ► Continue
│
├─ USB Debugging enabled?
│  │
│  ├─ NO ► Phone: Settings → Developer Options → USB Debugging ON
│  │
│  └─ YES ► Continue
│
├─ Run "adb tcpip 5555" with USB connected?
│  │
│  ├─ NO ► Plug in USB, run: adb tcpip 5555, then unplug
│  │
│  └─ YES ► Continue
│
├─ Check connection:
│  │
│  └─ $ adb devices
│     If shows "192.168.1.100:5555    device" ► WORKING! ✅
│     If shows "192.168.1.100:5555    offline" ► Reconnect: adb reconnect
│     If shows "192.168.1.100:5555    unauthorized" ► Tap Allow on phone
```

---

## After WiFi Connection Works

### Monitor Your Game in Real-Time

```
Terminal 1: Start logging               Terminal 2: Play game
────────────────────────               ──────────────────
$ adb logcat -s XenoWrapper:*          $ adb shell am start com.winlator
                                       
I XenoWrapper: ... initialized
D XenoWrapper: Shader BC4...            (Game launches)
I XenoWrapper: Decoding texture...      (Watch logs)
I XenoWrapper: ✓ Successfully...        (More logs!)
E XenoWrapper: Unsupported format: 99   (Found a problem!)
```

**Now you can see exactly what's happening in real-time!** 🎮

---

## Summary

```
╔═══════════════════════════════════════════════════════════╗
║                     YOU ARE HERE                          ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  ✅ PC has ADB installed                                 ║
║  ✅ Phone has USB Debugging enabled                      ║
║  ✅ Connected via WiFi using adb connect                 ║
║  ✅ Can see XenoWrapper logs with adb logcat             ║
║  ✅ Ready to test and debug!                             ║
║                                                           ║
║  NEXT: Install the new ExynosTools package              ║
║        Launch Elden Ring and watch the logs! 🎉          ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```
