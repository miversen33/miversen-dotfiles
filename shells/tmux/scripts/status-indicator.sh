#!/bin/bash
# Get prefix disabled status from tmux as argument
prefix_disabled="$1"
keyboard_status=""
caps_status=""

# Check if prefix is disabled
if [ "$prefix_disabled" = "on" ]; then
    keyboard_status=" "  # Keyboard icon when prefix is disabled
fi

# Caps lock detection for multiple environments
detect_caps_lock() {
    # Method 1: X11 (Linux/BSD with X server)
    if [ -n "$DISPLAY" ] && command -v xset >/dev/null 2>&1; then
        if xset q 2>/dev/null | grep "Caps Lock" | grep -q "on"; then
            return 0
        fi
    fi
    
    # Method 2: Wayland (using various Wayland-specific tools)
    if [ -n "$WAYLAND_DISPLAY" ]; then
        # Try hyprctl (Hyprland)
        if command -v hyprctl >/dev/null 2>&1; then
            if hyprctl devices 2>/dev/null | grep -A5 "Keyboard" | grep -q "capslock.*active"; then
                return 0
            fi
        fi
        
        # Try swaymsg (Sway)
        if command -v swaymsg >/dev/null 2>&1; then
            if swaymsg -t get_inputs 2>/dev/null | grep -q '"caps_lock": true'; then
                return 0
            fi
        fi
        
        # Try wlr-randr or other Wayland tools
        if command -v wtype >/dev/null 2>&1; then
            # This is a hack - we can't easily detect caps lock in Wayland
            # Fall back to other methods
            :
        fi
    fi
    
    # Method 3: Linux console/TTY
    if command -v setleds >/dev/null 2>&1; then
        if setleds 2>/dev/null | grep -q "CapsLock on"; then
            return 0
        fi
    fi
    
    # Method 4: Linux LED files (works in most Linux environments)
    for led_path in /sys/class/leds/*caps*lock*/brightness /sys/class/leds/*capslock*/brightness; do
        if [ -f "$led_path" ]; then
            if [ "$(cat "$led_path" 2>/dev/null)" = "1" ]; then
                return 0
            fi
        fi
    done
    
    # Method 5: macOS
    if command -v osascript >/dev/null 2>&1; then
        # Try the IOKit method
        caps_state=$(osascript -e '
            tell application "System Events"
                try
                    set capsLockState to (do shell script "python3 -c \"
import Quartz
kTISPropertyInputSourceID = Quartz.kTISPropertyInputSourceID
inputSources = Quartz.TISCreateInputSourceList(None, False)
for i in range(Quartz.CFArrayGetCount(inputSources)):
    inputSource = Quartz.CFArrayGetValueAtIndex(inputSources, i)
    if Quartz.TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID):
        capsLockState = Quartz.CGEventSourceFlagsState(Quartz.kCGEventSourceStateHIDSystemState)
        print(1 if (capsLockState & Quartz.kCGEventFlagMaskAlphaShift) else 0)
        break
\"")
                    return capsLockState
                on error
                    return "0"
                end try
            end tell
        ' 2>/dev/null)
        
        if [ "$caps_state" = "1" ]; then
            return 0
        fi
        
        # Fallback macOS method
        if ioreg -n IOHIDKeyboard -r | grep -q '"CapsLockState" = 1'; then
            return 0
        fi
    fi
    
    # Method 6: WSL (Windows Subsystem for Linux)
    if grep -q Microsoft /proc/version 2>/dev/null || grep -q microsoft /proc/version 2>/dev/null; then
        # Use PowerShell to check Windows caps lock state
        if command -v powershell.exe >/dev/null 2>&1; then
            caps_state=$(powershell.exe -Command "
                Add-Type -AssemblyName System.Windows.Forms
                [System.Windows.Forms.Control]::IsKeyLocked([System.Windows.Forms.Keys]::CapsLock)
            " 2>/dev/null | tr -d '\r')
            
            if [ "$caps_state" = "True" ]; then
                return 0
            fi
        elif command -v cmd.exe >/dev/null 2>&1; then
            # Alternative WSL method using VBScript
            caps_state=$(cmd.exe /c 'echo Set objShell = CreateObject("WScript.Shell") : WScript.Echo objShell.AppActivate("") : WScript.Echo CreateObject("WScript.Shell").SendKeys("{CAPSLOCK}") > %TEMP%\capscheck.vbs && cscript //nologo %TEMP%\capscheck.vbs' 2>/dev/null)
            # This is complex and might not work reliably
        fi
    fi
    
    return 1
}

# Check caps lock and set status
if detect_caps_lock; then
    caps_status="󰁞 "
fi

# Concatenate both statuses
echo "${keyboard_status}${caps_status}"
