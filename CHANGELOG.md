# Changelog

## [Unreleased]

### Added
- `.claude/ava/knowledge/` + `INDEX.md` — ข้อมูลโปรเจกต์ที่ owner เขียนเอง, Ava อ่านอย่างเดียว, ยึดเป็นหลักเมื่อขัดกับ memories (ava-init สร้างให้, Startup โหลด INDEX, routing ใน CLAUDE.md)
- skill `ava-memory` — บันทึก / ค้นหา / ลบ ความทรงจำใน `.claude/ava/memories/` (sessions / decisions / preferences / facts) พร้อม `INDEX.md` เป็นสารบัญ, Ava เรียกใช้เองได้
- `ava-init`: สร้าง `.claude/ava/memories/INDEX.md` + โฟลเดอร์ย่อย, Startup Sequence โหลด INDEX.md, SOUL.md เพิ่มกฎเสนอบันทึกความทรงจำ

### Changed
- `ava-init`: ลบขั้นถามข้อมูลเริ่มต้น (AskUserQuestion) และ argument ชื่อโปรเจกต์ — `/ava-init` ไม่ต้องรับ argument แล้ว
- `ava-init`: เลิกสร้าง `.claude/ava/PROJECT.md` (ลบ template + routing row ใน templates/CLAUDE.md + บรรทัดใน templates/CHANGELOG.md)
- `ava-init`: SOUL.md คง placeholder `[บทบาทที่ user กำหนด]` ไว้ให้ user แก้เอง (เพิ่มใน Next Steps)
- README.md / DOCS.md: อัปเดต usage และรายการไฟล์ของ ava-init
- `ava-init` templates/CHANGELOG.md: เปลี่ยน `sw-init` / `.claude/sw/` → `ava-init` / `.claude/ava/` และลบ PACKAGES.md
- `ava-init` templates/CLAUDE.md: ลบแถว routing ไป `PACKAGES.md` (ไม่มี template)
- CLAUDE.md (root): ลบแถว routing ไป `.claude/ava/PROJECT.md`

### Removed
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
