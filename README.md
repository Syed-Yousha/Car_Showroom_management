# Car Showroom Management System

[screen-capture.webm](https://github.com/user-attachments/assets/f86eb9c5-5001-482f-866e-10f839d44612)


I built this Desktop Point-of-Sale (POS) and Inventory Management application specifically for automotive showrooms. Developed using Flutter for Windows Desktop and backed by Firebase, the system is designed to handle complex, multi-layered operations. It manages everything from vehicle inventory and customer ledgers to investor equity and financial transactions, all while ensuring strict data integrity.

## Key Features

* **Complete Inventory Management:** Tracks vehicles, their current status (Available or Sold), and specific details like chassis number, engine number, make, model, and price.
* **Customer Ledger and Statements:** Maintains comprehensive profiles for buyers and sellers, tracks running balances, and generates chronological statements of account.
* **Investor Equity Tracking:** Manages capital from multiple investors. It tracks tied-up capital per vehicle and automatically calculates profit distribution when a car is sold.
* **Atomic Financial Transactions:** Utilizes Firestore WriteBatch to guarantee data integrity. A single car sale transaction atomically updates the ledger, changes the vehicle status, links the buyer, updates customer balances, and adjusts investor portfolios simultaneously.
* **Secure Authentication:** Features a private, single-tenant architecture using Firebase Authentication to ensure only authorized dealership personnel can access the system.
* **Document Handover Tracking:** Keeps digital records of physical document handovers, such as smart cards, transfer letters, and number plates.

## Technical Architecture and Stack

* **Frontend:** Flutter (Optimized for Windows Desktop executable builds).
* **Backend:** Firebase Cloud Firestore (NoSQL) and Firebase Authentication.
* **Custom REST Integration:** I engineered a custom Firestore REST client using the http package for all database read operations. This bypasses the native Windows C++ Firestore SDK to prevent known crash issues and maintain complete stability on Windows OS, while still leveraging the SDK for reliable bulk write operations.
* **State Management and Architecture:** Built with a clean separation of concerns, featuring decoupled data models, dedicated repository layers, and a responsive user interface.

## Database Schema Highlights

The system relies on highly interlinked NoSQL collections to maintain state:
* `users`: Staff and admin authentication metadata.
* `cars`: Vehicle inventory with bidirectional references to investors and buyers.
* `customers`: Buyer and seller profiles dynamically updated by the transaction ledger.
* `transactions`: The core ledger tracking sales, payments, trade-ins, and refunds.
* `investors`: Capital providers with dynamic held amount tracking.

## Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
* Visual Studio 2022 (with the "Desktop development with C++" workload installed) for Windows builds.
* A configured Firebase Project.

### Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/Syed-Yousha/Car_Showroom_management.git](https://github.com/Syed-Yousha/Car_Showroom_management.git)
