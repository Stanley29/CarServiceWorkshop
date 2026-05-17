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

        //protected override void OnModelCreating(ModelBuilder modelBuilder)
        //{
        //    base.OnModelCreating(modelBuilder);

        //    modelBuilder.Entity<Client>()
        //        .HasMany(c => c.Cars)
        //        .WithOne(c => c.Client)
        //        .HasForeignKey(c => c.ClientId)
        //        .OnDelete(DeleteBehavior.Cascade);

        //    modelBuilder.Entity<Car>()
        //        .HasMany(c => c.Orders)
        //        .WithOne(o => o.Car)
        //        .HasForeignKey(o => o.CarId)
        //        .OnDelete(DeleteBehavior.Cascade);
        //}

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Car>()
                .HasOne(c => c.Client)
                .WithMany(c => c.Cars)
                .HasForeignKey(c => c.ClientId)
                .IsRequired();

            modelBuilder.Entity<Order>()
                .HasOne(o => o.Car)
                .WithMany(c => c.Orders)
                .HasForeignKey(o => o.CarId)
                .IsRequired();
        }

    }
}
