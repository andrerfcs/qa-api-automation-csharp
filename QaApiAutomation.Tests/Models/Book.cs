namespace QaApiAutomation.Tests.Models;

public class Book
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int PageCount { get; set; }
    public string Excerpt { get; set; } = string.Empty;
    public DateTime PublishDate { get; set; }
}