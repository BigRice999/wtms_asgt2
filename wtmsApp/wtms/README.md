# Worker Task Management System (WTMS)

A mobile app built with **Flutter**, connected to a **PHP + MySQL** backend, for managing worker registration, login, profile display, viewing task list and submit completion report.

---

## 👩‍💻 Author

- **Name**: TAMMIE TAN QIAN HAN  
- **Matric No**: 299660  
- **Semester**: A242

---

## ✅ Features

- 📥 **Worker Registration** with profile image  
- 🔐 **Login** with “Remember Me” option  
- 🏠 **Main Dashboard** (Tab screen navigation)  
- 📋 **Task List** (Styled with yellow theme)  
- 📤 **Submit Task Completion**  
- 📜 **Submission History**  
  - View all submitted tasks  
  - Sort: *Earliest to Latest* or *Latest to Earliest*  
  - Edit previously submitted text with confirmation  
- 🙍‍♂️ **Profile Screen**  
  - View and edit email, phone, address, birth date, and gender  
  - Upload and update profile image  
- 🎨 **Unified Modern UI**  
  - All screens follow consistent design with gradient backgrounds, rounded cards, and color-themed layouts.

---

## 🧰 Tech Stack

| Layer         | Technology          |
|---------------|---------------------|
| Frontend      | Flutter (Dart)      |
| Backend       | PHP (XAMPP)         |
| Database      | MySQL (phpMyAdmin)  |
| Local Storage | SharedPreferences   |

---

## ⚙️ Backend (PHP & MySQL)

### 🧪 Setup Instructions

1. Install [XAMPP](https://www.apachefriends.org/index.html) and start **Apache** & **MySQL**.

2. Create a database named:

```sql
CREATE DATABASE workers;
-- tbl_users table
CREATE TABLE tbl_users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  password VARCHAR(255),
  phone VARCHAR(20),
  address TEXT,
  birth_date DATE,
  gender VARCHAR(10)
);

-- tbl_works table
CREATE TABLE tbl_works (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  assigned_to INT NOT NULL,
  date_assigned DATE NOT NULL,
  due_date DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'pending'
);

-- tbl_submissions table
CREATE TABLE tbl_submissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  work_id INT NOT NULL,
  worker_id INT NOT NULL,
  submission_text TEXT NOT NULL,
  submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

3. Backend
C:\xampp\htdocs\wtms_api\
│
├── db_connect.php
├── register_worker.php
├── login_worker.php
├── get_profile.php
├── update_profile.php
├── update_profile_image.php
├── get_works.php
├── submit_work.php
├── get_submissions.php
├── edit_submission.php
