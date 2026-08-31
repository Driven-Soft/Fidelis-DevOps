using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Fidelis.Infrastructure.Persistence;

public class FidelisContextFactory : IDesignTimeDbContextFactory<FidelisContext>
{
    public FidelisContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<FidelisContext>();
        var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__FidelisMySql")
            ?? "Server=localhost;Port=3306;Database=fidelis;User ID=fidelis;Password=fidelis;";

        optionsBuilder.UseMySql(connectionString, ServerVersion.Parse("8.0.0-mysql"));

        return new FidelisContext(optionsBuilder.Options);
    }
}