# ava-plugins

**Ava Claude Plugins** — ชุด skills & hooks สำหรับ Claude Code เพื่อ setup โปรเจกต์, จัดการ hooks, review code, และติดตั้ง MCP servers ได้อย่างรวดเร็ว

> 🎯 **Vision:** สร้าง plugin ecosystem ที่เป็น standard สำหรับ AI setup — คำนึงถึงมาตรฐานเครื่องมือ, การจัดการ API token อย่างปลอดภัย, และการบริหาร context window อย่างมีประสิทธิภาพ

---

## 📦 ติดตั้ง & อัปเดต

### ติดตั้งครั้งแรก

```bash
/plugin marketplace add secwind-dev/ava-plugins
/plugin install ava-claude-plugins@ava-plugins
```

### อัปเดต plugin ที่ติดตั้งอยู่

```bash
/plugin marketplace update ava-plugins        # รีเฟรช catalog ให้เห็น version ล่าสุด
/plugin update ava-claude-plugins@ava-plugins  # อัปเดต plugin ให้เป็น version ล่าสุด
```

---

## 🛠️ Skills ที่มีให้

| Skill | คำสั่ง | คำอธิบาย |
|-------|--------|----------|
| **ava-init** | `/ava-init <ชื่อโปรเจกต์>` | One-time setup สร้างไฟล์ทั้งหมด (CLAUDE.md, RULE.md, SOUL.md, MEMORY.md ฯลฯ) พร้อม default hooks อัตโนมัติ |
| **ava-hook** | `/ava-hook <ชื่อ-hook>` | สร้าง Claude Code hook แบบ guided พร้อม boilerplate และลงทะเบียนใน settings.json |
| **ava-review** | `/ava-review [target]` | Code review จาก git diff พร้อมวิเคราะห์ security, คะแนน quality, และแนะนำ best practices |
| **ava-validate** | `/ava-validate [task]` | ตรวจงานสำคัญตามระดับ L1/L2/L3 แก้ checklist ได้ก่อนตรวจ L3 มีผู้ตรวจอิสระ |
| **ava-explore** | `/ava-explore [topic] [files...]` | สำรวจ topic ซับซ้อนผ่านการถามตอบ interactive โยนไฟล์แนบได้ บันทึกลง `.claude/ava/explore/<topic>/` |
| **ava-deploy** | `/ava-deploy` | Deploy โปรเจกต์โดยอ่านและทำตาม `.claude/ava/DEPLOY.md` ทีละขั้นอัตโนมัติ |
| **ava-commit** | `/ava-commit` | วิเคราะห์ git diff แล้วสร้าง Conventional Commit message พร้อม confirm ก่อน commit |
| **ava-check** | `/ava-check` | ตรวจสอบ environment: runtime, git config, package manager, และ .env security |
| **ava-doctor** | `/ava-doctor` | ตรวจสอบ version เทียบกับ marketplace บน GitHub แจ้งเมื่อมี version ใหม่ให้อัปเดต |
| **ava-docs** | `/ava-docs` | แสดงคู่มือการใช้งาน skills ทั้งหมด โดยดึงจาก GitHub สดทุกครั้ง |
| **ava-awaken** | `/ava-awaken` | โหลด awaken knowledge ถาวรของ Claude จาก `.claude/ava/awaken/` |
| **ava-on-session** | `/ava-on-session` | เรียกใช้งานเมื่อเริ่ม session ใหม่ เพื่อ bootstrap context |

---

## 🪝 Default Hooks (สร้างอัตโนมัติโดย ava-init)

| Hook | Event | ทำอะไร |
|------|-------|--------|
| `track-action.sh` | PreToolUse | จับ action ล่าสุดของ Claude (Write, Edit, Bash, git ฯลฯ) |
| `notify-done.sh` | Stop | popup + เสียง + พูดภาษาไทยแจ้งว่าทำอะไรเสร็จ |

---

## 🔄 สำหรับผู้พัฒนา — deploy version ใหม่

เมื่อ deploy version ใหม่ ให้อัปเดต version ใน 3 ไฟล์นี้ให้ตรงกัน:

| ไฟล์ | field |
|------|-------|
| `.claude-plugin/plugin.json` | `"version"` |
| `.claude-plugin/marketplace.json` | `"metadata.version"` และ `"plugins[0].version"` |
| `DOCS.md` | `**Version:**` |
| `CHANGELOG.md` | entry header เช่น `## [YYYY-MM-DD] — vX.X.X` |

จากนั้น commit และ push — marketplace จะดึง version ใหม่จาก GitHub โดยอัตโนมัติ

---

## 👤 Author

**SecWind** — secwind.dev@gmail.com
