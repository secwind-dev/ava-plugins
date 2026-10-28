---
name: ava-secret
description: 'Scan codebase for hardcoded secrets, API keys, and credentials that might leak via git. Usage: /ava-secret [path]'
argument-hint: '[path หรือเว้นว่างเพื่อสแกนทั้ง project]'
disable-model-invocation: true
---
---

## ขั้นที่ 0 — รับ Argument

argument ที่รับมา: `$ARGUMENTS`

- ถ้ามี argument → ใช้เป็น path เป้าหมาย เช่น `/ava-secret src/`
- ถ้าไม่มี → สแกนทั้ง project (`.`)

---

## ขั้นที่ 1 — กำหนด Exclude Patterns

กำหนด directories ที่ควรข้ามเสมอ:
- `node_modules/`
- `.git/`
- `dist/`
- `build/`
- `.next/`
- `vendor/`
- `*.lock` files (package-lock.json, yarn.lock, bun.lockb, pnpm-lock.yaml)

---

## ขั้นที่ 2 — สแกนหา Secrets

รัน Bash tool สแกนด้วย pattern ต่างๆ โดยใช้ `grep -rn`:

```bash
# กำหนด target path
TARGET="${ARGUMENTS:-.}"

# กำหนด exclude flags
EXCLUDES='--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=.next --exclude-dir=vendor --exclude="*.lock" --exclude="bun.lockb"'

# Pattern 1: API Keys ทั่วไป (sk-, pk-, rk-, ak- + string ยาว)
echo "=== API_KEY_PREFIX ==="
grep -rn $EXCLUDES -iE "(api[_-]?key|apikey)\s*[:=]\s*['\"]?[a-zA-Z0-9_\-]{16,}['\"]?" "$TARGET" 2>/dev/null | grep -v "example\|placeholder\|your[_-]\|<\|TODO\|REPLACE\|xxxx\|test[_-]key" | head -20

# Pattern 2: Secret / Token keywords
echo "=== SECRET_TOKEN ==="
grep -rn $EXCLUDES -iE "(secret|token|password|passwd|pwd)\s*[:=]\s*['\"]?[a-zA-Z0-9!@#$%^&*_\-]{8,}['\"]?" "$TARGET" 2>/dev/null | grep -v "example\|placeholder\|your[_-]\|<\|TODO\|REPLACE\|xxxx\|test\|password123\|changeme\|secret_key_here" | head -20

# Pattern 3: Private Key headers
echo "=== PRIVATE_KEY ==="
grep -rn $EXCLUDES "BEGIN.*PRIVATE KEY\|BEGIN RSA\|BEGIN EC\|BEGIN OPENSSH" "$TARGET" 2>/dev/null | head -10

# Pattern 4: AWS credentials
echo "=== AWS ==="
grep -rn $EXCLUDES -E "AKIA[0-9A-Z]{16}|aws[_-]?(secret|access)[_-]?key\s*[:=]\s*['\"]?[A-Za-z0-9/+=]{20,}" "$TARGET" 2>/dev/null | head -10

# Pattern 5: JWT tokens
echo "=== JWT ==="
grep -rn $EXCLUDES -E "eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}" "$TARGET" 2>/dev/null | grep -v "test\|example\|mock" | head -10

# Pattern 6: Database URLs with credentials
echo "=== DB_URL ==="
grep -rn $EXCLUDES -iE "(postgres|mysql|mongodb|redis|amqp)://[^@\s]+:[^@\s]+@" "$TARGET" 2>/dev/null | grep -v "example\|placeholder\|user:password\|localhost:5432\|your-" | head -10

# Pattern 7: Generic high-entropy strings ที่ assign ให้ตัวแปรชื่อ sensitive
echo "=== HIGH_ENTROPY ==="
grep -rn $EXCLUDES -iE "(private_key|client_secret|auth_token|access_token|refresh_token|bearer|authorization)\s*[:=]\s*['\"][a-zA-Z0-9+/=_\-]{20,}['\"]" "$TARGET" 2>/dev/null | grep -v "example\|placeholder\|your[_-]\|<\|TODO\|REPLACE" | head -10
```

