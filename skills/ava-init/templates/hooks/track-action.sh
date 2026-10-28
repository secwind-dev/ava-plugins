#!/bin/bash
# Hook: track-action
# Event: PreToolUse (ไม่มี matcher = รับทุก tool)
# วัตถุประสงค์: บันทึก context ของ action ล่าสุดไว้ใน last-action.tmp
#              เพื่อให้ notify-done.sh นำไปพูดบริบทที่ถูกต้อง
#
# Input (stdin): JSON object จาก Claude Code
#   - tool_name  : ชื่อ tool เช่น Bash, Write, Edit
#   - tool_input : input ของ tool นั้น
#
# Output:
#   - exit 0 : อนุญาตเสมอ — hook นี้เป็น tracking-only ไม่บล็อก

# รับ JSON input จาก stdin
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# เลือก context ตาม tool — ข้าม Read/Glob/Grep เพราะเป็น query ไม่ใช่ action
case "$TOOL" in
  Bash)
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
    if echo "$CMD" | grep -q 'git push'; then
      echo "push git เสร็จแล้ว" > .claude/hooks/last-action.tmp
    elif echo "$CMD" | grep -q 'git commit'; then
      echo "commit เสร็จแล้ว" > .claude/hooks/last-action.tmp
    elif echo "$CMD" | grep -q 'git'; then
      echo "รัน git เสร็จแล้ว" > .claude/hooks/last-action.tmp
    elif echo "$CMD" | grep -q 'npm\|yarn\|bun\|pnpm'; then
      echo "ติดตั้ง packages เสร็จแล้ว" > .claude/hooks/last-action.tmp
    elif echo "$CMD" | grep -q 'mkdir'; then
      echo "สร้าง folder เสร็จแล้ว" > .claude/hooks/last-action.tmp
    else
      echo "รัน command เสร็จแล้ว" > .claude/hooks/last-action.tmp
    fi
    ;;
  Write)
    # ดึงแค่ชื่อไฟล์ (ตัดเอา path ออก)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' | xargs basename 2>/dev/null)
    echo "สร้างไฟล์ ${FILE} เสร็จแล้ว" > .claude/hooks/last-action.tmp
    ;;
  Edit|MultiEdit)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' | xargs basename 2>/dev/null)
    echo "แก้ไขไฟล์ ${FILE} เสร็จแล้ว" > .claude/hooks/last-action.tmp
    ;;
  NotebookEdit)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.notebook_path // empty' | xargs basename 2>/dev/null)
    echo "แก้ไข notebook ${FILE} เสร็จแล้ว" > .claude/hooks/last-action.tmp
    ;;
  # ข้าม Read, Glob, Grep, Task — เป็น query ไม่ใช่ action สำคัญ
  Read|Glob|Grep|Task)
    ;;
  *)
    echo "ทำงานเสร็จแล้ว" > .claude/hooks/last-action.tmp
    ;;
esac

# อนุญาตเสมอ
exit 0
