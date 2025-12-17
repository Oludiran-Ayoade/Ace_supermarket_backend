# Ace Mall Staff Management System - Backend

A comprehensive staff management system for Ace Mall with 13 branches across Nigeria.

## 🏢 System Overview

### Organizational Hierarchy

#### Senior Admin Officers (No branch/department specific)
- Chief Executive Officer (CEO)
- Chief Operating Officer (COO)
- Human Resource (HR)
- Auditors

#### Admin Officers - Group Heads (Oversee all branches)
- Group Head (SuperMarket)
- Group Head (Eatery)
- Group Head (Lounge)
- Group Head (Fun & Arcade)
- Group Head (Compliance Officer)
- Group Head (Facility Manager)

### Department Structure

#### 1. SuperMarket Department
**Admin Level:**
- Branch Manager
- Operations Manager
- Admin Officers
- Floor Manager

**General Staff:**
- Cashiers
- Bakers
- Customer Service Relations

#### 2. Eatery Department
**Admin Level:**
- Branch Manager
- Supervisors
- Store Manager
- Floor Manager

**General Staff:**
- Cashiers
- Bakers
- Cook
- Lobby Staffs
- Kitchen Assistant

#### 3. Lounge Department
**Admin Level:**
- Branch Manager
- Operations Managers
- Supervisors
- Floor Manager

**General Staff:**
- Cashiers
- Cook
- Bartender
- Waitress
- DJ
- Hypeman

#### 4. Fun & Arcade Department
**Sub-departments with Managers:**
- Cinema (Cinema Manager → Cinema Staffs)
- Photo Studio (Photo Studio Manager → Photographers, Studio Staffs)
- Saloon (Saloon Manager → Hair Stylist, Barber, Saloon Staffs)
- Arcade and Kiddies Park (Arcade Manager → Gamers, Arcade Staffs)
- Casino (Casino Manager → Casino Staffs)

#### 5. Compliance Department
- Compliance Officer 1
- Assistant Compliance Officer

#### 6. Facility Management Department
- Facility Manager 1
- Facility Manager 2
- Security
- Cleaners

### 13 Branches
1. Ace Mall, Oluyole
2. Ace Mall, Bodija
3. Ace Mall, Akobo
4. Ace Mall, Oyo
5. Ace Mall, Ogbomosho
6. Ace Mall, Ilorin
7. Ace Mall, Iseyin
8. Ace Mall, Saki
9. Ace Mall, Ife
10. Ace Mall, Osogbo
11. Ace Mall, Abeokuta
12. Ace Mall, Ijebu
13. Ace Mall, Sagamu

## 🔐 Authentication & Authorization

### User Creation Rules
- **HR**: Can create profiles for ALL staff (Senior Admin, Admin, General)
- **Floor Managers**: Can only create profiles for General Staff under them
- **Staff**: Cannot sign up themselves - profiles created by HR/Floor Managers
- **Login Only**: Staff can only log in with credentials created for them

### Staff Profile Information

#### Basic Information (Required for All)
1. Name
2. Email (for login)
3. Position/Designation
4. Department
5. Branch
6. ID No
7. Date Joined
8. Gender
9. Date of Birth
10. Phone Number
11. Home Address
12. State of Origin

#### Additional Information (Admin Staff)
13. Marital Status
14. Exam Scores
15. Work Experience
16. Course of Study
17. Grade (2-1, 1st Class, etc.)
18. Institution

#### Documents Upload
**Admin Staff (Required):**
- Birth Certificate
- Passport
- Valid ID Card
- NYSC Certificate
- Degree Certificate
- WAEC Certificate
- State of Origin Certificate
- First Leaving School Certificate

**General Staff:**
- Passport
- Valid ID Card
- WAEC Certificate (if applicable)

#### Next of Kin Information
- Name
- Relationship
- Email
- Phone Number
- Home Address
- Work Address

#### Guarantor Information (2 Guarantors Required)
- Name
- Phone Number
- Occupation
- Relationship with worker
- Sex
- Age
- Home Address
- Email
- Date of Birth
- Passport (Upload)
- National ID Card (Upload)
- Work ID Card (Upload)
- Grade Level at workplace

## 📋 Key Features

### HR Functions
1. **Staff Management**
   - Create profiles for all staff types
   - Add new departments
   - Add custom roles
   - Promote staff
   - Terminate staff (with reason tracking)

2. **Profile Management**
   - Staff can only edit email and password
   - HR can edit all information
   - Document upload and management

3. **Reporting**
   - View all staff by branch/department
   - Track terminated staff with reasons
   - View role history and promotions
   - Monitor work experience

### Floor Manager Functions
1. **Team Management**
   - Create profiles for general staff under them
   - Manage weekly rosters
   - Conduct weekly reviews (1-5 star rating)
   - Track attendance

