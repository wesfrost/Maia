namespace Maia.Contracts;
public record RunRequest(
    string UserId,
    string PersonaId,
    string TaskType,
    string Goal,
    System.Collections.Generic.Dictionary<string,object>? Inputs
);
public record RouteDecision(string Provider, string Model, double Temperature);
public record RunEvent(string Type, System.DateTime Ts, object Payload);
