# MedTracker

A premium, user-friendly medication tracking application built with Flutter. Designed to simplify daily prescription management with a clean UI, automated logging, and customizable themes.

---

## 📸 Screenshots

| Home | New Medicine | Frequency & Timings | Medicine Inventory |
|------|-------------|--------------------|--------------------|
| ![Home](https://github.com/user-attachments/assets/8878e64f-91e5-42de-97dc-6a368fca3a56) | ![New Medicine](https://github.com/user-attachments/assets/5088f628-1f0b-4d93-9e78-dbc45b2ade6a) | ![Frequency & Timings](https://github.com/user-attachments/assets/13548c5d-a5e0-4973-8c5a-b9df621cdb5f) | ![Medicine Inventory](https://github.com/user-attachments/assets/0d281087-7ef7-4c35-90d6-f5ab30717e12) |

| Today's Schedule | Today's Logs | Complete Logs | Dark Mode |
|-----------------|-------------|--------------|-----------|
| ![Today's Schedule](https://github.com/user-attachments/assets/7aba8426-eded-40c9-bbbf-b2b4f0c56ae3) | ![Today's Logs](https://github.com/user-attachments/assets/84d20837-8279-45e0-a053-c398f2d82fc1) | ![Complete Logs](https://github.com/user-attachments/assets/95195d94-d8e6-4f81-8ff3-5842bd723f71) | ![Dark Mode](https://github.com/user-attachments/assets/d7d5f961-c28c-4cfb-94f8-2299ba64cf48) |

---

## 🌟 Features

### 📅 Smart Scheduling
- **Daily Timeline:** View a structured schedule of medicines grouped by meal times (Breakfast, Lunch, Dinner, etc.).
- **Progress Tracking:** A visual progress bar on the home screen shows at a glance how many doses are left for the day.
- **Meal-Based Logic:** Set medications to be taken before, during, or after meals.

### 📝 Advanced Logging & History
- **Single-Tap Marking:** Mark medicines as "Taken" with a single tap.
- **Automated Timestamps:** Records the exact date and time a medicine is taken in the local database.
- **Journal View:** View a detailed "Today's Activity" log or a full "All-Time History" grouped by date.
- **Duplicate Prevention:** The app won't allow duplicate logs for the same medicine on the same day.

### 🎨 Premium UI/UX
- **Dark & Light Mode:** Fully manual theme switching for high legibility and comfort.
- **Visual Identification:** Capture and display photos of medicine strips or bottles to prevent confusion.

---

## 📖 How to Use

### 1. Adding a Medicine
1. Tap the **"+"** button at the bottom right.
2. Enter the name (e.g., "Aspirin") and quantity (e.g., "1 Pill").
3. Optionally tap the photo icon to photograph the medicine strip or bottle for visual identification.
4. Select the **Meal Time** (Breakfast, Lunch, etc.) and **Timing Rule** (Before, During, or After meal).
5. Set the specific reminder time and tap **Save**.

### 2. Tracking Daily Intake
- On the **Home Screen**, tap the **Circle/Check icon** next to a medicine to mark it as taken.
- The progress bar updates instantly and the app records the current time as the "Taken Time."

### 3. Reviewing Logs & History
- Tap the **Blue Progress Card** at the top of the Home Screen to open **Today's Activity**.
- Tap the **History Icon** (top right) to browse a complete calendar-style log of every dose ever taken.

### 4. Changing Appearance
- Go to **Settings → App Theme** and choose between **Normal (Light)** or **Dark Mode**.

---

## 🚀 Tech Stack

| Concern | Technology |
|---------|-----------|
| Framework | [Flutter](https://flutter.dev) |
| State Management | [Provider](https://pub.dev/packages/provider) |
| Local Database | [Hive](https://pub.dev/packages/hive) — high-performance NoSQL |
| Date Utilities | [Intl](https://pub.dev/packages/intl) |

---

## 🛠️ Installation

```bash
# 1. Clone the repository
git clone https://github.com/adityachaurasia357/medicine_tracker_flutter.git

# 2. Install dependencies
flutter pub get

# 3. Generate Hive database adapters
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

---

## ❤️ Credits

Developed with ❤️ by [Aditya Chaurasia](https://github.com/adityachaurasia357).
