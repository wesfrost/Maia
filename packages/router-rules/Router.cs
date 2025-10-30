namespace Maia.RouterRules;

public static class Router
{
    // Minimal, known-good prompt using raw string literal
    private const string SystemPrompt = """
You are Maia Router.
Decide which model/route id should handle the task.
Return only one of: fast, balanced, deep.
""";

    public static string Route(string task)
    {
        if (string.IsNullOrWhiteSpace(task))
            return "balanced";

        var len = task.Length;
        if (len < 120) return "fast";
        if (len < 800) return "balanced";
        return "deep";
    }
}
