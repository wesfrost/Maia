using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var host = Host.CreateDefaultBuilder(args)
 .ConfigureServices((ctx, services) =>
 {
 services.AddHostedService<OrchestratorService>();
 })
 .Build();

await host.RunAsync();

internal sealed class OrchestratorService : BackgroundService
{
 private readonly ILogger<OrchestratorService> _logger;

 public OrchestratorService(ILogger<OrchestratorService> logger)
 {
 _logger = logger;
 }

 protected override async Task ExecuteAsync(CancellationToken stoppingToken)
 {
 _logger.LogInformation("Orchestrator service starting.");

 try
 {
 while (!stoppingToken.IsCancellationRequested)
 {
 // Minimal heartbeat work — replace with real orchestration loop.
 _logger.LogDebug("Orchestrator heartbeat at {time}", DateTimeOffset.UtcNow);
 await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
 }
 }
 catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
 {
 // expected on shutdown
 }

 _logger.LogInformation("Orchestrator service stopping.");
 }
}