บันทึกผลลัพธ์แต่ละ section ไว้

---

## ขั้นที่ 3 — ตรวจ .gitignore ว่าครอบคลุม secret files หรือยัง

รัน Bash tool:

```bash
# ตรวจว่า .gitignore มีอยู่ไหม
if [ ! -f .gitignore ]; then
  echo "NO_GITIGNORE"
  exit 0
fi

# ตรวจ patterns ที่ควรมีใน .gitignore
echo "=== GITIGNORE_CHECK ==="
grep -q "\.env" .gitignore && echo "HAS_ENV" || echo "MISSING_ENV"
grep -q "\.pem\|\.key\|\.p12\|\.pfx" .gitignore && echo "HAS_KEYS" || echo "MISSING_KEYS"
grep -q "secrets\|credentials" .gitignore && echo "HAS_SECRETS" || echo "MISSING_SECRETS"
```

---

## ขั้นที่ 4 — วิเคราะห์และจัดกลุ่มผลลัพธ์

อ่านผลทั้งหมดจากขั้นที่ 2-3 แล้วจัดกลุ่มเป็น:

**ระดับความเสี่ยง:**
- 🚨 **Critical** — Private keys, AWS AKIA keys, JWT tokens จริง, database URLs พร้อม credentials
- ⚠️ **Warning** — API keys, secrets, tokens ที่ดูเหมือน real value
- 💡 **Info** — พบ pattern แต่อาจเป็น placeholder หรือ test value

ถ้าไม่พบ findings เลย → ข้ามไปขั้นที่ 5 (แสดงผล clean)

---

## ขั้นที่ 5 — แสดงผล Dashboard

### กรณี ไม่พบ secrets

```
🔐 Secret Scanner — ผลการสแกน

✅ ไม่พบ hardcoded secrets!

🎯 Target : <path>
📁 Scanned: <จำนวน pattern ที่ตรวจ> pattern groups

.gitignore Coverage:
  <แสดงสถานะแต่ละรายการ>

โค้ดปลอดภัยดี 🎉
```

---

### กรณี พบ secrets

```
🔐 Secret Scanner — ผลการสแกน

⚠️ พบรายการที่ต้องตรวจสอบ!

🎯 Target : <path>

---

### 🚨 Critical (<จำนวน> รายการ)

<สำหรับแต่ละ finding ให้แสดง:>
📍 `<file>:<line>` — <ประเภท secret เช่น "Private Key", "AWS Key">
   ข้อควรระวัง: <อธิบายสั้นๆ ว่าทำไมถึงอันตราย>

---

### ⚠️ Warning (<จำนวน> รายการ)

📍 `<file>:<line>` — <ประเภท เช่น "API Key", "Token">

---

### 💡 Info (<จำนวน> รายการ)

📍 `<file>:<line>` — <ประเภท> (อาจเป็น placeholder)

---

### 📋 .gitignore Coverage

| ไฟล์ประเภท | สถานะ |
|-----------|-------|
| .env files | ✅ / 🚨 ยังไม่ครอบคลุม |
| Key files (.pem, .key) | ✅ / 🚨 ยังไม่ครอบคลุม |
| Secret files | ✅ / 🚨 ยังไม่ครอบคลุม |

---

### 🛠️ คำแนะนำ

1. ย้าย secrets ทั้งหมดไปไว้ใน `.env` แล้วใช้ `process.env.KEY_NAME` แทน
2. เพิ่มไฟล์ที่ sensitive เข้า `.gitignore` ก่อน push
3. ถ้า secret หลุด git ไปแล้ว → **ต้อง rotate key ทันที** อย่าแค่ลบออกจาก code
4. พิจารณาใช้ secret manager เช่น AWS Secrets Manager, Vault, หรือ GitHub Secrets

> ⚠️ **หมายเหตุ:** ผล scan อาจมี false positive — ควรตรวจสอบแต่ละรายการด้วยตัวเอง
```
