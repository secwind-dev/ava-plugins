---
name: ava-deploy
description: 'Deploy โปรเจกต์โดยอ่านและทำตาม .claude/ava/DEPLOY.md ทีละขั้น. Usage: /ava-deploy'
disable-model-invocation: true
---

## ขั้นที่ 1 — ตรวจสอบ DEPLOY.md

ตรวจสอบว่ามีไฟล์ `.claude/ava/DEPLOY.md` อยู่หรือไม่:

```bash
test -f .claude/ava/DEPLOY.md && echo "FOUND" || echo "NOT_FOUND"
```

- ถ้า `NOT_FOUND` → แจ้ง user แล้วหยุด:

```
❌ ไม่พบ .claude/ava/DEPLOY.md

กรุณารัน /ava-init ก่อนเพื่อสร้างไฟล์ทั้งหมด
```

---

## ขั้นที่ 2 — อ่านและทำตาม DEPLOY.md

ใช้ Read tool อ่าน `.claude/ava/DEPLOY.md` แล้วทำตามคำสั่งทุกขั้นตามลำดับ **โดยไม่ต้องรอ confirm จาก user**
