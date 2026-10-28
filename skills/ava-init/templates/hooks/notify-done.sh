#!/bin/bash
# Hook: notify-done
# Event: Stop
# วัตถุประสงค์: แจ้งเตือนเมื่อ Claude ทำงานเสร็จ ด้วย popup + เสียง + พูด
#              - รองรับทั้ง macOS และ Windows (Git Bash / MSYS2 / Cygwin)
#              - ดึงชื่อ Claude จาก .claude/ava/SOUL.md อัตโนมัติ
#              - ดึงบริบท action ล่าสุดจาก track-action.sh ผ่าน last-action.tmp
#
# Input (stdin): JSON object จาก Claude Code
#   - stop_hook_active : true ถ้า stop hook กำลัง active
#
# Output:
#   - exit 0 : ยืนยันให้หยุด

# รับ JSON input จาก stdin (ไม่ได้ใช้ในกรณีนี้ แต่ต้อง consume stdin)
INPUT=$(cat)

# ตรวจสอบ OS
OS=$(uname -s)

# ดึงชื่อจาก SOUL.md — รูปแบบ: "- **ชื่อ:** <ชื่อไทย> (<ชื่ออังกฤษ>)"
# fallback เป็น "Claude" ถ้าไม่พบไฟล์หรือ pattern ไม่ตรง
SYSTEM_FILE=".claude/ava/SOUL.md"
if [ -f "$SYSTEM_FILE" ]; then
  NAME=$(grep 'ชื่อ:' "$SYSTEM_FILE" | sed 's/.*ชื่อ:\*\* \([^ ]*\).*/\1/')
  # แก้ไข: ดึงคำเรียก user จาก SOUL.md แทนการ hardcode — รูปแบบ: "- **เรียก user ว่า:** <คำเรียก>"
  CALL=$(grep 'เรียก user ว่า:' "$SYSTEM_FILE" | sed 's/.*เรียก user ว่า:\*\* *//')
fi
NAME=${NAME:-Claude}

# อ่าน context ของ action ล่าสุดจาก track-action.sh
# ถ้าไม่มีไฟล์ → Claude แค่ตอบคำถาม ไม่ต้องเล่นเสียงและพูด
ACTION_FILE=".claude/hooks/last-action.tmp"
IS_ACTION=false
if [ -f "$ACTION_FILE" ]; then
  ACTION=$(cat "$ACTION_FILE")
  rm -f "$ACTION_FILE"
  IS_ACTION=true
fi

# แก้ไข: ไม่ hardcode คำลงท้าย/คำเรียก user — โทนเป็นไปตาม SOUL.md ของแต่ละโปรเจกต์
#        ถ้าไม่มี action (แค่ตอบคำถาม) ใช้ข้อความ default แทน
ACTION=${ACTION:-ตอบเสร็จแล้ว}
MSG="${NAME} ${ACTION}${CALL:+ ${CALL}}"

# แสดง popup notification (ทำทุกครั้ง)
case "$OS" in
  Darwin*)
    osascript -e "display notification \"${MSG}\" with title \"Claude Code\""
    ;;
  MINGW*|CYGWIN*|MSYS*)
    powershell.exe -NoProfile -Command "
      Add-Type -AssemblyName System.Windows.Forms
      \$n = New-Object System.Windows.Forms.NotifyIcon
      \$n.Icon = [System.Drawing.SystemIcons]::Application
      \$n.Visible = \$true
      \$n.ShowBalloonTip(3000, 'Claude Code', '${MSG}', [System.Windows.Forms.ToolTipIcon]::Info)
      Start-Sleep -Seconds 1
      \$n.Dispose()
    " &
    ;;
esac

# เล่นเสียงและพูด เฉพาะเมื่อ Claude ทำ action จริง (ไม่ใช่แค่ตอบคำถาม)
if [ "$IS_ACTION" = "true" ]; then
  case "$OS" in
    Darwin*)
      afplay /System/Library/Sounds/Funk.aiff
      say -v Kanya -r 200 "[[pbas +6]]${MSG}"
      ;;
    MINGW*|CYGWIN*|MSYS*)
      powershell.exe -NoProfile -Command "
        [System.Media.SystemSounds]::Asterisk.Play()
        Start-Sleep -Milliseconds 500
        Add-Type -AssemblyName System.Speech
        \$s = New-Object System.Speech.Synthesis.SpeechSynthesizer
        \$s.Rate = 2
        \$s.Speak('${MSG}')
      "
      ;;
  esac
fi

# ยืนยันให้ Claude หยุดทำงาน
exit 0
