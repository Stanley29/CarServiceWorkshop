# CarServiceWorkshop

A simple ASP.NET Core MVC application for managing:
- Clients
- Cars
- Service Orders

The project demonstrates:
- Entity Framework Core (Code First)
- MVC pattern
- CRUD operations
- Navigation properties and relationships
- Bootstrap UI

---

## 🚀 How to Run

1. Install .NET 8 SDK  
2. Clone the repository  
3. Navigate to the Web project:

``` 
cd CarServiceWorkshop.Web
``` 



4. Run the application:

dotnet run



The app will start at:

``` 
https://localhost:5001
http://localhost:5000
``` 



---

## 📦 Project Structure

``` 
CarServiceWorkshop/
│
├── CarServiceWorkshop.Web/     # MVC UI
└── README.md
``` 


---

## 🗄 Database

The project uses **Entity Framework Core** with SQL Server LocalDB.

To apply migrations:

``` 

dotnet ef database update
``` 


---

## 🧩 Features

### Clients
- Create / Edit / Delete
- View details
- List all clients

### Cars
- Create / Edit / Delete
- Assign to a client
- View details

### Orders
- Create / Edit / Delete
- Assign to a car
- Track status
- View details

---

## 🛠 Technologies

- ASP.NET Core MVC
- Entity Framework Core
- SQL Server LocalDB
- Bootstrap 5
- C#

---

## 📄 License

Free to use for study and portfolio purposes.