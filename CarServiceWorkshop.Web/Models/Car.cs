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
        public Client? Client { get; set; } = null!;

        public ICollection<Order>? Orders { get; set; } = new List<Order>();
    }
}
