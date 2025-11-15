# Agent Instructions for ExynosTools Development

## Critical Information

### Build Environment
- **Target Platform**: Android (Termux/GameHub environment)
- **Builder**: User builds on their phone, NOT the agent
- **Agent Role**: Make code changes, verify syntax, but DO NOT BUILD

### Current Development Status

#### Vulkan Integration Approach
**IMPORTANT**: We are using **direct Vulkan headers**, NOT function pointer wrappers.

**History**:
- Previous attempt: Created `vk_funcs.c`, `vk_funcs.h`, `vk_stubs.c` with function pointer wrapper system
- **ROLLED BACK**: Function pointer approach was removed (commit d3d6a96 changes reverted)
- **Current approach**: Use standard Vulkan headers directly, link against GameHub's Vulkan implementation

**Why Direct Headers**:
1. Simpler and more maintainable
2. Standard Vulkan development practice
3. GameHub provides a specific Vulkan version
4. Easier to identify which functions fail at runtime

#### GameHub Vulkan Version
- User needs to identify specific Vulkan version in their GameHub image
- Build must target that specific version
- Missing functions will be identified through testing on user's phone

### Development Workflow

#### Agent Responsibilities
1. ✅ **Analyze code** and understand the problem
2. ✅ **Make surgical changes** - minimal modifications only
3. ✅ **Verify syntax** - ensure code compiles syntactically
4. ✅ **Commit changes** with clear messages
5. ❌ **DO NOT BUILD** - user builds on their phone
6. ❌ **DO NOT TEST** - user tests on their phone

#### User Responsibilities
1. Build the code on their Android device (Termux)
2. Test in GameHub/Winlator environment
3. Report build errors or runtime failures
4. Identify missing Vulkan functions
5. Provide logcat output for debugging

### Code Change Guidelines

#### DO
- Make minimal, targeted changes
- Use standard Vulkan headers: `#include <vulkan/vulkan.h>`
- Call Vulkan functions directly: `vkCreateShaderModule()`, not wrapper pointers
- Add logging for debugging: `XENO_LOGE()`, `XENO_LOGW()`, `XENO_LOGI()`, `XENO_LOGD()`
- Keep changes focused on specific issues
- Verify syntax before committing

#### DON'T
- Add complex abstraction layers or wrappers
- Build or compile the code yourself
- Make assumptions about what works without user testing
- Remove working code unless absolutely necessary
- Add function pointer systems or dynamic loading unless explicitly requested
- Test on non-Android environments

### Build Scripts

#### Primary Build Script
- **File**: `build_simple.sh`
- **Purpose**: Main build script for Termux/Android
- **Usage**: User runs this on their phone

#### Other Scripts
- `build_android_ndk.sh` - NDK cross-compilation
- `build_cross_android.sh` - Cross-compilation setup
- `build_meson_android.sh` - Meson build system
- `build_simple_android.sh` - Alternative Android build
- `build_termux.sh` - Termux-specific build

### CMake Configuration

#### Key Settings
```cmake
# Standard Vulkan linking (current approach)
find_package(Vulkan REQUIRED)
target_link_libraries(xeno_wrapper PRIVATE Vulkan::Vulkan)

# Android-specific
if(ANDROID)
    target_link_libraries(xeno_wrapper PRIVATE log)
endif()
```

#### What NOT to Do
```cmake
# DO NOT add these (from rolled-back changes):
# target_link_options(xeno_wrapper PRIVATE "-Wl,--allow-shlib-undefined")
# Manual function pointer loading systems
# Weak symbol stubs
```

### Debugging Process

#### When User Reports Failure
1. **Get exact error**: Ask for logcat output or build error
2. **Identify specific function**: Which Vulkan call failed?
3. **Research function**: Is it in core Vulkan or extension?
4. **Propose fix**: Minimal change to handle missing function
5. **Let user test**: Wait for user to build and report back

#### Example Debug Flow
```
User: "vkCreatePipelineCache fails"
Agent: "That's a core Vulkan 1.0 function. Let me add error handling."
Agent: [Makes minimal change to check return value]
Agent: "Please build and test this change."
User: [Builds, tests, reports result]
```

### Logging System

#### Log Levels
- `XENO_LOGE()` - Errors (always logged)
- `XENO_LOGW()` - Warnings (important issues)
- `XENO_LOGI()` - Info (major events)
- `XENO_LOGD()` - Debug (detailed tracing)

#### When to Log
- **Before** Vulkan calls that might fail
- **After** getting Vulkan results (log VkResult)
- **On error paths** with context
- **Major state changes** in initialization

### Current Architecture

