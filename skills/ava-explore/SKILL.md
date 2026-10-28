---
name: ava-explore
description: 'สำรวจ topic ซับซ้อนผ่านการถามตอบแบบ interactive พร้อมบันทึกลง .claude/ava/explore/<topic>/. Usage: /ava-explore [topic] [file1] [file2]...'
argument-hint: '[topic] [file paths...] (optional)'
disable-model-invocation: true
---

Skill นี้ช่วยสำรวจและค้นหาความต้องการผ่านการถามตอบ
ออกความเห็นได้เต็มที่ แต่การตัดสินใจสุดท้ายเป็นของ user เสมอ

---

## ขั้นที่ 0 — รับ Topic และ Files

Arguments ที่รับมา: `$ARGUMENTS`

**แยก arguments เป็น 2 กลุ่ม:**
- **files** = arguments ที่ขึ้นต้นด้วย `/`, `./`, `../`, `~` หรือลงท้ายด้วย extension (`.pdf`, `.xlsx`, `.xls`, `.csv`, `.docx`, `.txt`, `.md`, `.png`, `.jpg` ฯลฯ)
- **topic** = arguments ที่เหลือทั้งหมด รวมกันเป็นชื่อ topic

ตัวอย่าง:
- `/ava-explore react-hooks` → topic=`react-hooks`, files=[]
- `/ava-explore system-design ./spec.pdf ~/data.xlsx` → topic=`system-design`, files=[`./spec.pdf`, `~/data.xlsx`]
- `/ava-explore` → topic=ว่าง, files=[]

**ถ้าไม่มี topic → ใช้ `AskUserQuestion` ถามว่า:**
- **question:** "อยากสำรวจเรื่องอะไร?"
- **header:** "Topic"
- **options:**
  - `🏢 Business / Product` — flow, revenue model, user journey
  - `⚙️ Technical System` — architecture, system design, integration
  - `🎯 Strategy / Decision` — เปรียบเทียบทางเลือก, ตัดสินใจ
  - `🌐 อื่นๆ` — พิมพ์เองได้เลย

แปลง topic เป็น kebab-case สำหรับชื่อไฟล์ เช่น `Business Flow` → `business-flow`

---

## ขั้นที่ 0.3 — จัดการไฟล์ (ถ้ามี)

ทำเฉพาะเมื่อ **files ไม่ว่าง**:

```bash
mkdir -p .claude/ava/explore/<topic-kebab>
```

สำหรับแต่ละ file ที่โยนมา:

1. **ตรวจว่าไฟล์มีอยู่จริง:**
```bash
test -f "<file>" && echo "OK" || echo "NOT_FOUND"
```
- ถ้า NOT_FOUND → แจ้ง user แล้วข้ามไฟล์นั้น

2. **Copy เข้า topic folder** (ถ้ายังไม่มีไฟล์ชื่อเดียวกันอยู่แล้ว):
```bash
test -f ".claude/ava/explore/<topic-kebab>/<filename>" \
  && echo "ALREADY_EXISTS" \
  || cp "<file>" ".claude/ava/explore/<topic-kebab>/"
```
- ถ้า ALREADY_EXISTS → แจ้ง user ว่าไฟล์มีอยู่แล้ว ข้าม copy แต่ยัง read เข้า context ปกติ

3. **Read ไฟล์เข้า context** ด้วย Read tool — เพื่อให้เห็นเนื้อหาระหว่าง session

แจ้ง user:
```
📎 โหลดไฟล์เข้า context แล้ว:
  ✅ <ชื่อไฟล์1>
  ✅ <ชื่อไฟล์2>
  ...
```

---

## ขั้นที่ 0.5 — ตรวจ Session เก่า

ตรวจว่ามีไฟล์ `.claude/ava/explore/<topic-kebab>/notes.md` อยู่แล้วหรือไม่:

```bash
test -f ".claude/ava/explore/<topic-kebab>/notes.md" && echo "FOUND" || echo "NOT_FOUND"
```

**ถ้า FOUND:**
1. Read ไฟล์นั้น แล้วแสดงสรุปสั้นๆ (Key Insights + จำนวน Q&A เก่า) แก่ user
2. **ถ้ามีไฟล์โยนมา (files ไม่ว่าง)** → ต่อจากเดิมเลยทันที ไม่ต้องถาม (intent ชัดอยู่แล้ว) → โหลด Q&A Log เก่าเข้า context แล้วข้ามไปขั้นที่ 2
3. **ถ้าไม่มีไฟล์โยนมา** → ใช้ `AskUserQuestion`:
   - **question:** "พบ session เก่าของ [topic] — อยากทำอะไรต่อดี?"
   - **header:** "Session เก่า"
   - **options:**
     - `🔄 ต่อจากเดิม` — โหลด context เก่า ถามต่อจากจุดที่หยุด
     - `🆕 เริ่ม session ใหม่` — ล้าง context สร้างไฟล์ใหม่ทับ
   - ถ้าเลือก **ต่อจากเดิม** → โหลด Q&A Log เก่าเข้า context แล้วข้ามไปขั้นที่ 2
   - ถ้าเลือก **เริ่มใหม่** → ดำเนินการต่อขั้นที่ 1

**ถ้า NOT_FOUND → ข้ามไปขั้นที่ 1 ทันที**

---

## ขั้นที่ 1 — กำหนด Domain (เฉพาะ session ใหม่)

