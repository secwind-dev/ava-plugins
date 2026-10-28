---
name: ava-refactor-code
description: 'Refactor code at given path based on rules in .claude/ava/REFACTOR.md — สร้างไฟล์ rule อัตโนมัติถ้ายังไม่มี. Usage: /ava-refactor-code <path> [query]'
argument-hint: '<path> [query เพิ่มเติม เช่น "focus on performance" หรือ "ลด complexity"]'
disable-model-invocation: true
---
---

## ขั้นที่ 0 — รับ Argument

argument ที่รับมา: `$ARGUMENTS`

- แยก argument ออกเป็น 2 ส่วน:
  - `PATH_ARG` = ส่วนแรก (required) — path ของไฟล์หรือ directory ที่ต้องการ refactor
  - `QUERY_ARG` = ส่วนที่เหลือ (optional) — คำสั่งเพิ่มเติมจาก user

- ถ้าไม่มี argument เลย → แจ้ง user:

```
กรุณาระบุ path ที่ต้องการ refactor

Usage: /ava-refactor-code <path> [query]
ตัวอย่าง:
  /ava-refactor-code src/utils/helper.ts
  /ava-refactor-code src/components/ focus on readability
  /ava-refactor-code app.py ลด complexity และเพิ่ม error handling
```

แล้วหยุด

---

## ขั้นที่ 1 — ตรวจสอบและโหลด REFACTOR.md

ใช้ Read tool อ่านไฟล์ `.claude/ava/REFACTOR.md`

**ถ้าไม่พบไฟล์ → สร้างอัตโนมัติ** โดยใช้ Write tool สร้างที่ path `.claude/ava/REFACTOR.md` ด้วยเนื้อหานี้:

~~~markdown
# REFACTOR.md

> กฎและแนวทางสำหรับ refactor code ในโปรเจกต์นี้
> แก้ไขไฟล์นี้ได้เพื่อปรับ rule ตามความต้องการของโปรเจกต์

---

## หลักการทั่วไป (General Principles)

- **อ่านก่อนแก้** — เข้าใจ logic เดิมก่อนเสนอการเปลี่ยนแปลงทุกครั้ง
- **เปลี่ยนน้อยที่สุด** — แก้เฉพาะที่จำเป็น ไม่ over-engineer
- **ไม่เปลี่ยน behavior** — ผลลัพธ์ต้องเหมือนเดิม เว้นแต่ user ขอ
- **ตั้งชื่อให้ชัดเจน** — ชื่อ variable, function, class ต้องสื่อความหมาย
- **ลบโค้ดที่ไม่ใช้** — dead code, unused imports, commented-out blocks

---

## ความสะอาดของโค้ด (Code Cleanliness)

- แยก function ที่ทำหลายอย่างออกเป็น function ย่อย (Single Responsibility)
- ลด nesting ที่ลึกเกินไป (> 3 ชั้น) → ใช้ early return แทน
- ลบ magic numbers → ใช้ named constants
- ลบ duplicate code → extract เป็น helper function
- จัด import ให้เป็นระเบียบ (stdlib → third-party → local)

---

## ความอ่านง่าย (Readability)

- Comment ภาษาไทยสำหรับ logic ซับซ้อน
- Comment หัว function — อธิบายว่าทำอะไร รับอะไร คืนอะไร
- ความยาวบรรทัด ≤ 100 ตัวอักษร
- ความยาว function ≤ 50 บรรทัด (แนะนำ)
- ความยาว file ≤ 300 บรรทัด (แนะนำ)

---

## ประสิทธิภาพ (Performance)

- หลีกเลี่ยง N+1 query
- Cache ผลลัพธ์ที่คำนวณซ้ำ
- ใช้ lazy evaluation เมื่อเหมาะสม
- อย่า optimize ก่อนเวลา — ต้องมี evidence ว่าช้า

---

## ความปลอดภัย (Security)