2. **Roster Management**
   - Create weekly schedules
   - Assign shifts to staff
   - Mark attendance (Present/Absent/Late)

### General Staff Functions
1. **Profile Access**
   - View own profile
   - Update email and password only
   - View work history

2. **Schedule**
   - View assigned shifts
   - View weekly rosters

3. **Reviews**
   - View performance reviews from Floor Manager

## 🗄️ Database Schema

### Core Tables
- `users` - All staff information
- `branches` - 13 mall branches
- `departments` - 6 main departments (HR can add more)
- `sub_departments` - Sub-departments (e.g., Cinema, Saloon)
- `roles` - All job positions

### Supporting Tables
- `user_hierarchy` - Manager-subordinate relationships
- `user_documents` - Uploaded documents
- `exam_scores` - Educational qualifications
- `next_of_kin` - Emergency contacts
- `guarantors` - Guarantor information
- `guarantor_documents` - Guarantor documents
- `work_experience` - Previous employment
- `role_history` - Promotions and role changes
- `rosters` - Weekly schedules
- `roster_assignments` - Individual shift assignments
- `weekly_reviews` - Performance reviews
- `terminated_staff` - Historical records

## 🚀 Setup Instructions

### Prerequisites
- Go 1.21+
- PostgreSQL 14+
- Git

### Installation

1. **Clone the repository**
```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend
```

2. **Install dependencies**
```bash
go mod download
```

3. **Set up PostgreSQL database**
```bash
createdb ace_mall_db
psql ace_mall_db < database/schema.sql
psql ace_mall_db < database/roles_data.sql
```

4. **Configure environment variables**
```bash
cp .env.example .env
# Edit .env with your database credentials
```

5. **Run the server**
```bash
go run main.go
```

Server will start on `http://localhost:8080`

## 📡 API Endpoints

### Authentication
- `POST /api/v1/auth/login` - Staff login
- `POST /api/v1/auth/change-password` - Change password

### HR Management (Requires HR role)
- `POST /api/v1/hr/staff` - Create staff profile
- `GET /api/v1/hr/staff` - List all staff
- `GET /api/v1/hr/staff/:id` - Get staff details
- `PUT /api/v1/hr/staff/:id` - Update staff profile
- `DELETE /api/v1/hr/staff/:id` - Terminate staff
- `POST /api/v1/hr/departments` - Add new department
- `POST /api/v1/hr/roles` - Add new role
- `POST /api/v1/hr/promote/:id` - Promote staff

### Floor Manager (Requires Floor Manager role)
- `POST /api/v1/floor-manager/staff` - Create general staff
- `GET /api/v1/floor-manager/team` - Get team members
- `POST /api/v1/floor-manager/roster` - Create weekly roster
- `PUT /api/v1/floor-manager/roster/:id` - Update roster
- `POST /api/v1/floor-manager/review` - Submit weekly review

### General Staff
- `GET /api/v1/staff/profile` - Get own profile
- `PUT /api/v1/staff/profile` - Update email/password only
- `GET /api/v1/staff/schedule` - View assigned shifts
- `GET /api/v1/staff/reviews` - View performance reviews

### Data Endpoints
- `GET /api/v1/data/branches` - List all branches
- `GET /api/v1/data/departments` - List all departments
- `GET /api/v1/data/roles` - List all roles
- `GET /api/v1/data/roles/:category` - Get roles by category

### File Upload
- `POST /api/v1/upload/document` - Upload staff document
- `POST /api/v1/upload/guarantor-document` - Upload guarantor document

## 🔒 Security Features

1. **JWT Authentication** - Secure token-based auth
2. **Password Hashing** - bcrypt encryption
3. **Role-Based Access Control** - Granular permissions
4. **File Upload Validation** - Type and size restrictions
5. **SQL Injection Prevention** - Parameterized queries

## 📱 Flutter Integration

The backend is designed to work seamlessly with the Flutter mobile app:
- RESTful API design
- JSON responses
- File upload support
- Real-time data sync

## 🎯 Business Rules

1. **Branch Managers** are also department members with primary roles
2. **Floor Managers** are also floor members
3. **HR** has ultimate control over all staff
4. **Group Heads** oversee departments across all 13 branches
5. **Terminated staff** are archived with reasons for record-keeping
6. **Email addresses** are unique and used for login
7. **Employee IDs** are auto-generated and unique

## 📊 Reporting Capabilities

- Staff distribution by branch/department
- Terminated staff history with reasons
- Role progression tracking
- Performance review analytics
- Attendance patterns
- Roster compliance

## 🛠️ Tech Stack

- **Backend**: Go (Gin framework)
- **Database**: PostgreSQL
- **Authentication**: JWT
- **Password Hashing**: bcrypt
- **File Storage**: Local filesystem (can be extended to S3)

## 📝 License

Proprietary - Ace Mall Management System
