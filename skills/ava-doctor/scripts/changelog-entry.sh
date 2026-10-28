#!/usr/bin/env bash
# ดึง entry ของ version ที่ระบุจาก CHANGELOG (ข้าม deploy record)
# รับ: $1 = version เช่น 2.3.0 · CHANGELOG ทาง stdin
# คืน: พิมพ์ entry ตั้งแต่ header "## [...] — v<version>" จนก่อน header "## " ถัดไป
#      (ตัด "---" และบรรทัดว่างท้าย entry) · หาไม่เจอ → ไม่พิมพ์อะไร
#
# แยกเป็น script เพราะ Claude Code แทนที่ตัวแปร positional ใน SKILL.md ด้วย argument ของ skill

set -euo pipefail

VER="${1:-}"
[ -n "$VER" ] || { echo "Usage: changelog-entry.sh <version> < CHANGELOG.md" >&2; exit 1; }

awk -v tag="v$VER" '
  # header ตรงกับ version: มี "v<ver>" แล้วตามด้วยช่องว่างหรือจบบรรทัด (เทียบ string ไม่ใช่ regex)
  function is_entry(line,   i, rest) {
    i = index(line, tag)
    if (!i) return 0
    rest = substr(line, i + length(tag))
    return rest == "" || substr(rest, 1, 1) == " "
  }
  /^## / {
    if (found) exit
    # ข้าม deploy record — เอาเฉพาะ entry ที่บอกว่าอะไรเปลี่ยน
    if (is_entry($0) && index($0, "Deploy") == 0) found = 1
  }
  found { buf[++n] = $0 }
  END {
    # ตัดบรรทัดว่างและ "---" ท้าย entry
    while (n > 0 && (buf[n] ~ /^[[:space:]]*$/ || buf[n] == "---")) n--
    for (i = 1; i <= n; i++) print buf[i]
  }'
