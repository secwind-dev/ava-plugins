---
name: ava-adc
description: 'สร้าง function ใน ADC style จากคำสั่ง เช่น "create emailValid(email:string)" แล้วแนะนำ function ต่อยอด. Usage: /ava-adc <ชื่อ function และ signature>'
argument-hint: '<ชื่อ function เช่น "emailValid(email:string)" หรือ "getIncludeVat(price:number)">'
disable-model-invocation: true
---

## ขั้นที่ 0 — รับ Argument

argument ที่รับมา: `$ARGUMENTS`

ถ้าไม่มี argument → แจ้ง user แล้วหยุด:

```
กรุณาระบุ function ที่ต้องการสร้าง

Usage: /ava-adc <ชื่อ function>
ตัวอย่าง:
  /ava-adc emailValid(email: string)
  /ava-adc getIncludeVat(price: number, vat: number)
  /ava-adc parseUserProfile(raw: unknown)
```

---

## ขั้นที่ 1 — โหลด ADC.md

ใช้ Read tool อ่านไฟล์ `.claude/ava/ADC.md`

- ถ้าพบ → โหลดเนื้อหาและดำเนินการต่อ
- ถ้าไม่พบ → fetch จาก URL นี้:

```
https://raw.githubusercontent.com/app-adc/adc-directive/main/ADC.md
```

ถ้า fetch สำเร็จ → ใช้ Write tool บันทึกที่ `.claude/ava/ADC.md` แล้วดำเนินการต่อ
ถ้า fetch ล้มเหลว → แจ้ง user แล้วหยุด:

```
ไม่พบ .claude/ava/ADC.md และไม่สามารถ fetch จาก GitHub ได้
กรุณาสร้างไฟล์ .claude/ava/ADC.md ด้วยตนเอง
```

---

## ขั้นที่ 2 — วิเคราะห์คำสั่ง

อ่านชื่อ function และ signature จาก argument แล้วระบุ:

1. **ชื่อ function** — ต้องการทำอะไร
2. **Input** — parameter types ที่รับมา
3. **Output** — return type ที่คาดหวัง (ถ้าไม่ระบุ → อนุมานจากชื่อ)
4. **ADC pattern ที่เหมาะสม** — เลือกจากตารางนี้:

| ลักษณะงาน | ADC pattern |
|-----------|-------------|
| validate input แล้วคืนผล | `makeTag` + `ciTag` |
| ประมวลผลหลายขั้นตอน | `ci` |
| validate + transform หลายขั้น | `ciTag` + `makeTag` |
| ดึงค่าจาก Tag | `fold` |
| จัดการ array | `sortBy`, `uniqueBy`, `mapArray` |
| async / delay | `delayPromise` |

---

## ขั้นที่ 3 — สร้าง Code

สร้าง code ใน ADC style ตามที่วิเคราะห์ไว้ โดยยึดหลักการต่อไปนี้:

- **Comment บรรทัดแรก** — ระบุวันที่สร้างจริง เช่น `// Created: YYYY-MM-DD`
- **Pure function** — ห้าม mutate state ภายนอก
- **Comment ภาษาไทย** — อธิบาย ADC pattern ที่ใช้ในแต่ละขั้น
- **ไม่เดา logic** — ถ้า argument ไม่ระบุรายละเอียด → สร้างโครงสร้างหลักพร้อม `// TODO:` comment

จากนั้นแสดงผลดังนี้:

```
✨ ADC Style — <ชื่อ function>
════════════════════════════════════════
📝 Function : <ชื่อ function + signature>
📦 Patterns : <ADC patterns ที่ใช้>
════════════════════════════════════════
```

แล้วแสดง code block เต็ม:

````
```typescript
[full code พร้อม comment ภาษาไทย]
```
````

แสดง import ที่ต้องเพิ่ม:

```
📦 Import:
  import { [functions ที่ใช้] } from 'adc-directive'
```

---

## ขั้นที่ 4 — แนะนำ Function ต่อยอด

หลังสร้างเสร็จ แนะนำ function ที่เกี่ยวข้องและต่อยอดได้จาก function ที่เพิ่งสร้าง โดยเลือก 3 function ที่มีประโยชน์สูงสุดในบริบทเดียวกัน แสดงในรูปแบบ:

```
════════════════════════════════════════
💡 Function ที่แนะนำให้สร้างต่อ:

1. `<ชื่อ function + signature>` — <อธิบายสั้นๆ ว่าทำอะไรและต่อยอดจาก function เดิมยังไง>
2. `<ชื่อ function + signature>` — <อธิบาย>
3. `<ชื่อ function + signature>` — <อธิบาย>

💬 พิมพ์ /ava-adc <ชื่อ function> เพื่อสร้างได้เลย
════════════════════════════════════════
```
