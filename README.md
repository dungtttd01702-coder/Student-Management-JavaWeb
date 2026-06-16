# 🎓 Student Management System | Java Web MVC

A comprehensive web application for managing student information, classes, and academic records. Built with **Java Servlet/JSP**, **JDBC**, and **SQL Server** following **MVC architecture**.

## 🚀 Features

- **Authentication & Authorization**: Secure login with role-based access (Admin/User)
- **Student Management**: Full CRUD operations with search and filter
- **Class Management**: Organize and manage student classes
- **Score Management**: Input grades, calculate GPA automatically
- **Dashboard**: Statistics and data visualization
- **Responsive UI**: Mobile-friendly interface with Bootstrap 5
- **Data Export**: Export reports to Excel format

## 🛠️ Tech Stack

| Category | Technologies |
|----------|-------------|
| **Backend** | Java 11+, Servlet, JSP, JDBC, Maven |
| **Database** | SQL Server 2019+ |
| **Frontend** | HTML5, CSS3, Bootstrap 5, JavaScript, Chart.js |
| **Server** | Apache Tomcat 9+ |
| **Tools** | NetBeans/Eclipse, Git, GitHub |

## 📁 Project Structure
QuanLySinhVien/
├── src/main/java/com/studentmanagement/
│ ├── controller/ # Servlet classes
│ ├── model/ # Entity classes
│ ├── dao/ # Data Access Objects
│ ├── service/ # Business logic
│ └── util/ # Database connection & helpers
├── src/main/webapp/
│ ├── views/ # JSP pages
│ ├── assets/ # CSS, JS, images
│ └── WEB-INF/ # Configuration files
├── database.sql # Database schema
├── pom.xml # Maven dependencies
└── README.md

## 📋 Prerequisites

- Java 11 or higher
- Apache Maven 3.6+
- SQL Server 2019+
- Apache Tomcat 9+
- IDE: NetBeans, Eclipse, or IntelliJ IDEA

## ⚙️ Installation & Setup

### 1. Clone the repository
git clone https://github.com/yourusername/Student-Management-JavaWeb.git
cd Student-Management-JavaWeb

2. Database Setup
Open SQL Server Management Studio
Run the script in database.sql to create database and sample data
Update database credentials in src/main/java/com/studentmanagement/util/DBConnection.java

3. Build & Deploy
# Clean and build project
mvn clean package

# Deploy to Tomcat
# Copy target/StudentManagement.war to Tomcat webapps folder

4. Run Application
  Start Apache Tomcat server
  Access: http://localhost:8080/StudentManagement
5. Default Login Credentials
  Admin: username: admin | password: admin123
  User: username: user | password: user123
🎯 Key Features Explained
Student Management
  Add, edit, delete student records
  Search by name, ID, or class
  Filter by class and status
  Pagination support (10 records per page)
Score Management
  Input midterm and final exam scores
  Automatic GPA calculation
  Export score reports to Excel
Dashboard
  Total students, classes statistics
  Student distribution charts
  Recent activities log
  Top performing students
🔒 Security Features
  SQL injection prevention using PreparedStatement
  XSS protection
  Session management and timeout
  Role-based access control
📝 Database Schema
Tables:
  Users - System users with roles
  Students - Student information
  Classes - Class management
  Scores - Academic records
  Subjects - Subject catalog
🧪 Testing
-  Run the application and test with default credentials. Verify:
  Login/logout functionality
  CRUD operations for students
  Score calculation
  Search and filter features
  Responsive design on mobile
📚 Learning  Outcomes
This project demonstrates:
  MVC architecture implementation
  JDBC and database connectivity
  Session management in Java Web
  Bootstrap responsive design
  Clean code principles
  Git version control
🤝 Contributing
  Contributions are welcome! Please feel free to submit a Pull Request.
👨‍ Author
Trần Trung Dũng
📧 Email: dungtttd01702@gmail.com
📍 Location: Đà Nẵng, Vietnam
🎓 FPT Polytechnic - Software Development
🔗 GitHub: github.com/dungtttd01702-coder
📄 License
This project is open source and available under the MIT License.

Built with ❤️ as a learning project for FPT Polytechnic Software Development program
