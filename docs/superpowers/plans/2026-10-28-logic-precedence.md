# ลำดับความสำคัญเมื่อ logic ขัดกับ Ava — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** logic ที่เปิดใช้ชนะกฎปกติของ Ava อัตโนมัติ, logic ชนกันเองให้ owner ตัดสิน และผู้ใช้เดิมอัปเดตได้ผ่าน `/ava-check` M6 — ออกเป็น v2.2.0

**Architecture:** blockquote ลำดับความสำคัญมีแหล่งเดียวคือ `skills/ava-init/templates/AVA.md` · `add-import.sh` และ script M6 ตัวใหม่ดึงข้อความจาก template (ไม่ฝังซ้ำ) · ส่วนที่เหลือเป็นการแก้ถ้อยคำใน SKILL.md

**Tech Stack:** bash, awk (BSD/macOS compatible), Markdown SKILL.md

**Spec:** `docs/superpowers/specs/2026-10-28-logic-precedence-design.md`

## Global Constraints

- ทำบน branch `feat/logic-precedence` — ห้าม commit บน `main` (การตัดสินใจของ owner ใน logic superpowers)
- SKILL.md ห้ามมี `$` ตามด้วยตัวเลข — awk / shell ที่ใช้ตัวแปร positional ต้องอยู่ใน `skills/<name>/scripts/`
- comment ใน script เป็นภาษาไทย · หัว script อธิบาย รับอะไร / คืนอะไร · แก้ code เดิมใส่ `# แก้ไข: [เหตุผล]`
- blockquote ใหม่ใช้ข้อความตาม spec หัวข้อ "1." **ทุกตัวอักษร**
- ข้อความใหม่ต้องไม่มีวลี `บรรทัดบนชนะบรรทัดล่าง` (ใช้เป็นตัวตรวจ M6)
- test script เก็บใน `.test/logic-precedence/` (gitignored ไม่ commit) — รันด้วย `bash`
- version ใหม่ `2.2.0`

## Review Focus

1. AVA.md มีวลีเก่าอยู่ **นอก** section Active Logics (เช่น owner จดโน้ตไว้) → M6 ต้องตอบ `M6_OK` ไม่ใช่ FOUND ตลอดไปแล้วแก้ไม่หาย — ทดสอบใน Task 2
2. หา template ไม่เจอ (layout plugin ต่างไป) → script ต้อง exit 1 พร้อมข้อความ และไม่แตะ AVA.md — ทดสอบใน Task 1, 2
3. AVA.md ใช้ CRLF → ตรวจ / แก้ได้เหมือน LF และไม่ทำให้ไฟล์ปนกัน LF/CRLF — ทดสอบใน Task 2
4. owner เพิ่มบรรทัด `> ...` ของตัวเองใน blockquote → M6 แทนที่ทั้ง blockquote (ตาม spec) จึงต้องบอกไว้ในข้อความ confirm ของ ava-check — Task 2 step 5
5. section Active Logics อยู่กลางไฟล์ (มี `## ...` ตามหลัง) → แก้เฉพาะใน section ส่วนที่ตามมาไม่แตะ — ทดสอบใน Task 2

---

### Task 0: แยก branch + commit bug fix ที่ค้างอยู่

**Files:** (มีอยู่แล้ว ยังไม่ commit) `skills/ava-doctor/SKILL.md`, `skills/ava-use-logic/SKILL.md`, `skills/ava-use-logic/scripts/add-import.sh`

- [ ] **Step 1:** `git switch -c feat/logic-precedence` → `git branch --show-current` ได้ `feat/logic-precedence`
- [ ] **Step 2:** `grep -rnE '\$[0-9]' skills/*/SKILL.md` → ไม่มีผลลัพธ์
- [ ] **Step 3: Commit**

```bash
git add skills/ava-doctor/SKILL.md skills/ava-use-logic/SKILL.md skills/ava-use-logic/scripts/add-import.sh
git commit -m "fix: ย้ายตัวแปร positional ออกจาก SKILL.md (ava-use-logic, ava-doctor)"
git add docs/superpowers/plans/2026-10-28-logic-precedence.md
git commit -m "docs(plan): implementation plan ลำดับความสำคัญของ logic"
```

---

### Task 1: blockquote ใหม่ใน template + `add-import.sh` ดึงจาก template

**Files:**
- Modify: `skills/ava-init/templates/AVA.md` (blockquote ใต้ `## 🧩 Active Logics`)
- Modify: `skills/ava-use-logic/scripts/add-import.sh` (บรรทัด `printf` สร้าง section)
- Test: `.test/logic-precedence/test-add-import.sh`

