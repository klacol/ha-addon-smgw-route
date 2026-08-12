# .NET Agent Integration in Home Assistant Addon

## 📋 Übersicht

Dieses Dokument beschreibt, wie ein .NET 10 Agent als Daemon in einem Home Assistant Addon betrieben werden kann. Der Agent kommuniziert bidirektional mit einem zentralen RabbitMQ-Server im Internet.

## 🏗️ Architektur

```
┌─────────────────────────────────────────┐
│  Home Assistant Server                  │
│  ┌───────────────────────────────────┐  │
│  │  .NET Agent Addon (Docker)        │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │  .NET 10 Runtime             │  │  │
│  │  │  + Agent Application         │  │  │
│  │  │  + RabbitMQ Client           │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────┬───────────────────────┘
                  │ Internet
                  │ AMQPS (5671/5672)
                  ↓
       ┌────────────────────────┐
       │  RabbitMQ Server       │
       │  (Cloud/Internet)      │
       └────────────────────────┘
```

## 🚀 Implementierung

### Option 1: Self-Contained Deployment (Empfohlen)

Der Agent wird als self-contained binary kompiliert - kein separates .NET Runtime Setup nötig.

#### Dockerfile

```dockerfile
# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS build
WORKDIR /src

# Copy csproj and restore
COPY ["YourAgent/YourAgent.csproj", "./"]
RUN dotnet restore

# Copy source code
COPY ["YourAgent/", "./"]

# Publish as self-contained single file
RUN dotnet publish -c Release -o /app/publish \
    --self-contained true \
    --runtime linux-musl-x64 \
    /p:PublishSingleFile=true \
    /p:PublishTrimmed=true \
    /p:EnableCompressionInSingleFile=true

# Runtime Stage
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Install minimal dependencies
RUN apk add --no-cache \
    bash \
    jq \
    icu-libs \
    libgcc \
    libstdc++ \
    ca-certificates

# Copy published agent
COPY --from=build /app/publish /app/agent
RUN chmod +x /app/agent/YourAgent

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Health check (optional)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep -f YourAgent || exit 1

CMD [ "/run.sh" ]
```

#### run.sh

```bash
#!/usr/bin/with-contenv bashio

# ============================================
# Home Assistant Addon Run Script
# ============================================

set -e

# Read configuration from Home Assistant
RABBITMQ_HOST=$(bashio::config 'rabbitmq_host')
RABBITMQ_PORT=$(bashio::config 'rabbitmq_port')
RABBITMQ_USER=$(bashio::config 'rabbitmq_user')
RABBITMQ_PASSWORD=$(bashio::config 'rabbitmq_password')
RABBITMQ_VHOST=$(bashio::config 'rabbitmq_vhost')
RABBITMQ_USE_SSL=$(bashio::config 'rabbitmq_use_ssl')
AGENT_ID=$(bashio::config 'agent_id')
LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "========================================="
bashio::log.info "Starting .NET Energy Manager Agent..."
bashio::log.info "========================================="
bashio::log.info "Agent ID: ${AGENT_ID}"
bashio::log.info "RabbitMQ Host: ${RABBITMQ_HOST}:${RABBITMQ_PORT}"
bashio::log.info "RabbitMQ VHost: ${RABBITMQ_VHOST}"
bashio::log.info "RabbitMQ SSL: ${RABBITMQ_USE_SSL}"
bashio::log.info "Log Level: ${LOG_LEVEL}"
bashio::log.info "========================================="

# Set environment variables for the agent
export RabbitMQ__Host="${RABBITMQ_HOST}"
export RabbitMQ__Port="${RABBITMQ_PORT}"
export RabbitMQ__User="${RABBITMQ_USER}"
export RabbitMQ__Password="${RABBITMQ_PASSWORD}"
export RabbitMQ__VirtualHost="${RABBITMQ_VHOST}"
export RabbitMQ__UseSsl="${RABBITMQ_USE_SSL}"
export Agent__Id="${AGENT_ID}"
export Logging__LogLevel__Default="${LOG_LEVEL}"

# Change to agent directory
cd /app/agent

# Start agent in foreground (important for Docker!)
# Docker needs the main process to run in foreground
exec ./YourAgent
```

#### config.yaml

