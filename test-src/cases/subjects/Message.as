package cases.subjects
{
public class Message
{
    public static const SELECTOR_FORVIEW:String = "forView";
    public static const SELECTOR_FORACTOR:String = "forActor";

    [Selector]
    public var target:String;

    private var _payload:*;

    public function Message(payload:*, $target:String = null)
    {
        _payload = payload;
        target = $target;
    }

    public function get payload():*
    {
        return _payload;
    }
}
}
