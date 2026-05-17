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
