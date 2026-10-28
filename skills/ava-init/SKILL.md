---
name: ava-init
description: 'One-time project setup wizard. Usage: /ava-init. Creates CLAUDE.md, RULE.md, SOUL.md, memories/INDEX.md, CHANGELOG.md, and DEPLOY.md for a new project.'
disable-model-invocation: true
---

คุณคือ Setup Wizard สำหรับโปรเจกต์ใหม่ ทำตามขั้นตอนด้านล่างทีละขั้นตามลำดับ

---

## ขั้นที่ 1 — สร้างไฟล์ทั้งหมด

สร้างไฟล์ต่อไปนี้ตามลำดับโดยใช้ tool `Read` อ่าน template แล้วใช้ tool `Write` สร้างที่ปลายทาง แทนที่ `[วันที่ปัจจุบัน]` ด้วยวันที่จริงในรูปแบบ YYYY-MM-DD:

> **Template path:**
>
> Template ทั้งหมดอยู่ที่ `<Base directory for this skill>/templates/`
> โดย `<Base directory for this skill>` คือ path ที่ระบุใน header ของ skill นี้
> ตัวอย่าง: ถ้า base dir = `/path/to/skills/ava-init` → template อยู่ที่ `/path/to/skills/ava-init/templates/CLAUDE.md`

> **โครงสร้าง path ปลายทาง:**
>
> - `CLAUDE.md` และ `CHANGELOG.md` → สร้างที่ root ของโปรเจกต์
> - ไฟล์ที่เหลือทั้งหมด → สร้างใน `.claude/ava/`

### CLAUDE.md

อ่านจาก template: `<base_dir>/templates/CLAUDE.md`
ใช้ Write tool สร้างที่ `CLAUDE.md` (root) — ไม่มี placeholder ในไฟล์นี้

### .claude/ava/RULE.md

อ่านจาก template: `<base_dir>/templates/RULE.md`
ใช้ Write tool สร้างที่ `.claude/ava/RULE.md` — ไม่มี placeholder ในไฟล์นี้

### .claude/ava/SOUL.md

อ่านจาก template: `<base_dir>/templates/SOUL.md`
ใช้ Write tool สร้างที่ `.claude/ava/SOUL.md`
คง `[บทบาทที่ user กำหนด]` ไว้ตามเดิม — ให้ user แก้เองภายหลัง

### .claude/ava/memories/INDEX.md

อ่านจาก template: `<base_dir>/templates/memories/INDEX.md`
ใช้ Write tool สร้างที่ `.claude/ava/memories/INDEX.md` — ไม่มี placeholder ในไฟล์นี้ (สารบัญความทรงจำ จัดการผ่าน `/ava-memory`)

### CHANGELOG.md

อ่านจาก template: `<base_dir>/templates/CHANGELOG.md`
ใช้ Write tool สร้างที่ `CHANGELOG.md` (root)
แทนที่ `[วันที่ปัจจุบัน]` ด้วยวันที่จริง

### .claude/ava/DEPLOY.md

อ่านจาก template: `<base_dir>/templates/DEPLOY.md`
ใช้ Write tool สร้างที่ `.claude/ava/DEPLOY.md` — ไม่มี placeholder ในไฟล์นี้

---

## ขั้นที่ 2 — สร้าง Default Hooks

### 2.1 — สร้างโฟลเดอร์

```bash
mkdir -p .claude/hooks .claude/ava/memories/sessions .claude/ava/memories/decisions .claude/ava/memories/preferences .claude/ava/memories/facts
```

### 2.2 — สร้าง track-action.sh

อ่านจาก template: `<base_dir>/templates/hooks/track-action.sh`
ใช้ Write tool สร้างที่ `.claude/hooks/track-action.sh`

### 2.3 — สร้าง notify-done.sh

อ่านจาก template: `<base_dir>/templates/hooks/notify-done.sh`
ใช้ Write tool สร้างที่ `.claude/hooks/notify-done.sh`

### 2.4 — ให้สิทธิ์ execute ทั้ง 2 ไฟล์

```bash
chmod +x .claude/hooks/track-action.sh
chmod +x .claude/hooks/notify-done.sh
```

จากนั้น append `.claude/hooks/last-action.tmp` เข้า `.gitignore` (ถ้ายังไม่มี):

```bash
grep -qxF '.claude/hooks/last-action.tmp' .gitignore 2>/dev/null || echo '.claude/hooks/last-action.tmp' >> .gitignore
```

### 2.5 — ลงทะเบียน hooks ใน .claude/settings.json

อ่านไฟล์ `.claude/settings.json` ก่อน

- ถ้าไม่มีไฟล์ → อ่านจาก template: `<base_dir>/templates/settings.json` แล้วใช้ Write tool สร้างที่ `.claude/settings.json`
- ถ้ามีอยู่แล้ว → อ่านเนื้อหาเดิมก่อน แล้ว Write ทับโดยรวม hooks ใหม่เข้ากับ config เดิม

> **หมายเหตุ:** ถ้าไฟล์เดิมมี keys อื่นนอกจาก `hooks` (เช่น `model`, `permissions`) ให้คงไว้และ merge เฉพาะส่วน `hooks` เข้าไป

---

## ขั้นที่ 3 — แจ้งผลและ Next Steps

หลังสร้างไฟล์ครบทั้งหมดแล้ว แจ้ง user ดังนี้:

```
✅ Setup เสร็จแล้ว! สร้างไฟล์ 8 ไฟล์ + 1 โฟลเดอร์ + ตั้งค่า 1 config

📁 ไฟล์ที่สร้าง:
✅ CLAUDE.md
✅ CHANGELOG.md
✅ .claude/ava/RULE.md
✅ .claude/ava/SOUL.md
✅ .claude/ava/memories/INDEX.md
✅ .claude/ava/DEPLOY.md
✅ .claude/hooks/track-action.sh
✅ .claude/hooks/notify-done.sh
✅ .claude/settings.json

📂 โฟลเดอร์ที่สร้าง:
✅ .claude/ava/memories/ — ความทรงจำแยกตามประเภท sessions / decisions / preferences / facts (ใช้กับ /ava-memory)

📌 Next Steps:

1. แก้ `[บทบาทที่ user กำหนด]` ใน `.claude/ava/SOUL.md` ให้เป็นบทบาทของ Claude ในโปรเจกต์นี้
2. package recommend สำหรับ update version package.json รัน `npm install -D @changesets/cli` แล้วรัน `npx changeset init`
3. รัน skill /ava-check เพื่อตรวจสอบว่าไฟล์ทั้งหมดถูกโหลดและไม่มีปัญหา

พร้อมเริ่มงานแล้ว! 🚀
```
