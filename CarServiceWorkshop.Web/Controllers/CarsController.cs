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
            return View();
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

            car.Client = null; 
            _context.Cars.Add(car);
            await _context.SaveChangesAsync();

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
