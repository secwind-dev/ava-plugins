## 🛠️ Skills ทั้งหมด

### `/ava-init <ชื่อโปรเจกต์>`

**One-time setup** — สร้างไฟล์ทั้งหมดสำหรับโปรเจกต์ใหม่ในครั้งเดียว

สร้างไฟล์เหล่านี้อัตโนมัติ:

- `CLAUDE.md` — คำสั่งและ routing table สำหรับ Claude
- `.claude/ava/RULE.md` — กฎความปลอดภัย
- `.claude/ava/SOUL.md` — ตัวตนและบุคลิกภาพ
- `.claude/ava/MEMORY.md` — ความทรงจำข้ามเซสชั่น
- `.claude/ava/PROJECT.md` — ข้อมูลโปรเจกต์
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

### `/ava-explore [topic] [file1] [file2]...`

**สำรวจ topic ซับซ้อน** — ถามตอบแบบ interactive เพื่อช่วย user เรียบเรียงความต้องการที่ยังไม่ชัดเจน บันทึกผลลง `.claude/ava/explore/<topic>/`

- ไม่ระบุ topic → ถามก่อน
- โยนไฟล์ได้เลย (PDF, Excel ฯลฯ) — copy เข้า topic folder + โหลดเข้า context อัตโนมัติ
- ตรวจ session เก่าอัตโนมัติ — ถ้าโยนไฟล์มาจะต่อจากเดิมเลยโดยไม่ถาม
- ทุกรอบ Q&A มี `✏️ พิมพ์เองค่ะ` และ `❓ ถามเอวากลับ` เสมอ
- Ava ออกความเห็นหลังทุกคำตอบ แต่การตัดสินใจเป็นของ user เสมอ

---

### `/ava-deploy`

**Deploy โปรเจกต์** — อ่านและทำตาม `.claude/ava/DEPLOY.md` ทีละขั้นโดยอัตโนมัติ

- ถ้าไม่มี `DEPLOY.md` → แจ้ง user ให้รัน `/ava-init` ก่อน

---

### `/ava-commit`

**สร้าง Conventional Commit message** — วิเคราะห์ git diff แล้วสร้าง message พร้อม confirm ก่อน commit

รูปแบบ: `<type>(<scope>): <description>`
Types: `feat` / `fix` / `docs` / `refactor` / `style` / `test` / `chore` / `perf` / `ci`

---

### `/ava-review [target]`

**Code review** — วิเคราะห์ git diff แบบละเอียดพร้อม confidence level ต่อ issue

- ไม่ระบุ target → `git diff HEAD` (uncommitted changes)
- ระบุ target → เช่น `/ava-review main`, `/ava-review HEAD~3`

แสดงผล: สรุปการเปลี่ยนแปลง / จุดดี / จุดเสี่ยง (พร้อม `🔴 HIGH / 🟡 MED / ⚪ LOW`) / Breaking Changes / Security / CLAUDE.md Compliance / คะแนน

> ดึง `CLAUDE.md` และ `git log` ของไฟล์ที่เปลี่ยนมาประกอบการวิเคราะห์เพื่อลด false positive

---

### `/ava-hook <ชื่อ-hook>`

**สร้าง Claude Code hook** — guided wizard พร้อม boilerplate ครบ

- ถามว่า hook ตอบสนองต่อ event ไหน (PreToolUse / PostToolUse / Stop ฯลฯ)
- สร้างไฟล์ `.claude/hooks/<ชื่อ>.sh` พร้อม boilerplate
- ลงทะเบียนใน `.claude/settings.json` อัตโนมัติ

---

### `/ava-adc <ชื่อ function>`

**สร้าง function ใน ADC style** — รับ function signature แล้วสร้าง code แบบ Functional Programming พร้อมแนะนำ function ต่อยอด

ตัวอย่าง:

- `/ava-adc emailValid(email: string)`
- `/ava-adc getIncludeVat(price: number, vat: number)`

แสดงผล: code เต็มพร้อม comment ภาษาไทย + import ที่ต้องเพิ่ม + แนะนำ 3 function ที่ต่อยอดได้ทันที

> อ้างอิง `.claude/ava/ADC.md` — ดึงจาก GitHub อัตโนมัติถ้ายังไม่มีไฟล์

---

### `/ava-refactor-code <path> [query]`

**Refactor code** — อ่านไฟล์หรือ directory แล้ว refactor ตาม rule ใน `.claude/ava/REFACTOR.md`

- `/ava-refactor-code src/utils/helper.ts`
- `/ava-refactor-code src/components/ focus on readability`

แสดงผล: รายการเปลี่ยนแปลงพร้อม file:line / สิ่งที่ไม่แก้พร้อมเหตุผล / คำแนะนำเพิ่มเติม

> สร้าง `REFACTOR.md` ให้อัตโนมัติถ้ายังไม่มี รองรับ Functional Programming style

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

---

### `/ava-on-session [url]`

**โหลด session context** — โหลดข้อมูลเข้า context window ของ session ปัจจุบัน

- ไม่ระบุ argument → อ่านไฟล์ทั้งหมดใน `.claude/ava/session/` แล้ว load เข้า context
- ระบุ URL → fetch เนื้อหาจาก URL แล้ว load เข้า context
- ถ้ายังไม่มี folder `.claude/ava/session/` → สร้างให้อัตโนมัติพร้อมแนะนำวิธีใช้

> ⚠️ Context มีผลแค่ session ปัจจุบัน — ต้องรัน `/ava-on-session` ใหม่ทุกครั้งที่เปิด session ใหม่
> แนะนำเพิ่ม `.claude/ava/session/` ใน `.gitignore` ถ้ามีไฟล์ sensitive

---

### `/ava-docs`

**คู่มือการใช้งาน** — ดึงไฟล์นี้จาก GitHub มาแสดงสดทุกครั้ง (เสมอ up-to-date)