**Interfaces:**
- Produces: blockquote = บรรทัดที่ขึ้นต้นด้วย `> ` ที่ติดกันใต้หัว `## 🧩 Active Logics` ใน template — Task 2 ดึงด้วยวิธีเดียวกัน
- Produces: `add-import.sh <logic-name> [AVA.md path]` — output / exit code เหมือนเดิม (`IMPORT_ADDED` | `IMPORT_EXISTS` | exit 1) + exit 1 พร้อม `template not found` ถ้าหา template ไม่เจอ
- path ของ template จาก script: `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../ava-init/templates/AVA.md`

- [ ] **Step 1: เขียน test** — `.test/logic-precedence/test-add-import.sh` ใช้สำเนา AVA.md ใน `mktemp -d` ตรวจ:
  - `t1` AVA.md ไม่มี section → `IMPORT_ADDED` · blockquote ในไฟล์ตรงกับ blockquote ใน template ทุกบรรทัด · `grep -c 'บรรทัดบนชนะบรรทัดล่าง'` = 0
  - `t2` มี section + `@logics/superpowers/LOGIC.md` → เพิ่ม `figma` ได้ `IMPORT_ADDED` ต่อท้ายบรรทัด superpowers · รันซ้ำได้ `IMPORT_EXISTS` · `grep -c '^@logics/figma/'` = 1
  - `t3` ไม่ส่ง argument → exit 1
  - `t4` คัดลอก script ไปไว้ที่ที่ไม่มี template → exit 1 และ AVA.md ไม่เปลี่ยน (`cmp`)
- [ ] **Step 2:** `bash .test/logic-precedence/test-add-import.sh` → `t1` FAIL (ยังได้ข้อความเก่า), `t4` FAIL
- [ ] **Step 3:** แก้ blockquote ใน `templates/AVA.md` เป็นข้อความตาม spec หัวข้อ "1."
- [ ] **Step 4:** แก้ `add-import.sh`: ตอนสร้าง section ให้ดึง blockquote จาก template ด้วย awk (บรรทัด `> ` ที่ติดกันหลังหัว section) แทน `printf` ข้อความฝังตายตัว · หา template ไม่เจอ → `echo "template not found: <path>" >&2; exit 1` ก่อนแตะไฟล์
- [ ] **Step 5:** รัน test → ทุกข้อ PASS
- [ ] **Step 6: Commit** — `feat(ava-init): ลำดับความสำคัญใหม่ของ logic ใน template AVA.md`

---

### Task 2: `ava-check` M6

**Files:**
- Create: `skills/ava-check/scripts/logic-precedence.sh`
- Modify: `skills/ava-check/SKILL.md` (description, ขั้นที่ 1–4)
- Test: `.test/logic-precedence/test-m6.sh`

**Interfaces:**
- Consumes: blockquote จาก template (Task 1) — path `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../ava-init/templates/AVA.md`
- Produces: `logic-precedence.sh check|fix [AVA.md path]` (default `.claude/ava/AVA.md`)
  - `check` → พิมพ์ `M6_FOUND` เมื่อวลีเก่าอยู่ **ใน section** Active Logics เท่านั้น, ไม่งั้น `M6_OK`
  - `fix` → `M6_FIXED` | `M6_OK` (ไม่มีอะไรต้องแก้ / ไม่มี section)
  - exit 1: mode ผิด, ไม่มีไฟล์ AVA.md, หา template ไม่เจอ (ไม่แตะไฟล์)

- [ ] **Step 1: เขียน test** — `.test/logic-precedence/test-m6.sh` ตรวจ:
  - `m1` สำเนา `.claude/ava/AVA.md` ของโปรเจกต์นี้ → `check` = `M6_FOUND` · `fix` = `M6_FIXED` · blockquote ตรงกับ template · `@logics/superpowers/LOGIC.md` ยังอยู่ · `diff` กับต้นฉบับเปลี่ยนเฉพาะบรรทัด blockquote · `check` ซ้ำ = `M6_OK`
  - `m2` AVA.md ไม่มี section → `check` = `M6_OK` · `fix` = `M6_OK` · ไฟล์ไม่เปลี่ยน (`cmp`)
  - `m3` template ใหม่ → `check` = `M6_OK`
  - `m4` วลีเก่าอยู่นอก section (เพิ่มในหัวไฟล์) + section เป็นข้อความใหม่ → `check` = `M6_OK`
  - `m5` section อยู่กลางไฟล์ ตามด้วย `## ท้ายไฟล์` + เนื้อหา → `fix` แล้วส่วนหลัง section ตรงกับเดิม
  - `m6` สำเนา m1 แปลงเป็น CRLF → `check` = `M6_FOUND` · `fix` = `M6_FIXED` · ทุกบรรทัดในไฟล์ลงท้าย CRLF (`grep -c $'[^\r]$'` = 0)
  - `m7` mode ผิด / หา template ไม่เจอ → exit 1 และไฟล์ไม่เปลี่ยน
