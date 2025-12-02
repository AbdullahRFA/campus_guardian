
-----

# 🎓 CampusGuardian
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)

**Learn. Connect. Grow.**

**CampusGuardian** is a comprehensive university community application designed to bridge the gap between students, alumni, and professors. It facilitates mentorship, peer-to-peer skill sharing, and knowledge exchange in a centralized, user-friendly platform.

-----

## 🚀 Features

### 1\. 🤝 Mentorship System

Connect with experienced seniors, alumni, and professors.

  * **Find Mentors:** Browse mentor profiles filtered by expertise and availability.
  * **Book Sessions:** Schedule sessions based on real-time mentor availability slots.
  * **Session Management:** Track pending, confirmed, and completed sessions with status updates.
  * **Feedback & Ratings:** Rate sessions and provide feedback to ensure quality mentorship.
  * **Mentor Dashboard:** Users can toggle their availability and manage their mentor profile details.

### 2\. 📚 Knowledge Hub (MicroTalks)

A social feed for sharing academic insights and articles.

  * **Posts Feed:** View and interact with posts created by the community.
  * **Create & Edit:** Rich text support for creating posts with thumbnail images.
  * **Engagement:** Like and comment on posts to foster discussion.

### 3\. 🔄 Skill Exchange

A peer-to-peer marketplace for learning.

  * **Exchange Offers:** Post "I can teach X, I want to learn Y" offers.
  * **History:** View past and closed exchange requests.
  * **Connect:** Direct integration with chat to propose exchanges.

### 4\. 💬 Communication

  * **Private Chat:** Real-time 1-on-1 messaging with read receipts and online status indicators.
  * **AI KnowledgeBot:** An intelligent chatbot powered by **Google Gemini AI** to answer student queries instantly.

### 5\. 👤 User Profile

  * **Academic Identity:** Manage university details, session, batch, and CGPA.
  * **Social Links:** Integration for LinkedIn and Facebook profiles.
  * **Security:** Secure login, signup, and password management.

-----

## 🛠️ Tech Stack

  * **Framework:** Flutter (Dart)
  * **Backend:** Firebase (Auth, Firestore, Storage)
  * **AI Integration:** Google Generative AI (Gemini)
  * **State Management:** `setState`, `StreamBuilder`
  * **Navigation:** `go_router`
  * **Key Packages:**
      * `cloud_firestore`, `firebase_auth`
      * `google_generative_ai`
      * `flutter_markdown`, `gpt_markdown`
      * `shared_preferences`
      * `url_launcher`

-----

## 📸 Screenshots

| Splash Screen-1                             | Login-2                           |
|---------------------------------------------|-----------------------------------|
| ![](/assets/Screenshot/splash%20screen.jpg) | ![](/assets/Screenshot/login.jpg) |

| Sign Up-3  | Reset Password-4 |
|-----------|-----------|
| ![](/assets/Screenshot/signUp.jpg) | ![](/assets/Screenshot/resetPassword.jpg) |


| ResetPassword throughLink-5  | Change Password-6 |
|-----------|-----------|
| ![](/assets/Screenshot/resetPassword2.jpg) | ![](/assets/Screenshot/changePassword.jpg) |

| dashboard-7  | findMentor-8 |
|-----------|-----------|
| ![](/assets/Screenshot/dashboard.jpg) | ![](/assets/Screenshot/findMentor.jpg) |

| Mentor profile-9  | book session-10 |
|-----------|-----------|
| ![](/assets/Screenshot/mentorProfile.jpg) | ![](/assets/Screenshot/session%20book.jpg) |

| My session-11  | feedback-12 |
|-----------|-----------|
| ![](/assets/Screenshot/mysession.jpg) | ![](/assets/Screenshot/give%20feedback.jpg) |


| session and feedback-13  | mentee profile-14 |
|-----------|-----------|
| ![](/assets/Screenshot/session%20and%20feedback.jpg) | ![](/assets/Screenshot/mentee%20profile.jpg) |

| Edit profile-15  | messageBox-16 |
|-----------|-----------|
| ![](/assets/Screenshot/edit%20profile.jpg) | ![](/assets/Screenshot/messageBox.jpg) |

| chat page-17  | mentorship setting-18 |
|-----------|-----------|
| ![](/assets/Screenshot/chate%20page.jpg) | ![](/assets/Screenshot/mentorship%20setting.jpg) |

| Mypost_knowledgeHub-19  | nested comment-20 |
|-----------|-----------|
| ![](/assets/Screenshot/my%20post:%20knoledgeHub.jpg) | ![](/assets/Screenshot/nested%20comment.jpg) |

| skill exchange-21  | edit skill exchange-22 |
|-----------|-----------|
| ![](/assets/Screenshot/skill%20exchange.png) | ![](/assets/Screenshot/edit%20skill%20exchage.jpg) |

| Search-23  | knowledge bot-24 |
|-----------|-----------|
| ![](/assets/Screenshot/search-1.jpg) | ![](/assets/Screenshot/knowledge%20bot.png) |

-----

## ⚙️ Installation & Setup

Follow these steps to run the project locally.

### Prerequisites

  * Flutter SDK (Version `^3.8.1` or higher)
  * Dart SDK
  * A Firebase Project

### 1\. Clone the Repository

```bash
git clone https://github.com/your-username/campus-guardian.git
cd campus-guardian
```

### 2\. Install Dependencies

```bash
flutter pub get
```

### 3\. Firebase Configuration

This project uses `flutterfire_cli` for Firebase configuration.

1.  Ensure you have the Firebase CLI installed.
2.  Run the following command to link your Firebase project:
    ```bash
    flutterfire configure
    ```
    This will generate the `firebase_options.dart` file in `lib/`.

### 4\. Environment Variables

Create a `.env` file in the root directory and add your Gemini API key:

```env
GEMINI_API_KEY=your_api_key_here
```

*(Make sure to add `.env` to your `.gitignore` file)*

### 5\. Run the App

```bash
flutter run
```

-----

## 📂 Project Structure

```
lib/
├── core/               # App-wide constants (Routes, Theme)
├── features/           # Feature-based modules
│   ├── auth/           # Login, Signup, Auth Gate
│   ├── chat/           # Private messaging
│   ├── dashboard/      # Home screen & Global Search
│   ├── knowledgebot/   # Gemini AI Chatbot
│   ├── mentorship/     # Mentor booking & listing
│   ├── microtalks/     # Posts & Knowledge Hub
│   ├── profile/        # User profile & settings
│   ├── skill_exchange/ # Skill swap marketplace
│   └── splash/         # Splash screen
├── services/           # Firebase & API services
└── widgets/            # Reusable UI components
```

-----

## 🤝 Contributing

Contributions are welcome\! Please follow these steps:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/YourFeature`).
3.  Commit your changes (`git commit -m 'Add some feature'`).
4.  Push to the branch (`git push origin feature/YourFeature`).
5.  Open a Pull Request.

-----

## 👨‍💻 Developer

Developed by **Abdullah Nazmus-Sakib** CSE, Jahangirnagar University

-----

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.