ใช้ `AskUserQuestion`:
- **question:** "สิ่งที่อยากสำรวจเรื่อง [topic] เป็นประเภทไหน?"
- **header:** "Domain"
- **options:**
  - `🏢 Business / Product` — flow, revenue model, user journey, stakeholders
  - `⚙️ Technical System` — architecture, tech stack, system design
  - `🎯 Strategy / Decision` — เปรียบเทียบทางเลือก, risks, priorities
  - `🌐 อื่นๆ` — ให้ user อธิบายเอง

บันทึก domain ไว้ใช้สร้างคำถามใน ขั้นที่ 2

---

## ขั้นที่ 2 — Loop Q&A

วนซ้ำจนกว่า user จะเลือก "พอแล้ว สรุปได้เลย"

### แต่ละรอบทำดังนี้:

**2a. สร้างคำถาม**

สร้างคำถามที่เหมาะสมโดยอิง domain + คำตอบสะสมทั้งหมด ตามหลักการ **broad → specific**:

| รอบ | โฟกัส |
|-----|--------|
| 1 | Problem / Goal หลักคืออะไร? |
| 2 | Stakeholders / ผู้เกี่ยวข้องคือใคร? |
| 3 | Constraints / ข้อจำกัดที่มีอยู่? |
| 4+ | Adaptive — ขุดลึกตามคำตอบก่อนหน้า |

เลือกถามในมุมที่ยังไม่ได้คุยถึง — ห้ามถามซ้ำสิ่งที่ตอบแล้ว

**2b. ใช้ `AskUserQuestion`:**
- **question:** "[คำถามที่สร้าง]"
- **header:** "Q[รอบที่]"
- **options:** 3-4 choices ที่ฉลาด เหมาะกับบริบท + 3 options นี้ **เสมอ** (ทุกรอบ):
  - `✏️ พิมพ์เอง` — ตอบอิสระ ไม่มีตัวเลือกที่ตรง
  - `❓ ถามกลับ` — อยากถามอะไรก่อน
  - `✅ พอแล้ว สรุปได้เลย`

ตัวอย่าง choices สำหรับ Business domain รอบที่ 1:
- `เพิ่ม revenue จาก customer เดิม`
- `หา customer กลุ่มใหม่`
- `ลด cost / process ภายใน`
- `✏️ พิมพ์เอง`
- `❓ ถามกลับ`
- `✅ พอแล้ว สรุปได้เลย`

**2c. หลัง user เลือก — แยก 4 กรณี:**

**กรณี 1 — เลือก choice ปกติ:**
แสดง **insight/ความเห็น** 2-3 ประโยค เช่น:
> "ถ้า goal คือ [X] แปลว่า constraint หลักน่าจะอยู่ที่ [Y] และสิ่งที่ต้องตัดสินใจก่อนคือ [Z]"
จากนั้นวนกลับไป **2a** เพื่อถามต่อ

**กรณี 2 — เลือก `✏️ พิมพ์เอง`:**
พิมพ์ตรงในบทสนทนาว่า:
> "พิมพ์คำตอบได้เลย 📝"

รอ user ตอบกลับ → แสดง insight → วนกลับ **2a**

**กรณี 3 — เลือก `❓ ถามกลับ`:**
พิมพ์ตรงในบทสนทนาว่า:
> "อยากถามอะไร? ❓"

รอ user ถาม → ตอบให้ครบ → **loop กลับ Q เดิม** (ถามคำถามเดิมซ้ำ ไม่ขยับรอบ)
บันทึกลง Q&A Log ในรูป `[User ถาม]: ... / [Claude ตอบ]: ...`

**กรณี 4 — เลือก `✅ พอแล้ว สรุปได้เลย`:**
ไปขั้นที่ 3

---

## ขั้นที่ 3 — สรุปและบันทึก

### 3a. สร้าง/อัปเดตไฟล์

```bash
mkdir -p .claude/ava/explore/<topic-kebab>
```

**กรณี session ใหม่** — Write ไฟล์ใหม่ที่ `.claude/ava/explore/<topic-kebab>/notes.md`:

```markdown
# [Topic] — Explore Session [YYYY-MM-DD]

## บริบท
- **Topic:** [topic]
- **Domain:** [domain ที่เลือก]

## Files
- [ชื่อไฟล์ที่โยนมา — ถ้าไม่มีให้ข้าม section นี้]

## Key Insights
- [insight สำคัญจากการถามตอบ]
- ...

## Decisions & Constraints
- [สิ่งที่ตัดสินใจแล้ว หรือข้อจำกัดที่พบ]
- ...

## Open Questions
- [คำถามที่ยังไม่มีคำตอบ — สำหรับ explore รอบต่อไป]
- ...

## Q&A Log

| รอบ | คำถาม | คำตอบ | Insight |
|-----|--------|--------|-----------------|
| 1 | ... | ... | ... |
```

**กรณีต่อ session** — Append section ต่อท้ายไฟล์เดิม:

```markdown

---

## Session [YYYY-MM-DD] (ต่อ)

### Key Insights ใหม่
- ...

### Q&A Log (ต่อ)

| รอบ | คำถาม | คำตอบ | Insight |
|-----|--------|--------|-----------------|
| ... | ... | ... | ... |
```

### 3b. แจ้งผล

```
🌅 Explore เสร็จแล้ว!

📌 Topic    : [topic]
💾 บันทึกที่ : .claude/ava/explore/<topic-kebab>/notes.md
📝 สรุป     : [Key Insights 2-3 ข้อสั้นๆ]
❓ ค้างอยู่  : [Open Questions 1-2 ข้อ]

✨ ครั้งหน้ารัน /ava-explore [topic] แล้วเลือก "ต่อจากเดิม" ได้เลย
   โยนไฟล์มาพร้อมกันได้เลย: /ava-explore [topic] file1.pdf file2.xlsx
```