```yaml
name: "Energy Manager Agent"
version: "1.0.0"
slug: energy-manager-agent
description: ".NET Agent für bidirektionale RabbitMQ-Kommunikation mit Energy Manager"
url: "https://github.com/yourusername/ha-addon-energy-manager"
arch:
  - aarch64
  - amd64
  - armv7
init: false
host_network: false
hassio_api: true
hassio_role: default

# Startup settings
startup: application
boot: auto
watchdog: true

# Resource limits (optional)
map:
  - config:rw

# Options with defaults
options:
  rabbitmq_host: "rabbitmq.example.com"
  rabbitmq_port: 5672
  rabbitmq_user: "guest"
  rabbitmq_password: ""
  rabbitmq_vhost: "/"
  rabbitmq_use_ssl: true
  agent_id: ""
  log_level: "Information"

# Schema validation
schema:
  rabbitmq_host: str
  rabbitmq_port: port
  rabbitmq_user: str
  rabbitmq_password: password
  rabbitmq_vhost: str
  rabbitmq_use_ssl: bool
  agent_id: str
  log_level: list(Trace|Debug|Information|Warning|Error|Critical)?
```

#### build.json

```json
{
  "build_from": {
    "aarch64": "ghcr.io/home-assistant/aarch64-base:latest",
    "amd64": "ghcr.io/home-assistant/amd64-base:latest",
    "armv7": "ghcr.io/home-assistant/armv7-base:latest"
  },
  "args": {}
}
```

### Option 2: Framework-Dependent Deployment

Für kleinere Binary-Größe, erfordert .NET Runtime Installation:

#### Dockerfile (Alternative)

```dockerfile
# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS build
WORKDIR /src

COPY ["YourAgent/YourAgent.csproj", "./"]
RUN dotnet restore

COPY ["YourAgent/", "./"]
RUN dotnet publish -c Release -o /app/publish \
    --self-contained false \
    --runtime linux-musl-x64

# Runtime Stage
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Install .NET 10 Runtime
RUN apk add --no-cache \
    bash \
    jq \
    icu-libs \
    libgcc \
    libstdc++ \
    ca-certificates \
    wget \
    && wget -O dotnet-install.sh https://dot.net/v1/dotnet-install.sh \
    && chmod +x dotnet-install.sh \
    && ./dotnet-install.sh --channel 10.0 --runtime dotnet --install-dir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet-install.sh

COPY --from=build /app/publish /app/agent
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
```

## 🎯 .NET Agent Implementation

### Program.cs

```csharp
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var builder = Host.CreateApplicationBuilder(args);

// JSON Console Logging für bessere Home Assistant Integration
builder.Logging.ClearProviders();
builder.Logging.AddJsonConsole(options =>
{
    options.IncludeScopes = true;
    options.TimestampFormat = "yyyy-MM-dd HH:mm:ss ";
});

// Services registrieren
builder.Services.Configure<RabbitMqSettings>(
    builder.Configuration.GetSection("RabbitMQ"));
builder.Services.Configure<AgentSettings>(
    builder.Configuration.GetSection("Agent"));

builder.Services.AddSingleton<IRabbitMqService, RabbitMqService>();
builder.Services.AddHostedService<EnergyManagerAgent>();

var host = builder.Build();

// Agent im Vordergrund laufen lassen (wichtig für Docker!)
await host.RunAsync();
```

### EnergyManagerAgent.cs (BackgroundService)

```csharp
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

public class EnergyManagerAgent : BackgroundService
{
    private readonly ILogger<EnergyManagerAgent> _logger;
    private readonly IRabbitMqService _rabbitMq;
    private readonly AgentSettings _settings;

    public EnergyManagerAgent(
        ILogger<EnergyManagerAgent> logger,
        IRabbitMqService rabbitMq,
        IOptions<AgentSettings> settings)
    {
        _logger = logger;
        _rabbitMq = rabbitMq;
        _settings = settings.Value;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Energy Manager Agent starting...");
        _logger.LogInformation("Agent ID: {AgentId}", _settings.Id);

        try
        {
            // RabbitMQ Connection aufbauen
            await _rabbitMq.ConnectAsync(stoppingToken);
            _logger.LogInformation("Connected to RabbitMQ");

            // Message Consumer starten
            await _rabbitMq.StartConsumingAsync(stoppingToken);

            // Haupt-Loop
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    // Heartbeat oder periodische Tasks
                    await SendHeartbeatAsync(stoppingToken);
                    await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    // Normal shutdown
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error in agent loop");
                    await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogCritical(ex, "Fatal error in Energy Manager Agent");
            throw;
        }
        finally
        {
            _logger.LogInformation("Energy Manager Agent stopping...");
            await _rabbitMq.DisconnectAsync();
        }
    }

    private async Task SendHeartbeatAsync(CancellationToken cancellationToken)
    {
        var heartbeat = new
        {
            AgentId = _settings.Id,
            Timestamp = DateTimeOffset.UtcNow,
            Status = "Running"
        };

        await _rabbitMq.PublishAsync("heartbeat", heartbeat, cancellationToken);
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Graceful shutdown initiated...");
        await base.StopAsync(cancellationToken);
    }
}
```

