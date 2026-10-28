# Changelog

## [2026-10-28] — v2.1.0

### Added
- skill `ava-connector` — วิเคราะห์ repo ภายนอกแล้วร่าง logic ใน `.claude/ava/logics/<name>/LOGIC.md` (pin commit SHA, สถานะ draft, ห้าม copy เนื้อหา skill, กฎกัน prompt injection)
- skill `ava-use-logic` — เปิด / ปิด / list logic: บังคับ owner review, ตรวจ dependency, ถาม owner เมื่อขัดกับ Ava / logic อื่น แล้วเพิ่มบรรทัด `@logics/<name>/LOGIC.md` ใน section Active Logics ของ AVA.md (1 บรรทัด = 1 logic, บนชนะล่าง), `list` สแกน frontmatter ของคลัง
- `ava-init` สร้างโฟลเดอร์คลัง `.claude/ava/logics/`, AVA.md เพิ่ม section Active Logics (การตัดสินใจเมื่อขัดกันเก็บในตาราง "ชนกับ Ava" ของแต่ละ LOGIC.md)

## [2026-10-28] — v2.0.0 🚀 Deploy

### 🚀 Deploy

- pushed to `main` (aadca00..ab5f364)

---

## [2026-10-28] — v2.0.0

### Changed
- กฎของ Ava ย้ายจาก `CLAUDE.md` (root) → `.claude/ava/AVA.md` แล้ว import ด้วย `@.claude/ava/AVA.md` — ava-init ไม่เขียนทับ CLAUDE.md เดิมอีก (สร้าง / append / ข้าม แบบ idempotent) เพื่อไม่ชนกับโปรเจกต์หรือ plugin อื่น
- template `CLAUDE.md` → `AVA.md`, RULE.md / ava-memory อ้างถึง AVA.md
- ava-review อ่าน `.claude/ava/AVA.md` ด้วย, ava-check เพิ่ม M5 ย้าย layout เก่าให้อัตโนมัติ
- `ava-init`: ลบขั้นถามข้อมูลเริ่มต้น (AskUserQuestion) และ argument ชื่อโปรเจกต์ — `/ava-init` ไม่ต้องรับ argument แล้ว
- `ava-init`: เลิกสร้าง `.claude/ava/PROJECT.md` (ลบ template + routing row ใน templates/CLAUDE.md + บรรทัดใน templates/CHANGELOG.md)
- `ava-init`: SOUL.md คง placeholder `[บทบาทที่ user กำหนด]` ไว้ให้ user แก้เอง (เพิ่มใน Next Steps)
- README.md / DOCS.md: อัปเดต usage และรายการไฟล์ของ ava-init
- `ava-init` templates/CHANGELOG.md: เปลี่ยน `sw-init` / `.claude/sw/` → `ava-init` / `.claude/ava/` และลบ PACKAGES.md
- `ava-init` templates/CLAUDE.md: ลบแถว routing ไป `PACKAGES.md` (ไม่มี template)
- CLAUDE.md (root): ลบแถว routing ไป `.claude/ava/PROJECT.md`

- ava-init เลิกสร้าง activity log `CHANGELOG.md` + ลบกฎ "แก้ไฟล์ใดๆ → บันทึก CHANGELOG ทุกครั้ง" ใน AVA.md — ซ้ำกับ git log และ `memories/sessions/` (release changelog ของโปรเจกต์ยังจัดการผ่าน DEPLOY.md / changesets ตามเดิม)

### Added
- `.claude/ava/knowledge/` + `INDEX.md` — ข้อมูลโปรเจกต์ที่ owner เขียนเอง, Ava อ่านอย่างเดียว, ยึดเป็นหลักเมื่อขัดกับ memories (ava-init สร้างให้, Startup โหลด INDEX, routing ใน CLAUDE.md)
- skill `ava-memory` — บันทึก / ค้นหา / ลบ ความทรงจำใน `.claude/ava/memories/` (sessions / decisions / preferences / facts) พร้อม `INDEX.md` เป็นสารบัญ, Ava เรียกใช้เองได้
- `ava-init`: สร้าง `.claude/ava/memories/INDEX.md` + โฟลเดอร์ย่อย, Startup Sequence โหลด INDEX.md, SOUL.md เพิ่มกฎเสนอบันทึกความทรงจำ

### Removed
- `DOCS.md` ทั้งไฟล์ — ใช้ README.md เป็นเอกสารหลักแทน
- README.md: แถว `DOCS.md` `**Version:**` ในตาราง deploy (DOCS ไม่มี field นี้)
- skill `ava-awaken` + โฟลเดอร์ `.claude/ava/awaken/` (ava-init, Startup Sequence, README, DOCS)
- `MEMORY.md` (template + routing) — แทนด้วย `.claude/ava/memories/`
- skill `ava-hook`, `ava-explore`, `ava-docs`, `ava-commit`, `ava-deploy`, `ava-adc`, `ava-on-session`, `ava-refactor-code` พร้อม section ใน README.md / DOCS.md
- `ava-init`: เลิกสร้างโฟลเดอร์ `.claude/ava/session/` (ใช้กับ ava-on-session เท่านั้น)
- `ava-init`: ลบ Next Step ที่ให้พิมพ์ `ava-status` (ไม่มี skill นี้)

## [1.0.0] - 2026-10-28

### Added
- เริ่มโปรเจกต์ ava-plugins — แยกมาจาก claude-plugins v1.14.0 (fresh copy ไม่เอา history)
- เปลี่ยนตัวตนจาก ไอโกะ (Aiko) → เอวา (Ava)
- rename skill ทั้งชุด `sw-*` → `ava-*`, agent `sw-validator` → `ava-validator`
- ย้ายโฟลเดอร์ config `.claude/sw/` → `.claude/ava/`
- เปลี่ยนชื่อ plugin เป็น `ava-claude-plugins`, marketplace เป็น `ava-plugins`, repo เป็น `secwind-dev/ava-plugins`
