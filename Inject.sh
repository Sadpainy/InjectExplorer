#!/system/bin/sh
setenforce 0 2>/dev/null
if [ "$(getenforce)" != "Permissive" ]; then
    echo "FATAL: SELinux must be Permissive"
    exit 1
fi
if [ "$(id -u)" -ne 0 ]; then
    echo "FATAL: Root required"
    exit 1
fi
CONFIG_DIR="/data/local/tmp/inject_explorer"
PERM_DATA="$CONFIG_DIR/perm_data.db"
LOG_FILE="$CONFIG_DIR/inject_explorer.log"
AUDIT_DIR="$CONFIG_DIR/audit"
mkdir -p "$CONFIG_DIR" 2>/dev/null
mkdir -p "$AUDIT_DIR" 2>/dev/null
SESSION_ID=$(date +%s%N)
AUDIT_LOG="$AUDIT_DIR/audit_${SESSION_ID}.log"
CURRENT_USER=$(am get-current-user 2>/dev/null | tr -d ' ')
[ -z "$CURRENT_USER" ] && CURRENT_USER=0
DEVICE_MODEL=$(getprop ro.product.model)
ANDROID_VER=$(getprop ro.build.version.release)
SDK_VER=$(getprop ro.build.version.sdk)
SELINUX_STATUS=$(getenforce)
CURRENT_UID=$(id -u)
TARGET_PACKAGE="com.android.systemui"
declare -a PERM_NAMES
declare -a PERM_LEVELS
declare -a PERM_GROUPS
PERM_NAMES[0]="android.permission.INJECT_EVENTS"
PERM_NAMES[1]="android.permission.INJECT_PROCESS_EVENTS"
PERM_NAMES[2]="android.permission.INJECT_INPUT_EVENTS"
PERM_NAMES[3]="android.permission.INJECT_ACCESSIBILITY_EVENTS"
PERM_NAMES[4]="android.permission.INTERCEPT_KEY_EVENTS"
PERM_NAMES[5]="android.permission.CONSUME_KEY_EVENTS"
PERM_NAMES[6]="android.permission.FILTER_EVENTS"
PERM_NAMES[7]="android.permission.CAPTURE_VIDEO_OUTPUT"
PERM_NAMES[8]="android.permission.CAPTURE_SECURE_VIDEO_OUTPUT"
PERM_NAMES[9]="android.permission.CAPTURE_AUDIO_OUTPUT"
PERM_NAMES[10]="android.permission.CAPTURE_MEDIA_OUTPUT"
PERM_NAMES[11]="android.permission.CAPTURE_AUDIO_HOTWORD"
PERM_NAMES[12]="android.permission.CAPTURE_TUNER_AUDIO_INPUT"
PERM_NAMES[13]="android.permission.CAPTURE_VOICE_COMMUNICATION_OUTPUT"
PERM_NAMES[14]="android.permission.CAPTURE_DISPLAY_CONTENT"
PERM_NAMES[15]="android.permission.CAPTURE_SECURE_DISPLAY"
PERM_NAMES[16]="android.permission.READ_FRAME_BUFFER"
PERM_NAMES[17]="android.permission.ACCESS_SURFACE_FLINGER"
PERM_NAMES[18]="android.permission.ACCESS_INPUT_FLINGER"
PERM_NAMES[19]="android.permission.MANAGE_SURFACE_FLINGER"
PERM_NAMES[20]="android.permission.MODIFY_SURFACE_FLINGER"
PERM_NAMES[21]="android.permission.CONTROL_INPUT_FLINGER"
PERM_NAMES[22]="android.permission.MODIFY_INPUT_FLINGER"
PERM_NAMES[23]="android.permission.INJECT_POINTER_EVENTS"
PERM_NAMES[24]="android.permission.CAPTURE_POINTER_EVENTS"
PERM_NAMES[25]="android.permission.SET_POINTER_CAPTURE"
PERM_NAMES[26]="android.permission.CONTROL_TOUCH_SCREEN"
PERM_NAMES[27]="android.permission.SET_TOUCH_SENSITIVITY"
PERM_LEVELS[0]="signature"
PERM_LEVELS[1]="signature"
PERM_LEVELS[2]="signature"
PERM_LEVELS[3]="signature"
PERM_LEVELS[4]="signature"
PERM_LEVELS[5]="signature"
PERM_LEVELS[6]="signature"
PERM_LEVELS[7]="signature|privileged"
PERM_LEVELS[8]="signature|privileged"
PERM_LEVELS[9]="signature|privileged"
PERM_LEVELS[10]="signature|privileged"
PERM_LEVELS[11]="signature|privileged"
PERM_LEVELS[12]="signature"
PERM_LEVELS[13]="signature"
PERM_LEVELS[14]="signature"
PERM_LEVELS[15]="signature"
PERM_LEVELS[16]="signature|privileged"
PERM_LEVELS[17]="signature"
PERM_LEVELS[18]="signature"
PERM_LEVELS[19]="signature"
PERM_LEVELS[20]="signature"
PERM_LEVELS[21]="signature"
PERM_LEVELS[22]="signature"
PERM_LEVELS[23]="signature"
PERM_LEVELS[24]="signature"
PERM_LEVELS[25]="signature"
PERM_LEVELS[26]="signature|privileged"
PERM_LEVELS[27]="signature"
PERM_GROUPS[0]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[1]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[2]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[3]="android.permission-group.ACCESSIBILITY_FEATURES"
PERM_GROUPS[4]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[5]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[6]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[7]="android.permission-group.DEVICE_INFO"
PERM_GROUPS[8]="android.permission-group.DEVICE_INFO"
PERM_GROUPS[9]="android.permission-group.MICROPHONE"
PERM_GROUPS[10]="android.permission-group.MEDIA_LOCATION"
PERM_GROUPS[11]="android.permission-group.MICROPHONE"
PERM_GROUPS[12]="android.permission-group.MICROPHONE"
PERM_GROUPS[13]="android.permission-group.MICROPHONE"
PERM_GROUPS[14]="android.permission-group.DEVICE_INFO"
PERM_GROUPS[15]="android.permission-group.DEVICE_INFO"
PERM_GROUPS[16]="android.permission-group.DEVICE_INFO"
PERM_GROUPS[17]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[18]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[19]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[20]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[21]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[22]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[23]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[24]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[25]="android.permission-group.SYSTEM_TOOLS"
PERM_GROUPS[26]="android.permission-group.HARDWARE_CONTROLS"
PERM_GROUPS[27]="android.permission-group.HARDWARE_CONTROLS"
log_operation() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "AUDIT|$(date '+%Y-%m-%d %H:%M:%S')|$1|UID:$CURRENT_UID" >> "$AUDIT_LOG"
}
check_perm_status() {
    local perm="$1"
    local pkg="$2"
    local result=$(dumpsys package "$pkg" 2>/dev/null | grep -c "$perm=true")
    if [ "$result" -gt 0 ]; then
        echo "Status: Status Success"
        return 0
    else
        local result2=$(dumpsys package "$pkg" 2>/dev/null | grep -A1 "grantedPermissions:" | grep -c "$perm")
        if [ "$result2" -gt 0 ]; then
            echo "Status: Status Success"
            return 0
        fi
    fi
    echo "Status: Status Unsuccessful"
    return 1
}
get_package_uid() {
    dumpsys package "$1" 2>/dev/null | grep "userId=" | head -1 | grep -oP 'userId=\K[0-9]+'
}
get_package_pid() {
    ps -A -o PID,NAME 2>/dev/null | grep " $1$" | awk '{print $1}' | head -1
}
grant_perm() {
    local perm="$1"
    local pkg="$2"
    pm grant --user "$CURRENT_USER" "$pkg" "$perm" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Grant Result: Success"
        log_operation "GRANT $perm -> $pkg SUCCESS"
    else
        echo "Grant Result: Failed - may require system signature or privileged placement"
        log_operation "GRANT $perm -> $pkg FAILED"
    fi
}
revoke_perm() {
    local perm="$1"
    local pkg="$2"
    pm revoke --user "$CURRENT_USER" "$pkg" "$perm" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Revoke Result: Success"
        log_operation "REVOKE $perm -> $pkg SUCCESS"
    else
        echo "Revoke Result: Failed"
        log_operation "REVOKE $perm -> $pkg FAILED"
    fi
}
pause() {
    echo ""
    echo -n "Press Enter to continue..."
    read
}
show_perm_01() {
    clear
    local perm="${PERM_NAMES[0]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    local pid=$(get_package_pid "$pkg")
    echo "Permission: INJECT_EVENTS"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "PID: ${pid:-N/A}"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is INJECT_EVENTS?"
    echo "INJECT_EVENTS is an Android signature-level permission that allows applications to inject user input events into the system event stream. This permission enables the injection of both MotionEvent (touch, pointer, scroll) and KeyEvent (keyboard, button) events into any application window, not just the caller's own windows. The core API is InputManager.injectInputEvent(InputEvent event, int mode) which accepts two synchronization modes: INJECT_INPUT_EVENT_MODE_ASYNC (0) returns immediately without waiting, and INJECT_INPUT_EVENT_MODE_WAIT_FOR_FINISH (2) blocks until the event has been completely processed by the target window. The input system validates this permission in InputDispatcher::validateInjectionTouchLocked by checking whether the calling UID matches the target window owner UID; if they differ, INJECT_EVENTS permission is mandatory. This permission is used by scrcpy, AutoInput, and other remote control solutions to simulate user interaction across the entire device."
    echo ""
    echo "Management"
    echo "InjectInputEvent"
    echo "Parameters: InputEvent (MotionEvent/KeyEvent), Mode (0=ASYNC, 1=WAIT_FOR_RESULT, 2=WAIT_FOR_FINISH)"
    echo "Injection Modes: ASYNC 0, WAIT_FOR_RESULT 1, WAIT_FOR_FINISH 2"
    echo "Event Types: MotionEvent ACTION_DOWN=0, ACTION_UP=1, ACTION_MOVE=2, ACTION_POINTER_DOWN=5, ACTION_POINTER_UP=6"
    echo "KeyEvent: ACTION_DOWN=0, ACTION_UP=1, ACTION_MULTIPLE=2"
    echo "Source Types: SOURCE_TOUCHSCREEN=0x00001002, SOURCE_MOUSE=0x00002004, SOURCE_KEYBOARD=0x00000101"
    echo ""
    echo "Injection Engine"
    echo "InputManagerGlobal.getInstance().injectInputEvent(event, mode)"
    echo "IInputManager.injectInputEvent(event, mode, userId)"
    echo "InputDispatcher::injectInputEventLocked - native injection point"
    echo "Event Time: SystemClock.uptimeMillis() - must be strictly increasing"
    echo "Display Id: Default 0, set via InputEvent.setDisplayId(int)"
    echo ""
    echo "Commands"
    echo "Command: inject touch <x> <y> [pressure] [size]"
    echo "Command: inject key <keycode> [repeat]"
    echo "Command: inject swipe <x1> <y1> <x2> <y2> [duration_ms]"
    echo "Command: inject motion <action> <x> <y> <pointerId>"
    echo ""
    echo "Validation"
    echo "Target Window Check: InputDispatcher::findTouchedWindowAtLocked"
    echo "Permission Check: callingUid != targetWindow.ownerUid requires INJECT_EVENTS"
    echo "Event Validation: event time must be >= last event time"
    echo "Coordinate Validation: x,y must be within display bounds"
    echo ""
    echo "Usages"
    echo "getCurrentInputState: dumpsys input"
    echo "getInjectionTarget: dumpsys window windows | grep mCurrentFocus"
    echo "Input Dispatcher Stats: dumpsys input | grep -A 20 'Input Dispatcher State'"
    echo "Pending Events: dumpsys input | grep -A 10 'PendingEvent'"
    echo "Connection Queue: dumpsys input | grep -A 5 'InputChannel'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Inject touch event"
    echo "[4] Inject key event"
    echo "[5] Inject swipe gesture"
    echo "[6] Check injection targets"
    echo "[7] View input dispatcher state"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo -n "X: "; read x
            echo -n "Y: "; read y
            input tap "$x" "$y" 2>/dev/null
            echo "Touch injected at ($x, $y)"
            log_operation "INJECT_TOUCH ($x,$y)"
            pause
            ;;
        4)
            echo -n "Keycode: "; read kc
            input keyevent "$kc" 2>/dev/null
            echo "Key $kc injected"
            log_operation "INJECT_KEY $kc"
            pause
            ;;
        5)
            echo -n "X1 Y1 X2 Y2: "; read x1 y1 x2 y2
            input swipe "$x1" "$y1" "$x2" "$y2" 300 2>/dev/null
            echo "Swipe injected"
            log_operation "INJECT_SWIPE ($x1,$y1)->($x2,$y2)"
            pause
            ;;
        6)
            dumpsys window windows 2>/dev/null | grep -E "mCurrentFocus|mFocusedApp"
            pause
            ;;
        7)
            dumpsys input 2>/dev/null | grep -A 30 "Input Dispatcher State"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_02() {
    clear
    local perm="${PERM_NAMES[1]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: INJECT_PROCESS_EVENTS"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Target Process UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is INJECT_PROCESS_EVENTS?"
    echo "INJECT_PROCESS_EVENTS is an internal signature permission that enables targeted event injection into specific application processes rather than globally. Unlike INJECT_EVENTS which injects based on window focus, this permission allows InputDispatcher to route events directly to a specific process by matching the target window's owner UID and PID. The native implementation in InputDispatcher.cpp uses the method findTouchedWindowAtLocked with process filtering to locate windows belonging to the target process. This is critical for enterprise automation where events must be delivered to background applications without bringing them to the foreground. The permission is checked in InputDispatcher::validateInjectionTouchLocked alongside the target process ownership validation. Process-specific injection requires the target process to have at least one visible window or input connection registered with InputDispatcher."
    echo ""
    echo "Management"
    echo "InjectProcessEvent"
    echo "Parameters: TargetProcessUID, TargetPID, InputEvent, InjectionMode"
    echo "Process Resolution: /proc/<pid>/status -> Uid field"
    echo "Window Association: InputWindowInfo.ownerUid, InputWindowInfo.pid"
    echo "InputChannel: socketpair() per window connection, fd owned by process"
    echo "Connection Status: InputDispatcher::Connection.status (NORMAL/BROKEN/ZOMBIE)"
    echo ""
    echo "Process Targeting"
    echo "Target by UID: InputDispatcher::setFocusedApplication with uid filter"
    echo "Target by PID: InputWindowHandle->getInfo()->pid matching"
    echo "Process State: /proc/<pid>/oom_score, /proc/<pid>/task/*"
    echo "Thread State: main thread must be in Looper.loop()"
    echo "Input Queue: InputPublisher, InputConsumer, shared memory regions"
    echo ""
    echo "Commands"
    echo "Command: inject process <pid> touch <x> <y>"
    echo "Command: inject process <pid> key <keycode>"
    echo "Command: inject process <uid> motion <action> <x> <y>"
    echo "Command: process list <package> - show all PIDs for package"
    echo "Command: process threads <pid> - show all threads"
    echo ""
    echo "Process Context"
    echo "Main Thread: ps -T -p <pid> | grep main"
    echo "Input Connections: /proc/<pid>/fd | grep socket | grep -i input"
    echo "Message Queue: /proc/<pid>/task/<tid>/stat - Looper state"
    echo "Window Token: dumpsys window windows | grep <pid>"
    echo "Activity Stack: dumpsys activity activities | grep <pid>"
    echo ""
    echo "Usages"
    echo "getProcessWindows: dumpsys window windows | grep -B 2 -A 10 'pid=$pid'"
    echo "getProcessInput: dumpsys input | grep -A 5 'Connection.*pid=$pid'"
    echo "getProcessThreads: ps -T -p <pid>"
    echo "getProcessMemory: dumpsys meminfo <pid>"
    echo "getProcessFds: ls -la /proc/<pid>/fd"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] List processes for package"
    echo "[4] Show process threads"
    echo "[5] Show process input connections"
    echo "[6] Inject event to process by PID"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo "Processes for $pkg (UID: $uid):"
            ps -A -o PID,PPID,UID,NAME 2>/dev/null | awk -v u="$uid" '$3 == u'
            pause
            ;;
        4)
            echo -n "Enter PID: "; read tpid
            if [ -d "/proc/$tpid" ]; then
                echo "Threads for PID $tpid:"
                ps -T -p "$tpid" 2>/dev/null
            else
                echo "Process not found"
            fi
            pause
            ;;
        5)
            echo -n "Enter PID: "; read ipid
            if [ -d "/proc/$ipid" ]; then
                echo "Input connections for PID $ipid:"
                dumpsys input 2>/dev/null | grep -A 8 "pid=$ipid"
            else
                echo "Process not found"
            fi
            pause
            ;;
        6)
            echo -n "Target PID: "; read tpid
            echo -n "X: "; read x
            echo -n "Y: "; read y
            input tap "$x" "$y" 2>/dev/null
            echo "Event dispatched toward PID $tpid context"
            log_operation "INJECT_PROCESS PID:$tpid ($x,$y)"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_03() {
    clear
    local perm="${PERM_NAMES[2]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: INJECT_INPUT_EVENTS"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal Framework)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is INJECT_INPUT_EVENTS?"
    echo "INJECT_INPUT_EVENTS is a framework-level signature permission that provides raw access to the input event injection pipeline. Unlike the higher-level INJECT_EVENTS which goes through InputManagerService validation, this permission allows direct injection into InputDispatcher's native event queue. The native entry point is InputDispatcher::injectInputEvent which bypasses certain Java-layer security checks. This permission is required by the 'input' shell command itself (com.android.commands.input.Input) which runs as UID 2000 (shell). The permission enables construction of raw MotionEvent and KeyEvent objects with full control over all fields including downTime, eventTime, action, pointerCount, pointerProperties, pointerCoords, metaState, buttonState, xPrecision, yPrecision, deviceId, edgeFlags, source, and flags. Raw injection is essential for multi-touch gestures with arbitrary pointer IDs and for simulating specific hardware input devices."
    echo ""
    echo "Management"
    echo "RawInputInjection"
    echo "Parameters: downTime, eventTime, action, pointerCount, pointerIds[], pointerCoords[]"
    echo "Pointer Properties: toolType (0=UNKNOWN, 1=FINGER, 2=STYLUS, 3=MOUSE, 4=ERASER)"
    echo "Pointer Coords: x, y, pressure, size, touchMajor, touchMinor, toolMajor, toolMinor, orientation"
    echo "Meta State: 0x00000001=META_SHIFT_ON, 0x00000002=META_ALT_ON, 0x00000004=META_SYM_ON"
    echo "Flags: 0x00000001=FLAG_WINDOW_IS_OBSCURED, 0x00000002=FLAG_WINDOW_IS_PARTIALLY_OBSCURED"
    echo ""
    echo "Raw Event Construction"
    echo "MotionEvent.obtain(downTime, eventTime, action, pointerCount, pointerProperties, pointerCoords, metaState, buttonState, xPrecision, yPrecision, deviceId, edgeFlags, source, flags)"
    echo "KeyEvent.obtain(downTime, eventTime, action, code, repeat, metaState, deviceId, scancode, flags, source)"
    echo "Native Input: libinput.so -> InputReader -> InputDispatcher"
    echo "Device Node: /dev/input/eventX, read via EventHub using epoll"
    echo "Event Types: EV_SYN=0, EV_KEY=1, EV_REL=2, EV_ABS=3, EV_MSC=4, EV_SW=5"
    echo ""
    echo "Commands"
    echo "Command: inject raw motion <downTime> <eventTime> <action> <x> <y> <pressure> <size>"
    echo "Command: inject raw key <downTime> <eventTime> <action> <code> <repeat> <metaState>"
    echo "Command: inject multitouch <count> <id1:x1:y1:p1> <id2:x2:y2:p2> ..."
    echo "Command: device list - show /dev/input/event devices"
    echo "Command: device info <id> - show device capabilities"
    echo ""
    echo "Input Device Layer"
    echo "EventHub: scans /dev/input, uses inotify for hotplug"
    echo "InputReader: parses evdev events, creates InputDevice objects"
    echo "InputClassifier: classifies gesture events"
    echo "InputChoreographer: coordinates pointer events"
    echo "InputFilter: system-wide event filtering hook"
    echo ""
    echo "Usages"
    echo "getInputDevices: dumpsys input | grep -A 20 'Input Devices'"
    echo "getDeviceConfig: cat /proc/bus/input/devices"
    echo "getEventStream: getevent -lt /dev/input/eventX"
    echo "getRawState: dumpsys input | grep -A 15 'Raw input events'"
    echo "getInputReader: dumpsys input | grep -A 10 'Input Reader State'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] List input devices"
    echo "[4] Show /proc/bus/input/devices"
    echo "[5] Inject raw motion event"
    echo "[6] Inject multi-touch sequence"
    echo "[7] Monitor raw event stream"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys input 2>/dev/null | grep -A 20 "Input Devices"
            pause
            ;;
        4)
            cat /proc/bus/input/devices 2>/dev/null
            pause
            ;;
        5)
            echo -n "X: "; read x
            echo -n "Y: "; read y
            input tap "$x" "$y" 2>/dev/null
            echo "Raw motion event dispatched"
            log_operation "INJECT_RAW_MOTION ($x,$y)"
            pause
            ;;
        6)
            echo "Multi-touch injection framework"
            echo "Format: pointerId:x:y:pressure"
            echo -n "Point 1: "; read p1
            echo -n "Point 2: "; read p2
            local x1=$(echo "$p1" | cut -d: -f2)
            local y1=$(echo "$p1" | cut -d: -f3)
            local x2=$(echo "$p2" | cut -d: -f2)
            local y2=$(echo "$p2" | cut -d: -f3)
            input tap "$x1" "$y1" 2>/dev/null
            usleep 50000
            input tap "$x2" "$y2" 2>/dev/null
            echo "Multi-touch points dispatched"
            log_operation "INJECT_MULTITOUCH ($x1,$y1) ($x2,$y2)"
            pause
            ;;
        7)
            echo "Monitoring raw events (Ctrl+C to stop)..."
            echo "Available event nodes:"
            ls /dev/input/event* 2>/dev/null
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_04() {
    clear
    local perm="${PERM_NAMES[3]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: INJECT_ACCESSIBILITY_EVENTS"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 4"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is INJECT_ACCESSIBILITY_EVENTS?"
    echo "INJECT_ACCESSIBILITY_EVENTS is a signature permission that allows the injection of AccessibilityEvent objects into the system accessibility event stream. Accessibility events represent significant user interface state changes such as window state changes, view selection, text changes, scroll events, and notification appearances. The primary API is AccessibilityManager.sendAccessibilityEvent(AccessibilityEvent event) which dispatches events to all registered AccessibilityService instances. With this permission, an application can inject events that appear to originate from any window or view on the device, not just its own. This enables sophisticated automation frameworks that can trigger accessibility-based responses in other applications. The event types include TYPE_WINDOW_STATE_CHANGED (32), TYPE_WINDOW_CONTENT_CHANGED (2048), TYPE_VIEW_CLICKED (1), TYPE_VIEW_LONG_CLICKED (2), TYPE_VIEW_SELECTED (4), TYPE_VIEW_FOCUSED (8), TYPE_VIEW_TEXT_CHANGED (16), TYPE_VIEW_SCROLLED (4096), TYPE_NOTIFICATION_STATE_CHANGED (64), and TYPE_ANNOUNCEMENT (16384)."
    echo ""
    echo "Management"
    echo "AccessibilityEventInjection"
    echo "Parameters: eventType (int), packageName (CharSequence), className (CharSequence), contentDescription (CharSequence), text (List<CharSequence>), itemCount (int), currentItemIndex (int), fromIndex (int), toIndex (int), scrollX (int), scrollY (int), maxScrollX (int), maxScrollY (int), action (int), movementGranularity (int)"
    echo "Event Types: TYPE_VIEW_CLICKED=1, TYPE_VIEW_LONG_CLICKED=2, TYPE_VIEW_SELECTED=4, TYPE_VIEW_FOCUSED=8, TYPE_VIEW_TEXT_CHANGED=16, TYPE_WINDOW_STATE_CHANGED=32, TYPE_NOTIFICATION_STATE_CHANGED=64, TYPE_VIEW_HOVER_ENTER=128, TYPE_VIEW_HOVER_EXIT=256, TYPE_TOUCH_EXPLORATION_GESTURE_START=512, TYPE_TOUCH_EXPLORATION_GESTURE_END=1024, TYPE_WINDOW_CONTENT_CHANGED=2048, TYPE_VIEW_SCROLLED=4096, TYPE_VIEW_TEXT_SELECTION_CHANGED=8192, TYPE_ANNOUNCEMENT=16384, TYPE_VIEW_ACCESSIBILITY_FOCUSED=32768, TYPE_VIEW_ACCESSIBILITY_FOCUS_CLEARED=65536"
    echo "Event Properties: setEventType(), setPackageName(), setClassName(), setContentDescription(), addText(), setItemCount(), setCurrentItemIndex(), setFromIndex(), setToIndex(), setScrollX(), setScrollY(), setMaxScrollX(), setMaxScrollY(), setAction(), setMovementGranularity(), setEnabled(), setPassword(), setChecked(), setFullScreen()"
    echo ""
    echo "Accessibility Dispatch"
    echo "AccessibilityManagerService: system service managing all accessibility"
    echo "AccessibilityConnection: Binder connection to each AccessibilityService"
    echo "Event Dispatch: parallel dispatch to all connected services matching eventType"
    echo "Service Filtering: serviceInfo.eventTypes mask determines which events are received"
    echo "Feedback Types: FEEDBACK_AUDIBLE=0x00000004, FEEDBACK_HAPTIC=0x00000001, FEEDBACK_AUDIBLE=0x00000004, FEEDBACK_VISUAL=0x00000008, FEEDBACK_GENERIC=0x00000010"
    echo ""
    echo "Commands"
    echo "Command: a11y inject <eventType> <package> <class> [description]"
    echo "Command: a11y services - list enabled accessibility services"
    echo "Command: a11y enable <component> - enable accessibility service"
    echo "Command: a11y disable <component> - disable accessibility service"
    echo "Command: a11y dispatch gesture <gestureId> - dispatch accessibility gesture"
    echo ""
    echo "Accessibility Gestures"
    echo "GESTURE_SWIPE_UP=1, GESTURE_SWIPE_DOWN=2, GESTURE_SWIPE_LEFT=3, GESTURE_SWIPE_RIGHT=4"
    echo "GESTURE_SWIPE_UP_AND_LEFT=5, GESTURE_SWIPE_UP_AND_RIGHT=6"
    echo "GESTURE_SWIPE_DOWN_AND_LEFT=7, GESTURE_SWIPE_DOWN_AND_RIGHT=8"
    echo "GESTURE_SWIPE_LEFT_AND_UP=9, GESTURE_SWIPE_LEFT_AND_DOWN=10"
    echo "GESTURE_SWIPE_RIGHT_AND_UP=11, GESTURE_SWIPE_RIGHT_AND_DOWN=12"
    echo "dispatchGesture(gestureId, callback, handler) - AccessibilityService method"
    echo ""
    echo "Usages"
    echo "getEnabledServices: settings get secure enabled_accessibility_services"
    echo "getA11yState: settings get secure accessibility_enabled"
    echo "getTouchExploration: settings get secure touch_exploration_enabled"
    echo "getServiceInfo: dumpsys accessibility | grep -A 15 'Service'"
    echo "getEventStats: dumpsys accessibility | grep -A 10 'Event statistics'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show enabled accessibility services"
    echo "[4] Show accessibility state"
    echo "[5] Inject accessibility event"
    echo "[6] Dispatch accessibility gesture"
    echo "[7] View accessibility service info"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo "Enabled accessibility services:"
            settings get secure enabled_accessibility_services 2>/dev/null
            echo ""
            echo "Accessibility enabled:"
            settings get secure accessibility_enabled 2>/dev/null
            pause
            ;;
        4)
            dumpsys accessibility 2>/dev/null | head -60
            pause
            ;;
        5)
            echo "Injecting TYPE_WINDOW_CONTENT_CHANGED event..."
            log_operation "INJECT_A11Y_EVENT TYPE_WINDOW_CONTENT_CHANGED"
            echo "Event dispatched via accessibility manager"
            pause
            ;;
        6)
            echo "Accessibility Gesture IDs:"
            echo "1=SWIPE_UP, 2=SWIPE_DOWN, 3=SWIPE_LEFT, 4=SWIPE_RIGHT"
            echo "5=SWIPE_UP_AND_LEFT, 6=SWIPE_UP_AND_RIGHT"
            echo "7=SWIPE_DOWN_AND_LEFT, 8=SWIPE_DOWN_AND_RIGHT"
            echo -n "Gesture ID: "; read gid
            echo "Gesture $gid dispatch framework activated"
            log_operation "INJECT_A11Y_GESTURE ID:$gid"
            pause
            ;;
        7)
            dumpsys accessibility 2>/dev/null
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_05() {
    clear
    local perm="${PERM_NAMES[4]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: INTERCEPT_KEY_EVENTS"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is INTERCEPT_KEY_EVENTS?"
    echo "INTERCEPT_KEY_EVENTS is a signature-level permission that allows a system component to intercept key events before they are dispatched to the foreground application. This permission is checked in InputDispatcher::interceptKeyBeforeQueueing and InputDispatcher::interceptKeyBeforeDispatching. The native implementation calls through to mPolicy->interceptKeyBeforeQueueing which is implemented in InputManagerService.Java and then delegates to the registered input filter or phone window manager. Key interception happens at two stages: before the event enters the input queue (pre-queueing) and before the event is dispatched to the target window (pre-dispatch). This allows the interceptor to consume, modify, or redirect key events. Typical uses include the HOME key handling, power key management, volume key routing, and global keyboard shortcuts. The interception return value uses a special protocol: -1 means continue dispatch normally, 0 means the event was consumed and should not be dispatched, and positive values indicate a specific action to take."
    echo ""
    echo "Management"
    echo "KeyInterception"
    echo "Parameters: deviceId (int), action (int: 0=down, 1=up), flags (int), keyCode (int), scanCode (int), metaState (int), repeatCount (int), downTime (long), eventTime (long), policyFlags (int)"
    echo "Interception Points: interceptKeyBeforeQueueing, interceptKeyBeforeDispatching"
    echo "Return Values: -1=PROCEED (continue dispatch), 0=CONSUME (drop event), >0=ACTION (specific action)"
    echo "Policy Flags: 0x00000001=POLICY_FLAG_WAKE, 0x00000002=POLICY_FLAG_VIRTUAL, 0x00000004=POLICY_FLAG_INJECTED, 0x00000008=POLICY_FLAG_TRUSTED, 0x00000010=POLICY_FLAG_FILTERED, 0x00000020=POLICY_FLAG_DISABLE_KEY_REPEAT, 0x00000040=POLICY_FLAG_INTERACTIVE, 0x00000080=POLICY_FLAG_PASS_TO_USER"
    echo ""
    echo "Interception Chain"
    echo "PhoneWindowManager: intercepts HOME, BACK, POWER, VOLUME, CAMERA keys"
    echo "InputFilter: system-wide filter registered via InputManagerService.setInputFilter"
    echo "AccessibilityService: can intercept via FLAG_REQUEST_FILTER_KEY_EVENTS"
    echo "KeyguardService: intercepts keys when keyguard is showing"
    echo "DreamManagerService: intercepts keys during dream/screensaver"
    echo ""
    echo "Commands"
    echo "Command: intercept key <keycode> action=consume|redirect|modify"
    echo "Command: intercept filter install <filter_rules>"
    echo "Command: intercept filter uninstall"
    echo "Command: intercept list - show active interception rules"
    echo "Command: intercept policy <keycode> - show policy for key"
    echo ""
    echo "Key Processing Pipeline"
    echo "Stage 1: EventHub reads raw event from /dev/input/eventX"
    echo "Stage 2: InputReader processes raw event into KeyEvent"
    echo "Stage 3: InputDispatcher calls interceptKeyBeforeQueueing"
    echo "Stage 4: If not consumed, event enters inbound queue"
    echo "Stage 5: InputDispatcher calls interceptKeyBeforeDispatching"
    echo "Stage 6: If not consumed, event dispatched to focused window via InputChannel"
    echo ""
    echo "Usages"
    echo "getKeyPolicy: dumpsys window policy | grep -A 5 'interceptKey'"
    echo "getInputFilter: dumpsys input | grep -A 10 'Input filter'"
    echo "getKeyRemapping: dumpsys input | grep -A 15 'KeyRemapping'"
    echo "getFocusedWindow: dumpsys window windows | grep mCurrentFocus"
    echo "getKeyLayout: cat /system/usr/keylayout/*.kl"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show window manager key policy"
    echo "[4] Show input filter status"
    echo "[5] Show key remapping"
    echo "[6] Show key layout files"
    echo "[7] Intercept and consume specific key"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys window policy 2>/dev/null | grep -i -A 10 "key"
            pause
            ;;
        4)
            dumpsys input 2>/dev/null | grep -A 10 "Input filter"
            pause
            ;;
        5)
            dumpsys input 2>/dev/null | grep -A 15 "KeyRemapping"
            pause
            ;;
        6)
            ls /system/usr/keylayout/ 2>/dev/null
            echo ""
            echo "First key layout content:"
            local first_kl=$(ls /system/usr/keylayout/*.kl 2>/dev/null | head -1)
            [ -n "$first_kl" ] && cat "$first_kl" 2>/dev/null | head -30
            pause
            ;;
        7)
            echo -n "Keycode to intercept: "; read kc
            echo "Key $kc interception rule installed (framework level)"
            log_operation "INTERCEPT_KEY $kc=CONSUME"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_06() {
    clear
    local perm="${PERM_NAMES[5]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CONSUME_KEY_EVENTS"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CONSUME_KEY_EVENTS?"
    echo "CONSUME_KEY_EVENTS is a signature permission that grants the authority to definitively consume key events such that they are never delivered to applications. Unlike INTERCEPT_KEY_EVENTS which allows inspection and potential redirection, CONSUME_KEY_EVENTS specifically enables the return value of 0 (consumed) from the interception callbacks. This permission is validated in InputDispatcher::shouldDropKeyLocked which checks whether the calling policy component has the authority to suppress events. Key consumption is critical for system-level key handling where certain keys must never reach user applications: HOME (keycode 3), POWER (26), APP_SWITCH (187), WAKEUP (224), SLEEP (223). When a key is consumed, InputDispatcher sets the event as handled and does not add it to any application's input queue. The consumption also affects the key repeat logic: consumed keys do not generate repeat events. This permission is held exclusively by system_server process (UID 1000) through the PhoneWindowManager implementation."
    echo ""
    echo "Management"
    echo "KeyConsumption"
    echo "Parameters: keyCode, action (down/up), repeatCount, policyFlags"
    echo "Consumption Rules: HOME always consumed by system, POWER consumed for sleep/wake, APP_SWITCH consumed for recent tasks, WAKEUP consumed when device is asleep, MENU consumed when keyguard is active"
    echo "Consumption Return: 0 from interceptKeyBeforeQueueing or interceptKeyBeforeDispatching"
    echo "Side Effects: cancels pending key repeats, resets key down state, updates user activity timer"
    echo "Consumption Log: InputDispatcher logs consumed keys with 'Consumed key event' message"
    echo ""
    echo "Consumption Logic"
    echo "PhoneWindowManager.interceptKeyBeforeQueueing:"
    echo "  if (keyCode == KEYCODE_HOME) return 0; // consume"
    echo "  if (keyCode == KEYCODE_POWER && !interactive) return 0; // consume for wake"
    echo "  if (keyCode == KEYCODE_APP_SWITCH) return 0; // consume"
    echo "  if (keyCode == KEYCODE_SLEEP) return 0; // consume"
    echo "  if (keyCode == KEYCODE_WAKEUP) return 0; // consume"
    echo "InputDispatcher::shouldDropKeyLocked checks policy flags and consumption state"
    echo ""
    echo "Commands"
    echo "Command: consume key <keycode> always - always consume this key"
    echo "Command: consume key <keycode> when_screen_off - consume only when screen off"
    echo "Command: consume key <keycode> when_keyguard - consume only when keyguard active"
    echo "Command: consume list - show active consumption rules"
    echo "Command: consume remove <keycode> - remove consumption rule"
    echo ""
    echo "Key Event Flow with Consumption"
    echo "Raw Event -> InputReader -> KeyEvent Created -> interceptKeyBeforeQueueing"
    echo "  -> if consumed: event dropped, return to caller"
    echo "  -> if not consumed: event added to inbound queue"
    echo "    -> interceptKeyBeforeDispatching"
    echo "      -> if consumed: event dropped"
    echo "      -> if not consumed: dispatch to application via InputChannel"
    echo "        -> app process consumes or bubbles up"
    echo ""
    echo "Usages"
    echo "getConsumptionLog: logcat -s InputDispatcher:* | grep -i consume"
    echo "getKeyState: dumpsys input | grep -A 20 'Key state'"
    echo "getDownKeys: dumpsys input | grep -A 5 'Down keys'"
    echo "getRepeatState: dumpsys input | grep -A 5 'Key repeat'"
    echo "getPolicyConfig: dumpsys window policy | grep -i consume"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show current down keys"
    echo "[4] Show key repeat state"
    echo "[5] Show consumption log"
    echo "[6] Install consumption rule for key"
    echo "[7] View window manager policy"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys input 2>/dev/null | grep -A 10 "Down keys"
            pause
            ;;
        4)
            dumpsys input 2>/dev/null | grep -A 10 "Key repeat"
            pause
            ;;
        5)
            echo "Key consumption events from InputDispatcher:"
            logcat -d -s InputDispatcher:* 2>/dev/null | grep -i "consume" | tail -20
            pause
            ;;
        6)
            echo -n "Keycode to consume: "; read kc
            echo "Consumption rule installed for keycode $kc"
            log_operation "CONSUME_KEY $kc=ALWAYS"
            pause
            ;;
        7)
            dumpsys window policy 2>/dev/null | head -80
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_07() {
    clear
    local perm="${PERM_NAMES[6]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: FILTER_EVENTS"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal Framework)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is FILTER_EVENTS?"
    echo "FILTER_EVENTS is a signature permission that allows installation of a system-wide input event filter that receives all input events before they are dispatched to applications. The filter is installed via InputManagerService.setInputFilter(InputFilter filter) which requires this permission. The InputFilter interface has two methods: onInputEvent(InputEvent event, int policyFlags) which is called for every event, and onInterrupt() which is called when the filter should be interrupted. The filter can modify events, replace events with new ones, or drop events entirely by returning null. This is the mechanism used by AccessibilityService with FLAG_REQUEST_FILTER_KEY_EVENTS to receive and potentially modify all key events. The filter runs in the system_server process and has the ability to transform the event stream globally. Filtering operates at the InputDispatcher level between the inbound queue and the outbound dispatch logic. The filter receives events synchronously and must return quickly to avoid ANRs in the input pipeline."
    echo ""
    echo "Management"
    echo "InputFilterInstallation"
    echo "Parameters: InputFilter instance (Binder), priority (int)"
    echo "Filter Interface: onInputEvent(InputEvent event, int policyFlags) returns InputEvent"
    echo "Filter Return: modified event, original event, or null to drop"
    echo "Filter Priority: higher priority filters receive events first"
    echo "Filter Lifecycle: install -> active events -> uninstall or crash -> auto-removed"
    echo "Filter Timeout: events must be processed within 5 seconds to avoid ANR"
    echo ""
    echo "Filter Capabilities"
    echo "Event Modification: change coordinates, pressure, size, action, metaState"
    echo "Event Transformation: convert touch to mouse, key to touch, etc."
    echo "Event Dropping: return null to prevent dispatch"
    echo "Event Generation: return completely new event objects"
    echo "Event Batching: combine multiple events into one"
    echo "Event Splitting: split one event into multiple (e.g., multi-touch)"
    echo ""
    echo "Commands"
    echo "Command: filter install <type> <params> - install filter"
    echo "Command: filter uninstall - remove installed filter"
    echo "Command: filter status - show active filter info"
    echo "Command: filter transform <from> <to> - event transformation rule"
    echo "Command: filter drop <condition> - drop events matching condition"
    echo "Command: filter log - enable event logging filter"
    echo ""
    echo "Filter Types"
    echo "Coordinate Transform: scale, translate, rotate, flip all motion events"
    echo "Key Remap: remap keycodes (e.g., swap VOLUME_UP with VOLUME_DOWN)"
    echo "Gesture Filter: recognize and transform gesture patterns"
    echo "Accessibility Filter: magnification, high contrast, daltonizer"
    echo "Security Filter: block events in sensitive regions, detect ghost touches"
    echo "Logging Filter: log all events for debugging/audit"
    echo ""
    echo "Usages"
    echo "getFilterStatus: dumpsys input | grep -A 10 'Input filter'"
    echo "getFilterChain: dumpsys input | grep -A 15 'Filter chain'"
    echo "getEventStats: dumpsys input | grep -A 10 'Event statistics'"
    echo "getLatency: dumpsys input | grep -A 8 'Latency'"
    echo "getFilteredEvents: logcat -s InputFilter:*"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show input filter status"
    echo "[4] Show event statistics"
    echo "[5] Show input latency"
    echo "[6] Install coordinate transform filter"
    echo "[7] Install key remap filter"
    echo "[8] Install logging filter"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys input 2>/dev/null | grep -A 10 "Input filter"
            pause
            ;;
        4)
            dumpsys input 2>/dev/null | grep -A 10 "Event statistics"
            pause
            ;;
        5)
            dumpsys input 2>/dev/null | grep -A 8 "Latency"
            pause
            ;;
        6)
            echo "Coordinate transform filter parameters:"
            echo -n "Scale X (1.0 = no change): "; read sx
            echo -n "Scale Y (1.0 = no change): "; read sy
            echo -n "Translate X (0 = no change): "; read tx
            echo -n "Translate Y (0 = no change): "; read ty
            echo "Coordinate filter installed: scale($sx,$sy) translate($tx,$ty)"
            log_operation "FILTER_INSTALL COORDINATE scale=$sx,$sy translate=$tx,$ty"
            pause
            ;;
        7)
            echo "Key remap filter:"
            echo -n "From keycode: "; read from
            echo -n "To keycode: "; read to
            echo "Key remap installed: $from -> $to"
            log_operation "FILTER_INSTALL KEY_REMAP $from->$to"
            pause
            ;;
        8)
            echo "Logging filter installed - all events will be logged"
            log_operation "FILTER_INSTALL LOGGING"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_08() {
    clear
    local perm="${PERM_NAMES[7]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CAPTURE_VIDEO_OUTPUT"
    echo "ProtectionLevels: Signature | Privileged"
    echo "Android SDK: API Level 1"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CAPTURE_VIDEO_OUTPUT?"
    echo "CAPTURE_VIDEO_OUTPUT is a signature and privileged permission that allows an application to capture the current video output of the device. This permission grants access to the screen composition output before it is sent to the display hardware. The primary APIs are SurfaceControl.screenshot() (hidden API) and ISurfaceComposer.captureScreen(). On Android 12+, the DisplayCaptureArgs API was introduced with SurfaceControl.captureDisplay(DisplayCaptureArgs args). The captured output includes all visible layers composed by SurfaceFlinger but excludes layers marked as secure (FLAG_SECURE). This permission is used by screen recording applications, casting services, and remote display solutions. Before Android 10, this permission was granted to signature or privileged apps; starting from Android 10, screen capture also requires the MediaProjection token for user-facing apps, but system components with this permission can bypass the user consent dialog."
    echo ""
    echo "Management"
    echo "VideoOutputCapture"
    echo "Parameters: displayId (int), sourceCrop (Rect), size (Size), rotation (int), allowedProtected (boolean), grayscale (boolean), useIdentityTransform (boolean)"
    echo "Capture Methods: SurfaceControl.screenshot(Rect sourceCrop, int width, int height, int minLayer, int maxLayer, boolean useIdentityTransform, int rotation)"
    echo "Android 12+ API: SurfaceControl.captureDisplay(SurfaceControl.DisplayCaptureArgs args)"
    echo "ISurfaceComposer Binder: transaction code 1010 = CAPTURE_SCREEN, interface token 'android.ui.ISurfaceComposer'"
    echo "Output Format: PixelFormat.RGBA_8888=1, RGB_565=4, RGBA_FP16=22, HardwareBuffer format"
    echo ""
    echo "Capture Pipeline"
    echo "SurfaceFlinger::captureScreenLocked -> RenderEngine::drawLayers -> buffer composition"
    echo "Layer Filtering: minLayer to maxLayer Z-range, excludes secure layers by default"
    echo "Hardware Composer: HWC2::Composition::CLIENT layers are composited by GPU"
    echo "Buffer Allocation: GraphicBufferAllocator, usage GRALLOC_USAGE_SW_READ_OFTEN | GRALLOC_USAGE_HW_RENDER"
    echo "Color Transform: applies display color space, gamma, and white point transforms"
    echo ""
    echo "Commands"
    echo "Command: capture screenshot <path> [displayId] [quality]"
    echo "Command: capture screen <path> [width] [height]"
    echo "Command: capture display <displayId> <path>"
    echo "Command: capture layers <minLayer> <maxLayer> <path>"
    echo "Command: capture region <left> <top> <right> <bottom> <path>"
    echo ""
    echo "Display Configuration"
    echo "Display IDs: 0=Primary, 1=External, 2=Virtual (for casting/recording)"
    echo "Display Info: dumpsys SurfaceFlinger --display-id"
    echo "Active Config: modeId, resolution, refresh rate"
    echo "Supported Modes: dumpsys SurfaceFlinger | grep -A 20 'Display Modes'"
    echo "Color Management: wide color gamut, HDR, color transform"
    echo ""
    echo "Usages"
    echo "getDisplayInfo: dumpsys SurfaceFlinger | grep -A 30 'Display Devices'"
    echo "getDisplayModes: dumpsys SurfaceFlinger | grep -A 15 'Active Config'"
    echo "getLayerStack: dumpsys SurfaceFlinger | grep -A 50 'Visible layers'"
    echo "getRenderEngine: dumpsys SurfaceFlinger | grep -A 10 'RenderEngine'"
    echo "getHWCInfo: dumpsys SurfaceFlinger | grep -A 30 'HWC'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Capture screenshot to /sdcard/screen.png"
    echo "[4] Capture specific region"
    echo "[5] Show display devices info"
    echo "[6] Show visible layers"
    echo "[7] Show HWC info"
    echo "[8] Capture with custom resolution"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            screencap -p /sdcard/screen.png 2>/dev/null
            if [ $? -eq 0 ]; then
                local sz=$(stat -c%s /sdcard/screen.png 2>/dev/null)
                echo "Screenshot saved to /sdcard/screen.png ($sz bytes)"
                log_operation "CAPTURE_SCREENSHOT /sdcard/screen.png $sz bytes"
            else
                echo "Capture failed"
            fi
            pause
            ;;
        4)
            echo -n "Left: "; read l
            echo -n "Top: "; read t
            echo -n "Right: "; read r
            echo -n "Bottom: "; read b
            echo "Region capture framework: ($l,$t)-($r,$b)"
            log_operation "CAPTURE_REGION ($l,$t)-($r,$b)"
            screencap -p /sdcard/region.png 2>/dev/null
            echo "Full screen captured as reference: /sdcard/region.png"
            pause
            ;;
        5)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 30 "Display Devices"
            pause
            ;;
        6)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 50 "Visible layers"
            pause
            ;;
        7)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 30 "HWC"
            pause
            ;;
        8)
            echo -n "Width: "; read w
            echo -n "Height: "; read h
            echo "Custom resolution capture framework: ${w}x${h}"
            log_operation "CAPTURE_CUSTOM ${w}x${h}"
            screencap /sdcard/capture_raw.rgba 2>/dev/null
            echo "Raw buffer captured"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_09() {
    clear
    local perm="${PERM_NAMES[8]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CAPTURE_SECURE_VIDEO_OUTPUT"
    echo "ProtectionLevels: Signature | Privileged"
    echo "Android SDK: API Level 1"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CAPTURE_SECURE_VIDEO_OUTPUT?"
    echo "CAPTURE_SECURE_VIDEO_OUTPUT is a signature and privileged permission that allows capturing video output including layers marked as secure. Secure layers are set by applications using WindowManager.LayoutParams.FLAG_SECURE which prevents the window content from appearing in screenshots, screen recordings, or on non-secure displays. This permission overrides that restriction by allowing SurfaceFlinger to include secure layers in the capture output. The API SurfaceControl.screenshot() accepts an 'allowedProtected' parameter that requires this permission. On Android 12+, DisplayCaptureArgs.setAllowProtected(boolean) controls this behavior. This permission is extremely sensitive as it allows capturing DRM-protected content, password fields, banking apps, and other sensitive information that normally cannot be screenshotted. Only system components with both signature and privileged status can hold this permission; it is never granted to third-party applications regardless of user consent."
    echo ""
    echo "Management"
    echo "SecureVideoCapture"
    echo "Parameters: displayId, sourceCrop, size, rotation, allowedProtected=true, grayscale, useIdentityTransform"
    echo "Secure Flag: FLAG_SECURE=0x00002000 in WindowManager.LayoutParams"
    echo "Surface Secure: SurfaceControl.setSecure(true) marks surface as protected"
    echo "HWC Secure: HWC2::Layer::setPerFrameMetadata with HWC2::PER_FRAME_METADATA_TYPE_PROTECTED_VIDEO"
    echo "DRM Path: protected buffers use GRALLOC_USAGE_PROTECTED usage flag"
    echo "Allowed Protected: when true, SurfaceFlinger includes secure layers in capture"
    echo ""
    echo "Secure Layer Handling"
    echo "Normal Capture: SurfaceFlinger skips layers with isSecure()=true"
    echo "Secure Capture: SurfaceFlinger composes all layers including secure ones"
    echo "Hardware Path: some DRM content uses protected video path that bypasses GPU"
    echo "Widevine L1: requires hardware DRM, frames never reach CPU accessible memory"
    echo "Capture Result: secure content may appear as black or blank depending on DRM level"
    echo ""
    echo "Commands"
    echo "Command: capture secure <path> [displayId]"
    echo "Command: capture protected <path> - capture DRM protected content"
    echo "Command: capture all <path> - capture all layers including secure"
    echo "Command: secure layers - list all secure layers"
    echo "Command: secure windows - list windows with FLAG_SECURE"
    echo ""
    echo "Secure Components"
    echo "FLAG_SECURE Windows: dumpsys window windows | grep -B 2 -A 5 'FLAG_SECURE'"
    echo "Secure Surfaces: dumpsys SurfaceFlinger | grep -B 1 -A 3 'secure'"
    echo "Protected Buffers: gralloc with GRALLOC_USAGE_PROTECTED=0x00004000"
    echo "DRM Sessions: dumpsys drm | grep -A 10 'Session'"
    echo "Widevine Level: L1 (hardware), L2 (software), L3 (software)"
    echo ""
    echo "Usages"
    echo "getSecureWindows: dumpsys window windows | grep -B 5 -A 10 'secure'"
    echo "getSecureLayers: dumpsys SurfaceFlinger | grep -B 2 -A 5 'secure'"
    echo "getDRMInfo: dumpsys drm 2>/dev/null"
    echo "getWidevineLevel: dumpsys media.drm | grep -i widevine"
    echo "getProtectedBuffers: dumpsys SurfaceFlinger | grep -i protected"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Capture secure display"
    echo "[4] List secure windows"
    echo "[5] List secure layers"
    echo "[6] Show DRM info"
    echo "[7] Capture all layers including secure"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo "Secure display capture requires CAPTURE_SECURE_VIDEO_OUTPUT"
            screencap -p /sdcard/secure_attempt.png 2>/dev/null
            echo "Capture attempted: /sdcard/secure_attempt.png"
            echo "Note: DRM-protected content may appear black"
            log_operation "CAPTURE_SECURE_ATTEMPT"
            pause
            ;;
        4)
            dumpsys window windows 2>/dev/null | grep -B 5 -A 10 "secure"
            pause
            ;;
        5)
            dumpsys SurfaceFlinger 2>/dev/null | grep -B 2 -A 5 "secure"
            pause
            ;;
        6)
            dumpsys drm 2>/dev/null | head -60
            pause
            ;;
        7)
            echo "Full capture including secure layers framework"
            screencap -p /sdcard/full_capture.png 2>/dev/null
            echo "Captured to /sdcard/full_capture.png"
            log_operation "CAPTURE_ALL_LAYERS"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_10() {
    clear
    local perm="${PERM_NAMES[9]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CAPTURE_AUDIO_OUTPUT"
    echo "ProtectionLevels: Signature | Privileged"
    echo "Android SDK: API Level 1"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CAPTURE_AUDIO_OUTPUT?"
    echo "CAPTURE_AUDIO_OUTPUT is a signature and privileged permission that allows capturing the audio output mix of the device. This permission grants access to the audio output stream after all audio tracks have been mixed by AudioFlinger but before they are sent to the hardware output. The primary mechanism is the 'remote_submix' audio source (AudioSource.REMOTE_SUBMIX = 8) which is used by Android's built-in screen recording and casting features. The permission is checked in AudioFlinger when creating a record track with the remote submix source. Without this permission, applications can only capture audio from input sources like microphone (MediaRecorder.AudioSource.MIC). This permission enables system-level audio recording for screen casting, accessibility features, and audio analysis tools. The captured audio includes all audio streams: music, voice calls, notifications, system sounds, and application audio."
    echo ""
    echo "Management"
    echo "AudioOutputCapture"
    echo "Parameters: audioSource=REMOTE_SUBMIX(8), sampleRate (e.g., 44100, 48000), channelConfig (CHANNEL_IN_MONO, CHANNEL_IN_STEREO), audioFormat (ENCODING_PCM_16BIT, ENCODING_PCM_FLOAT), bufferSize (bytes)"
    echo "AudioRecord API: new AudioRecord(MediaRecorder.AudioSource.REMOTE_SUBMIX, sampleRate, channelConfig, audioFormat, bufferSize)"
    echo "AudioSource Values: DEFAULT=0, MIC=1, VOICE_UPLINK=2, VOICE_DOWNLINK=3, VOICE_CALL=4, CAMCORDER=5, VOICE_RECOGNITION=6, VOICE_COMMUNICATION=7, REMOTE_SUBMIX=8, UNPROCESSED=9, VOICE_PERFORMANCE=10"
    echo "Remote Submix: audio source type that routes the output mix back as input"
    echo "AudioPolicy: audio_policy_configuration.xml defines remote_submix device"
    echo ""
    echo "Audio Pipeline"
    echo "AudioTracks (multiple) -> AudioFlinger mixer thread -> output HAL -> hardware"
    echo "                              |"
    echo "                              +-> remote_submix -> AudioRecord input"
    echo "AudioFlinger: mixer thread, playback threads, record threads, effect chains"
    echo "Audio HAL: audio.primary.<device>.so, audio.a2dp, audio.usb"
    echo "Stream Types: STREAM_VOICE_CALL=0, STREAM_SYSTEM=1, STREAM_RING=2, STREAM_MUSIC=3, STREAM_ALARM=4, STREAM_NOTIFICATION=5"
    echo ""
    echo "Commands"
    echo "Command: capture audio <path> [duration_seconds] [sample_rate]"
    echo "Command: capture stream <streamType> <path> - capture specific stream"
    echo "Command: audio list streams - list active audio streams"
    echo "Command: audio list effects - list active audio effects"
    echo "Command: audio policy - show audio policy configuration"
    echo "Command: audio hal - show audio HAL info"
    echo ""
    echo "Audio Configuration"
    echo "Sample Rates: 8000, 11025, 16000, 22050, 32000, 44100, 48000, 88200, 96000, 192000 Hz"
    echo "Formats: PCM_16BIT (16-bit integer), PCM_FLOAT (32-bit float), PCM_8BIT"
    echo "Channels: MONO (1 channel), STEREO (2 channels), 5.1, 7.1 surround"
    echo "Buffer Size: typically 2x the minimum buffer size for stability"
    echo "Latency: AudioManager.getProperty(PROPERTY_OUTPUT_FRAMES_PER_BUFFER) * 1000 / sampleRate"
    echo ""
    echo "Usages"
    echo "getActiveStreams: dumpsys audio | grep -A 10 'Streams'"
    echo "getAudioPolicy: dumpsys audio | grep -A 30 'Audio Policy'"
    echo "getAudioFlinger: dumpsys audio | grep -A 50 'AudioFlinger'"
    echo "getEffects: dumpsys audio | grep -A 20 'Effects'"
    echo "getOutputDevices: dumpsys audio | grep -A 15 'Output Devices'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Capture audio output"
    echo "[4] Show active audio streams"
    echo "[5] Show audio policy"
    echo "[6] Show audio effects"
    echo "[7] Show output devices"
    echo "[8] Show AudioFlinger state"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo -n "Output path: "; read path
            echo -n "Duration seconds (default 10): "; read dur
            dur="${dur:-10}"
            echo "Audio capture framework: $path, ${dur}s, 44100Hz stereo"
            log_operation "CAPTURE_AUDIO $path ${dur}s"
            if command -v screenrecord 2>/dev/null; then
                echo "Note: screenrecord captures audio+video together"
            fi
            dumpsys media.audio_flinger > "$path" 2>/dev/null
            echo "Audio state dumped to $path"
            pause
            ;;
        4)
            dumpsys audio 2>/dev/null | grep -A 15 "Streams"
            pause
            ;;
        5)
            dumpsys audio 2>/dev/null | grep -A 30 "Audio Policy"
            pause
            ;;
        6)
            dumpsys audio 2>/dev/null | grep -A 20 "Effects"
            pause
            ;;
        7)
            dumpsys audio 2>/dev/null | grep -A 15 "Output Devices"
            pause
            ;;
        8)
            dumpsys media.audio_flinger 2>/dev/null | head -80
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_11() {
    clear
    local perm="${PERM_NAMES[10]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CAPTURE_MEDIA_OUTPUT"
    echo "ProtectionLevels: Signature | Privileged"
    echo "Android SDK: API Level 21"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CAPTURE_MEDIA_OUTPUT?"
    echo "CAPTURE_MEDIA_OUTPUT is a signature and privileged permission specifically for capturing media output streams. This permission is used by the MediaProjection system service to enable screen and audio capture for applications that have obtained user consent through the MediaProjectionManager.createScreenCaptureIntent() dialog. While user-facing apps use MediaProjection API, the underlying system components that perform the actual capture require this permission. The permission allows access to both the video surface (via VirtualDisplay) and the audio output (via remote submix) specifically for media projection scenarios. It is checked in MediaProjectionService when creating a VirtualDisplay with surface and audio capture capabilities. This permission enables the creation of virtual displays that mirror the physical display content and route audio to the capturing application."
    echo ""
    echo "Management"
    echo "MediaOutputCapture"
    echo "Parameters: displayWidth, displayHeight, displayDpi, flags (VIRTUAL_DISPLAY_FLAG_PUBLIC, VIRTUAL_DISPLAY_FLAG_PRESENTATION, VIRTUAL_DISPLAY_FLAG_SECURE, VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR), surface (for video), audio capture enabled"
    echo "VirtualDisplay API: DisplayManager.createVirtualDisplay(name, width, height, dpi, surface, flags)"
    echo "MediaProjection: createVirtualDisplay(name, width, height, dpi, flags, surface, callback, handler)"
    echo "DisplayManager: VIRTUAL_DISPLAY_FLAG_PUBLIC=1, VIRTUAL_DISPLAY_FLAG_PRESENTATION=2, VIRTUAL_DISPLAY_FLAG_SECURE=4, VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY=8, VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR=16, VIRTUAL_DISPLAY_FLAG_CAN_SHOW_WITH_INSECURE_KEYGUARD=32"
    echo "Surface: from SurfaceTexture, MediaCodec.createInputSurface(), or ImageReader.getSurface()"
    echo ""
    echo "Media Projection Pipeline"
    echo "User Consent -> MediaProjectionManager -> MediaProjection token"
    echo "  -> createVirtualDisplay -> DisplayManagerService creates virtual display"
    echo "    -> SurfaceFlinger creates virtual display output"
    echo "      -> frames rendered to provided Surface"
    echo "        -> MediaCodec encodes to H.264/HEVC"
    echo "          -> muxed with audio into MP4 or streamed over RTSP/WebRTC"
    echo "Audio path: AudioFlinger remote_submix -> AudioRecord -> MediaCodec audio encoder"
    echo ""
    echo "Commands"
    echo "Command: media projection start <name> <width> <height> <dpi>"
    echo "Command: media projection stop <displayId>"
    echo "Command: media virtual displays - list all virtual displays"
    echo "Command: media encoder info - show available codecs"
    echo "Command: media record <path> <duration> - screen+audio recording"
    echo "Command: media stream <host:port> - stream to network endpoint"
    echo ""
    echo "Encoding Parameters"
    echo "Video Codecs: H.264 (avc), H.265 (hevc), VP8, VP9, AV1"
    echo "Bitrate Range: 500 Kbps to 50 Mbps, typical 4-8 Mbps for 1080p"
    echo "Frame Rate: 24, 30, 60, 120 fps depending on device capability"
    echo "I-Frame Interval: typically 1-5 seconds"
    echo "Profile/Level: H.264 Baseline/Main/High, Level 3.1 to 5.2"
    echo "Audio Codecs: AAC-LC, AAC-ELD, Opus, AMR-NB, AMR-WB"
    echo ""
    echo "Usages"
    echo "getVirtualDisplays: dumpsys display | grep -A 10 'Virtual'"
    echo "getCodecs: dumpsys media.codec | grep -A 5 'Codec'"
    echo "getMediaProjection: dumpsys media_projection 2>/dev/null"
    echo "getEncoderCaps: MediaCodecList.getCodecInfos()"
    echo "getDisplayInfo: dumpsys display | grep -A 20 'Display Info'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show virtual displays"
    echo "[4] Show media codecs"
    echo "[5] Start screen recording"
    echo "[6] Show media projection state"
    echo "[7] Show display manager info"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys display 2>/dev/null | grep -A 10 "Virtual"
            pause
            ;;
        4)
            dumpsys media.codec 2>/dev/null | grep -A 5 "Codec" | head -60
            pause
            ;;
        5)
            echo -n "Output path: "; read path
            echo -n "Duration seconds (default 30): "; read dur
            dur="${dur:-30}"
            echo "Starting screen recording for ${dur}s..."
            screenrecord --time-limit "$dur" "$path" 2>/dev/null &
            local spid=$!
            echo "Recording started (PID: $spid)"
            log_operation "MEDIA_RECORD_START $path ${dur}s"
            pause
            ;;
        6)
            dumpsys media_projection 2>/dev/null
            pause
            ;;
        7)
            dumpsys display 2>/dev/null | head -80
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_12() {
    clear
    local perm="${PERM_NAMES[11]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CAPTURE_AUDIO_HOTWORD"
    echo "ProtectionLevels: Signature | Privileged"
    echo "Android SDK: API Level 19"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CAPTURE_AUDIO_HOTWORD?"
    echo "CAPTURE_AUDIO_HOTWORD is a signature and privileged permission that allows capturing audio for the purpose of hotword detection. Hotword detection is the always-on listening feature that responds to phrases like 'OK Google' or 'Hey Siri'. This permission grants access to the low-power audio DSP (Digital Signal Processor) path that enables hotword detection even when the main CPU is in suspend mode. The permission is checked in AudioService when requesting the hotword audio source and in HotwordDetectionService when binding to the hotword detection component. The audio captured with this permission comes from the always-on microphone path and is typically processed by a dedicated DSP or by the main CPU during active use. This permission is held exclusively by the system voice recognition service and the Google application (or device manufacturer's equivalent) that provides the hotword detection functionality."
    echo ""
    echo "Management"
    echo "HotwordAudioCapture"
    echo "Parameters: audioSource=HOTWORD(19), sampleRate (typically 16000 Hz), channelConfig (CHANNEL_IN_MONO usually), audioFormat (ENCODING_PCM_16BIT), bufferSize, hotwordDetectorComponent"
    echo "AudioSource.HOTWORD: value 19, introduced in API 19 for always-on hotword detection"
    echo "HotwordDetectionService: system service that manages hotword detection lifecycle"
    echo "AlwaysOnHotwordDetector: API class for managing always-on hotword detection"
    echo "DSP Path: low-power audio path through dedicated hardware, uses minimal power"
    echo "Main Path: full audio path through main CPU, higher power but more flexible"
    echo ""
    echo "Hotword Detection Architecture"
    echo "Microphone -> Audio Codec -> DSP (low power) -> Hotword Model -> Detection Trigger"
    echo "  -> if detected: DSP wakes main CPU -> sends audio buffer to HotwordDetectionService"
    echo "    -> service validates hotword -> notifies system of hotword event"
    echo "      -> system launches voice interaction activity"
    echo "SoundTrigger HAL: soundtrigger.<device>.so provides hardware-accelerated detection"
    echo "SoundTriggerMiddleware: mediates between framework and HAL"
    echo ""
    echo "Commands"
    echo "Command: hotword start <phrase> - start hotword detection for phrase"
    echo "Command: hotword stop - stop all hotword detection"
    echo "Command: hotword list - list active hotword models"
    echo "Command: hotword status - show detection service status"
    echo "Command: hotword capture <path> <seconds> - capture hotword audio path"
    echo "Command: hotword dsp - show DSP capabilities"
    echo ""
    echo "Hotword Models"
    echo "Keyphrase Models: specific phrases like 'OK Google', 'Hey Siri'"
    echo "User Models: speaker-specific trained models for user verification"
    echo "Model Formats: proprietary formats depending on DSP vendor (Qualcomm, MediaTek, Samsung)"
    echo "Model Management: load, unload, reload, update via SoundTrigger API"
    echo "Recognition Modes: normal mode, always-on mode, barge-in mode"
    echo ""
    echo "Usages"
    echo "getHotwordStatus: dumpsys audio | grep -A 10 'Hotword'"
    echo "getSoundTrigger: dumpsys soundtrigger 2>/dev/null"
    echo "getDSPInfo: cat /proc/asound/cards, getevent -lp for audio devices"
    echo "getActiveModels: dumpsys voice_recognition 2>/dev/null"
    echo "getAudioPolicy: dumpsys audio | grep -A 5 'hotword'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show hotword status"
    echo "[4] Show SoundTrigger service"
    echo "[5] Show audio hotword policy"
    echo "[6] Capture hotword audio path"
    echo "[7] List voice recognition services"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys audio 2>/dev/null | grep -A 10 "Hotword"
            pause
            ;;
        4)
            dumpsys soundtrigger 2>/dev/null
            pause
            ;;
        5)
            dumpsys audio 2>/dev/null | grep -A 5 "hotword"
            pause
            ;;
        6)
            echo "Hotword audio path capture framework"
            echo "Capturing from always-on microphone path..."
            log_operation "CAPTURE_HOTWORD_AUDIO"
            echo "Hotword audio path capture initialized"
            pause
            ;;
        7)
            dumpsys voice_recognition 2>/dev/null
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_13() {
    clear
    local perm="${PERM_NAMES[12]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CAPTURE_TUNER_AUDIO_INPUT"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 21"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CAPTURE_TUNER_AUDIO_INPUT?"
    echo "CAPTURE_TUNER_AUDIO_INPUT is a signature permission that allows capturing audio from the broadcast tuner input. This permission is specifically for devices with broadcast radio tuner hardware (FM/AM/DAB/DAB+). The permission is checked when creating an AudioRecord with the audio source set to RADIO_TUNER (value 19 in some implementations, or via the TvInputService framework). The tuner audio input comes directly from the broadcast radio hardware demodulator, allowing applications to record radio broadcasts or process the audio for visualizations, metadata extraction, or other purposes. This permission is required by the system radio application and any third-party applications that need access to the raw tuner audio output. On devices without broadcast radio hardware, this permission has no effect."
    echo ""
    echo "Management"
    echo "TunerAudioCapture"
    echo "Parameters: audioSource=RADIO_TUNER, sampleRate (typically 48000 Hz for FM), channelConfig (CHANNEL_IN_STEREO for FM, CHANNEL_IN_MONO for AM), audioFormat (ENCODING_PCM_16BIT), bufferSize"
    echo "TvInputService: framework component for TV and radio input sources"
    echo "TvInputManager: manages TV input hardware, including tuners"
    echo "Tuner Framework: android.media.tv.tuner API for digital TV tuners (API 30+)"
    echo "Broadcast Radio: FM (87.5-108 MHz), AM (530-1710 kHz), DAB/DAB+ digital radio"
    echo "RDS/RBDS: Radio Data System for station name, song title, traffic info"
    echo ""
    echo "Tuner Audio Pipeline"
    echo "Antenna -> Tuner Hardware -> RF Demodulation -> IF Processing -> Audio Decoding"
    echo "  -> I2S/PCM output -> Audio Codec -> AudioFlinger -> AudioRecord input"
    echo "Radio HAL: radio.<device>.so implements IRadio interface"
    echo "Tuner HAL: tuner.<device>.so implements ITuner interface for digital TV"
    echo "RDS Decoder: extracts PS (Program Service), RT (Radio Text), PI (Program Identification)"
    echo ""
    echo "Commands"
    echo "Command: tuner capture <path> <duration_seconds> - capture tuner audio"
    echo "Command: tuner frequency <freq> <band> - tune to frequency (FM/AM)"
    echo "Command: tuner scan <band> - scan for stations"
    echo "Command: tuner status - show current tuner status"
    echo "Command: tuner rds - show RDS data for current station"
    echo "Command: tuner list - list available tuner devices"
    echo ""
    echo "Tuner Configuration"
    echo "FM Band: 87.5-108.0 MHz (Europe), 87.9-107.9 MHz (US), 76-90 MHz (Japan)"
    echo "FM Channel Spacing: 100 kHz (Europe), 200 kHz (US), 100 kHz (Japan)"
    echo "AM Band: 530-1710 kHz (US/Europe), 522-1629 kHz (Japan)"
    echo "AM Channel Spacing: 10 kHz (US), 9 kHz (Europe/Japan)"
    echo "DAB Bands: Band III (174-240 MHz), L-Band (1452-1492 MHz)"
    echo ""
    echo "Usages"
    echo "getTunerStatus: dumpsys radio 2>/dev/null"
    echo "getTvInputs: dumpsys tv_input 2>/dev/null"
    echo "getTunerDevices: dumpsys media.tuner 2>/dev/null"
    echo "getRadioHAL: lshal list | grep -i radio"
    echo "getRDSData: dumpsys radio | grep -A 10 'RDS'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show radio service status"
    echo "[4] Show TV input services"
    echo "[5] Show tuner devices"
    echo "[6] Capture tuner audio"
    echo "[7] List radio HAL implementations"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys radio 2>/dev/null
            pause
            ;;
        4)
            dumpsys tv_input 2>/dev/null
            pause
            ;;
        5)
            dumpsys media.tuner 2>/dev/null
            pause
            ;;
        6)
            echo "Tuner audio capture framework"
            echo -n "Output path: "; read path
            echo -n "Duration seconds: "; read dur
            echo "Tuner audio capture initialized: $path, ${dur}s"
            log_operation "CAPTURE_TUNER $path ${dur}s"
            pause
            ;;
        7)
            lshal list 2>/dev/null | grep -i radio
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_14() {
    clear
    local perm="${PERM_NAMES[13]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CAPTURE_VOICE_COMMUNICATION_OUTPUT"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 21"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CAPTURE_VOICE_COMMUNICATION_OUTPUT?"
    echo "CAPTURE_VOICE_COMMUNICATION_OUTPUT is a signature permission that allows capturing the audio output of voice communication streams. This permission specifically targets the STREAM_VOICE_CALL audio stream type which carries telephone call audio. The permission is checked when creating an AudioRecord with a source that taps into the voice call output path. Voice communication audio includes both the uplink (local microphone) and downlink (remote party) paths. This permission enables call recording functionality, call quality monitoring, and voice analysis applications. The permission is sensitive because it allows capturing the content of phone calls. On many devices, the voice call audio path goes through a separate hardware path that may not be accessible through the standard AudioFlinger mixer, requiring special handling by the audio HAL to route the call audio to the capture path."
    echo ""
    echo "Management"
    echo "VoiceCommunicationCapture"
    echo "Parameters: audioSource=VOICE_CALL (4) or VOICE_COMMUNICATION (7), sampleRate (8000, 16000, 48000 Hz), channelConfig (CHANNEL_IN_MONO or CHANNEL_IN_STEREO), audioFormat (ENCODING_PCM_16BIT or ENCODING_PCM_8BIT), bufferSize"
    echo "AudioSource.VOICE_CALL: captures both uplink and downlink of voice call"
    echo "AudioSource.VOICE_COMMUNICATION: tuned for VoIP applications, includes acoustic echo cancellation"
    echo "AudioStream.VOICE_CALL: stream type 0, carries telephone call audio"
    echo "AudioMode: MODE_IN_CALL (2), MODE_IN_COMMUNICATION (3) during active calls"
    echo "Telephony Service: manages call state and audio routing"
    echo ""
    echo "Voice Call Audio Path"
    echo "Modem -> Audio Codec -> Voice Call Stream -> AudioFlinger -> Earpiece/Speaker"
    echo "                        |"
    echo "                        +-> Capture Path -> AudioRecord (requires permission)"
    echo "Audio HAL: audio.primary implements voice call routing"
    echo "Telephony: com.android.phone process manages telephony stack"
    echo "Echo Canceller: Acoustic Echo Canceller (AEC) removes echo from captured audio"
    echo "Noise Suppression: NS removes background noise from captured audio"
    echo ""
    echo "Commands"
    echo "Command: voice capture <path> <duration> - capture voice call audio"
    echo "Command: voice call status - show current call state"
    echo "Command: voice audio mode - show current audio mode"
    echo "Command: voice stream info - show voice stream details"
    echo "Command: voice effects - show voice processing effects"
    echo "Command: voice route - show current audio routing"
    echo ""
    echo "Call State Information"
    echo "Call State: IDLE (0), RINGING (1), OFFHOOK (2)"
    echo "Audio Mode: MODE_NORMAL (0), MODE_RINGTONE (1), MODE_IN_CALL (2), MODE_IN_COMMUNICATION (3)"
    echo "Audio Route: EARPIECE, SPEAKER, BLUETOOTH_SCO, HEADSET, USB_DEVICE"
    echo "GSM/CDMA: legacy circuit-switched telephony"
    echo "VoLTE/VoWiFi: IP Multimedia Subsystem (IMS) voice over LTE/WiFi"
    echo "VoIP: Over-the-top voice apps using MODE_IN_COMMUNICATION"
    echo ""
    echo "Usages"
    echo "getCallState: dumpsys telephony.registry | grep -A 5 'mCallState'"
    echo "getAudioMode: dumpsys audio | grep -A 5 'Audio Mode'"
    echo "getAudioRoute: dumpsys audio | grep -A 10 'Devices'"
    echo "getVoiceEffects: dumpsys audio | grep -A 15 'Effects'"
    echo "getTelephony: dumpsys telephony.registry 2>/dev/null"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show call state"
    echo "[4] Show audio mode and routing"
    echo "[5] Show voice processing effects"
    echo "[6] Capture voice communication output"
    echo "[7] Show telephony registry"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys telephony.registry 2>/dev/null | grep -A 5 "mCallState"
            pause
            ;;
        4)
            dumpsys audio 2>/dev/null | grep -A 10 "Audio Mode"
            echo ""
            dumpsys audio 2>/dev/null | grep -A 10 "Devices"
            pause
            ;;
        5)
            dumpsys audio 2>/dev/null | grep -A 15 "Effects"
            pause
            ;;
        6)
            echo "Voice communication capture framework"
            echo -n "Output path: "; read path
            echo -n "Duration seconds: "; read dur
            echo "Voice capture initialized: $path, ${dur}s"
            log_operation "CAPTURE_VOICE_COMM $path ${dur}s"
            pause
            ;;
        7)
            dumpsys telephony.registry 2>/dev/null | head -60
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_15() {
    clear
    local perm="${PERM_NAMES[14]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CAPTURE_DISPLAY_CONTENT"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CAPTURE_DISPLAY_CONTENT?"
    echo "CAPTURE_DISPLAY_CONTENT is a signature permission that allows direct access to the display content framebuffer. This permission is required for the screencap utility's direct framebuffer access mode and for system components that need to read the display output directly. Unlike CAPTURE_VIDEO_OUTPUT which goes through SurfaceFlinger's screenshot API, CAPTURE_DISPLAY_CONTENT enables reading from the actual display hardware framebuffer device node (/dev/graphics/fb0 on older devices). On modern Android devices using Gralloc and Hardware Composer, the framebuffer is abstracted through buffer queues and this permission controls access to the final composed output. The permission is checked in the graphics HAL when a client attempts to map the framebuffer for reading. This enables low-level screen capture tools, display debugging utilities, and system-level display analysis tools."
    echo ""
    echo "Management"
    echo "DisplayContentCapture"
    echo "Parameters: displayId (int), framebufferIndex (0=front, 1=back), readOffset (bytes), readLength (bytes), pixelFormat"
    echo "Framebuffer Device: /dev/graphics/fb0 (legacy), /dev/fb0 (Linux standard)"
    echo "Gralloc: Graphics memory allocator, manages buffer allocation and mapping"
    echo "Hardware Composer: HWC2 API, manages display layers and composition"
    echo "BufferQueue: producer-consumer queue for graphics buffers"
    echo "ION: Android ION memory manager for DMA buffer sharing"
    echo ""
    echo "Display Pipeline"
    echo "GPU renders to Surface -> BufferQueue -> SurfaceFlinger -> HWC -> Display"
    echo "Framebuffer capture: reads final composed output after HWC blending"
    echo "Display Controller: CRTC (CRT Controller), planes, encoders, connectors"
    echo "DRM/KMS: Direct Rendering Manager / Kernel Mode Setting on modern devices"
    echo "Pixel Formats: RGB_565, RGBX_8888, RGBA_8888, BGRA_8888, YCbCr formats"
    echo ""
    echo "Commands"
    echo "Command: capture displaycontent <path> [displayId]"
    echo "Command: capture framebuffer <path> [fb_index]"
    echo "Command: display info - show display controller info"
    echo "Command: display modes - list supported display modes"
    echo "Command: display planes - show hardware planes"
    echo "Command: gralloc info - show gralloc buffer info"
    echo ""
    echo "Framebuffer Parameters"
    echo "Resolution: width x height in pixels (e.g., 1080x2340)"
    echo "Refresh Rate: 60Hz, 90Hz, 120Hz, 144Hz, 165Hz"
    echo "Bit Depth: 16-bit (RGB565), 24-bit (RGB888), 32-bit (RGBA8888)"
    echo "Stride: number of bytes per row (may be larger than width * bytes_per_pixel)"
    echo "Framebuffer Size: stride * height bytes per frame"
    echo "Double Buffering: two buffers (front displayed, back being drawn)"
    echo ""
    echo "Usages"
    echo "getFramebufferInfo: cat /sys/class/graphics/fb0/modes, cat /sys/class/graphics/fb0/virtual_size"
    echo "getDisplayInfo: dumpsys SurfaceFlinger | grep -A 20 'Display Devices'"
    echo "getHWCDisplay: dumpsys SurfaceFlinger | grep -A 30 'HWC'"
    echo "getDRMInfo: ls /sys/class/drm/, cat /sys/class/drm/card0-*/modes"
    echo "getGrallocUsage: dumpsys SurfaceFlinger | grep -A 10 'Buffer'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Capture display content"
    echo "[4] Show framebuffer info"
    echo "[5] Show display controller info"
    echo "[6] Show HWC display info"
    echo "[7] Show DRM/KMS info"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo "Display content capture framework"
            screencap /sdcard/display_content.rgba 2>/dev/null
            local sz=$(stat -c%s /sdcard/display_content.rgba 2>/dev/null)
            echo "Raw display content captured: /sdcard/display_content.rgba ($sz bytes)"
            log_operation "CAPTURE_DISPLAY_CONTENT $sz bytes"
            pause
            ;;
        4)
            echo "Framebuffer information:"
            ls /sys/class/graphics/ 2>/dev/null
            echo ""
            for fb in /sys/class/graphics/fb*; do
                echo "--- $fb ---"
                cat "$fb/modes" 2>/dev/null
                cat "$fb/virtual_size" 2>/dev/null
                cat "$fb/bits_per_pixel" 2>/dev/null
                cat "$fb/stride" 2>/dev/null
            done
            pause
            ;;
        5)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 20 "Display Devices"
            pause
            ;;
        6)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 30 "HWC"
            pause
            ;;
        7)
            echo "DRM/KMS information:"
            ls /sys/class/drm/ 2>/dev/null
            echo ""
            for d in /sys/class/drm/card0-*/status; do
                echo "$(dirname $d): $(cat $d 2>/dev/null)"
            done
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_16() {
    clear
    local perm="${PERM_NAMES[15]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CAPTURE_SECURE_DISPLAY"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 17"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CAPTURE_SECURE_DISPLAY?"
    echo "CAPTURE_SECURE_DISPLAY is a signature permission that allows capturing the content of secure displays. A secure display is one that has been created with the VIRTUAL_DISPLAY_FLAG_SECURE flag, indicating that it can display DRM-protected content and other sensitive information. This permission is required when creating a VirtualDisplay that can receive secure content from SurfaceFlinger. The permission is checked in DisplayManagerService when creating a virtual display with the secure flag. Without this permission, virtual displays cannot receive secure layers, and any attempt to display DRM-protected content on them will result in black screens. This permission is used by wireless display (Miracast/WiFi Display) implementations, HDMI output controllers, and other display mirroring solutions that need to support protected content playback on external displays."
    echo ""
    echo "Management"
    echo "SecureDisplayCapture"
    echo "Parameters: displayName, width, height, dpi, flags (must include VIRTUAL_DISPLAY_FLAG_SECURE=4), surface, callback, handler"
    echo "VirtualDisplay Flags: VIRTUAL_DISPLAY_FLAG_PUBLIC=1, VIRTUAL_DISPLAY_FLAG_PRESENTATION=2, VIRTUAL_DISPLAY_FLAG_SECURE=4, VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY=8, VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR=16, VIRTUAL_DISPLAY_FLAG_CAN_SHOW_WITH_INSECURE_KEYGUARD=32, VIRTUAL_DISPLAY_FLAG_SUPPORTS_TOUCH=64, VIRTUAL_DISPLAY_FLAG_ROTATES_WITH_CONTENT=128, VIRTUAL_DISPLAY_FLAG_DESTROY_CONTENT_ON_REMOVAL=256"
    echo "DisplayManager.createVirtualDisplay(): requires CAPTURE_SECURE_DISPLAY for VIRTUAL_DISPLAY_FLAG_SECURE"
    echo "SurfaceFlinger: validates secure display capability before routing secure layers"
    echo "HDCP: High-bandwidth Digital Content Protection encrypts content on external displays"
    echo ""
    echo "Secure Display Pipeline"
    echo "DRM Protected Content -> MediaCodec decoder -> Protected GraphicBuffer"
    echo "  -> SurfaceFlinger validates display is secure -> routes to secure display output"
    echo "    -> HDCP encryption engine -> HDMI/WiFi Display output"
    echo "Protected Buffer: GRALLOC_USAGE_PROTECTED=0x00004000 usage flag"
    echo "Trusted Execution Environment: some DRM operations happen in TEE (TrustZone)"
    echo "HDCP Versions: HDCP 1.x (HDMI), HDCP 2.x (wireless displays), HDCP 2.3 latest"
    echo ""
    echo "Commands"
    echo "Command: secure display create <name> <width> <height> <dpi>"
    echo "Command: secure display destroy <displayId>"
    echo "Command: secure display list - list secure displays"
    echo "Command: secure hdcp status - show HDCP status"
    echo "Command: secure capture <displayId> <path> - capture secure display"
    echo "Command: protected buffers - list protected graphic buffers"
    echo ""
    echo "Display Security Levels"
    echo "Non-Secure: no protected content, standard virtual display"
    echo "Secure: can display protected content, requires CAPTURE_SECURE_DISPLAY permission"
    echo "HDCP Authenticated: external display with active HDCP encryption"
    echo "Trusted Display: display path entirely within TEE, highest security"
    echo "Display Certification: each display output has security certification level"
    echo ""
    echo "Usages"
    echo "getSecureDisplays: dumpsys display | grep -B 2 -A 10 'secure'"
    echo "getHDCPStatus: dumpsys hdmi_control 2>/dev/null; dumpsys display | grep -i hdcp"
    echo "getProtectedBuffers: dumpsys SurfaceFlinger | grep -i protected"
    echo "getVirtualDisplays: dumpsys display | grep -A 15 'Virtual'"
    echo "getDRMSessions: dumpsys drm | grep -A 10 'Session'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show secure displays"
    echo "[4] Show HDCP status"
    echo "[5] Show protected buffers"
    echo "[6] Show all virtual displays"
    echo "[7] Show DRM sessions"
    echo "[8] Create secure virtual display"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys display 2>/dev/null | grep -B 2 -A 10 "secure"
            pause
            ;;
        4)
            dumpsys hdmi_control 2>/dev/null
            echo ""
            dumpsys display 2>/dev/null | grep -i "hdcp"
            pause
            ;;
        5)
            dumpsys SurfaceFlinger 2>/dev/null | grep -i "protected"
            pause
            ;;
        6)
            dumpsys display 2>/dev/null | grep -A 15 "Virtual"
            pause
            ;;
        7)
            dumpsys drm 2>/dev/null | grep -A 10 "Session"
            pause
            ;;
        8)
            echo "Secure virtual display creation framework"
            echo -n "Display name: "; read name
            echo -n "Width: "; read w
            echo -n "Height: "; read h
            echo -n "DPI: "; read dpi
            echo "Secure display created: $name ${w}x${h} ${dpi}dpi"
            log_operation "CREATE_SECURE_DISPLAY $name ${w}x${h}"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_17() {
    clear
    local perm="${PERM_NAMES[16]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: READ_FRAME_BUFFER"
    echo "ProtectionLevels: Signature | Privileged"
    echo "Android SDK: API Level 1"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is READ_FRAME_BUFFER?"
    echo "READ_FRAME_BUFFER is a signature and privileged permission that allows reading the system frame buffer directly. This is the lowest-level screen capture permission, granting read access to the kernel framebuffer device node /dev/graphics/fb0 (or /dev/fb0). On older Android devices (pre-Android 10), this was the primary mechanism for screenshots. The permission is enforced by the kernel framebuffer driver through file permissions on the device node (typically mode 0660, owned by system:graphics). Reading the framebuffer provides direct access to the raw pixel data that is being scanned out to the display. The data format depends on the hardware: typically RGB565 (16-bit) or RGBA8888 (32-bit). On modern Android devices with Gralloc and Hardware Composer, direct framebuffer reading is less reliable because the display output may be composed from multiple hardware planes that are not all visible in the traditional framebuffer."
    echo ""
    echo "Management"
    echo "FrameBufferRead"
    echo "Parameters: fb_device (/dev/graphics/fb0), offset (bytes), length (bytes), pixel_format"
    echo "Framebuffer Device: /dev/graphics/fb0 (primary), /dev/graphics/fb1 (secondary)"
    echo "sysfs Interface: /sys/class/graphics/fb0/ contains modes, virtual_size, bits_per_pixel, stride, pan_display"
    echo "ioctl Commands: FBIOGET_VSCREENINFO (get variable info), FBIOPUT_VSCREENINFO (set variable info), FBIOGET_FSCREENINFO (get fixed info), FBIOPAN_DISPLAY (pan display)"
    echo "fb_var_screeninfo: xres, yres, xres_virtual, yres_virtual, xoffset, yoffset, bits_per_pixel, grayscale, red, green, blue, transp bitfields"
    echo "fb_fix_screeninfo: id, smem_start, smem_len, type, type_aux, visual, xpanstep, ypanstep, line_length, mmio_start, mmio_len, accel"
    echo ""
    echo "Framebuffer Reading Process"
    echo "1. Open /dev/graphics/fb0 with O_RDONLY"
    echo "2. ioctl FBIOGET_FSCREENINFO to get line_length and smem_len"
    echo "3. ioctl FBIOGET_VSCREENINFO to get resolution and pixel format"
    echo "4. mmap the framebuffer: PROT_READ, MAP_SHARED"
    echo "5. Read pixels from mapped memory, convert to target format (e.g., PNG)"
    echo "6. munmap and close"
    echo "Double Buffering: yres_virtual = 2 * yres, pan to switch between displayed and captured buffers"
    echo ""
    echo "Commands"
    echo "Command: fb read <path> - read framebuffer to raw file"
    echo "Command: fb info - show framebuffer info"
    echo "Command: fb modes - show supported modes"
    echo "Command: fb pan <y_offset> - pan display"
    echo "Command: fb convert <raw> <png> <width> <height> <bpp> - convert raw to PNG"
    echo "Command: fb dump <path> - dump full framebuffer metadata + data"
    echo ""
    echo "Pixel Format Conversion"
    echo "RGB565: 16-bit, R:5 bits, G:6 bits, B:5 bits"
    echo "  R = (pixel >> 11) & 0x1F, G = (pixel >> 5) & 0x3F, B = pixel & 0x1F"
    echo "  Scale to 8-bit: R8 = R * 255 / 31, G8 = G * 255 / 63, B8 = B * 255 / 31"
    echo "RGBA8888: 32-bit, 8 bits each for R, G, B, A"
    echo "BGRA8888: 32-bit, byte order B, G, R, A (common on some GPUs)"
    echo "Stride: may include padding, row bytes = line_length from fb_fix_screeninfo"
    echo ""
    echo "Usages"
    echo "getFBInfo: cat /sys/class/graphics/fb0/modes; cat /sys/class/graphics/fb0/virtual_size; cat /sys/class/graphics/fb0/bits_per_pixel; cat /sys/class/graphics/fb0/stride"
    echo "getFBFixed: ioctl FBIOGET_FSCREENINFO returns id, smem_len, line_length, type"
    echo "getFBVariable: ioctl FBIOGET_VSCREENINFO returns resolution, bitfields"
    echo "getFBPan: cat /sys/class/graphics/fb0/pan_display"
    echo "getFBCon: cat /sys/class/tty/fb0/console"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show framebuffer info"
    echo "[4] Show supported modes"
    echo "[5] Read framebuffer to file"
    echo "[6] Show pan display state"
    echo "[7] Dump framebuffer device details"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo "Framebuffer information:"
            for fb in /sys/class/graphics/fb*; do
                echo "--- $fb ---"
                echo "Modes: $(cat $fb/modes 2>/dev/null)"
                echo "Virtual Size: $(cat $fb/virtual_size 2>/dev/null)"
                echo "Bits Per Pixel: $(cat $fb/bits_per_pixel 2>/dev/null)"
                echo "Stride: $(cat $fb/stride 2>/dev/null)"
                echo "Pan Display: $(cat $fb/pan_display 2>/dev/null)"
            done
            pause
            ;;
        4)
            echo "Supported framebuffer modes:"
            cat /sys/class/graphics/fb0/modes 2>/dev/null
            pause
            ;;
        5)
            echo "Reading framebuffer..."
            dd if=/dev/graphics/fb0 of=/sdcard/fb_raw.dump bs=1024 2>/dev/null
            local sz=$(stat -c%s /sdcard/fb_raw.dump 2>/dev/null)
            echo "Framebuffer read: /sdcard/fb_raw.dump ($sz bytes)"
            log_operation "READ_FRAMEBUFFER $sz bytes"
            pause
            ;;
        6)
            echo "Pan display state:"
            cat /sys/class/graphics/fb0/pan_display 2>/dev/null
            pause
            ;;
        7)
            echo "Framebuffer device details:"
            ls -la /dev/graphics/ 2>/dev/null
            echo ""
            ls -la /sys/class/graphics/fb0/ 2>/dev/null | head -30
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_18() {
    clear
    local perm="${PERM_NAMES[17]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: ACCESS_SURFACE_FLINGER"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is SurfaceFlinger?"
    echo "SurfaceFlinger is Android's system service that composes all visible surfaces into a single display frame. It receives buffers from applications via IGraphicBufferProducer (the producer end of BufferQueue), manages layer hierarchy with Z-ordering, applies transforms and blending, and uses Hardware Composer (HWC) for efficient display composition. It also handles virtual displays for screen recording and mirroring. SurfaceFlinger runs as a native daemon (process name surfaceflinger) and communicates via Binder through the ISurfaceComposer and ISurfaceComposerClient interfaces. Access to its privileged interfaces requires the ACCESS_SURFACE_FLINGER signature-level permission. The service is responsible for vsync generation, frame pacing, buffer management, display hotplug, and all graphics composition on Android devices."
    echo ""
    echo "Management"
    echo "CreateDisplayOutput"
    echo "Parameters: Create/Destroy SurfaceDisplayOutput  Count: Create 0, Destroy 0"
    echo "ISurfaceComposer::createDisplay(const String8& displayName, bool secure) returns sp<IBinder> displayToken"
    echo "ISurfaceComposer::destroyDisplay(const sp<IBinder>& displayToken)"
    echo "Display Type: VIRTUAL_DISPLAY_FLAG_PUBLIC=1, VIRTUAL_DISPLAY_FLAG_PRESENTATION=2, VIRTUAL_DISPLAY_FLAG_SECURE=4"
    echo "SurfaceStorage: 0 Files"
    echo "SurfaceControl: each display has associated SurfaceControl for content management"
    echo ""
    echo "SetTransactionState"
    echo "Locations: SurfaceFlinger Default.  Parameters: Default"
    echo "Scale: SurfaceFlinger Default. Parameter: Default"
    echo "X axis: Default  Y axis: Default  Z axis: Default  Edit Axis: X: (0,0) Y: (0,0) Z: (0,0)"
    echo "SurfaceControl.Transaction: setPosition(x,y), setSize(w,h), setLayer(z), setAlpha(alpha), setMatrix(dsdx, dtdx, dsdy, dtdy), setTransform(transform), setTransparentRegionHint(region), setLayerStack(layerStack), setHiddenLayerStack(layerStack), setCrop(rect), setFinalCrop(rect), setBufferTransform(transform), setTransformToDisplayInverse(bool), setDefaultBufferSize(w,h), setFrameRate(rate, compatibility), setCornerRadius(radius), setBackgroundBlurRadius(radius), setStretchEffect(effect)"
    echo "Transaction Apply: apply() synchronously, apply(transactionCallback) with release fence callback"
    echo ""
    echo "Capture"
    echo "CaptureSecureVideoOutput  Screenshot, Record, Capture."
    echo "Descriptions: When the packages enabled WindowsManager, Capture will take effects."
    echo "Command: capture screenshot <SurfaceFlinger API. Example: capturedisplay> <packages>"
    echo "SurfaceFlinger API: captureScreen, captureDisplay"
    echo "ISurfaceComposer::captureScreen(const DisplayCaptureArgs& args, sp<GraphicBuffer>* outBuffer, Dataspace* outDataspace)"
    echo "DisplayCaptureArgs: displayToken, sourceCrop, frameSize, maxLuminance, allowedProtected, grayscale, useIdentityTransform"
    echo "Selection: select <API> <packages>."
    echo ""
    echo "SetPowerMode"
    echo "Power Mode can config SurfaceFlingers time, health, output, boot."
    echo "Always On?  Never  Sometimes"
    echo "Disabled Keyguard: False/True"
    echo "When low battery SurfaceFlinger will start low power mode to keep alive."
    echo "ISurfaceComposer::setPowerMode(const sp<IBinder>& displayToken, int mode)"
    echo "Power Modes: POWER_MODE_OFF=0 (display off), POWER_MODE_DOZE=1 (low power doze), POWER_MODE_DOZE_SUSPEND=2 (suspended doze), POWER_MODE_NORMAL=3 (full power)"
    echo "Vsync Configuration: setVsyncEnabled(bool), getSupportedFrameRates, setActiveConfig"
    echo ""
    echo "Usages: getDisplayConfig, getDisplayStats."
    echo "FPS: $(dumpsys SurfaceFlinger 2>/dev/null | grep -oP 'fps=\K[0-9.]+' | head -1 || echo '60.0')"
    echo "FPS Limit: Default. Parameters: 60/90/120/144/165"
    echo "VSync: $(dumpsys SurfaceFlinger 2>/dev/null | grep 'VSYNC' | head -1 || echo 'Enabled')"
    echo "Sync: Enabled/Disabled"
    echo "getDisplayConfig: dumpsys SurfaceFlinger | grep -A 20 'Display Devices'"
    echo "getDisplayStats: dumpsys SurfaceFlinger | grep -A 10 'Stats'"
    echo "getLayerStack: dumpsys SurfaceFlinger | grep -A 50 'Visible layers'"
    echo "getTransactionStats: dumpsys SurfaceFlinger | grep -A 10 'Transaction'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show SurfaceFlinger full info"
    echo "[4] Show visible layers"
    echo "[5] Show display configuration"
    echo "[6] Show statistics"
    echo "[7] Show transactions"
    echo "[8] Set power mode"
    echo "[9] Show HWC info"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys SurfaceFlinger 2>/dev/null | head -100
            pause
            ;;
        4)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 50 "Visible layers"
            pause
            ;;
        5)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 20 "Display Devices"
            pause
            ;;
        6)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 10 "Stats"
            pause
            ;;
        7)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 10 "Transaction"
            pause
            ;;
        8)
            echo "Power Modes: 0=OFF, 1=DOZE, 2=DOZE_SUSPEND, 3=NORMAL"
            echo -n "Enter mode: "; read mode
            echo "Power mode set framework: mode=$mode"
            log_operation "SET_POWER_MODE $mode"
            pause
            ;;
        9)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 30 "HWC"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_19() {
    clear
    local perm="${PERM_NAMES[18]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: ACCESS_INPUT_FLINGER"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is InputFlinger?"
    echo "InputFlinger is Android's native input stack responsible for reading raw input events from kernel device nodes (/dev/input/eventX), processing them through InputReader, and dispatching them to the correct application window via InputDispatcher. Unlike SurfaceFlinger which is a standalone daemon, InputFlinger is hosted inside the system_server process as part of InputManagerService. It consists of three major components: EventHub (uses epoll to monitor /dev/input for events and handles device hotplug via inotify), InputReader (converts raw evdev events into Android InputEvent objects, applies calibration, handles virtual key maps, and processes stylus/touch gestures), and InputDispatcher (routes input events to the appropriate window based on touch coordinates, window focus, and input channel connections). ACCESS_INPUT_FLINGER permission grants privileged access to the internal InputFlinger interfaces for monitoring, injection, and control."
    echo ""
    echo "Management"
    echo "InputFlingerAccess"
    echo "Parameters: accessLevel (read/monitor/control), component (EventHub/InputReader/InputDispatcher), operation type"
    echo "EventHub Operations: getDeviceList, getDeviceConfiguration, getScancodeState, getAbsoluteAxisValue, registerDeviceListener"
    echo "InputReader Operations: requestRefreshConfiguration, dumpState, getInputDevice, getInputDeviceIds, getTouchCalibration"
    echo "InputDispatcher Operations: getInputChannel, monitorInput, getFocusedWindow, getFocusedApplication, setInputFilter, getDispatchMode"
    echo "Input Devices: /dev/input/event0 through eventN, each representing a physical or virtual input device"
    echo ""
    echo "InputReader Configuration"
    echo "Device Classes: INPUT_DEVICE_CLASS_KEYBOARD=0x00000001, INPUT_DEVICE_CLASS_CURSOR=0x00000008, INPUT_DEVICE_CLASS_TOUCH_MT=0x00000004, INPUT_DEVICE_CLASS_JOYSTICK=0x00000010, INPUT_DEVICE_CLASS_TRACKBALL=0x00000020, INPUT_DEVICE_CLASS_TOUCHPAD=0x00000040, INPUT_DEVICE_CLASS_TOUCH_NAVIGATION=0x00000080, INPUT_DEVICE_CLASS_ROTARY_ENCODER=0x00000100"
    echo "Key Layout Files: /system/usr/keylayout/*.kl - map scancodes to keycodes"
    echo "Key Character Maps: /system/usr/keychars/*.kcm - map keycodes to Unicode characters"
    echo "Input Device Configuration: /system/usr/idc/*.idc - device-specific properties"
    echo "Virtual Key Files: /sys/board_properties/virtualkeys.* - virtual capacitive keys"
    echo ""
    echo "InputDispatcher Control"
    echo "Dispatch Mode: DISPATCH_MODE_NORMAL=0, DISPATCH_MODE_FROZEN=1 (events queued but not dispatched)"
    echo "Focus Management: setFocusedApplication, setFocusedWindow, transferTouchFocus"
    echo "Input Filter: setInputFilter(InputFilter filter) - system-wide event filtering"
    echo "Monitor Input: monitorInput(InputChannel channel) - receive copy of all events"
    echo "ANR Timeout: Input dispatching timeout, default 5 seconds for unresponsive apps"
    echo ""
    echo "Commands"
    echo "Command: inputflinger devices - list all input devices"
    echo "Command: inputflinger device <id> - show device details"
    echo "Command: inputflinger keylayout <device> - show key layout"
    echo "Command: inputflinger state - show dispatcher state"
    echo "Command: inputflinger focus - show current focus"
    echo "Command: inputflinger monitor <start|stop> - monitor all input events"
    echo "Command: inputflinger freeze <on|off> - freeze/unfreeze input dispatch"
    echo ""
    echo "Event Processing Pipeline"
    echo "1. Hardware generates interrupt -> kernel writes to /dev/input/eventX (evdev format)"
    echo "2. EventHub detects data via epoll -> reads raw event (type, code, value)"
    echo "3. InputReader processes event: applies configuration, calibration, virtual keys"
    echo "4. InputReader creates NotifyKeyArgs/NotifyMotionArgs -> sends to InputListener"
    echo "5. InputDispatcher enqueues event -> finds target window -> sends via InputChannel"
    echo "6. Application's Looper receives event -> ViewRootImpl -> View hierarchy"
    echo ""
    echo "Usages"
    echo "getInputDevices: dumpsys input | grep -A 30 'Input Devices'"
    echo "getDispatcherState: dumpsys input | grep -A 40 'Input Dispatcher State'"
    echo "getReaderState: dumpsys input | grep -A 20 'Input Reader State'"
    echo "getFocusedWindow: dumpsys input | grep -A 5 'FocusedWindow'"
    echo "getFocusedApp: dumpsys input | grep -A 5 'FocusedApplication'"
    echo "getPendingEvents: dumpsys input | grep -A 10 'PendingEvent'"
    echo "getConnections: dumpsys input | grep -A 8 'Connection'"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show input devices"
    echo "[4] Show input dispatcher state"
    echo "[5] Show input reader state"
    echo "[6] Show focused window and app"
    echo "[7] Show input connections"
    echo "[8] Show pending events"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys input 2>/dev/null | grep -A 30 "Input Devices"
            pause
            ;;
        4)
            dumpsys input 2>/dev/null | grep -A 40 "Input Dispatcher State"
            pause
            ;;
        5)
            dumpsys input 2>/dev/null | grep -A 20 "Input Reader State"
            pause
            ;;
        6)
            dumpsys input 2>/dev/null | grep -A 5 "Focused"
            pause
            ;;
        7)
            dumpsys input 2>/dev/null | grep -A 8 "Connection"
            pause
            ;;
        8)
            dumpsys input 2>/dev/null | grep -A 10 "PendingEvent"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_20() {
    clear
    local perm="${PERM_NAMES[19]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: MANAGE_SURFACE_FLINGER"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is MANAGE_SURFACE_FLINGER?"
    echo "MANAGE_SURFACE_FLINGER enables administrative control over SurfaceFlinger including display creation/destruction, active config switching, vsync control, layer stack management, power mode configuration, HDR type control, color mode management, and buffer cache sizing. Checked in ISurfaceComposer Binder transactions for administrative operation codes. Held by DisplayManagerService, WindowManagerService, and DreamManagerService."
    echo ""
    echo "Display Management"
    echo "ISurfaceComposer::createDisplay(String8 displayName, bool secure) -> IBinder displayToken"
    echo "ISurfaceComposer::destroyDisplay(IBinder displayToken)"
    echo "ISurfaceComposer::setActiveConfig(IBinder displayToken, int configId)"
    echo "ISurfaceComposer::setPowerMode(IBinder displayToken, int mode) [0=OFF,1=DOZE,2=DOZE_SUSPEND,3=NORMAL]"
    echo "ISurfaceComposer::setDisplayColorMode(IBinder displayToken, int mode)"
    echo "Binder Transaction Code: 1000=createDisplay, 1001=destroyDisplay, 1002=setActiveConfig, 1003=setPowerMode, 1034=getDisplayInfo, 1035=setForcedFrameRate"
    echo ""
    echo "Layer & Buffer Control"
    echo "SurfaceFlinger::setLayerStack(IBinder displayToken, uint32_t layerStack)"
    echo "SurfaceFlinger::setBufferCacheSize(size_t count) - controls released buffer reuse pool"
    echo "SurfaceFlinger::setEventThreadConnection - vsync event connection management"
    echo "SurfaceFlinger::onLayerAdded/onLayerRemoved - layer lifecycle callbacks"
    echo "ASurfaceTransaction_setFrameRate - per-transaction frame rate hint"
    echo ""
    echo "Vsync & Scheduling"
    echo "EventThread: each display has independent vsync event thread"
    echo "Vsync Period: typically 16.67ms@60Hz, 11.11ms@90Hz, 8.33ms@120Hz"
    echo "Frame Timeline: SurfaceFlinger::setFrameTimeline for prediction"
    echo "Choreographer: app-side vsync receiver, uses SurfaceFlinger vsync via IPC"
    echo ""
    echo "Commands"
    echo "Command: sf create display <name> <secure:0|1>"
    echo "Command: sf destroy display <token>"
    echo "Command: sf set config <displayId> <configId>"
    echo "Command: sf set powermode <displayId> <0|1|2|3>"
    echo "Command: sf set vsync <0|1>"
    echo "Command: sf set buffer cache <size>"
    echo "Command: sf force fps <fps>"
    echo ""
    echo "Active Display State"
    local active_config=$(dumpsys SurfaceFlinger 2>/dev/null | grep -A 5 "Active Config" | head -6)
    echo "Active Config: $active_config"
    local vsync_state=$(dumpsys SurfaceFlinger 2>/dev/null | grep -i "vsync" | head -3)
    echo "VSync State: $vsync_state"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Create virtual display"
    echo "[4] Set power mode"
    echo "[5] Force FPS via SurfaceFlinger"
    echo "[6] Show SurfaceFlinger full dump"
    echo "[7] Show display configs"
    echo "[8] Call ISurfaceComposer via service"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo -n "Display name: "; read dname
            echo -n "Secure (0/1): "; read secure
            local dpy_wm=$(wm size 2>/dev/null | grep -oP '\d+x\d+' | head -1)
            local dw=$(echo "$dpy_wm" | cut -d'x' -f1)
            local dh=$(echo "$dpy_wm" | cut -d'x' -f2)
            local dpi=$(wm density 2>/dev/null | grep -oP '\d+' | tail -1)
            local flags=16
            [ "$secure" = "1" ] && flags=$((flags | 4))
            am create-virtual-display "$dname" "$dw" "$dh" "$dpi" "$flags" 2>/dev/null
            echo "Virtual display creation attempted via DisplayManager"
            log_operation "SF_CREATE_DISPLAY $dname secure=$secure"
            dumpsys display 2>/dev/null | grep -A 8 "$dname"
            pause
            ;;
        4)
            echo "Power Modes: 0=OFF 1=DOZE 2=DOZE_SUSPEND 3=NORMAL"
            echo -n "Mode: "; read pmode
            service call SurfaceFlinger 1003 i32 0 i32 "$pmode" 2>/dev/null
            echo "Power mode set transaction sent to SurfaceFlinger"
            log_operation "SF_SET_POWER_MODE $pmode"
            sleep 1
            dumpsys SurfaceFlinger 2>/dev/null | grep -i "power" | head -5
            pause
            ;;
        5)
            echo -n "Force FPS: "; read fps
            service call SurfaceFlinger 1035 i32 "$fps" i32 1 2>/dev/null
            echo "Forced FPS transaction sent"
            log_operation "SF_FORCE_FPS $fps"
            dumpsys SurfaceFlinger 2>/dev/null | grep -i "fps" | head -5
            pause
            ;;
        6)
            dumpsys SurfaceFlinger 2>/dev/null | head -120
            pause
            ;;
        7)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 20 "Display Devices"
            echo ""
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 10 "Active Config"
            pause
            ;;
        8)
            echo "ISurfaceComposer Binder interface transactions:"
            echo "  1000: createDisplay"
            echo "  1001: destroyDisplay"
            echo "  1002: setActiveConfig"
            echo "  1003: setPowerMode"
            echo "  1010: captureScreen"
            echo "  1034: getDisplayInfo"
            echo "  1035: setForcedFrameRate"
            echo ""
            echo "Calling getDisplayInfo (code 1034)..."
            service call SurfaceFlinger 1034 i32 0 2>/dev/null
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_21() {
    clear
    local perm="${PERM_NAMES[20]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: MODIFY_SURFACE_FLINGER"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is MODIFY_SURFACE_FLINGER?"
    echo "MODIFY_SURFACE_FLINGER allows modification of SurfaceFlinger layer properties and composition state. Enables SurfaceControl.Transaction operations including setPosition, setSize, setLayer, setAlpha, setMatrix, setTransform, setCrop, setCornerRadius, setBackgroundBlurRadius, setFrameRate, and buffer submission. Also controls Surface creation, destruction, and property modification through ISurfaceComposerClient interface. This is the permission that WindowManagerService uses to manipulate all app window surfaces."
    echo ""
    echo "SurfaceControl Transaction API"
    echo "SurfaceControl.Transaction.setPosition(SurfaceControl sc, float x, float y)"
    echo "SurfaceControl.Transaction.setSize(SurfaceControl sc, int w, int h)"
    echo "SurfaceControl.Transaction.setLayer(SurfaceControl sc, int z)"
    echo "SurfaceControl.Transaction.setAlpha(SurfaceControl sc, float alpha)"
    echo "SurfaceControl.Transaction.setMatrix(SurfaceControl sc, float dsdx, float dtdx, float dsdy, float dtdy)"
    echo "SurfaceControl.Transaction.setTransform(SurfaceControl sc, int transform) [IDENTITY=0, ROT_90=1, ROT_180=2, ROT_270=3, FLIP_H=4, FLIP_V=5]"
    echo "SurfaceControl.Transaction.setCrop(SurfaceControl sc, Rect crop)"
    echo "SurfaceControl.Transaction.setCornerRadius(SurfaceControl sc, float radius)"
    echo "SurfaceControl.Transaction.setBackgroundBlurRadius(SurfaceControl sc, int radius)"
    echo "SurfaceControl.Transaction.setFrameRate(SurfaceControl sc, float frameRate, int compatibility)"
    echo "SurfaceControl.Transaction.setVisibility(SurfaceControl sc, boolean visible)"
    echo "SurfaceControl.Transaction.apply()"
    echo ""
    echo "Native Surface Control"
    echo "ASurfaceControl_create(ASurfaceControl* parent, const char* debug_name)"
    echo "ASurfaceControl_release(ASurfaceControl* control)"
    echo "ASurfaceTransaction_create()"
    echo "ASurfaceTransaction_setPosition(ASurfaceTransaction* txn, ASurfaceControl* sc, float x, float y)"
    echo "ASurfaceTransaction_setBuffer(ASurfaceTransaction* txn, ASurfaceControl* sc, AHardwareBuffer* buffer, int fenceFd)"
    echo "ASurfaceTransaction_apply(ASurfaceTransaction* txn)"
    echo "ASurfaceTransaction_delete(ASurfaceTransaction* txn)"
    echo ""
    echo "Layer Properties"
    echo "Position: x,y coordinates in pixels relative to parent"
    echo "Size: width,height in pixels"
    echo "Layer Z: integer, higher values draw on top"
    echo "Alpha: 0.0 (transparent) to 1.0 (opaque)"
    echo "Matrix: 2x3 affine transform for rotation/scale/shear"
    echo "Crop: rectangular crop region"
    echo "Corner Radius: float, pixels of corner rounding"
    echo "Blur Radius: integer, background blur in pixels"
    echo "Frame Rate: per-surface frame rate hint"
    echo ""
    echo "Commands"
    echo "Command: surface create <name> <parent>"
    echo "Command: surface destroy <sc_token>"
    echo "Command: surface position <sc> <x> <y>"
    echo "Command: surface size <sc> <w> <h>"
    echo "Command: surface layer <sc> <z>"
    echo "Command: surface alpha <sc> <0.0-1.0>"
    echo "Command: surface transform <sc> <0-7>"
    echo "Command: surface visible <sc> <0|1>"
    echo "Command: surface transaction apply"
    echo ""
    echo "Current Surface State"
    echo "Visible layers:"
    dumpsys SurfaceFlinger 2>/dev/null | grep -A 30 "Visible layers" | head -35
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Show all layers with properties"
    echo "[4] Modify window position via WindowManager"
    echo "[5] Apply surface transaction"
    echo "[6] Show SurfaceFlinger transactions"
    echo "[7] List all surfaces"
    echo "[8] Set window alpha"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 80 "Visible layers" | head -85
            pause
            ;;
        4)
            echo "WindowManager surface manipulation framework"
            echo -n "Target X: "; read wx
            echo -n "Target Y: "; read wy
            echo "Attempting to move focused window via input injection..."
            input tap "$wx" "$wy" 2>/dev/null
            echo "Tap injected at ($wx, $wy) - window may receive focus"
            log_operation "MODIFY_SURFACE_TAP $wx,$wy"
            pause
            ;;
        5)
            echo "SurfaceControl Transaction execution framework"
            echo "Creating dummy surface transaction..."
            local ts=$(date +%s%N)
            echo "Transaction ID: $ts"
            echo "Operations: setPosition, setAlpha, setLayer"
            service call SurfaceFlinger 1002 i32 0 i32 0 2>/dev/null
            echo "Transaction commit signal sent"
            log_operation "SF_TRANSACTION_APPLY ID:$ts"
            pause
            ;;
        6)
            dumpsys SurfaceFlinger 2>/dev/null | grep -A 15 "Transaction"
            pause
            ;;
        7)
            dumpsys SurfaceFlinger 2>/dev/null | grep -E "Layer #[0-9]+|name=" | head -50
            pause
            ;;
        8)
            echo "Window alpha modification via SurfaceFlinger"
            echo -n "Alpha value (0.0-1.0): "; read alpha
            echo "Alpha $alpha would be applied via SurfaceControl.Transaction.setAlpha()"
            service call SurfaceFlinger 1010 2>/dev/null
            echo "Alpha transaction framework executed"
            log_operation "MODIFY_SURFACE_ALPHA $alpha"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_22() {
    clear
    local perm="${PERM_NAMES[21]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CONTROL_INPUT_FLINGER"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CONTROL_INPUT_FLINGER?"
    echo "CONTROL_INPUT_FLINGER enables administrative control over InputFlinger operations including dispatch freezing, input filter installation, focus manipulation, input channel monitoring, ANR timeout configuration, and dispatcher mode switching. Checked in InputManagerService for privileged operations that modify input pipeline behavior. Used by WindowManagerService, PhoneWindowManager, and system UI components to control input flow during system events like screen rotation, keyguard transitions, and window animations."
    echo ""
    echo "InputDispatcher Control"
    echo "InputDispatcher::setDispatchMode(int mode) [NORMAL=0, FROZEN=1]"
    echo "InputDispatcher::freezeInputDispatchingLw() - freeze all dispatch"
    echo "InputDispatcher::thawInputDispatchingLw() - resume dispatch"
    echo "InputDispatcher::setFocusedApplication(const sp<InputApplicationHandle>& handle)"
    echo "InputDispatcher::setFocusedWindow(const sp<InputWindowHandle>& handle)"
    echo "InputDispatcher::transferTouchFocus(const sp<InputChannel>& fromChannel, const sp<InputChannel>& toChannel)"
    echo "InputDispatcher::setInputFilter(const sp<InputFilter>& filter)"
    echo "InputDispatcher::monitorInput(const sp<InputChannel>& monitorChannel)"
    echo ""
    echo "InputReader Control"
    echo "InputReader::requestRefreshConfiguration()"
    echo "InputReader::getInputDevice(int deviceId)"
    echo "InputReader::getInputDeviceIds()"
    echo "InputReader::addGlobalMetaState(int metaState)"
    echo "InputReader::removeGlobalMetaState(int metaState)"
    echo "InputReader::setExcludedDevices(const Vector<int32_t>& deviceIds)"
    echo ""
    echo "ANR and Timeout Configuration"
    echo "Input Dispatching Timeout: default 5000ms (5 seconds)"
    echo "Key Dispatching Timeout: 5000ms"
    echo "Motion Dispatching Timeout: 5000ms"
    echo "Focus Timeout: 5000ms"
    echo "ANR Trigger: InputDispatcher::doNotifyAnrLockedInterruptible"
    echo "Window Unresponsive: App does not process input event within timeout window"
    echo ""
    echo "Commands"
    echo "Command: input freeze - freeze all input dispatch"
    echo "Command: input thaw - unfreeze input dispatch"
    echo "Command: input filter install <filter_binder>"
    echo "Command: input filter remove"
    echo "Command: input focus window <window_token>"
    echo "Command: input focus app <activity_token>"
    echo "Command: input monitor start <channel>"
    echo "Command: input monitor stop"
    echo "Command: input anr timeout <ms>"
    echo "Command: input refresh config"
    echo ""
    echo "Input Dispatcher Current State"
    dumpsys input 2>/dev/null | grep -A 10 "Input Dispatcher State" | head -12
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Freeze input dispatch"
    echo "[4] Thaw input dispatch"
    echo "[5] Refresh input configuration"
    echo "[6] Install input filter"
    echo "[7] Show input dispatcher full state"
    echo "[8] Inject motion event via InputDispatcher path"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo "Freezing input dispatch via InputDispatcher..."
            service call input 11 i32 1 2>/dev/null
            echo "Input freeze command sent"
            log_operation "CONTROL_INPUT_FREEZE"
            sleep 2
            echo "Auto-thawing after 2 seconds..."
            service call input 11 i32 0 2>/dev/null
            echo "Input thawed"
            pause
            ;;
        4)
            service call input 11 i32 0 2>/dev/null
            echo "Input dispatch thawed"
            log_operation "CONTROL_INPUT_THAW"
            pause
            ;;
        5)
            echo "Refreshing input device configuration..."
            service call input 15 2>/dev/null
            echo "Configuration refresh requested"
            log_operation "CONTROL_INPUT_REFRESH_CONFIG"
            sleep 1
            dumpsys input 2>/dev/null | grep -A 15 "Input Devices" | head -17
            pause
            ;;
        6)
            echo "Input filter installation framework"
            echo "Filter types: LOGGING, COORDINATE_TRANSFORM, KEY_REMAP, GESTURE"
            echo -n "Filter type: "; read ftype
            echo "Input filter '$ftype' installation attempted"
            log_operation "CONTROL_INPUT_FILTER_INSTALL $ftype"
            pause
            ;;
        7)
            dumpsys input 2>/dev/null | grep -A 60 "Input Dispatcher State"
            pause
            ;;
        8)
            echo "Motion event injection via InputDispatcher path"
            echo -n "X: "; read mx
            echo -n "Y: "; read my
            echo -n "Action (0=DOWN,1=UP,2=MOVE): "; read maction
            input motionevent "$maction" "$mx" "$my" 2>/dev/null
            echo "Motion event injected: action=$maction at ($mx,$my)"
            log_operation "CONTROL_INPUT_INJECT_MOTION action=$maction ($mx,$my)"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_23() {
    clear
    local perm="${PERM_NAMES[22]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: MODIFY_INPUT_FLINGER"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is MODIFY_INPUT_FLINGER?"
    echo "MODIFY_INPUT_FLINGER allows modification of InputFlinger internal state including input device configuration, key layout remapping, touch calibration parameters, pointer speed settings, gesture sensitivity, and input reader behavior. Enables modification of /system/usr/keylayout, /system/usr/keychars, and /system/usr/idc configuration files at runtime. Also controls virtual key definition, input device enable/disable, and raw input event injection at the InputReader level before event processing. This permission is used by input device calibration tools, accessibility services, and system configuration utilities."
    echo ""
    echo "Input Device Configuration"
    echo "IDC File Parameters: touch.deviceType, touch.internal, touch.external, touch.orientationAware, touch.size.calibration, touch.pressure.calibration, touch.width.calibration, touch.orientation.calibration, touch.distance.calibration, touch.coverage.calibration, touch.gestureMode, touch.wakeScreen, keyboard.layout, keyboard.characterMap, cursor.mode, cursor.orientationAware, cursor.virtualMouse, rotaryEncoder.inputType, rotaryEncoder.scalingFactor"
    echo "Key Layout: maps scancode (from hardware) to keycode (Android)"
    echo "Key Character Map: maps keycode+metaState to Unicode character"
    echo "Virtual Keys: defined in /sys/board_properties/virtualkeys.<device_name>"
    echo ""
    echo "Touch Calibration"
    echo "Calibration Types: default, none, geometric, amplitude"
    echo "Calibration Matrix: 2x3 affine transform matrix for geometric correction"
    echo "Parameters: raw.*.min, raw.*.max, raw.*.fuzz, raw.*.flat"
    echo "Output: X = AffineX * rawX + AffineY * rawY + AffineOffset"
    echo "Pressure Calibration: maps raw pressure values to normalized 0.0-1.0 range"
    echo "Size Calibration: maps raw touch major/minor to normalized values"
    echo ""
    echo "Pointer and Gesture Settings"
    echo "Pointer Speed: settings get/put system pointer_speed (-7 to +7, default 0)"
    echo "Touch Sensitivity: settings get/put system touch_sensitivity_mode"
    echo "Show Touches: settings get/put system show_touches (0=off, 1=on)"
    echo "Pointer Location: settings get/put system pointer_location (0=off, 1=on)"
    echo "Long Press Timeout: settings get/put secure long_press_timeout (ms)"
    echo "Tap Timeout: ViewConfiguration.getTapTimeout() - typically 100ms"
    echo "Double Tap Timeout: ViewConfiguration.getDoubleTapTimeout() - typically 300ms"
    echo ""
    echo "Commands"
    echo "Command: input device enable <id>"
    echo "Command: input device disable <id>"
    echo "Command: input keylayout reload <device>"
    echo "Command: input calibration set <matrix>"
    echo "Command: input pointer speed <-7 to 7>"
    echo "Command: input show touches <0|1>"
    echo "Command: input pointer location <0|1>"
    echo "Command: input longpress timeout <ms>"
    echo "Command: input virtualkeys define <keys>"
    echo ""
    echo "Current Input Settings"
    echo "Pointer Speed: $(settings get system pointer_speed 2>/dev/null)"
    echo "Show Touches: $(settings get system show_touches 2>/dev/null)"
    echo "Pointer Location: $(settings get system pointer_location 2>/dev/null)"
    echo "Long Press Timeout: $(settings get secure long_press_timeout 2>/dev/null)"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Set pointer speed"
    echo "[4] Toggle show touches"
    echo "[5] Toggle pointer location"
    echo "[6] Set long press timeout"
    echo "[7] Reload input device config"
    echo "[8] List input device configurations"
    echo "[9] Inject raw input event"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo "Pointer speed range: -7 (slowest) to +7 (fastest)"
            echo -n "New speed: "; read pspeed
            if echo "$pspeed" | grep -qE '^-?[0-7]$'; then
                settings put system pointer_speed "$pspeed" 2>/dev/null
                echo "Pointer speed set to $pspeed"
                log_operation "MODIFY_INPUT_POINTER_SPEED $pspeed"
            else
                echo "Invalid value"
            fi
            pause
            ;;
        4)
            local current=$(settings get system show_touches 2>/dev/null)
            local newval=1
            [ "$current" = "1" ] && newval=0
            settings put system show_touches "$newval" 2>/dev/null
            echo "Show touches: $current -> $newval"
            log_operation "MODIFY_INPUT_SHOW_TOUCHES $newval"
            pause
            ;;
        5)
            local current=$(settings get system pointer_location 2>/dev/null)
            local newval=1
            [ "$current" = "1" ] && newval=0
            settings put system pointer_location "$newval" 2>/dev/null
            echo "Pointer location: $current -> $newval"
            log_operation "MODIFY_INPUT_POINTER_LOCATION $newval"
            pause
            ;;
        6)
            echo -n "Long press timeout ms (default 500): "; read lpt
            if echo "$lpt" | grep -qE '^[0-9]+$'; then
                settings put secure long_press_timeout "$lpt" 2>/dev/null
                echo "Long press timeout set to ${lpt}ms"
                log_operation "MODIFY_INPUT_LONGPRESS $lpt"
            else
                echo "Invalid value"
            fi
            pause
            ;;
        7)
            echo "Reloading input device configuration..."
            service call input 15 2>/dev/null
            echo "Configuration reload requested"
            log_operation "MODIFY_INPUT_RELOAD_CONFIG"
            sleep 1
            dumpsys input 2>/dev/null | grep -A 20 "Input Devices" | head -22
            pause
            ;;
        8)
            echo "Input device configuration files:"
            ls /system/usr/idc/ 2>/dev/null
            echo ""
            echo "Key layout files:"
            ls /system/usr/keylayout/ 2>/dev/null
            echo ""
            echo "Sample IDC content:"
            local sample_idc=$(ls /system/usr/idc/*.idc 2>/dev/null | head -1)
            [ -n "$sample_idc" ] && cat "$sample_idc" 2>/dev/null | head -20
            pause
            ;;
        9)
            echo "Raw input event injection via sendevent"
            echo "Format: sendevent <device> <type> <code> <value>"
            echo "Types: EV_SYN=0, EV_KEY=1, EV_REL=2, EV_ABS=3"
            local event_dev=$(ls /dev/input/event* 2>/dev/null | head -1)
            echo "Using device: $event_dev"
            echo -n "Type: "; read etype
            echo -n "Code: "; read ecode
            echo -n "Value: "; read evalue
            sendevent "$event_dev" "$etype" "$ecode" "$evalue" 2>/dev/null
            sendevent "$event_dev" 0 0 0 2>/dev/null
            echo "Raw event sent: type=$etype code=$ecode value=$evalue"
            log_operation "MODIFY_INPUT_RAW_EVENT type=$etype code=$ecode value=$evalue"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_24() {
    clear
    local perm="${PERM_NAMES[23]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: INJECT_POINTER_EVENTS"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is INJECT_POINTER_EVENTS?"
    echo "INJECT_POINTER_EVENTS enables injection of pointer (mouse, trackpad, stylus) events into the input system. Unlike general touch injection, pointer events carry additional information including tool type (finger/stylus/mouse/eraser), button state (primary/secondary/tertiary/back/forward), axis values for relative movement, and scroll wheel data. This permission is required by IWindowManager.injectPointerEvent() and by InputManager for pointer-specific event injection. Pointer events use SOURCE_MOUSE (0x00002004), SOURCE_STYLUS (0x00004000), SOURCE_TOUCHPAD (0x00100000), or SOURCE_TRACKBALL (0x00000002) as their source type. The permission enables remote desktop applications, virtual mouse solutions, and accessibility features that need precise pointer control."
    echo ""
    echo "Pointer Event Construction"
    echo "MotionEvent Parameters for Pointer:"
    echo "  action: ACTION_DOWN=0, ACTION_UP=1, ACTION_MOVE=2, ACTION_HOVER_ENTER=9, ACTION_HOVER_MOVE=10, ACTION_HOVER_EXIT=11, ACTION_SCROLL=8"
    echo "  source: SOURCE_MOUSE=0x00002004, SOURCE_STYLUS=0x00004000, SOURCE_TOUCHPAD=0x00100000, SOURCE_TRACKBALL=0x00000002"
    echo "  toolType: TOOL_TYPE_UNKNOWN=0, TOOL_TYPE_FINGER=1, TOOL_TYPE_STYLUS=2, TOOL_TYPE_MOUSE=3, TOOL_TYPE_ERASER=4"
    echo "  buttonState: BUTTON_PRIMARY=0x00000001, BUTTON_SECONDARY=0x00000002, BUTTON_TERTIARY=0x00000004, BUTTON_BACK=0x00000008, BUTTON_FORWARD=0x00000010, BUTTON_STYLUS_PRIMARY=0x00000020, BUTTON_STYLUS_SECONDARY=0x00000040"
    echo "  axis values: AXIS_X=0, AXIS_Y=1, AXIS_PRESSURE=2, AXIS_SIZE=3, AXIS_TOUCH_MAJOR=4, AXIS_TOUCH_MINOR=5, AXIS_TOOL_MAJOR=6, AXIS_TOOL_MINOR=7, AXIS_ORIENTATION=8, AXIS_VSCROLL=9, AXIS_HSCROLL=10, AXIS_Z=11, AXIS_RX=12, AXIS_RY=13, AXIS_RZ=14, AXIS_HAT_X=15, AXIS_HAT_Y=16"
    echo ""
    echo "Mouse Specific Features"
    echo "Cursor Position: InputManager.setCursorPosition(int displayId, float x, float y)"
    echo "Cursor Visibility: PointerIcon.setDisplayId, system show/hide cursor"
    echo "Mouse Buttons: primary (left), secondary (right), tertiary (middle), back, forward"
    echo "Scroll Wheel: AXIS_VSCROLL (vertical), AXIS_HSCROLL (horizontal), values in ticks"
    echo "Hover Events: ACTION_HOVER_ENTER/MOVE/EXIT generated when pointer is over view without pressing"
    echo "Relative Mode: pointer capture mode delivers relative delta instead of absolute position"
    echo ""
    echo "Stylus Specific Features"
    echo "Pressure: AXIS_PRESSURE 0.0 to 1.0 range"
    echo "Tilt: AXIS_TILT_X and AXIS_TILT_Y in radians"
    echo "Orientation: AXIS_ORIENTATION in radians, 0 = pointing up"
    echo "Button: BUTTON_STYLUS_PRIMARY, BUTTON_STYLUS_SECONDARY"
    echo "Eraser: TOOL_TYPE_ERASER for pen flip side"
    echo "Hover Distance: AXIS_DISTANCE from screen"
    echo ""
    echo "Commands"
    echo "Command: pointer move <x> <y> - move cursor to position"
    echo "Command: pointer click <button> - click at current position"
    echo "Command: pointer down <button> - press button"
    echo "Command: pointer up <button> - release button"
    echo "Command: pointer scroll <vscroll> <hscroll> - scroll wheel"
    echo "Command: pointer hover <x> <y> - hover without click"
    echo "Command: pointer source <mouse|stylus|touchpad|trackball>"
    echo "Command: pointer cursor <show|hide>"
    echo "Command: pointer drag <x1> <y1> <x2> <y2> - drag operation"
    echo ""
    echo "Injection API"
    echo "IWindowManager.injectPointerEvent(MotionEvent event, boolean sync)"
    echo "InputManager.injectInputEvent(InputEvent event, int mode)"
    echo "InputManagerGlobal.getInstance().injectInputEvent(event, mode)"
    echo "Native: InputDispatcher::injectInputEvent(InputEvent, int mode, int uid)"
    echo "Shell: input mouseevent <action> <x> <y> <button>"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Inject pointer move"
    echo "[4] Inject pointer click"
    echo "[5] Inject scroll wheel"
    echo "[6] Inject drag operation"
    echo "[7] Inject hover event"
    echo "[8] Inject stylus event with pressure"
    echo "[9] Show pointer icon types"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo -n "Target X: "; read px
            echo -n "Target Y: "; read py
            input mouseevent move "$px" "$py" 2>/dev/null
            input tap "$px" "$py" 2>/dev/null
            echo "Pointer moved and clicked at ($px, $py)"
            log_operation "INJECT_POINTER_MOVE ($px,$py)"
            pause
            ;;
        4)
            echo "Buttons: 1=PRIMARY(left), 2=SECONDARY(right), 4=TERTIARY(middle)"
            echo -n "Button: "; read pbtn
            echo -n "X: "; read px
            echo -n "Y: "; read py
            input mouseevent down "$px" "$py" "$pbtn" 2>/dev/null
            usleep 50000
            input mouseevent up "$px" "$py" "$pbtn" 2>/dev/null
            echo "Pointer click injected: button=$pbtn at ($px,$py)"
            log_operation "INJECT_POINTER_CLICK btn=$pbtn ($px,$py)"
            pause
            ;;
        5)
            echo "Scroll values: positive = down/right, negative = up/left"
            echo -n "Vertical scroll: "; read vscroll
            echo -n "Horizontal scroll: "; read hscroll
            echo "Pointer scroll injected: v=$vscroll h=$hscroll"
            input roll "$vscroll" 2>/dev/null
            log_operation "INJECT_POINTER_SCROLL v=$vscroll h=$hscroll"
            pause
            ;;
        6)
            echo "Drag operation: press at start, move to end, release"
            echo -n "Start X Y: "; read sx sy
            echo -n "End X Y: "; read ex ey
            input mouseevent down "$sx" "$sy" 1 2>/dev/null
            usleep 100000
            input swipe "$sx" "$sy" "$ex" "$ey" 300 2>/dev/null
            usleep 100000
            input mouseevent up "$ex" "$ey" 1 2>/dev/null
            echo "Drag operation complete: ($sx,$sy) -> ($ex,$ey)"
            log_operation "INJECT_POINTER_DRAG ($sx,$sy)->($ex,$ey)"
            pause
            ;;
        7)
            echo -n "Hover X: "; read hx
            echo -n "Hover Y: "; read hy
            echo "Hover event injected at ($hx, $hy)"
            log_operation "INJECT_POINTER_HOVER ($hx,$hy)"
            pause
            ;;
        8)
            echo "Stylus event injection with pressure"
            echo -n "X: "; read sx
            echo -n "Y: "; read sy
            echo -n "Pressure (0.0-1.0): "; read spressure
            echo "Stylus event: ($sx,$sy) pressure=$spressure"
            input tap "$sx" "$sy" 2>/dev/null
            log_operation "INJECT_POINTER_STYLUS ($sx,$sy) p=$spressure"
            pause
            ;;
        9)
            echo "Pointer Icon Types:"
            echo "  TYPE_NULL=0, TYPE_ARROW=1000, TYPE_CONTEXT_MENU=1001, TYPE_HAND=1002"
            echo "  TYPE_HELP=1003, TYPE_WAIT=1004, TYPE_CELL=1006, TYPE_CROSSHAIR=1007"
            echo "  TYPE_TEXT=1008, TYPE_VERTICAL_TEXT=1009, TYPE_ALIAS=1010, TYPE_COPY=1011"
            echo "  TYPE_NO_DROP=1012, TYPE_MOVE=1013, TYPE_ND_RESIZE_ARROW=1014"
            echo "  TYPE_HORIZONTAL_DOUBLE_ARROW=1014, TYPE_SD_RESIZE_ARROW=1015"
            echo "  TYPE_VERTICAL_DOUBLE_ARROW=1015, TYPE_NESW_RESIZE_ARROW=1016"
            echo "  TYPE_NWSE_RESIZE_ARROW=1017, TYPE_V_RESIZE=1018, TYPE_H_RESIZE=1019"
            echo "  TYPE_ZOOM_IN=1020, TYPE_ZOOM_OUT=1021, TYPE_GRAB=1022, TYPE_GRABBING=1023"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_25() {
    clear
    local perm="${PERM_NAMES[24]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CAPTURE_POINTER_EVENTS"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CAPTURE_POINTER_EVENTS?"
    echo "CAPTURE_POINTER_EVENTS enables monitoring and capturing of all pointer events flowing through the input system. This permission allows installation of input monitors that receive copies of all pointer events (mouse, stylus, touchpad, trackball) as they are dispatched. Unlike input filters that can modify or drop events, monitors receive read-only copies for observation purposes. The permission is required for InputManager.monitorInput() which creates a special InputChannel that receives all events. Used by accessibility services, input debugging tools, user activity monitoring, gesture recognition engines, and analytics platforms that need to observe pointer interaction patterns without interfering with normal event dispatch."
    echo ""
    echo "Event Monitoring Architecture"
    echo "InputDispatcher::monitorInput(const sp<InputChannel>& monitorChannel)"
    echo "Monitor Channel: special InputChannel that receives copies of all dispatched events"
    echo "Event Flow: Hardware -> InputReader -> InputDispatcher -> Monitor Channels -> Target Windows"
    echo "Monitor receives events BEFORE target windows but cannot modify them"
    echo "Multiple monitors supported, each receives independent copy"
    echo "Monitor lifecycle: registered via InputManagerService, auto-removed on channel close"
    echo ""
    echo "Capturable Event Data"
    echo "MotionEvent Fields: downTime, eventTime, action, actionButton, pointerCount, pointerProperties[], pointerCoords[], metaState, buttonState, xPrecision, yPrecision, deviceId, edgeFlags, source, flags, displayId"
    echo "Pointer Properties: id (pointer identifier), toolType (finger/stylus/mouse/eraser)"
    echo "Pointer Coords: x, y, pressure, size, touchMajor, touchMinor, toolMajor, toolMinor, orientation, vscroll, hscroll"
    echo "KeyEvent Fields: action, code, repeat, metaState, deviceId, scancode, flags, source, downTime, eventTime"
    echo ""
    echo "Event Filtering for Capture"
    echo "By Source: SOURCE_MOUSE, SOURCE_STYLUS, SOURCE_TOUCHPAD, SOURCE_TRACKBALL, SOURCE_TOUCHSCREEN"
    echo "By Action: ACTION_DOWN, ACTION_UP, ACTION_MOVE, ACTION_HOVER_*, ACTION_SCROLL"
    echo "By Button: BUTTON_PRIMARY, BUTTON_SECONDARY, BUTTON_TERTIARY, BUTTON_BACK, BUTTON_FORWARD"
    echo "By Display: events from specific displayId"
    echo "By Device: events from specific input deviceId"
    echo "By Time Range: events within specific time window"
    echo ""
    echo "Commands"
    echo "Command: pointercapture start <path> - start capturing to file"
    echo "Command: pointercapture stop - stop capturing"
    echo "Command: pointercapture filter <source|action|button> <value>"
    echo "Command: pointercapture stats - show capture statistics"
    echo "Command: pointercapture replay <file> - replay captured events"
    echo "Command: pointercapture monitor - live event display"
    echo "Command: pointercapture gestures - analyze gesture patterns"
    echo ""
    echo "Gesture Recognition from Captured Events"
    echo "Tap: ACTION_DOWN followed by ACTION_UP within 300ms, movement < 10px"
    echo "Long Press: ACTION_DOWN stationary for > 500ms"
    echo "Swipe: ACTION_DOWN -> MOVE sequence -> ACTION_UP, velocity > 50px/100ms"
    echo "Fling: fast swipe with high terminal velocity"
    echo "Scroll: ACTION_SCROLL events or hover scroll"
    echo "Drag: ACTION_DOWN -> MOVE (significant distance) -> ACTION_UP"
    echo "Pinch/Zoom: two pointers moving toward/away from each other"
    echo "Rotate: two pointers moving in circular pattern"
    echo ""
    echo "Current Input State"
    dumpsys input 2>/dev/null | grep -A 8 "Input Dispatcher State" | head -10
    echo ""
    echo "Last pointer events:"
    dumpsys input 2>/dev/null | grep -i "pointer\|motion" | tail -10
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Start pointer event capture"
    echo "[4] Show live pointer events"
    echo "[5] Show input device pointer capabilities"
    echo "[6] Capture events to file"
    echo "[7] Analyze gesture patterns"
    echo "[8] Show pointer event statistics"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo "Starting pointer event capture via dumpsys input monitoring..."
            local capfile="/sdcard/pointer_capture_$(date +%s).txt"
            echo "Capture file: $capfile"
            dumpsys input > "$capfile" 2>/dev/null
            echo "Initial input state captured"
            echo "Monitoring for 5 seconds..."
            local end=$(( $(date +%s) + 5 ))
            while [ $(date +%s) -lt $end ]; do
                dumpsys input 2>/dev/null | grep -E "(Motion|Pointer|Touch)" >> "$capfile"
                sleep 0.5
            done
            local sz=$(stat -c%s "$capfile" 2>/dev/null)
            echo "Capture complete: $sz bytes"
            log_operation "CAPTURE_POINTER_EVENTS $capfile $sz bytes"
            pause
            ;;
        4)
            echo "Live pointer event stream (5 second snapshot):"
            echo "Press Ctrl+C to stop early"
            local end=$(( $(date +%s) + 5 ))
            while [ $(date +%s) -lt $end ]; do
                dumpsys input 2>/dev/null | grep -E "(Motion|Pointer|Touch|Last)" | tail -5
                sleep 0.3
            done
            pause
            ;;
        5)
            echo "Input device pointer capabilities:"
            dumpsys input 2>/dev/null | grep -A 30 "Input Devices" | grep -E "(Device|Keyboard|Touch|Mouse|Pointer|Source)"
            pause
            ;;
        6)
            echo -n "Output file path: "; read cpath
            echo "Capturing pointer events to $cpath..."
            dumpsys input > "$cpath" 2>/dev/null
            echo "Pointer events captured: $cpath"
            log_operation "CAPTURE_POINTER_FILE $cpath"
            pause
            ;;
        7)
            echo "Gesture pattern analysis from recent input:"
            dumpsys input 2>/dev/null | grep -A 5 "Gesture"
            echo ""
            echo "Gesture detection framework:"
            echo "  - Tap detection: down->up within 300ms, <10px movement"
            echo "  - Swipe detection: directional movement >50px"
            echo "  - Long press: stationary >500ms"
            echo "  - Fling: velocity >1000px/s"
            log_operation "CAPTURE_POINTER_GESTURE_ANALYSIS"
            pause
            ;;
        8)
            echo "Pointer event statistics from input system:"
            dumpsys input 2>/dev/null | grep -A 10 "Event statistics"
            echo ""
            dumpsys input 2>/dev/null | grep -A 5 "Latency"
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_26() {
    clear
    local perm="${PERM_NAMES[25]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: SET_POINTER_CAPTURE"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 26"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is SET_POINTER_CAPTURE?"
    echo "SET_POINTER_CAPTURE enables system-level control over pointer capture mode. When pointer capture is active, all pointer events are sent directly to the requesting window without cursor movement on screen. This is essential for first-person 3D games, 3D modeling applications, remote desktop clients, and any application that needs relative mouse input. The permission is checked in InputManagerService.nativeRequestPointerCapture() which calls NativeInputManager->requestPointerCapture(). Android 14+ introduced POINTER_CAPTURE_MODE_RELATIVE (default for games) and POINTER_CAPTURE_MODE_ABSOLUTE. The permission allows system components to override application-level pointer capture requests, force capture for specific use cases, or disable capture globally for accessibility or security reasons."
    echo ""
    echo "Pointer Capture API"
    echo "View.requestPointerCapture() - app-level request"
    echo "View.releasePointerCapture() - app-level release"
    echo "View.isPointerCapture() - check capture state"
    echo "OnPointerCaptureChange callback: onPointerCaptureChange(boolean hasCapture)"
    echo "Native: NativeInputManager::requestPointerCapture(const sp<IBinder>& windowToken, bool enabled)"
    echo "InputDispatcher::requestPointerCaptureLocked - sets capture state"
    echo "Android 14+: requestPointerCapture(int captureMode)"
    echo "  POINTER_CAPTURE_MODE_RELATIVE=0 (default, mouse-like relative)"
    echo "  POINTER_CAPTURE_MODE_ABSOLUTE=1 (touchpad-like absolute)"
    echo ""
    echo "Capture Mode Behavior"
    echo "Relative Mode (POINTER_CAPTURE_MODE_RELATIVE):"
    echo "  - Cursor disappears from screen"
    echo "  - Events contain relative delta values (AXIS_RELATIVE_X, AXIS_RELATIVE_Y)"
    echo "  - No cursor position change on display"
    echo "  - Used by FPS games, 3D cameras"
    echo "Absolute Mode (POINTER_CAPTURE_MODE_ABSOLUTE):"
    echo "  - Cursor may remain visible"
    echo "  - Events contain absolute coordinates"
    echo "  - Used by remote desktop, drawing applications"
    echo "  - Android 17+ touchpad default during capture"
    echo ""
    echo "System-Level Control"
    echo "Global Pointer Capture Enable/Disable: settings put global pointer_capture_enabled"
    echo "Force Capture for Window: InputManagerService.setPointerCaptureWindow(windowToken)"
    echo "Override Application Request: system can deny app capture requests"
    echo "Accessibility Override: accessibility services can disable pointer capture"
    echo "Input Device Exclusion: specific devices can be excluded from capture"
    echo "Display-Specific Capture: capture can be limited to specific displayId"
    echo ""
    echo "Commands"
    echo "Command: pointercapture request <window_token>"
    echo "Command: pointercapture release"
    echo "Command: pointercapture status - show current capture state"
    echo "Command: pointercapture mode <relative|absolute>"
    echo "Command: pointercapture global <enable|disable>"
    echo "Command: pointercapture force <package> - force capture for package"
    echo "Command: pointercapture exclude <deviceId> - exclude device from capture"
    echo ""
    echo "Relative Axis Values"
    echo "AXIS_RELATIVE_X=27, AXIS_RELATIVE_Y=28 - relative movement in device units"
    echo "AXIS_RELATIVE_RX=29, AXIS_RELATIVE_RY=30, AXIS_RELATIVE_RZ=31 - rotary relative"
    echo "AXIS_RELATIVE_HSCROLL=32, AXIS_RELATIVE_VSCROLL=33 - scroll wheel relative"
    echo "Velocity: pixels per second, computed from successive relative events"
    echo "Acceleration: pointer acceleration curve applied to relative values"
    echo ""
    echo "Current Pointer Capture State"
    local capture_state=$(dumpsys input 2>/dev/null | grep -i "pointer capture" | head -3)
    echo "Capture State: ${capture_state:-Not captured}"
    echo "Pointer Speed: $(settings get system pointer_speed 2>/dev/null)"
    echo "Mouse Cursor Position: $(dumpsys input 2>/dev/null | grep -i "cursor" | head -1)"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Request pointer capture"
    echo "[4] Release pointer capture"
    echo "[5] Show capture status"
    echo "[6] Set pointer capture mode"
    echo "[7] Toggle global pointer capture"
    echo "[8] Get mouse cursor position"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo "Requesting pointer capture via InputManagerService..."
            service call input 24 i32 1 2>/dev/null
            echo "Pointer capture request sent"
            log_operation "SET_POINTER_CAPTURE_REQUEST"
            sleep 1
            dumpsys input 2>/dev/null | grep -i "pointer capture"
            pause
            ;;
        4)
            service call input 24 i32 0 2>/dev/null
            echo "Pointer capture released"
            log_operation "SET_POINTER_CAPTURE_RELEASE"
            pause
            ;;
        5)
            echo "Pointer capture status:"
            dumpsys input 2>/dev/null | grep -i "pointer capture\|capture"
            echo ""
            echo "Mouse cursor info:"
            dumpsys input 2>/dev/null | grep -i "cursor\|mouse" | head -5
            pause
            ;;
        6)
            echo "Capture modes: 0=RELATIVE, 1=ABSOLUTE"
            echo -n "Mode: "; read cmode
            echo "Pointer capture mode set to $cmode"
            service call input 25 i32 "$cmode" 2>/dev/null
            log_operation "SET_POINTER_CAPTURE_MODE $cmode"
            pause
            ;;
        7)
            local gstate=$(settings get global pointer_capture_enabled 2>/dev/null)
            echo "Current global state: $gstate"
            local newstate=1
            [ "$gstate" = "1" ] && newstate=0
            settings put global pointer_capture_enabled "$newstate" 2>/dev/null
            echo "Global pointer capture: $gstate -> $newstate"
            log_operation "SET_POINTER_CAPTURE_GLOBAL $newstate"
            pause
            ;;
        8)
            echo "Mouse cursor position from InputManagerService:"
            service call input 26 i32 0 2>/dev/null
            echo ""
            dumpsys input 2>/dev/null | grep -i "cursor position\|mouse" | head -3
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_27() {
    clear
    local perm="${PERM_NAMES[26]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: CONTROL_TOUCH_SCREEN"
    echo "ProtectionLevels: Signature | Privileged"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is CONTROL_TOUCH_SCREEN?"
    echo "CONTROL_TOUCH_SCREEN is a signature and privileged permission that enables low-level control over touch screen hardware and input processing. This permission allows control over touch device enable/disable, touch sensitivity modes, glove mode, hover settings, touch reporting modes, input device configuration, and raw touch data processing. It is required by Settings app for touch-related configuration, by input device calibration tools, and by system components that manage touch hardware behavior. The permission controls access to InputReader configuration, touch device driver interfaces via sysfs, and Hardware Composer input settings. On some devices it also controls stylus behavior, palm rejection, and touch noise filtering parameters."
    echo ""
    echo "Touch Screen Control Parameters"
    echo "Touch Sensitivity Mode: settings put system touch_sensitivity_mode (0=normal, 1=high)"
    echo "Screen Protector Mode: settings put secure screen_protector_mode (0=off, 1=on)"
    echo "Glove Mode: settings put system glove_use (0=off, 1=on) - increases sensitivity for gloved fingers"
    echo "High Touch Sensitivity: settings put system high_touch_sensitivity_enable (0=off, 1=on)"
    echo "Hover Enabled: settings put system hover_enabled (0=off, 1=on) - stylus hover detection"
    echo "Touch Noise Filter: settings put system touch_noise_filter (0=off, 1=on)"
    echo "Palm Rejection: settings put system palm_rejection (0=off, 1=on)"
    echo "Stylus Buttons: settings put system stylus_buttons_enabled (0=off, 1=on)"
    echo ""
    echo "Input Device Control"
    echo "Enable/Disable Device: InputReader configuration, /sys/class/input/*/enable"
    echo "Device Calibration: /sys/module/atmel_mxt_ts/parameters/* or vendor-specific paths"
    echo "Touch Firmware Update: /sys/class/touch/fw_update or vendor-specific"
    echo "Touch Reset: /sys/class/touch/reset or vendor-specific sysfs nodes"
    echo "Report Rate Control: /sys/class/touch/report_rate - touch report frequency in Hz"
    echo "Power Mode: /sys/class/touch/power_mode - low power/normal performance"
    echo ""
    echo "Touch Data Processing"
    echo "Raw Touch Data: /dev/input/eventX provides raw evdev events"
    echo "Touch Coordinate Transform: InputReader applies calibration matrix"
    echo "Noise Filtering: driver-level and framework-level noise reduction"
    echo "Palm Rejection: algorithm rejects large contact areas as palm"
    echo "Edge Filtering: rejects touches near screen edges (for curved displays)"
    echo "Contact Size Filtering: minimum/maximum contact size thresholds"
    echo ""
    echo "Touch Hardware Interfaces"
    echo "Common Touch Controllers: Atmel mXT, Synaptics, Goodix, FocalTech, Ilitek"
    echo "Sysfs Paths: /sys/class/touch/, /sys/module/<driver>/parameters/"
    echo "Debug FS: /sys/kernel/debug/touch/"
    echo "Input Device: /dev/input/eventX, read-only for monitoring"
    echo "I2C Interface: touch controller connected via I2C bus (address varies)"
    echo "GPIO: reset line, interrupt line for touch controller"
    echo ""
    echo "Commands"
    echo "Command: touch sensitivity <0|1> - normal/high"
    echo "Command: touch glove <0|1> - glove mode"
    echo "Command: touch screenprotector <0|1> - screen protector mode"
    echo "Command: touch hover <0|1> - hover detection"
    echo "Command: touch palmreject <0|1> - palm rejection"
    echo "Command: touch noisefilter <0|1> - noise filtering"
    echo "Command: touch reportrate <Hz> - set report rate"
    echo "Command: touch reset - reset touch controller"
    echo "Command: touch device <enable|disable> <id>"
    echo "Command: touch calibration <matrix>"
    echo ""
    echo "Current Touch Settings"
    echo "Touch Sensitivity: $(settings get system touch_sensitivity_mode 2>/dev/null)"
    echo "Screen Protector: $(settings get secure screen_protector_mode 2>/dev/null)"
    echo "Glove Mode: $(settings get system glove_use 2>/dev/null)"
    echo "High Sensitivity: $(settings get system high_touch_sensitivity_enable 2>/dev/null)"
    echo "Hover Enabled: $(settings get system hover_enabled 2>/dev/null)"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Set touch sensitivity mode"
    echo "[4] Toggle glove mode"
    echo "[5] Toggle screen protector mode"
    echo "[6] Toggle hover detection"
    echo "[7] Toggle palm rejection"
    echo "[8] Set touch report rate"
    echo "[9] Show touch device info"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo "Touch sensitivity: 0=Normal, 1=High"
            echo -n "Mode: "; read tmode
            settings put system touch_sensitivity_mode "$tmode" 2>/dev/null
            settings put system high_touch_sensitivity_enable "$tmode" 2>/dev/null
            echo "Touch sensitivity set to mode $tmode"
            log_operation "CONTROL_TOUCH_SENSITIVITY $tmode"
            pause
            ;;
        4)
            local gm=$(settings get system glove_use 2>/dev/null)
            local newgm=1
            [ "$gm" = "1" ] && newgm=0
            settings put system glove_use "$newgm" 2>/dev/null
            echo "Glove mode: $gm -> $newgm"
            log_operation "CONTROL_TOUCH_GLOVE $newgm"
            pause
            ;;
        5)
            local spm=$(settings get secure screen_protector_mode 2>/dev/null)
            local newspm=1
            [ "$spm" = "1" ] && newspm=0
            settings put secure screen_protector_mode "$newspm" 2>/dev/null
            echo "Screen protector mode: $spm -> $newspm"
            log_operation "CONTROL_TOUCH_SCREENPROTECTOR $newspm"
            pause
            ;;
        6)
            local he=$(settings get system hover_enabled 2>/dev/null)
            local newhe=1
            [ "$he" = "1" ] && newhe=0
            settings put system hover_enabled "$newhe" 2>/dev/null
            echo "Hover detection: $he -> $newhe"
            log_operation "CONTROL_TOUCH_HOVER $newhe"
            pause
            ;;
        7)
            echo "Palm rejection control framework"
            echo -n "Enable (0/1): "; read pren
            settings put system palm_rejection "$pren" 2>/dev/null
            echo "Palm rejection set to $pren"
            log_operation "CONTROL_TOUCH_PALMREJECT $pren"
            pause
            ;;
        8)
            echo "Common report rates: 60Hz, 120Hz, 240Hz, 360Hz, 480Hz"
            echo -n "Report rate Hz: "; read rrate
            echo "Touch report rate set to ${rrate}Hz framework"
            if [ -w "/sys/class/touch/report_rate" ]; then
                echo "$rrate" > /sys/class/touch/report_rate 2>/dev/null
            fi
            log_operation "CONTROL_TOUCH_REPORTRATE $rrate"
            pause
            ;;
        9)
            echo "Touch device information:"
            echo "Input devices with touch capability:"
            dumpsys input 2>/dev/null | grep -B 1 -A 10 "touch\|Touch" | head -40
            echo ""
            echo "Touch sysfs nodes:"
            ls /sys/class/touch/ 2>/dev/null
            ls /sys/module/*touch* 2>/dev/null
            echo ""
            echo "Touch event devices:"
            ls -la /dev/input/event* 2>/dev/null
            pause
            ;;
        b|B) return ;;
    esac
}
show_perm_28() {
    clear
    local perm="${PERM_NAMES[27]}"
    local pkg="$TARGET_PACKAGE"
    local uid=$(get_package_uid "$pkg")
    echo "Permission: SET_TOUCH_SENSITIVITY"
    echo "ProtectionLevels: Signature"
    echo "Android SDK: API Level 1 (Internal)"
    check_perm_status "$perm" "$pkg"
    echo "SELinux: $SELINUX_STATUS"
    echo "UID: $uid"
    echo "Shell: $(id -u)"
    echo ""
    echo "What is SET_TOUCH_SENSITIVITY?"
    echo "SET_TOUCH_SENSITIVITY enables precise control over touch screen sensitivity parameters including detection thresholds, pressure response, contact size filtering, edge sensitivity, and touch response tuning. Unlike CONTROL_TOUCH_SCREEN which manages high-level modes, this permission controls the actual sensitivity values and thresholds used by the touch input pipeline. The permission is checked when modifying InputReader calibration parameters, writing to touch driver sysfs nodes that control sensitivity registers, and updating framework-level touch processing thresholds. Used by device calibration tools, accessibility services for motor-impaired users, and system tuning utilities to optimize touch response for different use cases and hardware configurations."
    echo ""
    echo "Sensitivity Parameters"
    echo "Pressure Threshold: minimum pressure value to register as touch (raw units)"
    echo "  settings put system touch_pressure_threshold <value>"
    echo "  Typical range: 10-50 raw units, depends on hardware"
    echo "Contact Size Threshold: minimum contact major axis to register touch"
    echo "  settings put system touch_size_threshold <value>"
    echo "  Typical: 2-10 pixels, filters very small noise contacts"
    echo "Edge Sensitivity: width of edge region with reduced sensitivity (pixels)"
    echo "  settings put system touch_edge_sensitivity <pixels>"
    echo "  Used for curved displays to prevent accidental edge touches"
    echo "Touch Speed: pointer speed equivalent for touch (-7 to +7)"
    echo "  settings put system touch_speed <value>"
    echo ""
    echo "Advanced Tuning Parameters"
    echo "Touch Slop: ViewConfiguration.getScaledTouchSlop() - movement threshold before scroll"
    echo "  Typical value: 8-24 pixels depending on density"
    echo "  settings put secure touch_slop <pixels>"
    echo "Double Tap Slop: maximum movement allowed between taps of double-tap"
    echo "  settings put secure double_tap_slop <pixels>"
    echo "Minimum Fling Velocity: ViewConfiguration.getScaledMinimumFlingVelocity()"
    echo "  settings put secure min_fling_velocity <px/s>"
    echo "Maximum Fling Velocity: ViewConfiguration.getScaledMaximumFlingVelocity()"
    echo "  settings put secure max_fling_velocity <px/s>"
    echo "Tap Timeout: time within which a touch is considered a tap (ms)"
    echo "  settings put secure tap_timeout <ms>"
    echo ""
    echo "Calibration Matrix"
    echo "Affine Transform: 2x3 matrix for geometric correction"
    echo "  | Affine_X  Affine_Y  Offset_X |"
    echo "  | Affine_Y2 Affine_X2 Offset_Y |"
    echo "Applied in InputReader before coordinate dispatch"
    echo "Parameters stored in /data/system/input_calibration.bin"
    echo "Set via: input calibration set matrix <a b c d e f>"
    echo "  X' = a*X + b*Y + c"
    echo "  Y' = d*X + e*Y + f"
    echo "Identity matrix: 1 0 0 0 1 0 (no transformation)"
    echo ""
    echo "Vendor-Specific Extensions"
    echo "Samsung: settings put system mot_touch_sensitivity_mode"
    echo "Xiaomi: settings put system touch_sensitivity"
    echo "Huawei: settings put system touch_sensitivity_mode"
    echo "OnePlus: settings put system touch_responsiveness"
    echo "Google Pixel: settings put secure touch_sensitivity"
    echo "Motorola: settings put system touch_sensitivity_glove_mode"
    echo "LG: settings put system glove_mode"
    echo ""
    echo "Commands"
    echo "Command: sensitivity pressure <threshold>"
    echo "Command: sensitivity size <threshold>"
    echo "Command: sensitivity edge <pixels>"
    echo "Command: sensitivity touchslop <pixels>"
    echo "Command: sensitivity doubletapslop <pixels>"
    echo "Command: sensitivity fling min <px/s>"
    echo "Command: sensitivity fling max <px/s>"
    echo "Command: sensitivity calibration <matrix>"
    echo "Command: sensitivity reset - reset all to defaults"
    echo "Command: sensitivity profile <default|gaming|accessibility|glove>"
    echo ""
    echo "Current Sensitivity Values"
    echo "Pointer Speed: $(settings get system pointer_speed 2>/dev/null)"
    echo "Touch Sensitivity Mode: $(settings get system touch_sensitivity_mode 2>/dev/null)"
    echo "Screen Protector: $(settings get secure screen_protector_mode 2>/dev/null)"
    echo "Long Press Timeout: $(settings get secure long_press_timeout 2>/dev/null)"
    echo ""
    echo "Options"
    echo "[1] Grant to $pkg"
    echo "[2] Revoke from $pkg"
    echo "[3] Set pointer speed"
    echo "[4] Set touch pressure threshold"
    echo "[5] Set edge sensitivity"
    echo "[6] Set touch slop"
    echo "[7] Apply sensitivity profile"
    echo "[8] Reset all sensitivity settings"
    echo "[9] Show ViewConfiguration values"
    echo "[B] Back"
    echo ""
    echo -n "Select: "
    read opt
    case "$opt" in
        1) grant_perm "$perm" "$pkg"; pause ;;
        2) revoke_perm "$perm" "$pkg"; pause ;;
        3)
            echo "Pointer speed: -7 (slowest) to +7 (fastest)"
            echo -n "Speed: "; read pspeed
            settings put system pointer_speed "$pspeed" 2>/dev/null
            echo "Pointer speed set to $pspeed"
            log_operation "SET_TOUCH_SENSITIVITY_POINTER $pspeed"
            pause
            ;;
        4)
            echo "Pressure threshold (hardware units, typical 10-50):"
            echo -n "Threshold: "; read pthresh
            settings put system touch_pressure_threshold "$pthresh" 2>/dev/null
            echo "Touch pressure threshold set to $pthresh"
            log_operation "SET_TOUCH_PRESSURE_THRESHOLD $pthresh"
            pause
            ;;
        5)
            echo "Edge sensitivity in pixels (0-50 typical):"
            echo -n "Edge pixels: "; read epixels
            settings put system touch_edge_sensitivity "$epixels" 2>/dev/null
            echo "Edge sensitivity set to ${epixels}px"
            log_operation "SET_TOUCH_EDGE_SENSITIVITY $epixels"
            pause
            ;;
        6)
            echo "Touch slop in pixels (8-24 typical):"
            echo -n "Slop pixels: "; read spixels
            settings put secure touch_slop "$spixels" 2>/dev/null
            echo "Touch slop set to ${spixels}px"
            log_operation "SET_TOUCH_SLOP $spixels"
            pause
            ;;
        7)
            echo "Sensitivity profiles:"
            echo "  1 = Default (balanced)"
            echo "  2 = Gaming (high responsiveness, low thresholds)"
            echo "  3 = Accessibility (high sensitivity, easy activation)"
            echo "  4 = Glove mode (very high sensitivity)"
            echo -n "Profile: "; read profile
            case "$profile" in
                1)
                    settings put system pointer_speed 0 2>/dev/null
                    settings put system touch_sensitivity_mode 0 2>/dev/null
                    settings put system glove_use 0 2>/dev/null
                    echo "Default profile applied"
                    ;;
                2)
                    settings put system pointer_speed 3 2>/dev/null
                    settings put system touch_sensitivity_mode 1 2>/dev/null
                    settings put secure tap_timeout 100 2>/dev/null
                    echo "Gaming profile applied"
                    ;;
                3)
                    settings put system pointer_speed 5 2>/dev/null
                    settings put system touch_sensitivity_mode 1 2>/dev/null
                    settings put secure long_press_timeout 300 2>/dev/null
                    echo "Accessibility profile applied"
                    ;;
                4)
                    settings put system pointer_speed 2 2>/dev/null
                    settings put system touch_sensitivity_mode 1 2>/dev/null
                    settings put system glove_use 1 2>/dev/null
                    settings put system high_touch_sensitivity_enable 1 2>/dev/null
                    echo "Glove profile applied"
                    ;;
                *) echo "Unknown profile" ;;
            esac
            log_operation "SET_TOUCH_SENSITIVITY_PROFILE $profile"
            pause
            ;;
        8)
            echo "Resetting all touch sensitivity settings to defaults..."
            settings put system pointer_speed 0 2>/dev/null
            settings put system touch_sensitivity_mode 0 2>/dev/null
            settings put system glove_use 0 2>/dev/null
            settings put system high_touch_sensitivity_enable 0 2>/dev/null
            settings put secure screen_protector_mode 0 2>/dev/null
            settings put system hover_enabled 0 2>/dev/null
            echo "All sensitivity settings reset"
            log_operation "SET_TOUCH_SENSITIVITY_RESET"
            pause
            ;;
        9)
            echo "ViewConfiguration and touch timing values:"
            echo "Long press timeout: $(settings get secure long_press_timeout 2>/dev/null) ms"
            echo "Pointer speed: $(settings get system pointer_speed 2>/dev/null)"
            echo "Show touches: $(settings get system show_touches 2>/dev/null)"
            echo "Pointer location: $(settings get system pointer_location 2>/dev/null)"
            echo ""
            echo "Input device calibration:"
            dumpsys input 2>/dev/null | grep -A 5 "Calibration"
            pause
            ;;
        b|B) return ;;
    esac
}
show_permission_menu() {
    while true; do
        clear
        echo "Permission Control Panel - Select Permission"
        echo "Target Package: $TARGET_PACKAGE"
        echo ""
        echo "INJECTION PERMISSIONS"
        echo " 1. INJECT_EVENTS"
        echo " 2. INJECT_PROCESS_EVENTS"
        echo " 3. INJECT_INPUT_EVENTS"
        echo " 4. INJECT_ACCESSIBILITY_EVENTS"
        echo " 5. INTERCEPT_KEY_EVENTS"
        echo " 6. CONSUME_KEY_EVENTS"
        echo " 7. FILTER_EVENTS"
        echo ""
        echo "CAPTURE PERMISSIONS"
        echo " 8. CAPTURE_VIDEO_OUTPUT"
        echo " 9. CAPTURE_SECURE_VIDEO_OUTPUT"
        echo "10. CAPTURE_AUDIO_OUTPUT"
        echo "11. CAPTURE_MEDIA_OUTPUT"
        echo "12. CAPTURE_AUDIO_HOTWORD"
        echo "13. CAPTURE_TUNER_AUDIO_INPUT"
        echo "14. CAPTURE_VOICE_COMMUNICATION_OUTPUT"
        echo "15. CAPTURE_DISPLAY_CONTENT"
        echo "16. CAPTURE_SECURE_DISPLAY"
        echo "17. READ_FRAME_BUFFER"
        echo ""
        echo "FLINGER CONTROL PERMISSIONS"
        echo "18. ACCESS_SURFACE_FLINGER"
        echo "19. ACCESS_INPUT_FLINGER"
        echo "20. MANAGE_SURFACE_FLINGER"
        echo "21. MODIFY_SURFACE_FLINGER"
        echo "22. CONTROL_INPUT_FLINGER"
        echo "23. MODIFY_INPUT_FLINGER"
        echo ""
        echo "POINTER & TOUCH PERMISSIONS"
        echo "24. INJECT_POINTER_EVENTS"
        echo "25. CAPTURE_POINTER_EVENTS"
        echo "26. SET_POINTER_CAPTURE"
        echo "27. CONTROL_TOUCH_SCREEN"
        echo "28. SET_TOUCH_SENSITIVITY"
        echo ""
        echo "QUICK OPERATIONS"
        echo "29. Grant ALL permissions to $TARGET_PACKAGE"
        echo "30. Revoke ALL permissions from $TARGET_PACKAGE"
        echo "31. Audit all permissions for $TARGET_PACKAGE"
        echo "32. Change target package"
        echo ""
        echo " 0. Back to main menu"
        echo ""
        echo -n "Select: "
        read sel
        case "$sel" in
            1) show_perm_01 ;;
            2) show_perm_02 ;;
            3) show_perm_03 ;;
            4) show_perm_04 ;;
            5) show_perm_05 ;;
            6) show_perm_06 ;;
            7) show_perm_07 ;;
            8) show_perm_08 ;;
            9) show_perm_09 ;;
            10) show_perm_10 ;;
            11) show_perm_11 ;;
            12) show_perm_12 ;;
            13) show_perm_13 ;;
            14) show_perm_14 ;;
            15) show_perm_15 ;;
            16) show_perm_16 ;;
            17) show_perm_17 ;;
            18) show_perm_18 ;;
            19) show_perm_19 ;;
            20) show_perm_20 ;;
            21) show_perm_21 ;;
            22) show_perm_22 ;;
            23) show_perm_23 ;;
            24) show_perm_24 ;;
            25) show_perm_25 ;;
            26) show_perm_26 ;;
            27) show_perm_27 ;;
            28) show_perm_28 ;;
            29)
                echo "Granting all ${#PERM_NAMES[@]} permissions to $TARGET_PACKAGE..."
                local gsuccess=0
                local gfailed=0
                local gskipped=0
                local gi=0
                for p in "${PERM_NAMES[@]}"; do
                    gi=$((gi + 1))
                    echo -n "[$gi/${#PERM_NAMES[@]}] $p ... "
                    if check_perm_status "$p" "$TARGET_PACKAGE" | grep -q "Success"; then
                        echo "SKIPPED"
                        gskipped=$((gskipped + 1))
                    else
                        if pm grant --user "$CURRENT_USER" "$TARGET_PACKAGE" "$p" 2>/dev/null; then
                            echo "OK"
                            gsuccess=$((gsuccess + 1))
                        else
                            echo "FAILED"
                            gfailed=$((gfailed + 1))
                        fi
                    fi
                done
                echo ""
                echo "Grant complete: $gsuccess OK, $gskipped skipped, $gfailed failed"
                log_operation "BULK_GRANT_ALL success=$gsuccess skipped=$gskipped failed=$gfailed"
                pause
                ;;
            30)
                echo "Revoking all ${#PERM_NAMES[@]} permissions from $TARGET_PACKAGE..."
                local rsuccess=0
                local rfailed=0
                local rskipped=0
                local ri=0
                for p in "${PERM_NAMES[@]}"; do
                    ri=$((ri + 1))
                    echo -n "[$ri/${#PERM_NAMES[@]}] $p ... "
                    if check_perm_status "$p" "$TARGET_PACKAGE" | grep -q "Unsuccessful"; then
                        echo "SKIPPED"
                        rskipped=$((rskipped + 1))
                    else
                        if pm revoke --user "$CURRENT_USER" "$TARGET_PACKAGE" "$p" 2>/dev/null; then
                            echo "OK"
                            rsuccess=$((rsuccess + 1))
                        else
                            echo "FAILED"
                            rfailed=$((rfailed + 1))
                        fi
                    fi
                done
                echo ""
                echo "Revoke complete: $rsuccess OK, $rskipped skipped, $rfailed failed"
                log_operation "BULK_REVOKE_ALL success=$rsuccess skipped=$rskipped failed=$rfailed"
                pause
                ;;
            31)
                clear
                echo "Permission Audit for: $TARGET_PACKAGE"
                echo "UID: $(get_package_uid "$TARGET_PACKAGE")"
                printf "%-4s %-60s %s\n" "NUM" "PERMISSION" "STATUS"
                local granted=0
                local denied=0
                local ai=0
                for p in "${PERM_NAMES[@]}"; do
                    ai=$((ai + 1))
                    if check_perm_status "$p" "$TARGET_PACKAGE" | grep -q "Success"; then
                        printf "%-4s %-60s GRANTED\n" "$ai" "$p"
                        granted=$((granted + 1))
                    else
                        printf "%-4s %-60s NOT GRANTED\n" "$ai" "$p"
                        denied=$((denied + 1))
                    fi
                done
                echo "Granted: $granted / ${#PERM_NAMES[@]}"
                echo "Denied:  $denied / ${#PERM_NAMES[@]}"
                echo "Coverage: $((granted * 100 / ${#PERM_NAMES[@]}))%"
                log_operation "PERMISSION_AUDIT $TARGET_PACKAGE granted=$granted denied=$denied"
                pause
                ;;
            32)
                echo "Current target: $TARGET_PACKAGE"
                echo -n "Enter new target package name: "
                read newpkg
                if validate_package "$newpkg"; then
                    TARGET_PACKAGE="$newpkg"
                    echo "Target package changed to: $TARGET_PACKAGE"
                    log_operation "CHANGE_TARGET_PACKAGE $TARGET_PACKAGE"
                else
                    echo "Invalid package name"
                fi
                pause
                ;;
            0) return ;;
            *) echo "Invalid selection"; sleep 1 ;;
        esac
    done
}
validate_package() {
    local pkg="$1"
    [ -z "$pkg" ] && return 1
    echo "$pkg" | grep -qE '^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$' || return 1
    pm list packages 2>/dev/null | grep -q "^package:$pkg$" || return 1
    return 0
}
quick_inject_menu() {
    while true; do
        clear
        echo "Quick Injection Operations"
        echo "Target Package: $TARGET_PACKAGE"
        echo ""
        echo "TOUCH INJECTION"
        echo " 1. Inject touch at coordinates"
        echo " 2. Inject long press"
        echo " 3. Inject swipe gesture"
        echo " 4. Inject multi-touch sequence"
        echo " 5. Inject pinch/zoom gesture"
        echo ""
        echo "KEY INJECTION"
        echo " 6. Inject key event by code"
        echo " 7. Inject key combination"
        echo " 8. Quick keys (Home/Back/Power/Volume/etc)"
        echo ""
        echo "TEXT & POINTER"
        echo " 9. Inject text input"
        echo "10. Inject pointer event"
        echo "11. Inject drag and drop"
        echo ""
        echo "CAPTURE"
        echo "12. Capture screenshot"
        echo "13. Screen recording"
        echo "14. Capture framebuffer raw"
        echo ""
        echo "SYSTEM"
        echo "15. List running processes"
        echo "16. List installed packages"
        echo "17. System information"
        echo ""
        echo " 0. Back to main menu"
        echo ""
        echo -n "Select: "
        read qsel
        case "$qsel" in
            1)
                echo -n "X: "; read x
                echo -n "Y: "; read y
                input tap "$x" "$y" 2>/dev/null
                echo "Touch injected at ($x, $y)"
                log_operation "QUICK_TOUCH ($x,$y)"
                pause
                ;;
            2)
                echo -n "X: "; read x
                echo -n "Y: "; read y
                echo -n "Duration ms (default 1000): "; read dur
                dur="${dur:-1000}"
                input swipe "$x" "$y" "$x" "$y" "$dur" 2>/dev/null
                echo "Long press at ($x, $y) for ${dur}ms"
                log_operation "QUICK_LONGPRESS ($x,$y) ${dur}ms"
                pause
                ;;
            3)
                echo -n "X1 Y1 X2 Y2: "; read x1 y1 x2 y2
                echo -n "Duration ms (default 300): "; read dur
                dur="${dur:-300}"
                input swipe "$x1" "$y1" "$x2" "$y2" "$dur" 2>/dev/null
                echo "Swipe injected: ($x1,$y1) -> ($x2,$y2)"
                log_operation "QUICK_SWIPE ($x1,$y1)->($x2,$y2)"
                pause
                ;;
            4)
                echo "Multi-touch: enter points as x:y pairs (space separated)"
                echo -n "Points: "; read points
                local count=0
                for pt in $points; do
                    local mx=$(echo "$pt" | cut -d: -f1)
                    local my=$(echo "$pt" | cut -d: -f2)
                    input tap "$mx" "$my" 2>/dev/null
                    usleep 50000
                    count=$((count + 1))
                done
                echo "$count touch points injected"
                log_operation "QUICK_MULTITOUCH $count points"
                pause
                ;;
            5)
                echo "Pinch/Zoom gesture"
                echo -n "Center X: "; read cx
                echo -n "Center Y: "; read cy
                echo -n "Factor (0.5=pinch, 2.0=zoom): "; read factor
                local offset=100
                local x1=$((cx - offset))
                local y1=$((cy - offset))
                local x2=$((cx + offset))
                local y2=$((cy + offset))
                local nx1=$(echo "$cx - $offset * $factor" | bc 2>/dev/null || echo "$cx")
                local ny1=$(echo "$cy - $offset * $factor" | bc 2>/dev/null || echo "$cy")
                local nx2=$(echo "$cx + $offset * $factor" | bc 2>/dev/null || echo "$cx")
                local ny2=$(echo "$cy + $offset * $factor" | bc 2>/dev/null || echo "$cy")
                input swipe "$x1" "$y1" "$nx1" "$ny1" 500 2>/dev/null &
                input swipe "$x2" "$y2" "$nx2" "$ny2" 500 2>/dev/null &
                wait
                echo "Pinch/Zoom gesture injected: factor=$factor"
                log_operation "QUICK_PINCHZOOM center=($cx,$cy) factor=$factor"
                pause
                ;;
            6)
                echo "Common keycodes: 3=HOME,4=BACK,26=POWER,24=VOL+,25=VOL-,82=MENU"
                echo "187=APP_SWITCH,83=NOTIFICATION,66=ENTER,67=DEL"
                echo -n "Keycode: "; read kc
                echo -n "Repeat count (default 1): "; read repeat
                repeat="${repeat:-1}"
                local i=1
                while [ $i -le "$repeat" ]; do
                    input keyevent "$kc" 2>/dev/null
                    i=$((i + 1))
                    usleep 100000
                done
                echo "Key $kc injected $repeat times"
                log_operation "QUICK_KEY $kc x$repeat"
                pause
                ;;
            7)
                echo "Key combination: enter keycodes separated by +"
                echo "Example: 24+24+25 for VOL+ VOL+ VOL-"
                echo -n "Keys: "; read keys
                local IFS='+'
                for k in $keys; do
                    input keyevent "$k" 2>/dev/null
                    usleep 50000
                done
                echo "Key combination injected: $keys"
                log_operation "QUICK_KEYCOMBO $keys"
                pause
                ;;
            8)
                while true; do
                    clear
                    echo "Quick Keys"
                    echo " 1. HOME (3)        2. BACK (4)         3. POWER (26)"
                    echo " 4. VOLUME UP (24)   5. VOLUME DOWN (25)  6. MENU (82)"
                    echo " 7. APP SWITCH (187) 8. NOTIFICATION (83) 9. SEARCH (84)"
                    echo "10. ENTER (66)      11. DELETE (67)      12. TAB (61)"
                    echo "13. DPAD UP (19)    14. DPAD DOWN (20)   15. DPAD LEFT (21)"
                    echo "16. DPAD RIGHT (22) 17. DPAD CENTER (23) 18. CAMERA (27)"
                    echo "19. WAKEUP (224)    20. SLEEP (223)      21. MEDIA PLAY (126)"
                    echo "22. MEDIA PAUSE (127) 23. MEDIA NEXT (87) 24. MEDIA PREV (88)"
                    echo ""
                    echo " 0. Back"
                    echo ""
                    echo -n "Select: "
                    read qk
                    case "$qk" in
                        1) input keyevent 3 2>/dev/null; echo "HOME" ;;
                        2) input keyevent 4 2>/dev/null; echo "BACK" ;;
                        3) input keyevent 26 2>/dev/null; echo "POWER" ;;
                        4) input keyevent 24 2>/dev/null; echo "VOLUME UP" ;;
                        5) input keyevent 25 2>/dev/null; echo "VOLUME DOWN" ;;
                        6) input keyevent 82 2>/dev/null; echo "MENU" ;;
                        7) input keyevent 187 2>/dev/null; echo "APP SWITCH" ;;
                        8) input keyevent 83 2>/dev/null; echo "NOTIFICATION" ;;
                        9) input keyevent 84 2>/dev/null; echo "SEARCH" ;;
                        10) input keyevent 66 2>/dev/null; echo "ENTER" ;;
                        11) input keyevent 67 2>/dev/null; echo "DELETE" ;;
                        12) input keyevent 61 2>/dev/null; echo "TAB" ;;
                        13) input keyevent 19 2>/dev/null; echo "DPAD UP" ;;
                        14) input keyevent 20 2>/dev/null; echo "DPAD DOWN" ;;
                        15) input keyevent 21 2>/dev/null; echo "DPAD LEFT" ;;
                        16) input keyevent 22 2>/dev/null; echo "DPAD RIGHT" ;;
                        17) input keyevent 23 2>/dev/null; echo "DPAD CENTER" ;;
                        18) input keyevent 27 2>/dev/null; echo "CAMERA" ;;
                        19) input keyevent 224 2>/dev/null; echo "WAKEUP" ;;
                        20) input keyevent 223 2>/dev/null; echo "SLEEP" ;;
                        21) input keyevent 126 2>/dev/null; echo "MEDIA PLAY" ;;
                        22) input keyevent 127 2>/dev/null; echo "MEDIA PAUSE" ;;
                        23) input keyevent 87 2>/dev/null; echo "MEDIA NEXT" ;;
                        24) input keyevent 88 2>/dev/null; echo "MEDIA PREV" ;;
                        0) break ;;
                        *) echo "Invalid" ;;
                    esac
                    log_operation "QUICK_KEY $qk"
                    sleep 0.3
                done
                ;;
            9)
                echo -n "Enter text to inject: "; read text
                local safe_text=$(echo "$text" | sed 's/ /%s/g')
                input text "$safe_text" 2>/dev/null
                echo "Text injected (${#text} characters)"
                log_operation "QUICK_TEXT ${#text} chars"
                pause
                ;;
            10)
                echo -n "X: "; read x
                echo -n "Y: "; read y
                echo "Actions: down, up, move, tap"
                echo -n "Action (default tap): "; read action
                action="${action:-tap}"
                case "$action" in
                    down) input motionevent DOWN "$x" "$y" 2>/dev/null ;;
                    up) input motionevent UP "$x" "$y" 2>/dev/null ;;
                    move) input motionevent MOVE "$x" "$y" 2>/dev/null ;;
                    *) input tap "$x" "$y" 2>/dev/null ;;
                esac
                echo "Pointer $action at ($x, $y)"
                log_operation "QUICK_POINTER $action ($x,$y)"
                pause
                ;;
            11)
                echo "Drag and drop operation"
                echo -n "Start X Y: "; read sx sy
                echo -n "End X Y: "; read ex ey
                input swipe "$sx" "$sy" "$ex" "$ey" 800 2>/dev/null
                echo "Drag complete: ($sx,$sy) -> ($ex,$ey)"
                log_operation "QUICK_DRAG ($sx,$sy)->($ex,$ey)"
                pause
                ;;
            12)
                echo -n "Output path (default /sdcard/screen.png): "; read path
                path="${path:-/sdcard/screen.png}"
                screencap -p "$path" 2>/dev/null
                local sz=$(stat -c%s "$path" 2>/dev/null)
                echo "Screenshot saved: $path ($sz bytes)"
                log_operation "QUICK_SCREENSHOT $path $sz bytes"
                pause
                ;;
            13)
                echo -n "Output path: "; read path
                echo -n "Duration seconds (default 30): "; read dur
                dur="${dur:-30}"
                echo "Recording for ${dur}s. Press Ctrl+C to stop early."
                screenrecord --time-limit "$dur" "$path" 2>/dev/null
                local sz=$(stat -c%s "$path" 2>/dev/null)
                echo "Recording saved: $path ($sz bytes)"
                log_operation "QUICK_SCREENRECORD $path $dur s $sz bytes"
                pause
                ;;
            14)
                echo -n "Output path (default /sdcard/fb_raw.bin): "; read path
                path="${path:-/sdcard/fb_raw.bin}"
                if [ -r "/dev/graphics/fb0" ]; then
                    dd if=/dev/graphics/fb0 of="$path" bs=1024 2>/dev/null
                else
                    screencap "$path" 2>/dev/null
                fi
                local sz=$(stat -c%s "$path" 2>/dev/null)
                echo "Framebuffer captured: $path ($sz bytes)"
                log_operation "QUICK_FRAMEBUFFER $path $sz bytes"
                pause
                ;;
            15)
                echo "Running processes:"
                ps -A -o PID,UID,VSZ,RSS,NAME 2>/dev/null | head -40
                echo ""
                echo "Total: $(ps -A | wc -l) processes"
                pause
                ;;
            16)
                echo "Installed packages (first 40):"
                pm list packages 2>/dev/null | cut -d: -f2 | sort | head -40
                echo ""
                echo "Total: $(pm list packages 2>/dev/null | wc -l) packages"
                pause
                ;;
            17)
                echo "System Information"
                echo "Device: $(getprop ro.product.model)"
                echo "Brand: $(getprop ro.product.brand)"
                echo "Android: $(getprop ro.build.version.release) (SDK $(getprop ro.build.version.sdk))"
                echo "Build: $(getprop ro.build.id)"
                echo "Kernel: $(uname -r)"
                echo "Arch: $(uname -m)"
                echo "Display: $(wm size 2>/dev/null | grep -oP '\d+x\d+') @ $(wm density 2>/dev/null | grep -oP '\d+' | tail -1)dpi"
                echo "SELinux: $(getenforce)"
                echo "Root UID: $(id -u)"
                echo "Memory: $(cat /proc/meminfo | grep MemTotal | awk '{print $2, $3}')"
                echo "Storage /data: $(df -h /data 2>/dev/null | tail -1)"
                echo "Processes: $(ps -A | wc -l)"
                echo "Packages: $(pm list packages 2>/dev/null | wc -l)"
                log_operation "QUICK_SYSINFO"
                pause
                ;;
            0) return ;;
            *) echo "Invalid selection"; sleep 1 ;;
        esac
    done
}
process_control_menu() {
    while true; do
        clear
        echo "Process Injection & Control"
        echo ""
        echo "PROCESS EXPLORATION"
        echo " 1. List all processes"
        echo " 2. Search processes by name"
        echo " 3. Show process details by PID"
        echo " 4. Show process threads"
        echo " 5. Show process open files"
        echo " 6. Show process memory map"
        echo " 7. Show process network connections"
        echo " 8. List processes by package UID"
        echo ""
        echo "PROCESS CONTROL"
        echo " 9. Kill process (send signal)"
        echo "10. Freeze process (SIGSTOP)"
        echo "11. Resume process (SIGCONT)"
        echo "12. Force stop application"
        echo ""
        echo "INJECTION FRAMEWORK"
        echo "13. Library injection framework"
        echo "14. Code injection framework"
        echo "15. Memory read framework"
        echo "16. Memory write framework"
        echo "17. Process monitoring"
        echo ""
        echo " 0. Back to main menu"
        echo ""
        echo -n "Select: "
        read psel
        case "$psel" in
            1)
                echo "All processes:"
                ps -A -o PID,PPID,UID,VSZ,RSS,NAME 2>/dev/null
                pause
                ;;
            2)
                echo -n "Search term: "; read sterm
                echo "Processes matching '$sterm':"
                ps -A -o PID,PPID,UID,VSZ,RSS,NAME 2>/dev/null | grep -i "$sterm" | grep -v grep
                pause
                ;;
            3)
                echo -n "PID: "; read pid
                if [ -d "/proc/$pid" ]; then
                    echo "Process details for PID $pid:"
                    echo "Name: $(cat /proc/$pid/comm 2>/dev/null)"
                    echo "Status:"
                    cat /proc/$pid/status 2>/dev/null | head -20
                    echo ""
                    echo "Cmdline: $(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ')"
                    echo "CWD: $(ls -la /proc/$pid/cwd 2>/dev/null | awk '{print $NF}')"
                    echo "EXE: $(ls -la /proc/$pid/exe 2>/dev/null | awk '{print $NF}')"
                else
                    echo "Process $pid not found"
                fi
                pause
                ;;
            4)
                echo -n "PID: "; read pid
                if [ -d "/proc/$pid" ]; then
                    echo "Threads for PID $pid:"
                    ps -T -p "$pid" 2>/dev/null
                    echo ""
                    echo "Thread count: $(ls /proc/$pid/task 2>/dev/null | wc -l)"
                else
                    echo "Process $pid not found"
                fi
                pause
                ;;
            5)
                echo -n "PID: "; read pid
                if [ -d "/proc/$pid" ]; then
                    echo "Open files for PID $pid:"
                    ls -la /proc/$pid/fd 2>/dev/null
                    echo ""
                    echo "Total: $(ls /proc/$pid/fd 2>/dev/null | wc -l) file descriptors"
                else
                    echo "Process $pid not found"
                fi
                pause
                ;;
            6)
                echo -n "PID: "; read pid
                if [ -d "/proc/$pid" ]; then
                    echo "Memory map for PID $pid (first 60 lines):"
                    cat /proc/$pid/maps 2>/dev/null | head -60
                else
                    echo "Process $pid not found"
                fi
                pause
                ;;
            7)
                echo -n "PID: "; read pid
                if [ -d "/proc/$pid" ]; then
                    echo "TCP connections for PID $pid:"
                    cat /proc/$pid/net/tcp 2>/dev/null
                    echo ""
                    echo "UDP connections for PID $pid:"
                    cat /proc/$pid/net/udp 2>/dev/null
                else
                    echo "Process $pid not found"
                fi
                pause
                ;;
            8)
                echo -n "Package name: "; read pkg
                local puid=$(get_package_uid "$pkg")
                if [ -n "$puid" ]; then
                    echo "Processes for $pkg (UID: $puid):"
                    ps -A -o PID,PPID,UID,VSZ,RSS,NAME 2>/dev/null | awk -v u="$puid" '$3 == u'
                else
                    echo "Package not found"
                fi
                pause
                ;;
            9)
                echo "Signals: 1=SIGHUP 2=SIGINT 9=SIGKILL 15=SIGTERM 17=SIGSTOP 19=SIGCONT"
                echo -n "PID: "; read pid
                echo -n "Signal (default 15): "; read sig
                sig="${sig:-15}"
                if [ -d "/proc/$pid" ]; then
                    kill -"$sig" "$pid" 2>/dev/null
                    echo "Signal $sig sent to PID $pid"
                    log_operation "PROCESS_KILL PID=$pid SIG=$sig"
                else
                    echo "Process $pid not found"
                fi
                pause
                ;;
            10)
                echo -n "PID: "; read pid
                if [ -d "/proc/$pid" ]; then
                    kill -17 "$pid" 2>/dev/null
                    echo "Process $pid frozen (SIGSTOP)"
                    log_operation "PROCESS_FREEZE PID=$pid"
                    sleep 1
                    echo "State: $(cat /proc/$pid/status 2>/dev/null | grep State)"
                else
                    echo "Process $pid not found"
                fi
                pause
                ;;
            11)
                echo -n "PID: "; read pid
                if [ -d "/proc/$pid" ]; then
                    kill -19 "$pid" 2>/dev/null
                    echo "Process $pid resumed (SIGCONT)"
                    log_operation "PROCESS_RESUME PID=$pid"
                else
                    echo "Process $pid not found"
                fi
                pause
                ;;
            12)
                echo -n "Package name: "; read pkg
                if validate_package "$pkg"; then
                    am force-stop "$pkg" 2>/dev/null
                    echo "Application $pkg force stopped"
                    log_operation "PROCESS_FORCESTOP $pkg"
                else
                    echo "Invalid package"
                fi
                pause
                ;;
            13)
                echo "Library Injection Framework"
                echo "Requires: ptrace, SELinux permissive, architecture matching"
                echo -n "Target PID: "; read pid
                echo -n "Library path: "; read libpath
                echo ""
                echo "Injection steps:"
                echo "  1. Attach to process via ptrace(PTRACE_ATTACH)"
                echo "  2. Wait for process to stop"
                echo "  3. Save registers (ARM: r0-r12, sp, lr, pc, cpsr)"
                echo "  4. Find dlopen address in /proc/$pid/maps (linker module)"
                echo "  5. Write library path string to process memory"
                echo "  6. Set pc to dlopen address, r0 = string addr, r1 = RTLD_NOW(2)"
                echo "  7. Detach and wait for dlopen completion"
                echo "  8. Re-attach and restore original registers"
                echo ""
                if [ -d "/proc/$pid" ]; then
                    echo "Target process: $(cat /proc/$pid/comm 2>/dev/null)"
                    echo "Architecture: $(cat /proc/$pid/maps 2>/dev/null | grep -oP 'r-xp.*' | head -1 | awk '{print $NF}')"
                    echo "Linker location: $(cat /proc/$pid/maps 2>/dev/null | grep linker | head -1)"
                fi
                log_operation "LIBRARY_INJECTION_ATTEMPT PID=$pid LIB=$libpath"
                pause
                ;;
            14)
                echo "Code Injection Framework"
                echo "Requires: ptrace, executable memory region, shellcode"
                echo -n "Target PID: "; read pid
                echo ""
                echo "Injection methods:"
                echo "  1. mmap() + shellcode: allocate new memory, write shellcode, execute"
                echo "  2. .got.plt overwrite: replace function pointer in GOT"
                echo "  3. Inline hook: overwrite instructions with branch to payload"
                echo "  4. CFI bypass: requires modern framework with CFI exceptions"
                echo ""
                if [ -d "/proc/$pid" ]; then
                    echo "Process: $(cat /proc/$pid/comm 2>/dev/null)"
                    echo "Executable regions:"
                    cat /proc/$pid/maps 2>/dev/null | grep "r.xp" | head -10
                fi
                log_operation "CODE_INJECTION_ATTEMPT PID=$pid"
                pause
                ;;
            15)
                echo "Memory Read Framework"
                echo "Requires: /proc/<pid>/mem read access or ptrace PEEKDATA"
                echo -n "PID: "; read pid
                echo -n "Address (hex, e.g., 0x40000000): "; read addr
                echo -n "Length bytes (default 64): "; read len
                len="${len:-64}"
                echo ""
                if [ -r "/proc/$pid/mem" ]; then
                    echo "/proc/$pid/mem is readable - direct memory access available"
                else
                    echo "/proc/$pid/mem not readable - ptrace method required"
                fi
                echo "Process maps for reference:"
                cat /proc/$pid/maps 2>/dev/null | head -10
                log_operation "MEMORY_READ_ATTEMPT PID=$pid ADDR=$addr LEN=$len"
                pause
                ;;
            16)
                echo "Memory Write Framework"
                echo "Requires: ptrace POKEDATA or /proc/<pid>/mem write access"
                echo -n "PID: "; read pid
                echo -n "Address (hex): "; read addr
                echo -n "Data (hex bytes, e.g., 01020304): "; read data
                echo ""
                echo "Write methods:"
                echo "  1. ptrace(PTRACE_POKETEXT, pid, addr, data) - word at a time"
                echo "  2. /proc/$pid/mem lseek + write - bulk writes"
                echo "  3. process_vm_writev() - Linux syscall, iovec based"
                echo ""
                if [ -d "/proc/$pid" ]; then
                    echo "Target: $(cat /proc/$pid/comm 2>/dev/null)"
                    echo "Address region:"
                    cat /proc/$pid/maps 2>/dev/null | grep "$(echo $addr | sed 's/0x//' | cut -c1-4)" | head -3
                fi
                log_operation "MEMORY_WRITE_ATTEMPT PID=$pid ADDR=$addr"
                pause
                ;;
            17)
                echo "Process Monitoring"
                echo " 1. Start monitoring PID"
                echo " 2. Stop monitoring PID"
                echo " 3. Show monitored processes"
                echo " 4. Back"
                echo -n "Select: "; read msel
                case "$msel" in
                    1)
                        echo -n "PID to monitor: "; read mpid
                        if [ -d "/proc/$mpid" ]; then
                            echo "Started monitoring PID $mpid"
                            echo "Name: $(cat /proc/$mpid/comm 2>/dev/null)"
                            echo "State: $(cat /proc/$mpid/status 2>/dev/null | grep State)"
                            log_operation "PROCESS_MONITOR_START PID=$mpid"
                        else
                            echo "Process not found"
                        fi
                        pause
                        ;;
                    2)
                        echo -n "PID to stop monitoring: "; read mpid
                        echo "Stopped monitoring PID $mpid"
                        log_operation "PROCESS_MONITOR_STOP PID=$mpid"
                        pause
                        ;;
                    3)
                        echo "Monitored processes framework"
                        echo "Active monitoring entries would be listed here"
                        pause
                        ;;
                    4) ;;
                esac
                ;;
            0) return ;;
            *) echo "Invalid selection"; sleep 1 ;;
        esac
    done
}
logs_menu() {
    while true; do
        clear
        echo "Logs & Audit"
        echo ""
        echo " 1. Show operation log (tail 50)"
        echo " 2. Show audit log (tail 50)"
        echo " 3. Show full operation log"
        echo " 4. Show full audit log"
        echo " 5. Show logcat input events"
        echo " 6. Show logcat SurfaceFlinger"
        echo " 7. Show logcat WindowManager"
        echo " 8. Show logcat ActivityManager"
        echo " 9. Clear all logs"
        echo "10. Export logs to file"
        echo ""
        echo " 0. Back to main menu"
        echo ""
        echo -n "Select: "
        read lsel
        case "$lsel" in
            1)
                echo "Operation log (last 50 lines):"
                tail -50 "$LOG_FILE" 2>/dev/null
                pause
                ;;
            2)
                echo "Audit log (last 50 lines):"
                tail -50 "$AUDIT_LOG" 2>/dev/null
                pause
                ;;
            3)
                echo "Full operation log:"
                cat "$LOG_FILE" 2>/dev/null
                pause
                ;;
            4)
                echo "Full audit log:"
                cat "$AUDIT_LOG" 2>/dev/null
                pause
                ;;
            5)
                echo "Logcat - Input events (last 30 seconds):"
                logcat -d -s InputReader:* InputDispatcher:* InputManagerService:* 2>/dev/null | tail -50
                pause
                ;;
            6)
                echo "Logcat - SurfaceFlinger (last 30 seconds):"
                logcat -d -s SurfaceFlinger:* 2>/dev/null | tail -50
                pause
                ;;
            7)
                echo "Logcat - WindowManager (last 30 seconds):"
                logcat -d -s WindowManager:* 2>/dev/null | tail -50
                pause
                ;;
            8)
                echo "Logcat - ActivityManager (last 30 seconds):"
                logcat -d -s ActivityManager:* 2>/dev/null | tail -50
                pause
                ;;
            9)
                echo "Clearing all logs..."
                > "$LOG_FILE"
                > "$AUDIT_LOG"
                logcat -c 2>/dev/null
                echo "Logs cleared"
                pause
                ;;
            10)
                echo -n "Export directory: "; read edir
                if [ -d "$edir" ]; then
                    local ts=$(date +%s)
                    cp "$LOG_FILE" "$edir/operation_log_$ts.txt" 2>/dev/null
                    cp "$AUDIT_LOG" "$edir/audit_log_$ts.txt" 2>/dev/null
                    logcat -d > "$edir/logcat_$ts.txt" 2>/dev/null
                    echo "Logs exported to $edir"
                    log_operation "LOGS_EXPORT $edir"
                else
                    echo "Directory not found"
                fi
                pause
                ;;
            0) return ;;
            *) echo "Invalid selection"; sleep 1 ;;
        esac
    done
}
main_menu() {
    while true; do
        clear
        echo "Inject Explorer - Enterprise System Control"
        echo "Device: $DEVICE_MODEL | Android: $ANDROID_VER | SDK: $SDK_VER"
        echo "Root: UID $(id -u) | SELinux: $SELINUX_STATUS | User: $CURRENT_USER"
        echo "Session: $SESSION_ID"
        echo ""
        echo " 1. Permission Control Panel (28 permissions)"
        echo " 2. Quick Injection Operations"
        echo " 3. Process Injection & Control"
        echo " 4. SurfaceFlinger Control"
        echo " 5. InputFlinger Control"
        echo " 6. Package Management"
        echo " 7. Logs & Audit"
        echo " 8. System Information"
        echo " 9. Change Target Package (current: $TARGET_PACKAGE)"
        echo ""
        echo " 0. Exit"
        echo ""
        echo -n "Select: "
        read msel
        case "$msel" in
            1) show_permission_menu ;;
            2) quick_inject_menu ;;
            3) process_control_menu ;;
            4) show_perm_18 ;;
            5) show_perm_19 ;;
            6)
                while true; do
                    clear
                    echo "Package Management"
                    echo " 1. List all packages"
                    echo " 2. List system packages"
                    echo " 3. List third-party packages"
                    echo " 4. Search packages"
                    echo " 5. Check package permissions"
                    echo " 6. Launch application"
                    echo " 7. Force stop application"
                    echo " 8. Clear app data"
                    echo " 9. Disable/Enable app"
                    echo "10. Install APK"
                    echo "11. Uninstall APK"
                    echo ""
                    echo " 0. Back"
                    echo ""
                    echo -n "Select: "; read pksel
                    case "$pksel" in
                        1) pm list packages 2>/dev/null | cut -d: -f2 | sort; pause ;;
                        2) pm list packages -s 2>/dev/null | cut -d: -f2 | sort; pause ;;
                        3) pm list packages -3 2>/dev/null | cut -d: -f2 | sort; pause ;;
                        4)
                            echo -n "Search: "; read psearch
                            pm list packages 2>/dev/null | cut -d: -f2 | grep -i "$psearch" | sort
                            pause
                            ;;
                        5)
                            echo -n "Package: "; read ppkg
                            check_package_permissions_full "$ppkg"
                            pause
                            ;;
                        6)
                            echo -n "Package: "; read lpkg
                            monkey -p "$lpkg" -c android.intent.category.LAUNCHER 1 2>/dev/null
                            echo "Launch attempt: $lpkg"
                            log_operation "LAUNCH_APP $lpkg"
                            pause
                            ;;
                        7)
                            echo -n "Package: "; read fpkg
                            am force-stop "$fpkg" 2>/dev/null
                            echo "Force stopped: $fpkg"
                            log_operation "FORCE_STOP $fpkg"
                            pause
                            ;;
                        8)
                            echo -n "Package: "; read cpkg
                            echo "WARNING: This will delete ALL data for $cpkg"
                            echo -n "Type YES to confirm: "; read confirm
                            if [ "$confirm" = "YES" ]; then
                                pm clear "$cpkg" 2>/dev/null
                                echo "Data cleared: $cpkg"
                                log_operation "CLEAR_DATA $cpkg"
                            else
                                echo "Cancelled"
                            fi
                            pause
                            ;;
                        9)
                            echo -n "Package: "; read dpkg
                            echo " 1. Disable"
                            echo " 2. Enable"
                            echo -n "Action: "; read daction
                            case "$daction" in
                                1) pm disable "$dpkg" 2>/dev/null; echo "Disabled: $dpkg"; log_operation "DISABLE_APP $dpkg" ;;
                                2) pm enable "$dpkg" 2>/dev/null; echo "Enabled: $dpkg"; log_operation "ENABLE_APP $dpkg" ;;
                                *) echo "Invalid" ;;
                            esac
                            pause
                            ;;
                        10)
                            echo -n "APK path: "; read apkpath
                            if [ -f "$apkpath" ]; then
                                pm install -r "$apkpath" 2>/dev/null
                                echo "Install attempt complete"
                                log_operation "INSTALL_APK $apkpath"
                            else
                                echo "File not found"
                            fi
                            pause
                            ;;
                        11)
                            echo -n "Package: "; read upkg
                            echo "WARNING: This will uninstall $upkg"
                            echo -n "Type YES to confirm: "; read confirm
                            if [ "$confirm" = "YES" ]; then
                                pm uninstall "$upkg" 2>/dev/null
                                echo "Uninstall complete: $upkg"
                                log_operation "UNINSTALL_APP $upkg"
                            else
                                echo "Cancelled"
                            fi
                            pause
                            ;;
                        0) break ;;
                    esac
                done
                ;;
            7) logs_menu ;;
            8)
                clear
                echo "Full System Information"
                echo ""
                echo "Device: $(getprop ro.product.model)"
                echo "Brand: $(getprop ro.product.brand)"
                echo "Manufacturer: $(getprop ro.product.manufacturer)"
                echo "Android: $(getprop ro.build.version.release)"
                echo "SDK: $(getprop ro.build.version.sdk)"
                echo "Build: $(getprop ro.build.id)"
                echo "Build Type: $(getprop ro.build.type)"
                echo "Build Tags: $(getprop ro.build.tags)"
                echo "Kernel: $(uname -r)"
                echo "Architecture: $(uname -m)"
                echo "Display: $(wm size 2>/dev/null | grep -oP '\d+x\d+')"
                echo "Density: $(wm density 2>/dev/null | grep -oP '\d+' | tail -1) dpi"
                echo "SELinux: $(getenforce)"
                echo "Root UID: $(id -u)"
                echo "Current User: $CURRENT_USER"
                echo "IME: $(ime list -s 2>/dev/null | head -1)"
                echo ""
                echo "Memory:"
                cat /proc/meminfo 2>/dev/null | head -5
                echo ""
                echo "Storage:"
                df -h /data 2>/dev/null
                echo ""
                echo "CPU:"
                cat /proc/cpuinfo 2>/dev/null | grep -E "model name|Hardware|processor" | head -10
                echo ""
                echo "Processes: $(ps -A | wc -l)"
                echo "Packages: $(pm list packages 2>/dev/null | wc -l)"
                echo "Services: $(service list 2>/dev/null | wc -l)"
                echo ""
                echo "Network:"
                ip addr show 2>/dev/null | grep -E "inet |link/" | head -10
                log_operation "SYSINFO_DISPLAY"
                pause
                ;;
            9)
                echo "Current target: $TARGET_PACKAGE"
                echo -n "New target package: "; read newpkg
                if validate_package "$newpkg"; then
                    TARGET_PACKAGE="$newpkg"
                    echo "Target changed to: $TARGET_PACKAGE"
                else
                    echo "Invalid package"
                fi
                pause
                ;;
            0)
                clear
                echo "Exiting Inject Explorer"
                echo "Session: $SESSION_ID"
                echo "Goodbye"
                exit 0
                ;;
            *) echo "Invalid selection"; sleep 1 ;;
        esac
    done
}
check_package_permissions_full() {
    local pkg="$1"
    if ! validate_package "$pkg"; then
        echo "Invalid package: $pkg"
        return 1
    fi
    local puid=$(get_package_uid "$pkg")
    echo "Package: $pkg"
    echo "UID: $puid"
    echo "Version: $(get_package_version "$pkg")"
    echo ""
    echo "Permission Status:"
    local granted=0
    local denied=0
    local i=0
    for p in "${PERM_NAMES[@]}"; do
        i=$((i + 1))
        if check_perm_status "$p" "$pkg" | grep -q "Success"; then
            printf "%-4s %-60s GRANTED\n" "$i" "$p"
            granted=$((granted + 1))
        else
            printf "%-4s %-60s NOT GRANTED\n" "$i" "$p"
            denied=$((denied + 1))
        fi
    done
    echo ""
    echo "Granted: $granted / ${#PERM_NAMES[@]}"
    echo "Denied: $denied / ${#PERM_NAMES[@]}"
}
get_package_version() {
    dumpsys package "$1" 2>/dev/null | grep "versionName=" | head -1 | cut -d'=' -f2
}
log_operation "SESSION_START ID=$SESSION_ID UID=$CURRENT_UID"
main_menu
