var app = WebApplication.CreateBuilder(args).Build();
app.MapGet("/health", () => Results.Ok(new { ok = true, ts = DateTime.UtcNow }));
app.Run();
