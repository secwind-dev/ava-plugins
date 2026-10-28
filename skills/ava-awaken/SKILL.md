---
name: ava-awaken
description: 'เพิ่มความรู้ถาวรให้ Claude จำข้ามทุก session จาก URL หรือ file path. Usage: /ava-awaken <url|path>'
argument-hint: '<url|path>'
disable-model-invocation: true
---

argument ที่รับมา: `$ARGUMENTS`

---

## ขั้นที่ 0 — ตรวจสอบ Argument

- ถ้าไม่มี argument → แจ้ง user แล้วหยุด:

```
❌ กรุณาระบุ URL หรือ file path

Usage:
  /ava-awaken https://example.com/info.md   ← fetch จาก URL
  /ava-awaken /path/to/file.md              ← โหลดจาก file
```

- ถ้า argument ขึ้นต้นด้วย `http://` หรือ `https://` → ไปที่ **ขั้นที่ 1 (URL)**
- ถ้าเป็น path → ไปที่ **ขั้นที่ 2 (File)**

---

## ขั้นที่ 1 — Fetch จาก URL

ใช้ WebFetch tool ดึงเนื้อหาจาก URL ที่รับมา

- ถ้า fail หรือ error → แจ้ง user แล้วหยุด:

    ```
    ❌ ไม่สามารถ fetch URL ได้
    URL: <url ที่รับมา>

    กรุณาตรวจสอบ:
    - URL ถูกต้องและ public access ได้
    - Internet connection ปกติ
    - ถ้าเป็น GitHub private repo จะไม่สามารถ fetch ได้โดยตรง
    ```

- ถ้าสำเร็จ:
    - สร้าง folder: `mkdir -p .claude/ava/awaken/`
    - ตั้งชื่อไฟล์จาก URL path → แปลงเป็น kebab-case ลงท้ายด้วย `.md`
        - เช่น `https://example.com/my/page` → `my-page.md`
    - บันทึก content ลงไฟล์ `.claude/ava/awaken/<filename>.md` ด้วย Write tool
    - Load เนื้อหาเข้า session context
    - ไปที่ **ขั้นที่ 3**

---

## ขั้นที่ 2 — โหลดจาก File Path

ใช้ Read tool อ่านไฟล์จาก path ที่รับมา

- ถ้าไม่พบไฟล์หรือ error → แจ้ง user แล้วหยุด:

    ```
    ❌ ไม่พบไฟล์
    Path: <path ที่รับมา>

    กรุณาตรวจสอบว่า path ถูกต้องและไฟล์มีอยู่จริง
    ```

- ถ้าสำเร็จ:
    - สร้าง folder: `mkdir -p .claude/ava/awaken/`
    - ตั้งชื่อไฟล์จากชื่อไฟล์เดิม (basename)
    - คัดลอก content ไปบันทึกที่ `.claude/ava/awaken/<filename>` ด้วย Write tool
    - Load เนื้อหาเข้า session context
    - ไปที่ **ขั้นที่ 3**

---

## ขั้นที่ 3 — แสดง Summary

กรณีโหลดจาก URL:

```
🌅 Awaken จาก URL สำเร็จแล้ว!

🌐 URL        : <url ที่ fetch มา>
💾 บันทึกเป็น : .claude/ava/awaken/<filename>.md
📝 เรียนรู้   : <สรุปสั้นๆ ว่าเนื้อหานั้นคืออะไร>

✨ auto-load ทุก session
```

กรณีโหลดจาก file:

```
🌅 Awaken จาก File สำเร็จแล้ว!

📄 File       : <path ที่รับมา>
💾 บันทึกเป็น : .claude/ava/awaken/<filename>
📝 เรียนรู้   : <สรุปสั้นๆ ว่าเนื้อหานั้นคืออะไร>

✨ auto-load ทุก session
```