#### Key Files
- `src/xeno_wrapper.c` - Main Vulkan interception layer
- `src/bc_emulate.c` - BC texture compression emulation (compute shaders)
- `src/detect.c` - Device detection (Xclipse GPU)
- `src/hud.c` - Performance overlay
- `src/logging.c/h` - Logging system
- `src/app_profile.c` - Per-app configuration

#### Vulkan Flow
1. App calls Vulkan function
2. `xeno_wrapper.c` intercepts via `vkGetDeviceProcAddr`
3. Emulation logic (BC textures, etc.) applied
4. Real Vulkan function called
5. Result returned to app

### Testing Environment

#### User's Setup
- **Device**: Android phone with Xclipse GPU (Samsung Exynos)
- **Environment**: Termux + GameHub/Winlator
- **Vulkan**: GameHub's bundled Vulkan loader (version TBD)
- **Build**: On-device compilation with clang

#### What This Means
- Cannot test on x86_64 Linux (different Vulkan version)
- Cannot assume desktop Vulkan features available
- Must handle mobile Vulkan limitations
- Runtime detection of features required

### Version Control

#### Commit Messages
Format: `[component] Brief description`

Examples:
- `[bc_emulate] Add error handling for pipeline creation`
- `[cmake] Remove function pointer wrapper system`
- `[logging] Add VkResult logging macro`

#### Branching
- User works on `main` branch
- Changes pushed to `vscunha/ExynosTools` fork
- No complex branching needed

### Common Issues

#### Vulkan Functions Not Found
**Symptom**: Undefined reference at link time or runtime failure
**Cause**: GameHub's Vulkan version doesn't include function
**Solution**: 
1. Check if function is extension-based
2. Add runtime detection
3. Provide fallback or disable feature gracefully

#### Build Failures on Phone
**Symptom**: User reports compilation errors
**Cause**: Syntax issues, missing includes, wrong flags
**Solution**:
1. Review exact error message
2. Fix syntax issues
3. Verify include paths
4. DO NOT try to reproduce build locally

#### Runtime Crashes
**Symptom**: App crashes when loading library
**Cause**: Symbol resolution, initialization issues
**Solution**:
1. Request logcat output
2. Check initialization order
3. Add null checks and error handling
4. Verify LD_PRELOAD setup

### Future Work

#### Next Steps (As Reported by User)
1. Identify which Vulkan function is failing
2. Determine GameHub's exact Vulkan version
3. Implement version-specific compatibility layer
4. Test BC compression on real games

#### Potential Enhancements
- Extension detection system
- Graceful feature degradation
- Vulkan version detection at runtime
- Better error messages for missing functions

### Contact Points

#### When to Ask User
- Before making major architectural changes
- When multiple solutions are possible
- If build system changes are needed
- When testing results are required

#### What to Provide User
- Clear commit messages
- Summary of changes made
- Expected behavior after changes
- What to look for when testing

### Anti-Patterns

#### Things That Didn't Work
1. ❌ Function pointer wrapper systems (`vk_funcs.c`)
2. ❌ Weak symbol stubs (`vk_stubs.c`)
3. ❌ `--allow-shlib-undefined` linker flags
4. ❌ Building on non-Android systems

#### Why They Failed
- Added complexity without solving root issue
- Harder to debug missing functions
- Made code harder to maintain
- Didn't match user's actual environment

### Success Criteria

#### Good Changes
- ✅ Code compiles on user's phone
- ✅ Minimal modification to existing code
- ✅ Clear error messages when something fails
- ✅ Easy to identify what's not working

#### Bad Changes
- ❌ Adds layers of abstraction
- ❌ Requires testing agent can't perform
- ❌ Makes debugging harder
- ❌ Breaks existing functionality

---

## Quick Reference

### Common Commands (User Runs These)
```bash
# Build on phone
./build_simple.sh

# Package for Winlator
./package_winlator.sh

# Test in Winlator
# (Use Winlator UI to load package)
```

### Common Git Operations (Agent Does These)
```bash
# Check status
git status

# Stage changes
git add [files]

# Commit
git commit -m "[component] Description"

# Push (user does this or agent if credentials work)
git push my-fork main
```

### Checking Syntax Without Building
```bash
# Check C syntax only (no linking)
clang -fsyntax-only -I/path/to/vulkan-headers src/file.c

# Note: Agent doesn't actually run this, but keeps it in mind
```

---

## Summary for AI Agents

**TL;DR**:
1. Make minimal code changes
2. Use direct Vulkan headers, no wrappers
3. Verify syntax but DON'T BUILD
4. User builds and tests on their Android phone
5. Wait for user feedback before next iteration
6. Log everything for debugging
7. Keep it simple

**Remember**: You're making code changes for the user to test. You cannot test yourself because you don't have their exact Android/GameHub environment.
