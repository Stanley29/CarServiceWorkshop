# Create solution and MVC project
dotnet new sln -n CarServiceWorkshop
dotnet new mvc -n CarServiceWorkshop.Web
dotnet sln add CarServiceWorkshop.Web/CarServiceWorkshop.Web.csproj

cd CarServiceWorkshop.Web

# Remove default files
Remove-Item -Path "Controllers\HomeController.cs","Views\Home" -Recurse -Force -ErrorAction SilentlyContinue

# Create folders
New-Item -ItemType Directory -Path "Models","Data","Services","Services\Interfaces","Views\Clients","Views\Cars","Views\Orders","wwwroot\css","wwwroot\images\cars" -Force | Out-Null

# ---------------- Program.cs ----------------
@'
using CarServiceWorkshop.Web.Data;
using CarServiceWorkshop.Web.Services;
using CarServiceWorkshop.Web.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IClientService, ClientService>();
builder.Services.AddScoped<ICarService, CarService>();
builder.Services.AddScoped<IOrderService, OrderService>();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Clients}/{action=Index}/{id?}");

app.Run();
'@ | Set-Content Program.cs

# ---------------- appsettings.json ----------------
@'
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=CarServiceWorkshopDb;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
'@ | Set-Content appsettings.json

# ---------------- Models ----------------
@'
using System.Collections.Generic;

namespace CarServiceWorkshop.Web.Models
{
    public class Client
    {
        public int Id { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;

        public ICollection<Car> Cars { get; set; } = new List<Car>();
    }
}
'@ | Set-Content Models\Client.cs

@'
using System.Collections.Generic;

namespace CarServiceWorkshop.Web.Models
{
    public class Car
    {
        public int Id { get; set; }
        public string PlateNumber { get; set; } = string.Empty;
        public string Brand { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public int Year { get; set; }

        public int ClientId { get; set; }
        public Client Client { get; set; } = null!;

        public ICollection<Order> Orders { get; set; } = new List<Order>();
    }
}
'@ | Set-Content Models\Car.cs

@'
using System;

namespace CarServiceWorkshop.Web.Models
{
    public enum OrderStatus
    {
        Pending = 0,
        InProgress = 1,
        WaitingForParts = 2,
        Completed = 3,
        Cancelled = 4
    }