- [ ] **Step 2:** รัน test → FAIL (ยังไม่มี script)
- [ ] **Step 3:** สร้าง `logic-precedence.sh` — awk เดินไฟล์ทีละบรรทัด: เจอหัว section → อยู่ใน section จนเจอ `## ` ถัดไป · `check` หาวลีเฉพาะใน section · `fix` แทนที่กลุ่มบรรทัด `> ` แรกที่ติดกันใน section ด้วย blockquote จาก template · CRLF: ตรวจว่าไฟล์ใช้ `\r\n` ไหม แล้วตัด `\r` ก่อนประมวลผล และใส่กลับตอนเขียน · เขียนผ่านไฟล์ `.tmp` แล้ว `mv`
- [ ] **Step 4:** รัน test → ทุกข้อ PASS
- [ ] **Step 5:** แก้ `skills/ava-check/SKILL.md`
  - description เพิ่ม "อัปเดตลำดับความสำคัญของ logic ใน AVA.md"
  - ขั้นที่ 1: "ตรวจ 5 จุด" → "6 จุด" + M6 เรียก `bash "<Base directory for this skill>/scripts/logic-precedence.sh" check`
  - ขั้นที่ 2: บรรทัดแสดง issue `⚠️ M6: ลำดับความสำคัญของ logic ใน AVA.md เป็นแบบเก่า (บรรทัดบนชนะบรรทัดล่าง) — จะแทนที่ blockquote ทั้งก้อนใต้ "## 🧩 Active Logics" (บรรทัด > ที่เพิ่มเองจะหาย)`
  - ขั้นที่ 3: **Fix M6** เรียก script ด้วย `fix`
  - ขั้นที่ 4: แถว `| ลำดับความสำคัญ logic | ✅/⚠️ | อัปเดตแล้ว / ข้ามไป / ไม่มีปัญหา |`
- [ ] **Step 6:** `grep -nE '\$[0-9]' skills/ava-check/SKILL.md` → ว่าง
- [ ] **Step 7: Commit** — `feat(ava-check): M6 อัปเดตลำดับความสำคัญของ logic`

---

### Task 3: `ava-use-logic` — ถ้อยคำตามลำดับใหม่

**Files:** Modify: `skills/ava-use-logic/SKILL.md`

- [ ] **Step 1:** แก้ตามจุด (เลขบรรทัดอ้างอิงจากไฟล์ปัจจุบัน)
  - `:3` description: "ตรวจ dependency และจุดที่ขัดกับ Ava / logic อื่นแล้วถาม owner" → "ตรวจ dependency, แสดงจุดที่ logic จะเปลี่ยนพฤติกรรมของ Ava, ถาม owner เฉพาะเมื่อขัดกับ logic อื่น"
  - `:20` → `- ขัดกัน: \`RULE.md\` ชนะเสมอ → คอลัมน์ "owner ตัดสิน" ของ LOGIC.md → logic ที่เปิดใช้ชนะกฎใน AVA.md / SOUL.md · logic ชนกันเอง = ถาม owner แล้วบันทึก`
  - `:50` A2: เพิ่มให้แสดงตาราง "ชนกับ Ava" (เรื่อง / Ava / logic / owner ตัดสิน — ช่องว่างแสดงเป็น "ใช้แบบ logic") + บอกว่าถ้าอยากปรับ ให้เลือก ❌ แล้วแก้คอลัมน์ "owner ตัดสิน" ใน LOGIC.md ก่อน
  - A4: เปลี่ยนหัวเป็น "ตรวจจุดที่ขัดกับ logic อื่น" · ข้อ 1 ตัดออก · ข้อ 2: เจอเรื่องที่ชนกับ Ava ใหม่ → เพิ่มแถวในตาราง "ชนกับ Ava" โดยปล่อยคอลัมน์ "owner ตัดสิน" ว่าง ไม่ถาม · ข้อ 3: ถาม owner และบันทึกในตาราง "เมื่อใช้คู่กับ logic อื่น" **ของทั้งสอง logic** · option ของคำถาม: `ใช้แบบ <logic ที่เปิดอยู่>`, `ใช้แบบ <name>`, ข้อเสนอ
  - `:77` A5: ตัด "(ลำดับความสำคัญต่ำสุด) — แจ้ง owner ว่าสลับลำดับบรรทัดได้ถ้าต้องการให้ชนะ logic อื่น"
  - `:98` A7: `(ลำดับที่ <n>)` → ตัดออก · `⚖️ owner ตัดสิน: <จำนวน> เรื่อง` → `⚖️ เปลี่ยนพฤติกรรม Ava: <จำนวน> เรื่อง · ชนกับ logic อื่น: <จำนวน> เรื่อง (บันทึกใน LOGIC.md)`
  - `:135` C: "active เรียงตามลำดับใน AVA.md ก่อน" คงไว้ — ไม่ต้องแก้