- Validate input ที่รับจากภายนอกเสมอ
- ไม่ hardcode secrets, credentials, API keys
- ใช้ parameterized query แทน string concatenation ใน SQL
- Sanitize output ก่อน render ใน HTML

---

## Error Handling

- จัดการ error ที่ boundary (user input, external API, filesystem)
- ใช้ specific error types แทน generic Exception
- Log error ด้วยข้อมูลที่เพียงพอสำหรับ debug
- ไม่ swallow errors โดยไม่มีเหตุผล

---

## การทดสอบ (Testing)

- หลัง refactor ต้องไม่มี test ที่ fail
- ถ้าเพิ่ม function ใหม่ → เสนอ test case ให้ user พิจารณา
- ไม่แก้ test เพื่อให้ผ่าน — แก้โค้ดแทน

---

## รูปแบบโค้ด — Functional (ไม่ใช่ OOP)

> โปรเจกต์นี้เขียนในสไตล์ **Functional Programming** ไม่ใช่ Object-Oriented
> การ refactor ต้องรักษารูปแบบนี้เอาไว้เสมอ

### หลักการ Functional ที่ต้องปฏิบัติตาม

**1. Pure Function — ไม่มี Side Effect**
- function ต้องคืนผลลัพธ์จาก input เท่านั้น ห้ามแก้ state ภายนอก
- ห้าม mutate parameter ที่รับเข้ามา → ให้ return ค่าใหม่แทน
- ห้าม access หรือแก้ global variable ภายใน function

```python
# ❌ มี side effect — แก้ list ที่รับเข้ามา
def add_tax(items):
    for item in items:
        item["price"] *= 1.07  # mutate!
    return items

# ✅ Pure — คืน list ใหม่โดยไม่แตะ input
def add_tax(items):
    return [{"price": item["price"] * 1.07, **item} for item in items]
```

**2. Immutability — ไม่แก้ไขข้อมูลเดิม**
- ใช้ spread / copy / map แทนการ mutate โดยตรง
- ตัวแปรที่ประกาศแล้วไม่ควรถูกแก้ไข ให้สร้างตัวแปรใหม่แทน

```typescript
// ❌ mutate object โดยตรง
function applyDiscount(order) {
    order.total = order.total * 0.9;  // แก้ของเดิม
    return order;
}

// ✅ คืน object ใหม่
function applyDiscount(order) {
    return { ...order, total: order.total * 0.9 };
}
```

**3. Function Composition — ประกอบ function เล็กๆ แทน class**
- แทนที่จะสร้าง class ที่มี method → ใช้ function หลายตัวที่ส่งผลต่อกัน
- แต่ละ function ทำสิ่งเดียว (Single Responsibility) แล้วนำมา compose กัน

```typescript
// ❌ OOP style
class OrderProcessor {
    constructor(private order) {}
    applyDiscount() { this.order.total *= 0.9; return this; }
    addTax() { this.order.total *= 1.07; return this; }
}

// ✅ Functional style
const applyDiscount = (order) => ({ ...order, total: order.total * 0.9 });
const addTax = (order) => ({ ...order, total: order.total * 1.07 });
const processOrder = (order) => addTax(applyDiscount(order));
```

**4. ใช้ map / filter / reduce แทน for loop ที่มี mutation**

```python
# ❌ loop + mutation
result = []
for user in users:
    if user["active"]:
        result.append(user["email"])

# ✅ functional pipeline
result = [u["email"] for u in users if u["active"]]
# หรือ
result = list(map(lambda u: u["email"], filter(lambda u: u["active"], users)))
```

**5. ถ้าพบ class ในโค้ดเดิม**
- ถ้า class มีแค่ method ไม่มี state → แปลงเป็น module of functions
- ถ้า class มี state → ให้แจ้ง user ก่อน ไม่แก้เองโดยพลการ

---

## หมายเหตุสำหรับ Skill

> section นี้ใช้โดย skill เท่านั้น — ไม่ต้องแก้ไข

