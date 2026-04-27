# Inam Motors – Showroom Management System

A secure, offline desktop management solution designed specifically for car showrooms to streamline inventory, customer transactions, and legal documentation.

<img width="1203" height="677" alt="image" src="https://github.com/user-attachments/assets/8a188f65-78e9-4057-b1cf-7fdbc4ddeb10" />


## 🚀 Key Features

### 📦 Advanced Inventory Management
* **Multi-Image Support:** High-resolution photo galleries for every vehicle.
* **Document Tracking:** Built-in tracking for critical files, including:
    * Original Smart Cards & Number Plates.
    * Sales/Transfer files.
    * Remote keys and physical spare keys.

 <img width="1363" height="704" alt="image" src="https://github.com/user-attachments/assets/dfed0c0e-9c25-4c4b-9065-4411014ccff4" />
<img width="1364" height="702" alt="image" src="https://github.com/user-attachments/assets/57ab1722-ad41-4c8e-b485-567b770f1373" />


### 💳 Unified Customer Ledger
* **Consolidated Transactions:** Replaces fragmented sales and payment modules with a single, chronological ledger.
* **Dynamic Balances:** Automatically calculates outstanding amounts for vehicle purchases, trade-ins, and installment plans.
* **Trade-in Logic:** Seamlessly handles "Exchange" deals where a customer's old vehicle is adjusted against a new purchase.
<img width="1364" height="704" alt="image" src="https://github.com/user-attachments/assets/5f705306-ccb0-42bc-bdf4-bd820d1e7b95" />



### 🔒 Enterprise-Grade Security
* **Global System Lock:** Instant lockdown feature to secure the entire application.
* **PIN-Protected Data:** Sensitive financial records and admin settings require secondary PIN authentication.
* **Privacy-First PDFs:** Generates professional customer receipts and legal handover slips while hiding internal cost pricing.

## 🛠️ Tech Stack

* **Frontend/UI:** Flutter (Desktop)
* **Language:** Dart
* **Local Storage:** (e.g., SQLite / Hive) – *Optimized for offline performance.*

## 📂 Project Structure

```text
lib/
├── models/         # Data structures for Vehicles, Customers, and Transactions
├── screens/        # UI components (Inventory, Ledger, Dashboard)
├── services/       # PDF generation and local database logic
├── widgets/        # Reusable UI components (Custom Buttons, Data Cards)
└── utils/          # Security logic and PIN authentication
```

## 📝 Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Syed-Yousha/Car_Showroom_management.git
    ```
2.  **Navigate to project directory:**
    ```bash
    cd Car_Showroom_management
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the application:**
    ```bash
    flutter run -d windows  # (or macos/linux depending on your OS)
    ```

## 📄 Documentation & Receipts
The system generates automated professional documents in PDF format:
* **Payment Receipts:** Instant proof of installments or full payments.
* **Handover Slips:** Legal documentation for vehicle delivery.
* **Ledger Reports:** Transparent financial history for customers.

<img width="1366" height="707" alt="image" src="https://github.com/user-attachments/assets/39fcc5af-a946-4f31-8d79-239b6a805e3b" />
<img width="1366" height="702" alt="image" src="https://github.com/user-attachments/assets/88946757-52ec-4b50-84c1-4da7ddbdc9dd" />
<img width="1366" height="699" alt="image" src="https://github.com/user-attachments/assets/619f191f-97e7-45cf-acc9-f30d17edc41d" />


---
*Developed for Inam Motors.*
