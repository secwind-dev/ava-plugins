# RULE.md

## กฎและข้อห้ามสำหรับ Claude

### 🔒 ข้อห้ามด้านความปลอดภัย

#### ไฟล์ที่ห้ามอ่าน เข้าถึง หรือแสดงเนื้อหาโดยเด็ดขาด:

1. **ไฟล์ Environment & Secrets**
    - `.env`, `.env.local`, `.env.production`, `.env.development`, `.env.*` ทุกรูปแบบ
    - `*.secret`, `*.secrets`, `secrets.json`, `secrets.yaml`, `secrets.yml`

2. **ไฟล์ Credentials & Keys**
    - `credentials.json`, `credentials.yaml`
    - `serviceAccountKey.json` หรือไฟล์ Service Account ใดๆ
    - `*.pem`, `*.key`, `*.p12`, `*.pfx`
    - `id_rsa`, `id_ed25519` และ SSH keys ทุกรูปแบบ
    - `*.keystore`

3. **ไฟล์ Configuration ที่มีข้อมูล sensitive**
    - ไฟล์ config ใดๆ ที่มี password, token, secret, api_key
    - `database.yml`, `database.json` ที่มี credentials

4. **ไฟล์ Auth & Session**
    - `token.json`, `auth.json`, `session.json`
    - Cookie files, Session files

5. **ไฟล์ข้อมูลส่วนบุคคล (PII)**
    - ไฟล์ที่มีเลขบัตรประชาชน, เลขบัตรเครดิต, รหัสผ่าน, เบอร์โทร, ที่อยู่
    - ไฟล์ database dump ที่มีข้อมูลผู้ใช้จริง

#### กฎเพิ่มเติม:

- ถ้า user ขอให้อ่านไฟล์ที่น่าสงสัยว่ามี sensitive data → ปฏิเสธและแจ้งเหตุผล
- ห้าม print, log, หรือแสดงค่า sensitive ใดๆ แม้จะเป็นบางส่วน
- ถ้าเจอ sensitive data โดยไม่ตั้งใจ → หยุดทันที ไม่แสดงข้อมูลนั้น

### ✅ กฎทั่วไป

- ทำตาม Startup Sequence ใน `CLAUDE.md` ทุกครั้ง
- ห้ามแก้ไข `RULE.md` โดยไม่ได้รับอนุญาตจาก user
- ถ้า user ขอให้ละเมิดกฎความปลอดภัย → ปฏิเสธและอธิบายเหตุผล
