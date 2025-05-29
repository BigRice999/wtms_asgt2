# Worker Task Management System (WTMS)

A mobile app built with **Flutter**, connected to a **PHP + MySQL** backend, for managing worker registration, login, and profile display.

## Author

Name: TAMMIE TAN QIAN HAN
Matric No: 299660
Semester: A242

## Features

- Worker Registration
- Login with Email & Password (with SHA1 encrypted)
- View Full Worker Profile
- Session Persistence using SharedPreferences
- PHP REST API backend
- MySQL Database

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: PHP (XAMPP)
- **Database**: MySQL (phpMyAdmin)
- **State Persistence**: SharedPreferences

### ⚙️ Backend (PHP & MySQL)

1. Install [XAMPP](https://www.apachefriends.org/index.html) and start **Apache** & **MySQL**.

2. Create a database named: `workers` 

3. Create a table named `workerinfo` using:
```sql
CREATE TABLE workerinfo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  password VARCHAR(255),
  phone VARCHAR(20),
  address TEXT
  image VARCHAR(255)
);

4. Placed Php file in: 
    C:\xampp\htdocs\wtms_api\db_connect.php
    C:\xampp\htdocs\wtms_api\register_worker.php
    C:\xampp\htdocs\wtms_api\login_worker.php