### RabbitMqService.cs (Beispiel)

```csharp
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Text;
using System.Text.Json;

public interface IRabbitMqService
{
    Task ConnectAsync(CancellationToken cancellationToken = default);
    Task DisconnectAsync();
    Task StartConsumingAsync(CancellationToken cancellationToken = default);
    Task PublishAsync<T>(string routingKey, T message, CancellationToken cancellationToken = default);
}

public class RabbitMqService : IRabbitMqService, IDisposable
{
    private readonly ILogger<RabbitMqService> _logger;
    private readonly RabbitMqSettings _settings;
    private IConnection? _connection;
    private IChannel? _channel;

    public RabbitMqService(
        ILogger<RabbitMqService> logger,
        IOptions<RabbitMqSettings> settings)
    {
        _logger = logger;
        _settings = settings.Value;
    }

    public async Task ConnectAsync(CancellationToken cancellationToken = default)
    {
        var factory = new ConnectionFactory
        {
            HostName = _settings.Host,
            Port = _settings.Port,
            UserName = _settings.User,
            Password = _settings.Password,
            VirtualHost = _settings.VirtualHost,
            AutomaticRecoveryEnabled = true,
            NetworkRecoveryInterval = TimeSpan.FromSeconds(10)
        };

        if (_settings.UseSsl)
        {
            factory.Ssl = new SslOption
            {
                Enabled = true,
                ServerName = _settings.Host
            };
        }

        _connection = await factory.CreateConnectionAsync(cancellationToken);
        _channel = await _connection.CreateChannelAsync(cancellationToken);

        _logger.LogInformation("RabbitMQ connection established");

        // Exchange und Queue deklarieren
        await _channel.ExchangeDeclareAsync(
            exchange: "energy-manager",
            type: ExchangeType.Topic,
            durable: true,
            cancellationToken: cancellationToken);

        await _channel.QueueDeclareAsync(
            queue: $"agent-{_settings.User}",
            durable: true,
            exclusive: false,
            autoDelete: false,
            cancellationToken: cancellationToken);

        await _channel.QueueBindAsync(
            queue: $"agent-{_settings.User}",
            exchange: "energy-manager",
            routingKey: $"commands.{_settings.User}.*",
            cancellationToken: cancellationToken);
    }

    public async Task StartConsumingAsync(CancellationToken cancellationToken = default)
    {
        if (_channel == null)
            throw new InvalidOperationException("Not connected");

        var consumer = new AsyncEventingBasicConsumer(_channel);
        consumer.ReceivedAsync += async (sender, ea) =>
        {
            try
            {
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                
                _logger.LogInformation("Received message: {Message}", message);
                
                // Message verarbeiten
                await ProcessMessageAsync(message, cancellationToken);
                
                // ACK senden
                await _channel.BasicAckAsync(ea.DeliveryTag, false, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing message");
                // NACK bei Fehler
                await _channel.BasicNackAsync(ea.DeliveryTag, false, true, cancellationToken);
            }
        };

        await _channel.BasicConsumeAsync(
            queue: $"agent-{_settings.User}",
            autoAck: false,
            consumer: consumer,
            cancellationToken: cancellationToken);

        _logger.LogInformation("Started consuming messages");
    }

    public async Task PublishAsync<T>(string routingKey, T message, CancellationToken cancellationToken = default)
    {
        if (_channel == null)
            throw new InvalidOperationException("Not connected");

        var json = JsonSerializer.Serialize(message);
        var body = Encoding.UTF8.GetBytes(json);

        await _channel.BasicPublishAsync(
            exchange: "energy-manager",
            routingKey: routingKey,
            body: body,
            cancellationToken: cancellationToken);

        _logger.LogDebug("Published message to {RoutingKey}", routingKey);
    }

    private async Task ProcessMessageAsync(string message, CancellationToken cancellationToken)
    {
        // Ihre Message-Processing-Logik hier
        await Task.CompletedTask;
    }

    public async Task DisconnectAsync()
    {
        if (_channel != null)
        {
            await _channel.CloseAsync();
            _channel.Dispose();
        }

        if (_connection != null)
        {
            await _connection.CloseAsync();
            _connection.Dispose();
        }

        _logger.LogInformation("RabbitMQ connection closed");
    }

    public void Dispose()
    {
        _channel?.Dispose();
        _connection?.Dispose();
    }
}

public class RabbitMqSettings
{
    public string Host { get; set; } = "localhost";
    public int Port { get; set; } = 5672;
    public string User { get; set; } = "guest";
    public string Password { get; set; } = "guest";
    public string VirtualHost { get; set; } = "/";
    public bool UseSsl { get; set; } = false;
}

public class AgentSettings
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
}
```

