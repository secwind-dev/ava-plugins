---
name: ava-audit
description: 'Security audit for codebase — ตรวจ OWASP patterns, hardcoded secrets, dependency vulnerabilities, และ code risks. Usage: /ava-audit [path]'
argument-hint: '[path หรือเว้นว่างเพื่อ audit ทั้งโปรเจกต์]'
disable-model-invocation: true
---
---

## ขั้นที่ 0 — รับ Argument

argument ที่รับมา: `$ARGUMENTS`

- ถ้ามี argument → ใช้เป็น target path
- ถ้าไม่มี → target = `.` (ทั้งโปรเจกต์)

---

## ขั้นที่ 1 — Scan Hardcoded Secrets

รัน Bash tool ในคำสั่งเดียว (ประหยัด context):

```bash
TARGET="${ARGUMENTS:-.}"
EX='--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=.next --exclude-dir=vendor --exclude=*.lock --exclude=bun.lockb'

echo "--- SECRETS ---"
grep -rn $EX -iE "(api[_-]?key|apikey|secret|token|password|passwd)\s*[:=]\s*['\"]?[a-zA-Z0-9!@#$%^&*_\-]{8,}['\"]?" "$TARGET" 2>/dev/null \
  | grep -v "example\|placeholder\|your[_-]\|<\|TODO\|REPLACE\|xxxx\|test\|changeme\|password123" | head -8

echo "--- KEYS ---"
grep -rn $EX "BEGIN.*PRIVATE KEY\|BEGIN RSA\|BEGIN EC\|BEGIN OPENSSH\|AKIA[0-9A-Z]{16}" "$TARGET" 2>/dev/null | head -5

echo "--- DB_URL ---"
grep -rn $EX -iE "(postgres|mysql|mongodb|redis)://[^@\s]+:[^@\s]+@" "$TARGET" 2>/dev/null \
  | grep -v "example\|placeholder\|user:password\|your-" | head -5
```

---

## ขั้นที่ 2 — Scan OWASP Code Patterns

รัน Bash tool ในคำสั่งเดียว:

```bash
TARGET="${ARGUMENTS:-.}"
EX='--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=.next --exclude-dir=vendor --exclude=*.lock --exclude=bun.lockb'

echo "--- SQL_INJECTION ---"
grep -rn $EX -iE "(\"|'|`)\s*SELECT.*(WHERE|FROM).*(\+|\$\{|%s|format\()" "$TARGET" 2>/dev/null \
  | grep -v "test\|spec" | head -5

echo "--- CMD_INJECTION ---"
grep -rn $EX -iE "(exec|eval|system|shell_exec|subprocess)\s*\(.*(\$|req\.|request\.|input|param|arg)" "$TARGET" 2>/dev/null \
  | grep -v "test\|spec" | head -5

echo "--- XSS ---"
grep -rn $EX -iE "(innerHTML\s*=|dangerouslySetInnerHTML|document\.write\()" "$TARGET" 2>/dev/null \
  | grep -v "test\|spec\|sanitize" | head -5

echo "--- EVAL ---"
grep -rn $EX -iE "\beval\s*\(|\bnew Function\s*\(" "$TARGET" 2>/dev/null \
  | grep -v "test\|spec" | head -5

echo "--- CORS_WILDCARD ---"
grep -rn $EX -iE "Access-Control-Allow-Origin\s*[:=]\s*['\"]?\*['\"]?" "$TARGET" 2>/dev/null | head -5

echo "--- PATH_TRAVERSAL ---"
grep -rn $EX -iE "(readFile|writeFile|open|join)\s*\(.*(\$|req\.|request\.|param|query)" "$TARGET" 2>/dev/null \
  | grep -v "test\|spec" | head -5
```

---

## ขั้นที่ 3 — ตรวจ Dependencies

รัน Bash tool ในคำสั่งเดียว (ใช้ text แทน JSON เพื่อประหยัด context):

```bash
echo "--- NPM_AUDIT ---"
if [ -f package.json ]; then
  npm audit 2>/dev/null | tail -20 || echo "NPM_AUDIT_UNAVAILABLE"
fi

echo "--- PIP_AUDIT ---"
if [ -f requirements.txt ]; then
  pip-audit 2>/dev/null | head -20 || echo "PIP_AUDIT_UNAVAILABLE"
fi
```

---

## ขั้นที่ 4 — ตรวจ Config Safety

รัน Bash tool ในคำสั่งเดียว:

```bash
TARGET="${ARGUMENTS:-.}"
EX='--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=.next --exclude-dir=vendor --exclude=*.lock --exclude=bun.lockb'

echo "--- GITIGNORE ---"
if [ ! -f .gitignore ]; then
  echo "NO_GITIGNORE"
else
  grep -q "\.env" .gitignore && echo "HAS_ENV" || echo "MISSING_ENV"
  grep -q "\.pem\|\.key\|\.p12\|\.pfx" .gitignore && echo "HAS_KEYS" || echo "MISSING_KEYS"
  grep -qxF ".claude/" .gitignore && echo "HAS_CLAUDE" || echo "MISSING_CLAUDE"
fi

echo "--- ENV_FILES ---"
find . -name ".env*" -not -path "./.git/*" -not -path "./node_modules/*" 2>/dev/null | head -5

echo "--- DEBUG_FLAGS ---"
grep -rn $EX -iE "NODE_ENV\s*[:=]\s*['\"]?development['\"]?" "$TARGET" 2>/dev/null \
  | grep -v "test\|spec\|example\|\.env" | head -5
```

---

## ขั้นที่ 5 — วิเคราะห์ผลและคำนวณ Risk Score

อ่านผล findings ทั้งหมด จัดกลุ่มตามความเสี่ยง:

- 🚨 **Critical** — Private keys, AWS keys, SQL injection ชัดเจน, eval รับ user input
- ⚠️ **High** — Hardcoded secrets, XSS จากข้อมูลผู้ใช้, command injection
- 🔶 **Medium** — CORS wildcard, path traversal, debug flags ใน production
- 💡 **Low** — Patterns ที่อาจเป็น false positive, npm warnings

**คำนวณ Risk Score (0-100):**
- เริ่มที่ 100
- Critical: -20 ต่อรายการ (min 0)
- High: -10 ต่อรายการ
- Medium: -5 ต่อรายการ
- Low: -2 ต่อรายการ

**Risk Level:**
- 80-100 → ✅ Low Risk
- 60-79 → 🔶 Medium Risk
- 40-59 → ⚠️ High Risk
- 0-39 → 🚨 Critical Risk

---

## ขั้นที่ 6 — แสดงผล Dashboard

### กรณีพบ issues:

```
🔍 Security Audit Report
════════════════════════════════════════
🎯 Target    : <path>
📊 Risk Score: [X/100] — <Risk Level>
════════════════════════════════════════

🚨 Critical (<N>)
  📍 `<file>:<line>` — <ประเภท>
     └ <อธิบายสั้นๆ>

⚠️ High (<N>)
  📍 `<file>:<line>` — <ประเภท>

🔶 Medium (<N>)
  📍 `<file>:<line>` — <ประเภท>

💡 Low (<N>)
  📍 `<file>:<line>` — <ประเภท> (อาจเป็น false positive)

════════════════════════════════════════
📦 Dependencies
  <สรุป npm audit / pip-audit — เฉพาะ critical/high เท่านั้น>

🛡️ Config
  .env gitignored    : ✅ / 🚨
  Key files gitignored: ✅ / 🚨
  .claude/ gitignored: ✅ / 🚨
  Debug flags        : ✅ / ⚠️

════════════════════════════════════════
🛠️ Priority Actions
  1. <สิ่งที่ต้องแก้ก่อน — actionable>
  2. <รายการถัดมา>

> ⚠️ ผล audit อาจมี false positive — ควรตรวจสอบแต่ละรายการก่อนแก้

════════════════════════════════════════
💡 Tip: audit นี้เพิ่ม context ไปพอสมควรแล้ว
   แนะนำให้เปิด session ใหม่ก่อนเริ่มแก้ไขโค้ด
   เพื่อให้ Claude มี context เต็มสำหรับงานถัดไป
```

### กรณีไม่พบ issues:

```
🔍 Security Audit Report
════════════════════════════════════════
🎯 Target    : <path>
📊 Risk Score: 100/100 — ✅ Low Risk

✅ ไม่พบ security issues ในโค้ดเลย!

🛡️ Config & .gitignore ครอบคลุมครบ
📦 Dependencies ไม่มี known vulnerabilities


════════════════════════════════════════
💡 Tip: แนะนำให้เปิด session ใหม่ก่อนเริ่มงานต่อไป
   เพื่อให้ Claude มี context เต็ม
```
