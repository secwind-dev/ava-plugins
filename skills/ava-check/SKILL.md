---
name: ava-check
description: 'ตรวจสอบและอัปเดต plugin structure ให้ตรงกับ version ปัจจุบัน — rename SYSTEM.md → SOUL.md, อัปเดต references, เปลี่ยนชื่อ character. Usage: /ava-check'
disable-model-invocation: true
---

ตรวจสอบและ fix migration issues ของ ava-claude-plugins อัตโนมัติ — batch fix ในครั้งเดียว

---

## ขั้นที่ 1 — ตรวจ Migration Issues

รัน Bash commands เพื่อตรวจ 4 จุด:

```bash
# M1: ตรวจว่ายังมี SYSTEM.md และยังไม่มี SOUL.md
test -f .claude/ava/SYSTEM.md && echo "M1_FOUND" || echo "M1_OK"
test -f .claude/ava/SOUL.md && echo "SOUL_EXISTS" || echo "SOUL_MISSING"
```

```bash
# M2: ตรวจ CLAUDE.md ยังมี reference ถึง SYSTEM.md ไหม
grep -q "SYSTEM\.md" CLAUDE.md 2>/dev/null && echo "M2_FOUND" || echo "M2_OK"
```

```bash
# M3: ตรวจ notify-done.sh ยังมี reference ถึง SYSTEM.md ไหม
grep -q "SYSTEM\.md" .claude/hooks/notify-done.sh 2>/dev/null && echo "M3_FOUND" || echo "M3_OK"
```

```bash
# M4: ตรวจชื่อ "อิงโกะ" ยังเหลืออยู่ใน .claude/ava/ ไหม
grep -rq "อิงโกะ" .claude/ava/ 2>/dev/null && echo "M4_FOUND" || echo "M4_OK"
```

บันทึกผลแต่ละข้อไว้ก่อน

---

## ขั้นที่ 2 — แสดงผลและขอ Confirm

**กรณีไม่พบ issue ใดเลย** → แสดงข้อความแล้วหยุด:

```
✅ Plugin structure เป็น version ปัจจุบันแล้ว ไม่มีอะไรต้อง fix
```

**กรณีพบ issue ≥ 1** → ถาม user ด้วย `AskUserQuestion`:

- **header:** `Plugin Migration Check`
- **question:** แสดงเฉพาะ issues ที่พบ เช่น:

    ```
    พบ migration issues ที่ต้อง fix:

    - ⚠️ M1: ยังมี `.claude/ava/SYSTEM.md` (ต้อง rename → SOUL.md)
    - ⚠️ M2: `CLAUDE.md` ยังมี reference ถึง SYSTEM.md
    - ⚠️ M3: `notify-done.sh` ยังมี reference ถึง SYSTEM.md
    - ⚠️ M4: พบชื่อ "อิงโกะ" ใน `.claude/ava/`

    Fix ทั้งหมดเลยไหม?
    ```

- **options:**
    - `✅ Fix ทั้งหมดเลย` — description: `แก้ทุก issue ที่พบอัตโนมัติ`
    - `❌ ข้ามไป` — description: `ไม่ทำอะไร แค่แสดง issues ที่พบ`

---

## ขั้นที่ 3 — Execute Fixes (ถ้า user เลือก Fix)

แก้ตามลำดับ — **ทำ M1 ก่อนเสมอ** เพราะ M4 ต้องการ SOUL.md:

**Fix M1** (ถ้า M1_FOUND และ SOUL_MISSING):

```bash
mv .claude/ava/SYSTEM.md .claude/ava/SOUL.md
```

**Fix M2** (ถ้า M2_FOUND):

```bash
sed -i '' 's/SYSTEM\.md/SOUL.md/g' CLAUDE.md
```

**Fix M3** (ถ้า M3_FOUND):

```bash
sed -i '' 's/SYSTEM\.md/SOUL.md/g' .claude/hooks/notify-done.sh
```

**Fix M4** (ถ้า M4_FOUND):

```bash
grep -rl "อิงโกะ" .claude/ava/ 2>/dev/null | xargs sed -i '' 's/อิงโกะ (Inko)/เอวา (Ava)/g'
```

---

## ขั้นที่ 4 — แสดงสรุปผล

รวบรวมผลทั้งหมดแสดงตาราง:

```
🔧 Plugin Migration — สรุปผล

| รายการ                   | สถานะ | รายละเอียด                        |
|--------------------------|-------|-----------------------------------|
| SYSTEM.md → SOUL.md      | ✅/⚠️  | rename แล้ว / ข้ามไป / ไม่มีปัญหา |
| CLAUDE.md reference      | ✅/⚠️  | อัปเดตแล้ว / ข้ามไป / ไม่มีปัญหา  |
| notify-done.sh reference | ✅/⚠️  | อัปเดตแล้ว / ข้ามไป / ไม่มีปัญหา  |
| ชื่อ character            | ✅/⚠️  | เอวาแล้ว / ข้ามไป / ไม่มีปัญหา   |
```

ถ้ามี ⚠️ ค้างอยู่ → แนะนำให้รัน `/ava-check` อีกครั้งหลังแก้ไขเอง