- skill จะใช้ rule ทุกข้อด้านบนในการ refactor
- ถ้า user ส่ง `query` มาด้วย → ให้ query นั้น override หรือเพิ่มเติม rule
- แสดงผลสรุปการเปลี่ยนแปลงหลัง refactor เสมอ
~~~

แจ้ง user:
```
สร้าง `.claude/ava/REFACTOR.md` ให้แล้ว
สามารถแก้ไข rule ในไฟล์นั้นได้ตามต้องการเลย
กำลังเริ่ม refactor ต่อเลย...
```

---

## ขั้นที่ 2 — อ่านโค้ดที่ต้องการ refactor

ใช้ Read tool อ่านไฟล์ที่ `PATH_ARG`

- ถ้า `PATH_ARG` เป็น directory → ใช้ Glob tool หา source files ก่อน แล้วอ่านแต่ละไฟล์ที่เกี่ยวข้อง
  - ใช้ pattern ตามภาษาของโปรเจกต์ เช่น `**/*.{ts,js,tsx,jsx}`, `**/*.{py}`, `**/*.{go}`, `**/*.{rb,java,kt}`
  - ถ้าไม่แน่ใจภาษา → ใช้ `**/*.{ts,js,tsx,jsx,py,go,rb,java,kt,rs,swift}` แล้ว filter ไฟล์ที่มีอยู่จริง
- ถ้าไม่พบไฟล์ → แจ้ง user:

```
ไม่พบไฟล์หรือ directory ที่ระบุ: `<PATH_ARG>`
กรุณาตรวจสอบ path อีกครั้ง
```

แล้วหยุด

---

## ขั้นที่ 3 — วิเคราะห์และ Refactor

วิเคราะห์โค้ดโดยอ้างอิง rule จาก `REFACTOR.md` ทุกข้อ และ `QUERY_ARG` (ถ้ามี)

แนวทางวิเคราะห์:
1. ดู structure — function ยาวเกินไปไหม? nesting ลึกเกินไปไหม?
2. ดู naming — ชื่อสื่อความหมายชัดเจนไหม?
3. ดู duplication — มีโค้ดซ้ำที่ extract ได้ไหม?
4. ดู dead code — มี code ที่ไม่ใช้งานไหม?
5. ดู imports — มี unused import ไหม? จัดระเบียบแล้วหรือยัง?
6. ดู error handling — handle error ครบไหม?
7. ดู comments — comment ครบและถูกต้องไหม?
8. ถ้ามี `QUERY_ARG` → focus เพิ่มเติมตามที่ระบุ

จากนั้นใช้ Edit tool แก้ไขไฟล์ตามที่วิเคราะห์

---

## ขั้นที่ 4 — แสดงผลสรุป

แสดงผลในรูปแบบนี้:

```
🔧 Refactor สรุป
════════════════════════════════════════
📁 Target  : <PATH_ARG>
🔍 Query   : <QUERY_ARG หรือ "—" ถ้าไม่มี>
📋 Rules   : .claude/ava/REFACTOR.md
════════════════════════════════════════

✅ การเปลี่ยนแปลงที่ทำ:

  📍 `<file>:<line_range>` — <อธิบายการเปลี่ยนแปลง>
  📍 `<file>:<line_range>` — <อธิบายการเปลี่ยนแปลง>
  ...

⏭️ ไม่ได้เปลี่ยน (เหตุผล):
  - <สิ่งที่เจอแต่ไม่แก้ พร้อมเหตุผล — ถ้ามี>

════════════════════════════════════════
💡 แนะนำเพิ่มเติม (ไม่บังคับ):
  - <สิ่งที่อาจปรับปรุงได้แต่อยู่นอกขอบเขต เช่น ต้องแก้ test หรือต้อง refactor ไฟล์อื่นด้วย>
```

ถ้าไม่มีอะไรต้องแก้เลย:

```
🔧 Refactor สรุป
════════════════════════════════════════
📁 Target  : <PATH_ARG>

✅ โค้ดสะอาดดีแล้ว ไม่มีอะไรต้องแก้ตาม rule ใน REFACTOR.md เลย
```
