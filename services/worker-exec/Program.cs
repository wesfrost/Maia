var builder = Host.CreateApplicationBuilder(args);
builder.Services.AddHostedService<Worker>();
var app = builder.Build();
await app.RunAsync();

sealed class Worker : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var logger = LoggerFactory.Create(b=>b.AddConsole()).CreateLogger<Worker>();
        logger.LogInformation("WorkerExec running.");
        while (!stoppingToken.IsCancellationRequested)
        {
            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
            logger.LogInformation("WorkerExec heartbeat {Time}", DateTimeOffset.Now);
        }
    }
}
