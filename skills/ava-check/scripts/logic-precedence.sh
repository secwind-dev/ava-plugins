#!/usr/bin/env bash
# M6 — ตรวจ / แก้ลำดับความสำคัญของ logic แบบเก่าใน section "## 🧩 Active Logics" ของ AVA.md
# รับ: $1 = check | fix, $2 = path ของ AVA.md (default: .claude/ava/AVA.md)
# คืน: check → M6_FOUND | M6_OK · fix → M6_FIXED | M6_OK
#      exit 1 เมื่อ mode ผิด / ไม่มี AVA.md / หา template ไม่เจอ (ไม่แตะไฟล์)
#
# แยกเป็น script เพราะ Claude Code แทนที่ตัวแปร positional ใน SKILL.md ด้วย argument ของ skill

set -euo pipefail

MODE="${1:-}"
AVA="${2:-.claude/ava/AVA.md}"
OLD_PHRASE='บรรทัดบนชนะบรรทัดล่าง'
TEMPLATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../ava-init/templates/AVA.md"

# ตรวจ argument และไฟล์ที่ต้องใช้ก่อนทำอะไร
case "$MODE" in check|fix) ;; *) echo "Usage: logic-precedence.sh check|fix [AVA.md path]" >&2; exit 1 ;; esac
[ -f "$AVA" ] || { echo "AVA.md not found: $AVA" >&2; exit 1; }
[ -f "$TEMPLATE" ] || { echo "template not found: $TEMPLATE" >&2; exit 1; }

# ตรวจว่าวลีเก่าอยู่ "ใน" section Active Logics ของไฟล์ที่ระบุหรือไม่ (นอก section ไม่นับ)
# รับ: path ของไฟล์ · คืน: พิมพ์ "yes" ถ้าเจอ
has_old_phrase() {
  awk -v p="$OLD_PHRASE" '
    { sub(/\r$/, "") }
    /^## 🧩 Active Logics/ { s=1; next }
    s && /^## / { s=0 }
    s && index($0, p) { print "yes"; exit }' "$1"
}

found=$(has_old_phrase "$AVA")

if [ "$MODE" = "check" ]; then
  [ "$found" = "yes" ] && echo "M6_FOUND" || echo "M6_OK"
  exit 0
fi

# fix: ไม่มีอะไรต้องแก้ → จบเลย ไม่แตะไฟล์
if [ "$found" != "yes" ]; then
  echo "M6_OK"
  exit 0
fi

# ดึง blockquote ใหม่จาก template ลงไฟล์ชั่วคราว (ส่งเข้า awk เป็นไฟล์แรก)
QUOTE_FILE=$(mktemp)
trap 'rm -f "$QUOTE_FILE" "$AVA.tmp"' EXIT
awk '/^## 🧩 Active Logics/{s=1; next} s && /^> /{print; q=1; next} s && q{exit} s && /^## /{exit}' "$TEMPLATE" > "$QUOTE_FILE"
# แก้ไข: template ไม่มี blockquote → หยุด (ไฟล์ว่างทำให้ awk ด้านล่างกลืน AVA.md ทั้งไฟล์จนว่าง)
if [ ! -s "$QUOTE_FILE" ]; then
  echo "template blockquote not found: $TEMPLATE" >&2
  exit 1
fi

# ไฟล์เดิมใช้ CRLF ไหม — ถ้าใช่ ใส่ \r กลับตอนเขียน
EOL=""
grep -q $'\r$' "$AVA" && EOL=$'\r'

# แทนที่กลุ่มบรรทัด "> " แรกที่ติดกันใน section ด้วย blockquote ใหม่ ส่วนอื่นคงเดิม
awk -v eol="$EOL" '
  NR == FNR { quote[++nq] = $0; next }
  { sub(/\r$/, "") }
  /^## 🧩 Active Logics/ { s=1; print $0 eol; next }
  s && /^## / { s=0 }
  s && !done && /^> / {
    if (!inq) { for (i = 1; i <= nq; i++) print quote[i] eol; inq=1 }
    next
  }
  inq { inq=0; done=1 }
  { print $0 eol }' "$QUOTE_FILE" "$AVA" > "$AVA.tmp"

# แก้ไข: ตรวจผลก่อนเขียนทับ — วลีเก่ายังอยู่ (อยู่นอกกลุ่ม "> " แรก) → ให้ owner แก้เอง ไม่แตะไฟล์
if [ "$(has_old_phrase "$AVA.tmp")" = "yes" ]; then
  echo "old precedence text is outside the first blockquote of Active Logics — edit $AVA manually" >&2
  echo "M6_MANUAL"
  exit 1
fi

mv "$AVA.tmp" "$AVA"
echo "M6_FIXED"
