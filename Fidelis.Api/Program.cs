using Fidelis.Api.Exceptions;
using Fidelis.Api.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();
builder.Services.AddSwagger();
builder.Services.AddServices();
builder.Services.AddRepositories();
builder.Services.AddDbContext(builder.Configuration);

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();
app.UseExceptionHandler();
app.UseAuthorization();
app.MapControllers();

app.Run();
