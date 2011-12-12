package cases.subjects
{
public class Actor
{
    [MessageDispatcher]
    public var dispatcher:Function;

    private var _receivedMessage:*;

    private var _id:String;

    public function Actor(id:String)
    {
        _id = id;
    }

    [Init]
    public function init():void
    {
        trace("Actor id: " + _id + " initiated");
    }

    public function sendMessage(payload:*, target:String = null):void
    {
        var message:Message = new Message(payload, target);
        dispatcher(message);
    }

    /**
     * Handles only messages directed to Actor
     * @see selector
     * @param message
     */
    [MessageHandler(selector="forActor")]
    public function messageHandler(message:Message):void
    {
        _receivedMessage = message.payload;
    }

    public function get receivedMessage():*
    {
        return _receivedMessage;
    }

    public function get id():String
    {
        return _id;
    }

    [Destroy]
    public function destroy():void
    {
        _id = null;
        dispatcher = null;

        trace("Actor id: " + _id + " destroyed");
    }
}
}
