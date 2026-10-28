## 🛠️ Skills ทั้งหมด

### `/ava-init`

**One-time setup** — สร้างไฟล์ทั้งหมดสำหรับโปรเจกต์ใหม่ในครั้งเดียว

สร้างไฟล์เหล่านี้อัตโนมัติ:

- `CLAUDE.md` — คำสั่งและ routing table สำหรับ Claude
- `.claude/ava/RULE.md` — กฎความปลอดภัย
- `.claude/ava/SOUL.md` — ตัวตนและบุคลิกภาพ
- `.claude/ava/MEMORY.md` — ความทรงจำข้ามเซสชั่น
- `.claude/ava/DEPLOY.md` — คู่มือ deploy
- `CHANGELOG.md` — บันทึกการเปลี่ยนแปลง
- `.claude/hooks/` — default hooks (track-action + notify-done)

---

### `/ava-check`

**ตรวจสอบ environment** — รันครั้งเดียวได้ dashboard สรุปทันที

ตรวจสอบ:

- Node.js / Bun version
- Git user.name / user.email
- Package manager (npm / yarn / bun / pnpm)
- `.env` safety (gitignored หรือยัง)
- `.claude/` safety (gitignored หรือยัง)

---

### `/ava-review [target]`

**Code review** — วิเคราะห์ git diff แบบละเอียดพร้อม confidence level ต่อ issue

- ไม่ระบุ target → `git diff HEAD` (uncommitted changes)
- ระบุ target → เช่น `/ava-review main`, `/ava-review HEAD~3`

แสดงผล: สรุปการเปลี่ยนแปลง / จุดดี / จุดเสี่ยง (พร้อม `🔴 HIGH / 🟡 MED / ⚪ LOW`) / Breaking Changes / Security / CLAUDE.md Compliance / คะแนน

> ดึง `CLAUDE.md` และ `git log` ของไฟล์ที่เปลี่ยนมาประกอบการวิเคราะห์เพื่อลด false positive

---

### `/ava-validate [task]`

**ตรวจงานสำคัญก่อนส่ง** — เลือกระดับการตรวจ แก้ checklist ได้ก่อนเริ่ม

- ไม่ระบุ task → ตรวจงานล่าสุดในบทสนทนา
- ระบุ task → เช่น `/ava-validate ฟังก์ชันคำนวณดอกเบี้ย`

ขั้นตอน: เลือกระดับ L1/L2/L3 → อนุมัติ/แก้ checklist → ตรวจ → รายงาน (ตรวจแล้ว / ยังไม่ได้ตรวจ / ความเสี่ยงที่เหลือ)

| ระดับ | ตรวจอะไร |
|---|---|
| L1 ปกติ | ผลจริง 1 รอบ |
| L2 สำคัญ | + edge case, breaking changes, test suite |
| L3 วิกฤต | + checklist เฉพาะด้าน (การเงิน / สัญญา / ข้อมูลส่วนบุคคล) + ผู้ตรวจอิสระ `ava-validator` |

> ผู้ตรวจอิสระรับบทบาทและบริบทเฉพาะงานทุกครั้ง ไม่เห็นเหตุผลของผู้เขียน ไม่มี Write/Edit (ยังมี Bash ไว้รัน test — ห้ามเขียนไฟล์ด้วยกฎใน prompt) · พบ 🔴 แก้ได้ 1 รอบ ไม่วนต่อ

---

### `/ava-secret [path]`

**สแกน hardcoded secrets** — ตรวจหา API keys, passwords, private keys, AWS credentials ใน codebase

- ไม่ระบุ path → สแกนทั้งโปรเจกต์
- ระบุ path → สแกนเฉพาะ directory/file นั้น

แสดงผล: findings จัดกลุ่มตาม severity (Critical/Warning/Info) + .gitignore coverage

---

### `/ava-audit [path]`

**Security audit แบบ comprehensive** — ตรวจ OWASP Top 10 patterns, hardcoded secrets, dependency vulnerabilities, และ config safety

- ไม่ระบุ → audit ทั้งโปรเจกต์
- `<path>` → audit เฉพาะ path นั้น

แสดงผล: Risk Score (0-100), findings จัดกลุ่ม Critical/High/Medium/Low, คำแนะนำเรียงลำดับ priority

> แนะนำให้เปิด session ใหม่หลัง audit เสมอ เพื่อให้ Claude มี context เต็มสำหรับงานถัดไป

---

### `/ava-version`

**แสดง version** — เช็ค version ของ ava-claude-plugins ที่ติดตั้งอยู่ในปัจจุบัน

---

### `/ava-doctor`

**ตรวจสอบ version** — เช็คว่า plugin ที่ติดตั้งอยู่เป็น version ล่าสุดหรือยัง

- เปรียบเทียบ local version กับ GitHub
- ถ้ามี version ใหม่ → แสดง changelog + คำสั่ง update
- ถ้าเป็น version ล่าสุดแล้ว → แจ้งว่าไม่ต้องทำอะไร

---

### `/ava-awaken [url]`

**ความรู้ถาวรข้ามทุก session** — สอนเอวาให้รู้จักบางอย่างตลอดไป เช่น ข้อมูลบริษัท, spec โปรเจกต์

- ไม่ระบุ argument → โหลดไฟล์ทั้งหมดใน `.claude/ava/awaken/` เข้า context
- ระบุ URL → fetch เนื้อหา + **บันทึกเป็นไฟล์ถาวร** ใน `.claude/ava/awaken/`
- ถ้ายังไม่มี folder → สร้างให้อัตโนมัติ + ตั้งค่า auto-load ใน `SOUL.md`

> ✨ ความรู้ใน `awaken/` จะ **auto-load ทุก session** โดยอัตโนมัติ ไม่ต้องรันซ้ำ
> ⚠️ ไฟล์ใหญ่มากอาจกิน context window ทุก session — แนะนำเก็บเฉพาะข้อมูลสำคัญ
