#!/usr/bin/env bash
# Notification hook — fires when Claude Code sends a notification
# Shows a Windows toast via PowerShell

# Opt-out: every notification (including every permission prompt) otherwise
# launches a fresh powershell.exe that holds a NotifyIcon for 6 seconds.
# Set CCGS_DISABLE_TOAST=1 to keep the transcript line without the toast.
TOAST_ENABLED=1
if [ "${CCGS_DISABLE_TOAST:-0}" = "1" ]; then
    TOAST_ENABLED=0
fi

# Throttle: during a burst of prompts, one toast is informative and ten are not.
# Suppress the toast if another fired within CCGS_TOAST_THROTTLE_SEC (default 10).
THROTTLE_SEC="${CCGS_TOAST_THROTTLE_SEC:-10}"
THROTTLE_FILE="${TMPDIR:-/tmp}/ccgs-last-toast"
if [ "$TOAST_ENABLED" = "1" ] && [ -f "$THROTTLE_FILE" ]; then
    LAST=$(cat "$THROTTLE_FILE" 2>/dev/null)
    NOW=$(date +%s)
    if [ -n "$LAST" ] && [ $((NOW - LAST)) -lt "$THROTTLE_SEC" ]; then
        TOAST_ENABLED=0
    fi
fi

# Read notification JSON from stdin
INPUT=$(cat)

# Extract message — try jq first, fall back to grep
if command -v jq &>/dev/null; then
  MESSAGE=$(echo "$INPUT" | jq -r '.message // empty' 2>/dev/null)
fi
if [ -z "$MESSAGE" ]; then
  MESSAGE=$(echo "$INPUT" | grep -oE '"message":"[^"]*"' | sed 's/"message":"//;s/"//')
fi
if [ -z "$MESSAGE" ]; then
  MESSAGE="Claude Code needs your attention"
fi

# Sanitize message for PowerShell string embedding (escape single quotes)
MESSAGE_SAFE=$(echo "$MESSAGE" | sed "s/'/''/g" | head -c 200)

# Show Windows balloon tip notification (works on all Windows 10/11 without extra modules)
# The NotifyIcon must stay alive while the balloon is displayed, so the sleep
# has to outlast ShowBalloonTip — shortening it just cuts the toast short.
# Cost is controlled by the throttle above, not by trimming the sleep.
if [ "$TOAST_ENABLED" = "1" ]; then
    date +%s > "$THROTTLE_FILE" 2>/dev/null
    powershell.exe -NonInteractive -WindowStyle Hidden -Command "
      Add-Type -AssemblyName System.Windows.Forms
      \$notify = New-Object System.Windows.Forms.NotifyIcon
      \$notify.Icon = [System.Drawing.SystemIcons]::Information
      \$notify.BalloonTipTitle = 'Claude Code'
      \$notify.BalloonTipText = '$MESSAGE_SAFE'
      \$notify.Visible = \$true
      \$notify.ShowBalloonTip(5000)
      Start-Sleep -Seconds 6
      \$notify.Dispose()
    " 2>/dev/null &
fi

echo "Notification: $MESSAGE_SAFE"
