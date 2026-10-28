# DEPLOY.md

## คู่มือ Deploy สำหรับ Claude

เมื่อได้รับคำสั่ง `deploy` ให้ทำตามขั้นตอนด้านล่างทีละขั้น ห้ามข้ามขั้นตอน

---

### ขั้นที่ 1 — ตรวจสอบ Tests

```bash
npm run validate
```

- ❌ ถ้ามี error → หยุดทันที แจ้ง user ห้ามทำขั้นตอนถัดไป
- ✅ ถ้าผ่าน → ทำขั้นตอนถัดไป

### ขั้นที่ 2 — อัปเดต Version และ CHANGELOG.md

```bash
npx changeset version
```

- อัปเดต version ใน `package.json` อัตโนมัติ
- สร้าง/อัปเดต `CHANGELOG.md` อัตโนมัติ

### ขั้นที่ 4 — Build

```bash
npm run build
```

- ❌ ถ้า fail → หยุดทันที แจ้ง user

### ขั้นที่ 5 — Commit & Push _(confirm กับ user ก่อนทุกครั้ง)_

ระบุไฟล์ที่เปลี่ยนแปลงจริงๆ เสมอ ห้ามใช้ `git add .`:

```bash
git add CHANGELOG.md package.json <ไฟล์อื่นๆ ที่เปลี่ยน>
git commit -m "chore: v<version> — <สรุปสั้นๆ>"
git push
```

### ⚠️ กฎสำคัญ

- ทุก step ที่ fail → หยุดและรายงาน ห้าม skip
- ขั้นที่ 5 เท่านั้นที่ต้อง confirm กับ user ก่อน
- หลัง deploy สำเร็จให้บันทึกลง CHANGELOG.md ด้วย
