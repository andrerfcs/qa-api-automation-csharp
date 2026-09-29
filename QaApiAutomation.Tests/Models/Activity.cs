namespace QaApiAutomation.Tests.Models;

public class Activity
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public DateTime DueDate { get; set; }
    public bool Completed { get; set; }
}
