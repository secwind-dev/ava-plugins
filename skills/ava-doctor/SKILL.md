---
name: ava-doctor
description: 'ตรวจสอบ version ของ ava-claude-plugins เทียบกับ GitHub — ถ้ามี version ใหม่จะ auto-update ให้เลย แล้วแสดง changelog. Usage: /ava-doctor'
disable-model-invocation: true
---


ทำทุกอย่างอัตโนมัติ — ตรวจสอบ → update → แจ้งผล โดยไม่ต้องถาม

---

## ขั้นที่ 1 — หา Local Version และ Plugin Directory

รัน Bash tool:

```bash
INSTALLED_JSON=~/.claude/plugins/installed_plugins.json

# อ่าน installPath จาก installed_plugins.json (source of truth)
# เลือก scope "user" ก่อน ถ้าไม่มีค่อย fallback ไป scope แรกที่เจอ
if [ -f "$INSTALLED_JSON" ]; then
  INSTALL_PATH=$(jq -r '
    (.plugins["ava-claude-plugins@ava-plugins"] // [])
    | (map(select(.scope == "user"))[0] // .[0])
    | .installPath // empty
  ' "$INSTALLED_JSON")
fi

# ถ้าเจอ installPath → ใช้ plugin.json จาก path นั้น
if [ -n "$INSTALL_PATH" ]; then
  PLUGIN_JSON="$INSTALL_PATH/.claude-plugin/plugin.json"
fi

# fallback: dev mode (รันจาก repo โดยตรง)
if [ -z "$PLUGIN_JSON" ] || [ ! -f "$PLUGIN_JSON" ]; then
  DEV_PATH=".claude-plugin/plugin.json"
  if [ -f "$DEV_PATH" ] && grep -q '"ava-claude-plugins"' "$DEV_PATH" 2>/dev/null; then
    PLUGIN_JSON="$DEV_PATH"
  fi
fi

if [ -n "$PLUGIN_JSON" ] && [ -f "$PLUGIN_JSON" ]; then
  LOCAL_VER=$(jq -r '.version // empty' "$PLUGIN_JSON")
  # ขึ้นไป 2 ระดับจาก .claude-plugin/plugin.json → ได้ root ของ plugin
  PLUGIN_DIR=$(dirname "$(dirname "$PLUGIN_JSON")")
  echo "VERSION:$LOCAL_VER"
  echo "DIR:$PLUGIN_DIR"
else
  echo "NOT_FOUND"
fi
```

- ถ้า `NOT_FOUND` → แจ้ง user:
  ```
  ❌ ไม่พบ ava-claude-plugins ที่ติดตั้งอยู่
  กรุณาติดตั้งก่อนด้วยคำสั่ง:
    /plugin marketplace add secwind-dev/ava-plugins
    /plugin install ava-claude-plugins@ava-plugins
  ```
  แล้วหยุด

- บันทึก `LOCAL_VER` และ `PLUGIN_DIR` ไว้ใช้ต่อ

---

## ขั้นที่ 2 — ดึง Remote Version จาก GitHub

รัน Bash tool:

```bash
curl -sf "https://raw.githubusercontent.com/secwind-dev/ava-plugins/main/.claude-plugin/plugin.json" \
  | jq -r '.version // empty'
```

- ถ้าได้ version → บันทึกเป็น `REMOTE_VER`
- ถ้า output ว่างหรือ fail → แจ้ง user:
  ```
  ❌ ไม่สามารถเชื่อมต่อ GitHub ได้
  กรุณาตรวจสอบ internet connection แล้วลองใหม่
  ```
  แล้วหยุด

---

## ขั้นที่ 3 — เปรียบเทียบ Version

รัน Bash tool (แทนที่ `<local>` และ `<remote>` ด้วยค่าจริง):

```bash
LOCAL_VER="<local>"
REMOTE_VER="<remote>"

# แก้ไข: เลิกใช้ function ที่รับ argument แบบ positional — Claude Code แทนที่ตัวแปร positional ใน SKILL.md ด้วย argument ของ skill
# version ที่ต่ำกว่า = ตัวแรกหลัง sort -V
LOWER_VER=$(printf '%s\n%s' "$LOCAL_VER" "$REMOTE_VER" | sort -V | head -n1)

if [ "$LOCAL_VER" = "$REMOTE_VER" ]; then
  echo "UP_TO_DATE"
elif [ "$LOCAL_VER" = "$LOWER_VER" ]; then
  echo "OUTDATED"
else
  echo "AHEAD"
fi
```

---

## ขั้นที่ 4 — แยก Flow ตามผล

### กรณี `UP_TO_DATE`

แสดงผลทันที:

```
🩺 ava-doctor — ผลการตรวจสอบ

✅ คุณใช้ version ล่าสุดอยู่แล้ว!

📌 Local  : v<local_version>
🌐 Remote : v<remote_version>

ไม่ต้องทำอะไรเพิ่มเติม 🎉
```

หยุด

---

### กรณี `AHEAD` (dev mode)

แสดงผลทันที:

```
🩺 ava-doctor — ผลการตรวจสอบ

🔵 Local version ใหม่กว่า remote (dev mode?)

📌 Local  : v<local_version>
🌐 Remote : v<remote_version>

ดูเหมือน local จะเป็น development version — ไม่ต้องทำอะไร
```

หยุด

---

### กรณี `OUTDATED` → ไปขั้นที่ 5

---

## ขั้นที่ 5 — ดึง Changelog ของ version ใหม่

รัน Bash tool เพื่อดึง CHANGELOG จาก GitHub แล้วกรองเฉพาะ entry ของ version ใหม่:

```bash
REMOTE_VER="<remote_version>"

# ดึง CHANGELOG ทั้งหมด
CHANGELOG=$(curl -sf "https://raw.githubusercontent.com/secwind-dev/ava-plugins/main/CHANGELOG.md")

if [ -z "$CHANGELOG" ]; then
  echo "CHANGELOG_NOT_FOUND"
else
  # แก้ไข: ใช้ script ดึง entry ของ version (ข้าม deploy record) — regex เดิมได้แค่ deploy record
  # (<Base directory for this skill> คือ path ใน header ของ skill)
  ENTRY=$(printf '%s\n' "$CHANGELOG" | bash "<Base directory for this skill>/scripts/changelog-entry.sh" "$REMOTE_VER")
  [ -n "$ENTRY" ] && printf '%s\n' "$ENTRY" || echo "CHANGELOG_NOT_FOUND"
fi
```

- ถ้าได้ changelog content → บันทึกไว้
- ถ้า `CHANGELOG_NOT_FOUND` → ใช้ข้อความ "ดู changelog ได้ที่ https://github.com/secwind-dev/ava-plugins"

---

## ขั้นที่ 6 — แสดงผลสรุป

```
🩺 ava-doctor — ผลการตรวจสอบ

⚠️ มี version ใหม่ให้อัปเดต!

📌 Local  : v<local_version>
🌐 Remote : v<remote_version>

📋 สิ่งที่เปลี่ยนแปลงใน v<remote_version>:
──────────────────────────────────────
<changelog content ที่ได้จากขั้นที่ 5>
──────────────────────────────────────

🔄 รัน 2 คำสั่งนี้เพื่ออัปเดต:

  /plugin marketplace update ava-plugins
  /plugin update ava-claude-plugins@ava-plugins
```
