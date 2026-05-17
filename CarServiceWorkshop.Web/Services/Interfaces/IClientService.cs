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