## 📦 Build und Deployment

### Lokaler Build

```powershell
# In Ihrem Agent-Projekt-Verzeichnis
cd YourAgent

# Test build
dotnet build -c Release

# Publish test (self-contained)
dotnet publish -c Release -o ./publish `
    --self-contained true `
    --runtime linux-musl-x64 `
    /p:PublishSingleFile=true
```

### Docker Build

```bash
# Single architecture (für Tests)
docker build -t energy-manager-agent:latest .

# Multi-architecture (für Production)
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t energy-manager-agent:1.0.0 \
  --push .
```

### Addon Repository Struktur

```
ha-addon-energy-manager/
├── energy-manager-agent/
│   ├── build.json
│   ├── config.yaml
│   ├── Dockerfile
│   ├── run.sh
│   ├── CHANGELOG.md
│   ├── DOCS.md
│   ├── README.md
│   └── YourAgent/
│       ├── YourAgent.csproj
│       ├── Program.cs
│       ├── EnergyManagerAgent.cs
│       ├── RabbitMqService.cs
│       └── appsettings.json
└── repository.yaml
```

### repository.yaml

```yaml
name: "Energy Manager Addons"
url: "https://github.com/yourusername/ha-addon-energy-manager"
maintainer: "Your Name <your.email@example.com>"
```

## 🔧 Konfiguration

### appsettings.json (im Agent-Projekt)

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "RabbitMQ.Client": "Warning"
    }
  },
  "RabbitMQ": {
    "Host": "localhost",
    "Port": 5672,
    "User": "guest",
    "Password": "guest",
    "VirtualHost": "/",
    "UseSsl": false
  },
  "Agent": {
    "Id": "default-agent-id"
  }
}
```

### .csproj Dependencies

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <PublishSingleFile>true</PublishSingleFile>
    <PublishTrimmed>true</PublishTrimmed>
    <EnableCompressionInSingleFile>true</EnableCompressionInSingleFile>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.Extensions.Hosting" Version="10.0.0" />
    <PackageReference Include="Microsoft.Extensions.Logging.Console" Version="10.0.0" />
    <PackageReference Include="RabbitMQ.Client" Version="7.0.0" />
  </ItemGroup>

</Project>
```

## ✅ Best Practices

### 1. Graceful Shutdown

```csharp
// In ExecuteAsync
protected override async Task ExecuteAsync(CancellationToken stoppingToken)
{
    // Registriere Shutdown-Handler
    stoppingToken.Register(() => 
        _logger.LogInformation("Shutdown signal received"));

    try
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            // Ihre Logik mit CancellationToken
            await DoWorkAsync(stoppingToken);
        }
    }
    catch (OperationCanceledException)
    {
        // Normal shutdown - nicht loggen als Error
    }
    finally
    {
        // Cleanup
        await CleanupAsync();
    }
}
```

### 2. Connection Resilience

```csharp
// Automatic reconnection
var factory = new ConnectionFactory
{
    AutomaticRecoveryEnabled = true,
    NetworkRecoveryInterval = TimeSpan.FromSeconds(10),
    RequestedHeartbeat = TimeSpan.FromSeconds(60)
};

// Connection-Recovery Events
_connection.ConnectionShutdownAsync += async (sender, args) =>
{
    _logger.LogWarning("Connection lost: {Reason}", args.ReplyText);
    await Task.CompletedTask;
};

_connection.ConnectionRecoveryErrorAsync += async (sender, args) =>
{
    _logger.LogError(args.Exception, "Recovery failed");
    await Task.CompletedTask;
};
```

### 3. Health Monitoring

```bash
# In run.sh - optional health check script erstellen
cat > /usr/local/bin/healthcheck.sh << 'EOF'
#!/bin/bash
if pgrep -f YourAgent > /dev/null; then
    exit 0
else
    exit 1
fi
EOF
chmod +x /usr/local/bin/healthcheck.sh
```

### 4. Structured Logging

```csharp
// Verwenden Sie strukturiertes Logging
_logger.LogInformation(
    "Message received from {Source} with {MessageType}",
    source,
    messageType);

// NICHT:
_logger.LogInformation($"Message received from {source} with {messageType}");
```

### 5. Configuration Validation

```csharp
// In Program.cs
builder.Services.AddOptions<RabbitMqSettings>()
    .Bind(builder.Configuration.GetSection("RabbitMQ"))
    .ValidateDataAnnotations()
    .ValidateOnStart();

