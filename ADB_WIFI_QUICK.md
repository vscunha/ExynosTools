# ADB WiFi - TL;DR (Quick Start)

## 5 Minutes to WiFi Debugging

### Step 1: Enable USB Debugging (Phone)
```
Settings → About Phone → Build Number (tap 7x)
→ Developer Options → USB Debugging: ON
```

### Step 2: Connect USB Cable
```bash
# On PC:
adb devices
# Tap "Allow" on phone when prompted
```

### Step 3: Get Phone's WiFi IP
```
Phone Settings → WiFi → [Your Network] → IP Address
# Example: 192.168.1.100
```

### Step 4: Enable WiFi ADB (PC - With USB Still Connected)
```bash
adb tcpip 5555
# Now unplug USB cable!
```

### Step 5: Connect via WiFi (PC)
```bash
adb connect 192.168.1.100:5555
# Replace 192.168.1.100 with YOUR IP address
```

### Step 6: View Logs!
```bash
adb logcat -s XenoWrapper:*
```

**Now open Winlator on your phone and launch a game → Watch logs appear in real-time!** 🎉

---

## Troubleshooting Quick Reference

| Problem | Solution |
|---------|----------|
| `adb: command not found` | `sudo apt install adb` |
| `failed to connect` | Check IP, same WiFi, re-run `adb tcpip 5555` |
| `unauthorized` | Look at phone, tap "Allow" |
| `no logs appearing` | Run `adb devices` - make sure it shows connected |

---

## Pro Tips

### Alias for easier commands:
```bash
# Add to ~/.bashrc:
alias adb-wifi='adb connect 192.168.1.100:5555'  # Replace with your IP
alias adb-logs='adb logcat -s XenoWrapper:*'

# Then just use:
adb-wifi
adb-logs
```

### Save logs to file:
```bash
adb logcat -s XenoWrapper:* > game_test.log
# Play your game
# Ctrl+C to stop
# cat game_test.log to view
```

### Reconnect after phone restart:
```bash
adb connect 192.168.1.100:5555
```

---

## That's It!

You now have wireless debugging. Go test your game and capture those logs! 🚀

For detailed guide, see `ADB_WIFI_SETUP.md`
