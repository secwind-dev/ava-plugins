## 🛠️ Skills ทั้งหมด

### `/ava-init`

**One-time setup** — สร้างไฟล์ทั้งหมดสำหรับโปรเจกต์ใหม่ในครั้งเดียว

สร้างไฟล์เหล่านี้อัตโนมัติ:

- `CLAUDE.md` — คำสั่งและ routing table สำหรับ Claude
- `.claude/ava/RULE.md` — กฎความปลอดภัย
- `.claude/ava/SOUL.md` — ตัวตนและบุคลิกภาพ
- `.claude/ava/memories/INDEX.md` — สารบัญความทรงจำ (+ โฟลเดอร์ sessions / decisions / preferences / facts)
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

### `/ava-memory [ข้อความ] | find <คำค้น> | forget <เรื่อง>`

**ความทรงจำของ Ava** — เก็บใน `.claude/ava/memories/` แยกโฟลเดอร์ตามประเภท มี `INDEX.md` เป็นสารบัญ 1 แถวต่อ 1 ไฟล์

| คำสั่ง | ทำอะไร |
| --- | --- |
| `/ava-memory` | สรุปบทสนทนานี้ลง `sessions/` + แยก decision / preference / fact เป็นไฟล์ของตัวเอง |
| `/ava-memory <ข้อความ>` | บันทึกเรื่องที่ระบุ — มีเรื่องเดิมแล้วจะอัปเดตแทนสร้างซ้ำ |
| `/ava-memory find <คำค้น>` | ค้นจาก INDEX ก่อน แล้ว grep เนื้อหา |
| `/ava-memory forget <เรื่อง>` | ลบไฟล์ + แถวใน INDEX (confirm ก่อน) |

- `INDEX.md` โหลดทุก session — ถาม "วันนี้คุยอะไรไว้บ้าง" Ava กรองจาก INDEX แล้วเปิดเฉพาะไฟล์ที่ตรง
- Ava เรียกใช้เองได้เมื่อ user พูดว่า "จำไว้" / "บันทึกไว้" หรือถามเรื่องที่เคยคุย
- memories/ เข้า git เพื่อใช้ร่วมกันทั้งทีม — ห้ามบันทึก secret / ข้อมูลส่วนบุคคล