- [ ] **Step 2: Verify**
  - `grep -n 'บรรทัดบนชนะ\|ลำดับความสำคัญต่ำสุด\|สลับลำดับ' skills/ava-use-logic/SKILL.md` → ว่าง
  - `grep -nE '\$[0-9]' skills/ava-use-logic/SKILL.md` → ว่าง
- [ ] **Step 3: Commit** — `feat(ava-use-logic): logic ชนะกฎ Ava อัตโนมัติ ถาม owner เฉพาะ logic ชนกันเอง`

---

### Task 4: `ava-connector` — ความหมายของตาราง

**Files:** Modify: `skills/ava-connector/SKILL.md`

- [ ] **Step 1:** แก้
  - `:90` `## ชนกับ Ava (owner ต้องยืนยัน)` → `## ชนกับ Ava (ว่าง = ใช้แบบ logic)`
  - `:108` → `- ทุกจุดที่ชนกับ Ava ต้องอยู่ในตาราง "ชนกับ Ava" — คอลัมน์ "owner ตัดสิน" เว้นว่าง (= ใช้แบบ logic จนกว่า owner จะแก้) ห้ามตัดสินแทน owner`
  - `:119` → `⚠️ จุดที่ logic จะเปลี่ยนพฤติกรรมของ Ava: <จำนวน> ข้อ (อยากปรับข้อไหน แก้คอลัมน์ "owner ตัดสิน" ก่อนเปิดใช้)`
- [ ] **Step 2: Verify** — `grep -n 'owner ต้องยืนยัน\|ต้องตัดสินใจ' skills/ava-connector/SKILL.md` → ว่าง
- [ ] **Step 3: Commit** — `docs(ava-connector): ตาราง ชนกับ Ava ว่าง = ใช้แบบ logic`

---

### Task 5: Release prep v2.2.0

**Files:** Modify: `.claude-plugin/plugin.json`, `CHANGELOG.md`

- [ ] **Step 1:** `plugin.json` `"version": "2.2.0"`
- [ ] **Step 2:** `CHANGELOG.md` เพิ่มบนสุด `## [2026-10-28] — v2.2.0` (ตาม format เดิม) มี
  - Changed: ลำดับความสำคัญใหม่ (logic ชนะกฎ Ava, ว่าง = ใช้แบบ logic, logic ชนกันเอง = ถาม owner, เลิก "บรรทัดบนชนะ") · `ava-use-logic` ถามเฉพาะ logic ชนกันเอง · `ava-connector` ความหมายตาราง
  - Added: `ava-check` M6
  - Fixed: ตัวแปร positional ใน SKILL.md ของ `ava-use-logic` / `ava-doctor` ถูก Claude Code แทนที่ด้วย argument
- [ ] **Step 3: Verify ทั้ง branch**
  - `bash .test/logic-precedence/test-add-import.sh && bash .test/logic-precedence/test-m6.sh` → PASS ทั้งหมด
  - `grep -rnE '\$[0-9]' skills/*/SKILL.md` → ว่าง
  - `grep -rln 'บรรทัดบนชนะ' skills/` → มีเฉพาะ `skills/ava-check/`
  - `jq -r .version .claude-plugin/plugin.json` → `2.2.0`
- [ ] **Step 4: Commit** — `chore: v2.2.0`

merge เข้า `main` / deploy ตาม `.claude/ava/DEPLOY.md` → ผ่าน `superpowers:finishing-a-development-branch` ให้ owner เลือก (ไม่อยู่ในขอบเขต plan นี้)
