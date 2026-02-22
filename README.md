# MedTracker

A premium, user-friendly medication tracking application built with Flutter. This project was specifically designed to help management of daily prescriptions with ease, featuring a clean UI, automated logging, and customizable themes.

---

## 🌟 Features

### 📅 Smart Scheduling
* **Daily Timeline:** View a structured schedule of medicines grouped by meal times (Breakfast, Lunch, Dinner, etc.).
* **Progress Tracking:** A visual progress bar on the home screen shows at a glance how many doses are left for the day.
* **Meal-Based Logic:** Set medications to be taken before, during, or after meals.

### 📝 Advanced Logging & History
* **Single-Tap Marking:** Mark medicines as "Taken" with a single tap.
* **Automated Timestamps:** Records the exact date and time a medicine is taken in the local database.
* **Journal View:** View a detailed "Today's Activity" log or a full "All-Time History" grouped by date.

### 🎨 Premium UI/UX
* **Dark & Normal Mode:** Fully manual theme switching for high legibility and comfort.
* **Visual Identification:** Capture and display photos of the actual medicine strips or bottles to prevent confusion.

---

## 📖 How to Use (Documentation)

### 1. Adding a Medicine
1. Open the app and tap the **"+"** button at the bottom right.
2. **Details:** Enter the name (e.g., "Aspirin") and the quantity (e.g., "1 Pill").
3. **Photo (Optional):** Tap the photo icon to take a picture of the medicine strip or bottle. This helps in visual identification.
4. **Schedule:** Select the **Meal Time** (Breakfast, Lunch, etc.) and the **Timing Rule** (Before, During, or After meal).
5. **Reminder:** Set the specific time you want to be notified.
6. Tap **Save**. The medicine will now appear in your daily schedule.

### 2. Tracking Daily Intake
* On the **Home Screen**, find the medicine you just took.
* Tap the **Circle/Check icon** next to the medicine. 
* The progress bar at the top will update, and the app will record the current time as the "Taken Time."
* **Note:** The app won't allow duplicate logs for the same medicine on the same day if it's already marked done.

### 3. Reviewing Logs & History
* Tap on the **Blue Progress Card** at the top of the Home Screen.
* This opens the **Today's Activity** page, showing exactly what time each pill was taken.
* Tap the **History Icon** (top right) to see a complete calendar-style log of every dose taken since you started using the app.

### 4. Changing Appearance
* Go to the **Settings** tab.
* Tap **App Theme**.
* Choose between **Normal (Light)** for daytime use or **Dark Mode** for better visibility at night.

---

## 🚀 Technical Stack

* **Framework:** [Flutter](https://flutter.dev)
* **State Management:** [Provider](https://pub.dev/packages/provider)
* **Local Database:** [Hive](https://pub.dev/packages/hive) (High-performance NoSQL)
* **Date Utilities:** [Intl](https://pub.dev/packages/intl)

---

## 🛠️ Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/adityachaurasia357/medicine_tracker_flutter.git](https://github.com/adityachaurasia357/medicine_tracker_flutter.git)
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Generate Database Adapters:**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

---

## ❤️ Credits
Developed by [Aditya Chaurasia](https://github.com/adityachaurasia357).Developed with ❤️ by [Aditya Chaurasia](https://github.com/adityachaurasia357).
