package cases.subjects
{
public class Order
{
    public var id:String;

    [ChoiceType("cases.subjects.Book")]
    public var bookList:Array;

    [ChoiceType("cases.subjects.Album")]
    public var albumList:Array
}
}
