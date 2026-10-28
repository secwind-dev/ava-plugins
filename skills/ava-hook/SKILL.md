---
name: ava-hook
description: 'Create a Claude Code hook with shell script template and register it in .claude/settings.json. Usage: /ava-hook <hook-name>'
argument-hint: <hook-name>
disable-model-invocation: true
---


path รับมา: `$ARGUMENTS`

---

## ขั้นที่ 0 — รับ Argument

ดึงชื่อ hook จาก argument (เช่น `/ava-hook log-bash` → hook-name = `log-bash`)

- ถ้าไม่มี argument → แจ้ง user ว่า "กรุณาระบุชื่อ hook เช่น `/ava-hook ชื่อ-hook`" แล้วหยุด
- ชื่อ hook ที่รับมาใช้เป็นชื่อไฟล์ script (เช่น `log-bash` → `.claude/hooks/log-bash.sh`)

---

## ขั้นที่ 1 — ถามข้อมูล

ใช้ `AskUserQuestion` ถาม 3 ข้อพร้อมกัน:

**ข้อ 1:** Hook event นี้ trigger เมื่อใด?
- `PreToolUse` — ก่อน Claude ใช้ tool
- `PostToolUse` — หลัง Claude ใช้ tool เสร็จ
- `Notification` — เมื่อ Claude ส่ง notification
- `Stop` — เมื่อ Claude หยุดทำงาน

**ข้อ 2:** Hook นี้ match กับ tool ไหน? (สำหรับ PreToolUse / PostToolUse เท่านั้น)
- `Bash` — match เฉพาะ Bash tool
- `Write` — match เฉพาะ Write tool
- `Edit` — match เฉพาะ Edit tool
- `Read` — match เฉพาะ Read tool
- *(ทุก tool)* — ไม่ระบุ matcher ให้ trigger กับทุก tool

**ข้อ 3:** Hook นี้ควรทำอะไร? (อธิบายสั้นๆ เช่น "log คำสั่ง bash ทุกอย่าง", "แจ้งเตือนผ่าน notification")

---

## ขั้นที่ 2 — สร้าง Hook Script

สร้างโฟลเดอร์ก่อน (ถ้ายังไม่มี):

```bash
mkdir -p .claude/hooks
```

จากนั้นใช้ tool `Write` สร้างไฟล์ `.claude/hooks/<hook-name>.sh` โดยใส่ boilerplate ตาม event type:

### PreToolUse / PostToolUse

```bash
#!/bin/bash
# Hook: <hook-name>
# Event: <event-type>
# Matcher: <tool-name หรือ ทุก tool>
# วัตถุประสงค์: <คำอธิบายจาก user>
#
# Input (stdin): JSON object จาก Claude Code
#   - tool_name   : ชื่อ tool ที่ถูกใช้
#   - tool_input  : input ที่ส่งให้ tool (object)
#
# Output:
#   - exit 0      : อนุญาตให้ Claude ทำงานต่อ
#   - exit 2      : บล็อก tool และส่ง stderr กลับให้ Claude

# รับ JSON input จาก stdin
INPUT=$(cat)

# ดึงข้อมูลจาก JSON
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}')

# TODO: เพิ่ม logic ของ hook ที่นี่
# ตัวอย่าง: log ข้อมูลลงไฟล์
# echo "[$(date '+%Y-%m-%d %H:%M:%S')] $TOOL_NAME: $TOOL_INPUT" >> .claude/hooks/hook.log

exit 0
```

### Notification

```bash
#!/bin/bash
# Hook: <hook-name>
# Event: Notification
# วัตถุประสงค์: <คำอธิบายจาก user>
#
# Input (stdin): JSON object จาก Claude Code
#   - message     : ข้อความ notification
#   - title       : หัวข้อ (ถ้ามี)
#
# Output:
#   - exit 0      : รับทราบ notification

# รับ JSON input จาก stdin
INPUT=$(cat)

# ดึงข้อมูลจาก JSON
MESSAGE=$(echo "$INPUT" | jq -r '.message // empty')

# TODO: เพิ่ม logic ของ hook ที่นี่
# ตัวอย่าง: แสดง desktop notification (macOS)
# osascript -e "display notification \"$MESSAGE\" with title \"Claude\""

exit 0
```

### Stop

```bash
#!/bin/bash
# Hook: <hook-name>
# Event: Stop
# วัตถุประสงค์: <คำอธิบายจาก user>
#
# Input (stdin): JSON object จาก Claude Code
#   - stop_hook_active : true ถ้า stop hook กำลัง active
#
# Output:
#   - exit 0      : ยืนยันให้หยุด
#   - exit 2      : ขอให้ Claude ทำงานต่อ (พร้อม reason ใน stderr)

# รับ JSON input จาก stdin
INPUT=$(cat)

# TODO: เพิ่ม logic ของ hook ที่นี่

exit 0
```

ให้ทำไฟล์ executable ด้วย:

```bash
chmod +x .claude/hooks/<hook-name>.sh
```

---

## ขั้นที่ 3 — ลงทะเบียนใน settings.json

อ่านไฟล์ `.claude/settings.json` ก่อน (ถ้าไม่มีให้สร้างใหม่เป็น `{}`)

เพิ่ม hook entry เข้าไปใน `hooks` object โดยรักษา config เดิมไว้ทั้งหมด

### โครงสร้าง JSON ที่ต้องเพิ่ม:

**กรณี PreToolUse / PostToolUse + ระบุ matcher:**
```json
{
  "hooks": {
    "<EventType>": [
      {
        "matcher": "<ToolName>",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/<hook-name>.sh"
          }
        ]
      }
    ]
  }
}
```

**กรณี PreToolUse / PostToolUse + ไม่ระบุ matcher (ทุก tool):**
```json
{
  "hooks": {
    "<EventType>": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/<hook-name>.sh"
          }
        ]
      }
    ]
  }
}
```

**กรณี Notification / Stop:**
```json
{
  "hooks": {
    "<EventType>": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/<hook-name>.sh"
          }
        ]
      }
    ]
  }
}
```

> ถ้า event type นั้นมี entries อยู่แล้ว → append เข้าไปใน array อย่าเขียนทับ

---

## ขั้นที่ 4 — แจ้งผล

```
✅ สร้าง Hook เรียบร้อยแล้ว!

📄 Hook Script : .claude/hooks/<hook-name>.sh
⚙️  Event       : <EventType>
🎯 Matcher     : <ToolName หรือ "ทุก tool">
📋 วัตถุประสงค์ : <คำอธิบาย>

🔧 ลงทะเบียนใน .claude/settings.json แล้ว

📌 Next Steps:
1. เปิดไฟล์ .claude/hooks/<hook-name>.sh แล้วเติม logic ใน TODO section
2. ทดสอบโดยใช้ tool ที่ matcher ไว้ดูว่า hook ทำงานถูกต้อง
3. ถ้าต้องการให้ hook บล็อก tool → ใช้ exit 2 พร้อมเขียน reason ลง stderr
```
