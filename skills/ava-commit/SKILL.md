---
name: ava-commit
description: 'Generate a Conventional Commit message from git diff and commit. Usage: /ava-commit'
disable-model-invocation: true
---

---

## ขั้นที่ 1 — ดึง Git Diff

รัน Bash tool:

```bash
git diff --staged
```

ถ้าผลว่าง → รัน:

```bash
git diff HEAD
```

ถ้ายังว่างอยู่ → แจ้ง user: "ไม่พบ changes ที่จะ commit" แล้วหยุด

---

## ขั้นที่ 2 — วิเคราะห์และสร้าง Commit Message

วิเคราะห์ diff ที่ได้ แล้วสร้าง commit message ในรูปแบบ **Conventional Commits**:

```
<type>(<scope>): <description>
```

**Types:**

- `feat` — เพิ่ม feature ใหม่
- `fix` — แก้ bug
- `docs` — แก้ไข documentation
- `refactor` — refactor code ไม่เพิ่ม feature ไม่แก้ bug
- `style` — เปลี่ยน formatting, whitespace
- `test` — เพิ่ม/แก้ test
- `chore` — งาน maintenance เช่น deps, config
- `perf` — ปรับ performance
- `ci` — แก้ CI/CD pipeline

**Scope:** ชื่อ module หรือ directory หลักที่เกี่ยวข้อง (ถ้ามี)

**Description:** กระชับ ไม่เกิน 72 ตัวอักษร ภาษาไทยหรืออังกฤษ

---

## ขั้นที่ 3 — ยืนยันกับ User

ใช้ `AskUserQuestion` แสดง message ที่สร้าง:

- **question:** "สร้าง commit message ด้านล่างนี้ — ดำเนินการต่อยังไงดี?\n\n`<message>`"
- **header:** "Commit"
- **options:**
    - `✅ Commit เลย` — description: "git add -A && git commit ทันที"
    - `✏️ แก้ไข message` — description: "รอรับ message ใหม่จาก user"
    - `❌ ยกเลิก` — description: "หยุดโดยไม่ commit"

---

## ขั้นที่ 4 — ดำเนินการตามคำตอบ

**✅ Commit เลย:**

```bash
git add -A && git commit -m "<message>"
```

**✏️ แก้ไข message:**

- แจ้ง user: "กรุณาพิมพ์ commit message ที่ต้องการ"
- รับ message ใหม่จาก user
- รัน: `git add -A && git commit -m "<new message>"`

**❌ ยกเลิก:**

- แจ้ง user: "ยกเลิกแล้ว ยังไม่มีการ commit ใดๆ"
- หยุด
