---
name: ava-review
description: 'Read git diff and perform code review with feedback, risks, and best practices. Usage: /ava-review [target]'
argument-hint: '[branch/commit หรือเว้นว่างเพื่อ review ทุก uncommitted changes]'
disable-model-invocation: true
---
---

## ขั้นที่ 1 — กำหนด target

argument ที่รับมา: `$ARGUMENTS`

- ถ้ามี argument → ใช้เป็น target เช่น `/ava-review main` → `git diff main`
- ถ้าไม่มี argument → ใช้ `git diff HEAD` (ทุก uncommitted changes ทั้ง staged + unstaged รวมกัน)

---

## ขั้นที่ 2 — รวบรวม context ด้วย Bash แบบ parallel

รันคำสั่งต่อไปนี้ทั้งหมดพร้อมกัน:

```bash
# 2a. ดึง diff stat (ภาพรวม)
git diff --stat HEAD   # หรือ git diff --stat <target> ถ้ามี argument

# 2b. ดึง diff เต็ม
git diff HEAD          # หรือ git diff <target> ถ้ามี argument

# 2c. ดึง CLAUDE.md + ไฟล์กฎของ Ava (ถ้ามี) เพื่อรู้ convention ของโปรเจกต์
cat CLAUDE.md .claude/CLAUDE.md .claude/ava/AVA.md 2>/dev/null || echo "NO_CLAUDE_MD"

# 2d. ดึง git log 5 commits ล่าสุดของไฟล์ที่เปลี่ยน (เพื่อดู context ประวัติ)
git diff --name-only HEAD | head -20 | xargs -I{} git log --oneline -3 -- {} 2>/dev/null
```

ถ้า diff (2b) ว่างเปล่า ให้รัน fallback:

```bash
# fallback สำหรับ repo ใหม่ที่ยังไม่มี commit (HEAD ไม่มี)
git diff --cached --stat
git diff --cached
```

---

## ขั้นที่ 3 — ตรวจสอบ diff

- ถ้า diff ยังว่างอยู่ → แจ้ง user:

```
ไม่พบการเปลี่ยนแปลงที่จะ review

💡 ลองใช้:
   /ava-review main     — เปรียบเทียบกับ branch main
   /ava-review HEAD~3   — ย้อนกลับ 3 commits
```

แล้วหยุด

---

## ขั้นที่ 4 — วิเคราะห์และแสดงผล Review

อ่าน diff และ context ทั้งหมด แล้ววิเคราะห์อย่างละเอียดตามหัวข้อด้านล่าง

**หลักการวิเคราะห์:**
- ถ้ามี CLAUDE.md → ตรวจว่าโค้ดใหม่ละเมิดกฎใน CLAUDE.md หรือไม่
- ถ้ามี git log → ตรวจว่า issue ที่พบเป็น pre-existing issue หรือของใหม่
- แต่ละ issue ต้องระบุ confidence level: `🔴 HIGH` / `🟡 MED` / `⚪ LOW`
- ละเว้น issue ระดับ LOW ที่เป็น nitpick หรือ false positive ชัดเจน

จากนั้นแสดงผลในรูปแบบต่อไปนี้:

---

## 📝 Code Review

> 🎯 Target: `<target ที่ใช้>` | 📁 `<จำนวนไฟล์>` ไฟล์ | ➕`<บรรทัดที่เพิ่ม>` ➖`<บรรทัดที่ลบ>`

---

### 📋 สรุปการเปลี่ยนแปลง

[อธิบายภาพรวมว่าโค้ดเปลี่ยนแปลงอะไรบ้าง ใน 3-5 bullet points]

---

### ✅ จุดดี

[สิ่งที่ทำได้ดีในโค้ดนี้ — ถ้าไม่มีให้ข้ามหัวข้อนี้]

---

### ⚠️ จุดเสี่ยง / ปัญหา

[ปัญหาที่พบ พร้อมระบุไฟล์และบรรทัด เรียงลำดับจาก confidence สูงไปต่ำ]

- แต่ละจุดใช้รูปแบบ: `🔴 HIGH` `📍 file.ts:NN` — [อธิบายปัญหา]
- ถ้าไม่มีปัญหา → แสดง "✅ ไม่พบจุดเสี่ยง"

ระดับ confidence:
- `🔴 HIGH` — มั่นใจว่าเป็น bug จริง หรือละเมิด CLAUDE.md ชัดเจน
- `🟡 MED` — น่าจะเป็นปัญหา แต่อาจ intentional
- `⚪ LOW` — แนะนำเพิ่มเติม ไม่บังคับแก้

---

### 💥 Breaking Changes

[ตรวจสอบว่า function signature, interface, หรือ export ที่ไฟล์อื่น depend อยู่ถูกเปลี่ยนหรือลบไปไหม]

- ถ้าไม่มี → แสดง "✅ ไม่พบ breaking changes"

---

### 🔒 Security

[ตรวจสอบด้าน security เช่น injection, exposed secrets, insecure dependencies, XSS]

- ถ้าไม่มีความเสี่ยง → แสดง "✅ ไม่พบความเสี่ยงด้าน security"

---

### 📏 CLAUDE.md Compliance

[แสดงเฉพาะเมื่อพบ CLAUDE.md — ระบุว่าโค้ดใหม่ผ่านหรือละเมิดกฎใดบ้าง]

- ถ้าไม่มี CLAUDE.md → ข้ามหัวข้อนี้
- ถ้าผ่านทุกกฎ → แสดง "✅ ผ่าน CLAUDE.md ทุกข้อ"

---

### 💡 Best Practice & คำแนะนำ

[แนะนำการปรับปรุงที่ควรทำ — เน้น actionable ระดับ HIGH/MED เท่านั้น]

---

### 🏁 สรุป

| หัวข้อ | ผล |
|--------|-----|
| Code Quality | [⭐⭐⭐⭐⭐ / 5 พร้อมคำอธิบายสั้น] |
| Security | [✅ ปลอดภัย / ⚠️ มีความเสี่ยง / 🚨 Critical] |
| Breaking Changes | [✅ ไม่มี / 🚨 มี — ระบุ] |
| CLAUDE.md | [✅ ผ่าน / ⚠️ ละเมิด N ข้อ / — ไม่มีไฟล์] |
| ควร commit? | [✅ พร้อม commit / ⚠️ ควรแก้ก่อน / 🚫 ยังไม่ควร] |
