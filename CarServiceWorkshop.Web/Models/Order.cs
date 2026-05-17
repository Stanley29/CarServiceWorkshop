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
        public Car? Car { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
        public string Description { get; set; } = string.Empty;
        public decimal EstimatedCost { get; set; }
        public OrderStatus Status { get; set; }
    }
}
