# Worker Task Management System (WTMS)

A mobile app built with **Flutter**, connected to a **PHP + MySQL** backend, for managing worker registration, login, profile display, viewing task list and submit completion report.

## Author

Name: TAMMIE TAN QIAN HAN
Matric No: 299660
Semester: A242

## Features

- 📥 Worker Registration
- 🔐 Login with Email & Password (SHA1 encrypted)
- 🧾 View Full Worker Profile (with profile image)
- ✅ View Assigned Task List
- 📤 Submit Task Completion Report
- 💾 Session Persistence using SharedPreferences
- 🌐 PHP-based RESTful API backend
- 🗄️ MySQL Database integration

## Tech Stack

| Layer         | Technology          |
|---------------|---------------------|
| Frontend      | Flutter (Dart)      |
| Backend       | PHP (XAMPP)         |
| Database      | MySQL (phpMyAdmin)  |
| Local Storage | SharedPreferences   |

### ⚙️ Backend (PHP & MySQL)

1. Install [XAMPP](https://www.apachefriends.org/index.html) and start **Apache** & **MySQL**.

2. Create a database named: `workers` 

3. Create the table named `workerinfo` using:
```sql
CREATE TABLE workerinfo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  password VARCHAR(255),
  phone VARCHAR(20),
  address TEXT
);

and the table named 'tbl_works' and 'tbl_submissions' using:
CREATE TABLE tbl_works (
    id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  assigned_to INT NOT NULL,
  date_assigned DATE NOT NULL,
  due_date DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'pending'
);

CREATE TABLE tbl_submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
  work_id INT NOT NULL,
  worker_id INT NOT NULL,
  submission_text TEXT NOT NULL,
  submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

4. Placed Php file in: 
C:\xampp\htdocs\wtms_api\
│
├── db_connect.php
├── register_worker.php
├── login_worker.php
├── update_profile_image.php
├── get_works.php
└── submit_work.php