    public class Order
    {
        public int Id { get; set; }
        public int CarId { get; set; }
        public Car Car { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
        public string Description { get; set; } = string.Empty;
        public decimal EstimatedCost { get; set; }
        public OrderStatus Status { get; set; }
    }
}
'@ | Set-Content Models\Order.cs

# ---------------- Data/AppDbContext.cs ----------------
@'
using CarServiceWorkshop.Web.Models;
using Microsoft.EntityFrameworkCore;

namespace CarServiceWorkshop.Web.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Client> Clients => Set<Client>();
        public DbSet<Car> Cars => Set<Car>();
        public DbSet<Order> Orders => Set<Order>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Client>()
                .HasMany(c => c.Cars)
                .WithOne(c => c.Client)
                .HasForeignKey(c => c.ClientId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Car>()
                .HasMany(c => c.Orders)
                .WithOne(o => o.Car)
                .HasForeignKey(o => o.CarId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
'@ | Set-Content Data\AppDbContext.cs

# ---------------- Services Interfaces ----------------
@'
using CarServiceWorkshop.Web.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarServiceWorkshop.Web.Services.Interfaces
{
    public interface IClientService
    {
        Task<IEnumerable<Client>> GetAllAsync();
        Task<Client?> GetByIdAsync(int id);
        Task CreateAsync(Client client);
        Task UpdateAsync(Client client);
        Task DeleteAsync(int id);
    }
}
'@ | Set-Content Services\Interfaces\IClientService.cs

@'
using CarServiceWorkshop.Web.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarServiceWorkshop.Web.Services.Interfaces
{
    public interface ICarService
    {
        Task<IEnumerable<Car>> GetAllAsync();
        Task<Car?> GetByIdAsync(int id);
        Task CreateAsync(Car car);
        Task UpdateAsync(Car car);
        Task DeleteAsync(int id);
    }
}
'@ | Set-Content Services\Interfaces\ICarService.cs

@'
using CarServiceWorkshop.Web.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarServiceWorkshop.Web.Services.Interfaces
{
    public interface IOrderService
    {
        Task<IEnumerable<Order>> GetAllAsync();
        Task<Order?> GetByIdAsync(int id);
        Task CreateAsync(Order order);
        Task UpdateAsync(Order order);
        Task DeleteAsync(int id);
    }
}
'@ | Set-Content Services\Interfaces\IOrderService.cs

# ---------------- Services Implementations ----------------
@'
using CarServiceWorkshop.Web.Data;
using CarServiceWorkshop.Web.Models;
using CarServiceWorkshop.Web.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarServiceWorkshop.Web.Services
{
    public class ClientService : IClientService
    {
        private readonly AppDbContext _context;

        public ClientService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Client>> GetAllAsync()
        {
            return await _context.Clients
                .Include(c => c.Cars)
                .ToListAsync();
        }

        public async Task<Client?> GetByIdAsync(int id)
        {
            return await _context.Clients
                .Include(c => c.Cars)
                .ThenInclude(c => c.Orders)
                .FirstOrDefaultAsync(c => c.Id == id);
        }

        public async Task CreateAsync(Client client)
        {
            _context.Clients.Add(client);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Client client)
        {
            _context.Clients.Update(client);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var client = await _context.Clients.FindAsync(id);
            if (client != null)
            {
                _context.Clients.Remove(client);
                await _context.SaveChangesAsync();
            }
        }
    }
}
'@ | Set-Content Services\ClientService.cs

@'
using CarServiceWorkshop.Web.Data;
using CarServiceWorkshop.Web.Models;
using CarServiceWorkshop.Web.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarServiceWorkshop.Web.Services
{
    public class CarService : ICarService
    {
        private readonly AppDbContext _context;

        public CarService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Car>> GetAllAsync()
        {
            return await _context.Cars
                .Include(c => c.Client)
                .Include(c => c.Orders)
                .ToListAsync();
        }

        public async Task<Car?> GetByIdAsync(int id)
        {
            return await _context.Cars
                .Include(c => c.Client)
                .Include(c => c.Orders)
                .FirstOrDefaultAsync(c => c.Id == id);
        }

        public async Task CreateAsync(Car car)
        {
            _context.Cars.Add(car);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Car car)
        {
            _context.Cars.Update(car);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var car = await _context.Cars.FindAsync(id);
            if (car != null)
            {
                _context.Cars.Remove(car);
                await _context.SaveChangesAsync();
            }
        }
    }
}
'@ | Set-Content Services\CarService.cs

@'
using CarServiceWorkshop.Web.Data;
using CarServiceWorkshop.Web.Models;
using CarServiceWorkshop.Web.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarServiceWorkshop.Web.Services
{
    public class OrderService : IOrderService
    {
        private readonly AppDbContext _context;

        public OrderService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Order>> GetAllAsync()
        {
            return await _context.Orders
                .Include(o => o.Car)
                .ThenInclude(c => c.Client)
                .ToListAsync();
        }

        public async Task<Order?> GetByIdAsync(int id)
        {
            return await _context.Orders
                .Include(o => o.Car)
                .ThenInclude(c => c.Client)
                .FirstOrDefaultAsync(o => o.Id == id);
        }

        public async Task CreateAsync(Order order)
        {
            _context.Orders.Add(order);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Order order)
        {
            _context.Orders.Update(order);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var order = await _context.Orders.FindAsync(id);
            if (order != null)
            {
                _context.Orders.Remove(order);
                await _context.SaveChangesAsync();
            }
        }
    }
}
'@ | Set-Content Services\OrderService.cs

# ---------------- Controllers ----------------
@'
using CarServiceWorkshop.Web.Models;
using CarServiceWorkshop.Web.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace CarServiceWorkshop.Web.Controllers
{
    public class ClientsController : Controller
    {
        private readonly IClientService _clientService;

        public ClientsController(IClientService clientService)
        {
            _clientService = clientService;
        }

        public async Task<IActionResult> Index()
        {
            var clients = await _clientService.GetAllAsync();
            return View(clients);
        }

        public async Task<IActionResult> Details(int id)
        {
            var client = await _clientService.GetByIdAsync(id);
            if (client == null) return NotFound();
            return View(client);
        }

        public IActionResult Create()
        {
            return View(new Client());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Client client)
        {
            if (!ModelState.IsValid) return View(client);
            await _clientService.CreateAsync(client);
            return RedirectToAction(nameof(Index));
        }

        public async Task<IActionResult> Edit(int id)
        {
            var client = await _clientService.GetByIdAsync(id);
            if (client == null) return NotFound();
            return View(client);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Client client)
        {
            if (!ModelState.IsValid) return View(client);
            await _clientService.UpdateAsync(client);
            return RedirectToAction(nameof(Index));
        }

        public async Task<IActionResult> Delete(int id)
        {
            var client = await _clientService.GetByIdAsync(id);
            if (client == null) return NotFound();
            return View(client);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            await _clientService.DeleteAsync(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
'@ | Set-Content Controllers\ClientsController.cs

@'
using CarServiceWorkshop.Web.Models;
using CarServiceWorkshop.Web.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using System.Threading.Tasks;
using CarServiceWorkshop.Web.Data;
using Microsoft.EntityFrameworkCore;

namespace CarServiceWorkshop.Web.Controllers
{
    public class CarsController : Controller
    {
        private readonly ICarService _carService;
        private readonly AppDbContext _context;

        public CarsController(ICarService carService, AppDbContext context)
        {
            _carService = carService;
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            var cars = await _carService.GetAllAsync();
            return View(cars);
        }

        public async Task<IActionResult> Details(int id)
        {
            var car = await _carService.GetByIdAsync(id);
            if (car == null) return NotFound();
            return View(car);
        }

        public async Task<IActionResult> Create()
        {
            ViewBag.ClientId = new SelectList(await _context.Clients.ToListAsync(), "Id", "FullName");
            return View(new Car());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Car car)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.ClientId = new SelectList(await _context.Clients.ToListAsync(), "Id", "FullName", car.ClientId);
                return View(car);
            }
            await _carService.CreateAsync(car);
            return RedirectToAction(nameof(Index));
        }

        public async Task<IActionResult> Edit(int id)
        {
            var car = await _carService.GetByIdAsync(id);
            if (car == null) return NotFound();
            ViewBag.ClientId = new SelectList(await _context.Clients.ToListAsync(), "Id", "FullName", car.ClientId);
            return View(car);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Car car)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.ClientId = new SelectList(await _context.Clients.ToListAsync(), "Id", "FullName", car.ClientId);
                return View(car);
            }
            await _carService.UpdateAsync(car);
            return RedirectToAction(nameof(Index));
        }

        public async Task<IActionResult> Delete(int id)
        {
            var car = await _carService.GetByIdAsync(id);
            if (car == null) return NotFound();
            return View(car);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            await _carService.DeleteAsync(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
'@ | Set-Content Controllers\CarsController.cs

@'
using CarServiceWorkshop.Web.Data;
using CarServiceWorkshop.Web.Models;
using CarServiceWorkshop.Web.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;

namespace CarServiceWorkshop.Web.Controllers
{
    public class OrdersController : Controller
    {
        private readonly IOrderService _orderService;
        private readonly AppDbContext _context;

        public OrdersController(IOrderService orderService, AppDbContext context)
        {
            _orderService = orderService;
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            var orders = await _orderService.GetAllAsync();
            return View(orders);
        }

        public async Task<IActionResult> Details(int id)
        {
            var order = await _orderService.GetByIdAsync(id);
            if (order == null) return NotFound();
            return View(order);
        }

        public async Task<IActionResult> Create()
        {
            ViewBag.CarId = new SelectList(await _context.Cars.Include(c => c.Client).ToListAsync(), "Id", "PlateNumber");
            ViewBag.StatusList = new SelectList(System.Enum.GetValues(typeof(OrderStatus)));
            return View(new Order { Status = OrderStatus.Pending });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Order order)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.CarId = new SelectList(await _context.Cars.Include(c => c.Client).ToListAsync(), "Id", "PlateNumber", order.CarId);
                ViewBag.StatusList = new SelectList(System.Enum.GetValues(typeof(OrderStatus)), order.Status);
                return View(order);
            }
            order.CreatedAt = System.DateTime.UtcNow;
            await _orderService.CreateAsync(order);
            return RedirectToAction(nameof(Index));
        }

        public async Task<IActionResult> Edit(int id)
        {
            var order = await _orderService.GetByIdAsync(id);
            if (order == null) return NotFound();
            ViewBag.CarId = new SelectList(await _context.Cars.Include(c => c.Client).ToListAsync(), "Id", "PlateNumber", order.CarId);
            ViewBag.StatusList = new SelectList(System.Enum.GetValues(typeof(OrderStatus)), order.Status);
            return View(order);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Order order)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.CarId = new SelectList(await _context.Cars.Include(c => c.Client).ToListAsync(), "Id", "PlateNumber", order.CarId);
                ViewBag.StatusList = new SelectList(System.Enum.GetValues(typeof(OrderStatus)), order.Status);
                return View(order);
            }
            await _orderService.UpdateAsync(order);
            return RedirectToAction(nameof(Index));
        }

        public async Task<IActionResult> Delete(int id)
        {
            var order = await _orderService.GetByIdAsync(id);
            if (order == null) return NotFound();
            return View(order);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            await _orderService.DeleteAsync(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
'@ | Set-Content Controllers\OrdersController.cs

# ---------------- Layout + CSS + Simple Views ----------------
@'
@using CarServiceWorkshop.Web
@addTagHelper *, Microsoft.AspNetCore.Mvc.TagHelpers
'@ | Set-Content Views\_ViewImports.cshtml

@'
@{
    Layout = "_Layout";
}
'@ | Set-Content Views\_ViewStart.cshtml

@'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Car Service Workshop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="~/css/site.css" />
</head>
<body>
    <header class="top-bar">
        <div class="logo">
            <img src="~/images/cars/hero.jpg" alt="Car Service" />
            <span>Car Service Workshop</span>
        </div>
        <nav>
            <a asp-controller="Clients" asp-action="Index">Clients</a>
            <a asp-controller="Cars" asp-action="Index">Cars</a>
            <a asp-controller="Orders" asp-action="Index">Orders</a>
        </nav>
    </header>
    <main class="content">
        @RenderBody()
    </main>
    <footer class="footer">
        <span>© @DateTime.Now.Year - Car Service Workshop</span>
    </footer>
</body>
</html>
'@ | Set-Content Views\Shared\_Layout.cshtml

@'
body {
    margin: 0;
    font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    background: #0f172a;
    color: #e5e7eb;
}

.top-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 30px;
    background: linear-gradient(90deg, #111827, #1f2937);
    border-bottom: 1px solid #374151;
}

.logo {
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 600;
    color: #f97316;
}

.logo img {
    height: 40px;
    border-radius: 8px;
    object-fit: cover;
}

nav a {
    margin-left: 20px;
    color: #e5e7eb;
    text-decoration: none;
    font-weight: 500;
}

nav a:hover {
    color: #f97316;
}

.content {
    padding: 30px;
}

.footer {
    text-align: center;
    padding: 10px;
    border-top: 1px solid #374151;
    background: #020617;
    color: #6b7280;
    font-size: 0.9rem;
}

.table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
}

.table th, .table td {
    border-bottom: 1px solid #374151;
    padding: 8px 10px;
}

.table th {
    text-align: left;
    background: #111827;
}

.btn {
    display: inline-block;
    padding: 6px 12px;
    border-radius: 6px;
    text-decoration: none;
    font-size: 0.9rem;
    margin-right: 5px;
}

.btn-primary {
    background: #2563eb;
    color: white;
}

.btn-secondary {
    background: #4b5563;
    color: white;
}

.btn-danger {
    background: #b91c1c;
    color: white;
}

.btn-primary:hover {
    background: #1d4ed8;
}

.btn-secondary:hover {
    background: #374151;
}

.btn-danger:hover {
    background: #991b1b;
}

.card {
    background: #020617;
    border-radius: 10px;
    padding: 20px;
    border: 1px solid #1f2937;
    box-shadow: 0 10px 30px rgba(0,0,0,0.4);
}
'@ | Set-Content wwwroot\css\site.css

# Simple Index views (Clients, Cars, Orders)
@'
@model IEnumerable<CarServiceWorkshop.Web.Models.Client>

<h1>Clients</h1>
<a class="btn btn-primary" asp-action="Create">Create New Client</a>

<table class="table">
    <thead>
        <tr>
            <th>Full Name</th>
            <th>Phone</th>
            <th>Email</th>
            <th>Cars</th>
            <th></th>
        </tr>
    </thead>
    <tbody>
@foreach (var c in Model)
{
        <tr>
            <td>@c.FullName</td>
            <td>@c.Phone</td>
            <td>@c.Email</td>
            <td>@c.Cars.Count</td>
            <td>
                <a class="btn btn-secondary" asp-action="Details" asp-route-id="@c.Id">Details</a>
                <a class="btn btn-secondary" asp-action="Edit" asp-route-id="@c.Id">Edit</a>
                <a class="btn btn-danger" asp-action="Delete" asp-route-id="@c.Id">Delete</a>
            </td>
        </tr>
}
    </tbody>
</table>
'@ | Set-Content Views\Clients\Index.cshtml

@'
@model IEnumerable<CarServiceWorkshop.Web.Models.Car>

<h1>Cars</h1>
<a class="btn btn-primary" asp-action="Create">Create New Car</a>

<table class="table">
    <thead>
        <tr>
            <th>Plate</th>
            <th>Brand</th>
            <th>Model</th>
            <th>Year</th>
            <th>Client</th>
            <th>Orders</th>
            <th></th>
        </tr>
    </thead>
    <tbody>
@foreach (var c in Model)
{
        <tr>
            <td>@c.PlateNumber</td>
            <td>@c.Brand</td>
            <td>@c.Model</td>
            <td>@c.Year</td>
            <td>@c.Client.FullName</td>
            <td>@c.Orders.Count</td>
            <td>
                <a class="btn btn-secondary" asp-action="Details" asp-route-id="@c.Id">Details</a>
                <a class="btn btn-secondary" asp-action="Edit" asp-route-id="@c.Id">Edit</a>
                <a class="btn btn-danger" asp-action="Delete" asp-route-id="@c.Id">Delete</a>
            </td>
        </tr>
}
    </tbody>
</table>
'@ | Set-Content Views\Cars\Index.cshtml

@'
@model IEnumerable<CarServiceWorkshop.Web.Models.Order>

<h1>Orders</h1>
<a class="btn btn-primary" asp-action="Create">Create New Order</a>

<table class="table">
    <thead>
        <tr>
            <th>Car</th>
            <th>Client</th>
            <th>Created</th>
            <th>Description</th>
            <th>Estimated Cost</th>
            <th>Status</th>
            <th></th>
        </tr>
    </thead>
    <tbody>
@foreach (var o in Model)
{
        <tr>
            <td>@o.Car.PlateNumber (@o.Car.Brand @o.Car.Model)</td>
            <td>@o.Car.Client.FullName</td>
            <td>@o.CreatedAt.ToLocalTime()</td>
            <td>@o.Description</td>
            <td>@o.EstimatedCost.ToString("C")</td>
            <td>@o.Status</td>
            <td>
                <a class="btn btn-secondary" asp-action="Details" asp-route-id="@o.Id">Details</a>
                <a class="btn btn-secondary" asp-action="Edit" asp-route-id="@o.Id">Edit</a>
                <a class="btn btn-danger" asp-action="Delete" asp-route-id="@o.Id">Delete</a>
            </td>
        </tr>
}
    </tbody>
</table>
'@ | Set-Content Views\Orders\Index.cshtml

Write-Host "Project skeleton created. Next: add EF migrations and DB scripts."
