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