// In Settings-Klasse
public class RabbitMqSettings
{
    [Required]
    public string Host { get; set; } = string.Empty;
    
    [Range(1, 65535)]
    public int Port { get; set; } = 5672;
    
    [Required]
    public string User { get; set; } = string.Empty;
}
```

## 🐛 Troubleshooting

### Agent startet nicht

```bash
# Logs anschauen in Home Assistant
# Settings -> System -> Logs -> Energy Manager Agent

# Oder via SSH
docker logs addon_SLUG

# Container inspizieren
docker exec -it addon_SLUG /bin/bash
```

### RabbitMQ Connection Fehler

```bash
# SSL/TLS Probleme
# Prüfen Sie in run.sh:
export DOTNET_SYSTEM_NET_HTTP_SOCKETSHTTPHANDLER_HTTP2SUPPORT=1

# Certificate validation überspringen (nur für Tests!)
export NODE_TLS_REJECT_UNAUTHORIZED=0
```

### Logs nicht sichtbar

```csharp
// Sicherstellen, dass Console Logging aktiviert ist
builder.Logging.AddConsole();

// Und Log Level nicht zu hoch
builder.Logging.SetMinimumLevel(LogLevel.Information);
```

### Memory Leaks

```bash
# Memory Usage überwachen in config.yaml
# Resource limits setzen (optional)
# In config.yaml:
apparmor: false
resources:
  memory:
    max: 512M
```

## 📊 Monitoring

### Logs in Home Assistant

Die Addon-Logs sind automatisch in Home Assistant verfügbar:
- **UI**: Settings → System → Logs → Ihr Addon
- **CLI**: `ha addons logs your-addon-slug`

### Custom Metrics (Optional)

```csharp
// Prometheus Metrics via HTTP endpoint
builder.Services.AddSingleton<IMetricsService, MetricsService>();

// Simple HTTP endpoint für Health Check
app.MapGet("/health", () => Results.Ok(new { 
    Status = "Healthy",
    Timestamp = DateTime.UtcNow 
}));
```

## 🔒 Security

### Secrets Management

```yaml
# In config.yaml - Passwörter als protected fields
schema:
  rabbitmq_password: password  # Automatisch maskiert in UI
```

```bash
# In run.sh - Secrets nicht loggen!
bashio::log.info "RabbitMQ User: ${RABBITMQ_USER}"
bashio::log.info "RabbitMQ Password: ***REDACTED***"
```

### TLS/SSL

```csharp
// RabbitMQ mit TLS
var factory = new ConnectionFactory
{
    Ssl = new SslOption
    {
        Enabled = true,
        ServerName = _settings.Host,
        AcceptablePolicyErrors = 
            SslPolicyErrors.RemoteCertificateNameMismatch |
            SslPolicyErrors.RemoteCertificateChainErrors  // Nur für Tests!
    }
};
```

## 📝 Testing

### Lokaler Test ohne Home Assistant

```bash
# Environment Variables setzen
export RabbitMQ__Host=your-rabbitmq.example.com
export RabbitMQ__Port=5672
export RabbitMQ__User=testuser
export RabbitMQ__Password=testpass

# Agent lokal starten
dotnet run --project YourAgent
```

### Docker Test

```bash
# Lokal builden
docker build -t energy-manager-agent:test .

# Mit ENV vars starten
docker run --rm \
  -e RabbitMQ__Host=rabbitmq.example.com \
  -e RabbitMQ__User=test \
  -e RabbitMQ__Password=test123 \
  energy-manager-agent:test
```

## 📚 Weitere Ressourcen

- [Home Assistant Addon Development](https://developers.home-assistant.io/docs/add-ons)
- [.NET 10 Documentation](https://learn.microsoft.com/dotnet/)
- [RabbitMQ .NET Client](https://www.rabbitmq.com/tutorials/tutorial-one-dotnet.html)
- [Docker Multi-Platform Builds](https://docs.docker.com/build/building/multi-platform/)

## 🎯 Nächste Schritte

1. ✅ Agent-Code in .NET 10 implementieren
2. ✅ RabbitMQ Client integrieren
3. ✅ Dockerfile und run.sh anpassen
4. ✅ config.yaml konfigurieren
5. ✅ Lokal testen
6. ✅ Docker Image für Multi-Architecture bauen
7. ✅ In Home Assistant Addon Store veröffentlichen

---

**Lizenz**: Anpassen an Ihr Projekt  
**Maintainer**: Ihr Name  
**Version**: 1.0.0
