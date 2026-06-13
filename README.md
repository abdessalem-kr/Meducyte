# Meducyte 🧠 – Medical Education Reinvented
Meducyte is an educational mobile app designed to help medical students study smarter. It offers quizzes with spaced repetition, medical etymology, abbreviations, and access to essential textbooks and mind maps — all in one place. Built with Flutter and Laravel, Meducyte is a modern tool to simplify medical learning and boost long-term retention.

---

## 📱 Features
- 🧪 Quiz Engine with smart filtering (by module, lesson, source)
- ⏳ Spaced Repetition System for long-term retention
- 📚 Access to PDF textbooks, etymologies, and abbreviations
- 🧭 Search Tool across all resources (books, mind maps, notes)
- 📊 Progress Tracking & study planner
- 🩺 Clinical case simulation (AI-enhanced anamnesis module – planned)
- 💡 Custom content creation & flashcard saving
- 🌐 Built for Android with local + cloud storage support

---

## 🛠️ Tech Stack

| Layer | Tools |
|---|---|
| Frontend | Flutter + Riverpod + go_router + Dio |
| Backend | Laravel (PHP) + GraphQL (Lighthouse), SQL, Filament PHP |
| Local Storage | Drift (SQLite, for offline performance) |
| AI | Groq (LLM inference for chatbot, simulation & insights) |
| Hosting | Freehostia + Railway |
| Authentication | Token auth with refresh, secure email login (via Namecheap SMTP) |

---

## 📁 Project Structure

```
meducyte_app/
├── lib/
│   ├── core/          # config, database, network, routes, themes, l10n
│   ├── features/      # feature modules (quiz, learn, chatbot, simulation, …)
│   │   └── <feature>/
│   │       ├── data/          # repositories & data sources
│   │       ├── domain/        # models
│   │       └── presentation/  # screens, widgets, providers
│   └── shared/        # cross-feature providers, services, widgets
├── assets/
├── load_tests/        # k6 load-testing scripts
├── meducyte-backend/  # Laravel + GraphQL API
└── README.md
```

---

## 🚀 Getting Started

To run the Flutter app:

```bash
git clone https://github.com/abdessalem-kr/meducyte.git
cd meducyte
flutter pub get
cp env.json.example env.json   # then put your real Groq API key in env.json
flutter run --dart-define-from-file=env.json
```

> 🔑 AI features (chatbot, clinical insights, drug interactions, TTS) require a
> Groq API key. Copy `env.json.example` to `env.json` (gitignored) and fill in
> your key. VS Code launch configs in `.vscode/launch.json` pass it
> automatically; from the CLI use `--dart-define-from-file=env.json`.
> Never commit API keys to source control.

To set up the backend locally:

```bash
cd meducyte-backend
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

---

## 📌 Roadmap
- Quiz engine with filter
- Spaced repetition system
- User analytics & progress dashboard
- Medical etymology, abbreviations DB
- AI-powered patient simulator
- Voice-based clinical interviews
- Full offline mode for rural areas

---

## 🔒 License

This project is part of a private portfolio and is intended for demonstration purposes only.
You may view the code but are not allowed to copy, modify, or distribute it.
For usage or collaboration inquiries, please contact me.

---

## 📬 Contact

Dr. MDev
- 📧 meducyte.dev@gmail.com
- 📷 Instagram • 💼 LinkedIn • 🌍 Website
