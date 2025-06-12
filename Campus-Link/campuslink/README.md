# CampusLink

CampusLink is an interactive social platform designed to help students connect through events, conversations, and shared experiences. Built by students at NHL Stenden, this project combines mobile/web app development, NFC hardware, and interactive storytelling.

## 🎯 Project Goals

- Improve social integration among students
- Enable event creation and participation via app and kiosk
- Use NFC to check in and track event attendance

---

## 📱 Features

- ✅ User authentication with Supabase
- ✅ Event creation & filtering
- 🛠️ NFC-based event check-in
- ✅ Interactive map view
- 🛠️ User profiles & feedback system
- 🛠️ Kiosk mode with Raspberry Pi (in progress)
- 🛠️ Storytelling companion website (in progress)

---

## 🧠 Tech Stack

| Area        | Technology         |
|-------------|--------------------|
| Frontend    | Flutter            |
| Backend     | Supabase (self-hosted) |
| Database    | PostgreSQL (via Supabase) |
| Hardware    | Raspberry Pi, NFC Scanner |

---

## 🗂️ Project Structure


/Project-Innovate
├── /Campus-Link
|   ├── /campuslink # Flutter application
|   └── /backend # Supabase Docker setup & SQL
└── /Project-Innovate
    └── /Invisible-Heroes # Storytelling website

---

## 🚀 Getting Started

### Backend (Supabase)

1. Clone the repo:  
   `git clone https://github.com/Pharrellstu/Project-Innovate`
2. Navigate to backend:  
   `cd Campus-Link/backend`
3. Start Supabase (Docker required):  
   `docker-compose up -d`

### Frontend (Flutter)

1. Go to app folder:  
   `cd Campus-Link/campuslink`
2. Set your `.env` with:
   ```env
   SUPABASE_URL=http://your-server-ip:8000
   SUPABASE_ANON_KEY=your_anon_key
3. Run the app:
   `flutter run`