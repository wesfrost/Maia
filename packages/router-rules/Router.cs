using Maia.Contracts;

namespace Maia.RouterRules;
public interface IRouter { RouteDecision ChooseModel(RunRequest req); }

public sealed class SimpleRouter : IRouter
{
    public RouteDecision ChooseModel(RunRequest req) => req.TaskType?.ToLowerInvariant() switch
    {
        "refactor"  => new("openai","gpt-5",   0.2),
        "transform" => new("openai","gpt-4.1", 0.0),
        _           => new("openai","gpt-5-mini", 0.3)
    };
}
