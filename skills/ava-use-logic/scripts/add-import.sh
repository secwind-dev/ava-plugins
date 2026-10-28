#!/usr/bin/env bash
# เพิ่มบรรทัด import ของ logic เข้า section "## 🧩 Active Logics" ใน AVA.md
# รับ: $1 = ชื่อ logic, $2 = path ของ AVA.md (default: .claude/ava/AVA.md)
# คืน: พิมพ์ IMPORT_ADDED (เพิ่มแล้ว) หรือ IMPORT_EXISTS (มีอยู่แล้ว) · exit 1 ถ้า argument ผิด
#
# แยกเป็น script เพราะ Claude Code แทนที่ $0 / $1 ... ใน SKILL.md ด้วย argument ของ skill
# ถ้าเขียน awk ไว้ใน SKILL.md ตรงๆ $0 จะกลายเป็นชื่อ logic แล้วบรรทัดใน section จะหายหมด

set -euo pipefail

NAME="${1:-}"
AVA="${2:-.claude/ava/AVA.md}"

# ตรวจ argument — ต้องมีชื่อ logic และไฟล์ AVA.md
if [ -z "$NAME" ] || [ ! -f "$AVA" ]; then
  echo "Usage: add-import.sh <logic-name> [AVA.md path]" >&2
  exit 1
fi

IMPORT="@logics/$NAME/LOGIC.md"

# ไม่มี section (AVA.md รุ่นเก่า) → เพิ่มท้ายไฟล์
# แก้ไข: ดึง blockquote จาก template ของ ava-init แทนข้อความฝังตายตัว — ให้ข้อความมีแหล่งเดียว
if ! grep -q '^## 🧩 Active Logics' "$AVA"; then
  TEMPLATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../ava-init/templates/AVA.md"
  # หา template ไม่เจอ → หยุดก่อนแตะ AVA.md
  if [ ! -f "$TEMPLATE" ]; then
    echo "template not found: $TEMPLATE" >&2
    exit 1
  fi
  # blockquote = บรรทัด "> " ที่ติดกันใต้หัว section ใน template
  QUOTE=$(awk '/^## 🧩 Active Logics/{s=1; next} s && /^> /{print; q=1; next} s && q{exit} s && /^## /{exit}' "$TEMPLATE")
  printf '\n---\n\n## 🧩 Active Logics\n\n%s\n\n' "$QUOTE" >> "$AVA"
fi

if grep -qxF "$IMPORT" "$AVA"; then
  echo "IMPORT_EXISTS"
  exit 0
fi

# แทรกต่อจากบรรทัด @logics/ ตัวสุดท้ายใน section
# ไม่มี → ต่อจากบรรทัดสุดท้ายที่ไม่ว่าง + เว้น 1 บรรทัด ไม่ให้ติด blockquote
awk -v line="$IMPORT" '
  function flush(   i,pos){ pos=0
    for(i=1;i<=n;i++) if(buf[i] ~ /^@logics\//) pos=i
    if(!pos) for(i=n;i>=1;i--) if(buf[i] !~ /^[[:space:]]*$/ && buf[i] != "---"){pos=i;break}
    for(i=1;i<=n;i++){ print buf[i]; if(i==pos){ if(buf[i] !~ /^@logics\//) print ""; print line } }
    n=0; insec=0 }
  /^## 🧩 Active Logics/ {insec=1; print; next}
  insec && /^## / {flush()}
  insec {buf[++n]=$0; next}
  {print}
  END{ if(insec) flush() }' "$AVA" > "$AVA.tmp" && mv "$AVA.tmp" "$AVA" && echo "IMPORT_ADDED"
