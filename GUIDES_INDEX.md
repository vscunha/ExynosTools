# 📚 ExynosTools Debugging Guides - Index

I've created comprehensive guides to help you debug ExynosTools. Here's what's available:

---

## 🚀 Start Here (Pick Your Level)

### ⚡ Super Quick (5 minutes)
**File:** `ADB_WIFI_QUICK.md`
- Just the essential commands
- No explanation, just do it
- Best if you just want to get logging running NOW

### 🎯 Step-by-Step with Visuals (10 minutes)
**File:** `ADB_WIFI_VISUAL.md`
- Diagrams and flowcharts
- Visual guides for each step
- Troubleshooting decision trees
- Best for visual learners

### 📖 Complete Guide with Explanations (20 minutes)
**File:** `ADB_WIFI_SETUP.md`
- Full detailed explanations
- Why each step is needed
- Pro tips and aliases
- Best if you want to understand everything

---

## 🔍 Debugging Workflow

### **Complete End-to-End Testing**
**File:** `COMPLETE_DEBUGGING_WORKFLOW.md`
- Connects WiFi setup → Game launch → Log analysis
- Step-by-step with what to look for
- Automated bash script included
- **START HERE for actual debugging**

---

## 📋 Log Interpretation

### **What Do the Logs Mean?**
**File:** `LOG_ANALYSIS_PATTERNS.md`
- What different log messages indicate
- Success patterns vs error patterns
- How to identify missing formats (BC6H, BC7)
- How to spot bugs in BC4/BC5
- Quick diagnosis table

### **Detailed Logging Reference**
**File:** `LOGCAT_FIX_NOTES.md`
- How logging is implemented
- Environment variables explained
- Default behavior (it's ON by default!)
- Troubleshooting logging issues

---

## 🛠️ Additional Resources

### **For Winlator Installation**
**File:** `QUICKSTART.md`
- How to install the package
- Configuration options
- Multiple installation methods

### **ADB and Logcat Basics**
**File:** `DEBUGGING_GUIDE.md`
- ADB setup and installation
- Logcat filtering
- Android debugging apps
- Log interpretation basics

---

## 📊 Recommended Reading Order

### Scenario 1: "I want to test right now"
1. `ADB_WIFI_QUICK.md` - Get WiFi working (5 min)
2. `COMPLETE_DEBUGGING_WORKFLOW.md` - Run the test (20 min)
3. `LOG_ANALYSIS_PATTERNS.md` - Understand the results (10 min)

### Scenario 2: "I want to understand everything"
1. `ADB_WIFI_SETUP.md` - Full detailed guide (20 min)
2. `COMPLETE_DEBUGGING_WORKFLOW.md` - Full workflow (20 min)
3. `LOG_ANALYSIS_PATTERNS.md` - Interpret logs (10 min)
4. `LOGCAT_FIX_NOTES.md` - How logging works (10 min)

### Scenario 3: "I'm a visual learner"
1. `ADB_WIFI_VISUAL.md` - Diagrams and flowcharts (10 min)
2. `COMPLETE_DEBUGGING_WORKFLOW.md` - Full workflow (20 min)
3. `LOG_ANALYSIS_PATTERNS.md` - Interpret logs (10 min)

---

## 🎯 TL;DR - The Fastest Way

```bash
# 1. Enable USB Debugging on phone (Settings → Developer Options)

# 2. USB connect and enable WiFi ADB:
adb tcpip 5555

# 3. Disconnect USB and connect via WiFi:
adb connect 192.168.1.100:5555  # Replace with your IP

# 4. Clear and capture logs:
adb logcat -c
adb logcat -s XenoWrapper:* > game_test.log

# 5. Launch game and play for 1 minute

# 6. Stop logging (Ctrl+C)

# 7. Analyze:
grep "Unsupported format" game_test.log  # Any missing formats?
grep "✓ Successfully" game_test.log      # Count successful decompression
grep "Failed\|Error" game_test.log       # Any Vulkan errors?
```

**Then share the `game_test.log` file with me and I can tell you exactly what to fix!**

---

## ❓ Quick Q&A

**Q: Do I need to do anything to enable logging?**  
A: No! Logging is ON by default. Just run `adb logcat -s XenoWrapper:*`

**Q: What if I see no logs?**  
A: Check the troubleshooting section in `ADB_WIFI_SETUP.md`

**Q: Can I use this without a PC?**  
A: You can use a logcat app on phone, but WiFi ADB from PC is much easier

**Q: How long should I capture logs for?**  
A: 1-2 minutes of gameplay is enough to see patterns

**Q: What format is BC7?**  
A: Format ID 99. If you see "Unsupported format requested: 99", BC7 is missing

**Q: What if I don't understand the logs?**  
A: Share them with me! Post the log file in the repo and I'll analyze it

---

## 📁 Document Quick Reference

| Document | Purpose | Time | Best For |
|----------|---------|------|----------|
| ADB_WIFI_QUICK.md | Commands only | 5 min | Getting started fast |
| ADB_WIFI_VISUAL.md | Visual guide | 10 min | Visual learners |
| ADB_WIFI_SETUP.md | Detailed explanation | 20 min | Understanding everything |
| COMPLETE_DEBUGGING_WORKFLOW.md | End-to-end testing | 20 min | **Actual debugging** |
| LOG_ANALYSIS_PATTERNS.md | Log interpretation | 10 min | Understanding results |
| LOGCAT_FIX_NOTES.md | Logging system | 10 min | How it works |
| DEBUGGING_GUIDE.md | Basics | 15 min | ADB/logcat fundamentals |
| QUICKSTART.md | Installation | 10 min | Setting up package |

---

## 🚀 Ready?

**To start debugging:**
1. Pick your guide from above
2. Follow the steps
3. Capture logs from your game
4. Share the logs with me
5. I'll tell you what to fix!

**Most common issues to look for in logs:**
- ❌ `Unsupported format requested: 99` → Need to implement BC7
- ❌ `Unsupported format requested: 98` → Need to implement BC6H  
- ✅ `Successfully decompressed` → This format works!
- ⚠️ `Failed to create pipeline` → Vulkan issue

Let's go debug! 🎮
