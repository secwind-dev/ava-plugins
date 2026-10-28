---
name: ava-docs
description: 'แสดงคู่มือการใช้งาน ava-claude-plugins ทั้งหมด โดยดึงข้อมูลสดจาก GitHub เสมอ. Usage: /ava-docs'
disable-model-invocation: true
---
---

## ขั้นที่ 1 — ดึง DOCS.md จาก GitHub

รัน Bash tool:

```bash
curl -sf "https://raw.githubusercontent.com/secwind-dev/ava-plugins/main/DOCS.md"
```

- ถ้าสำเร็จ → นำ content ไปแสดงในขั้นที่ 2
- ถ้า fail → แจ้ง user:
  ```
  ❌ ไม่สามารถเชื่อมต่อ GitHub ได้
  กรุณาตรวจสอบ internet connection แล้วลองใหม่
  ```
  แล้วหยุด

---

## ขั้นที่ 2 — แสดงผล

แสดง content ที่ได้จาก DOCS.md ทั้งหมดให้ user เห็นโดยตรง — ไม่ต้องสรุปหรือแปลงรูปแบบ
