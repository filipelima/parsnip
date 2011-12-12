package cases.subjects
{
import mx.core.UIComponent;

public class View extends UIComponent
{
    private var _receivedMessage:*;

    [Init]
    public function init():void
    {
        trace("View initiated");
    }

    /**
     * Handles only messages directed to View
     * @see selector
     * @param message
     */
    [MessageHandler(selector="forView")]
    public function messageHandler(message:Message):void
    {
        _receivedMessage = message.payload;
    }

    /**
     * Return the message received from the framework
     */
    public function get receivedMessage():*
    {
        return _receivedMessage;
    }

    [Destroy]
    public function destroy():void
    {
        _receivedMessage = null;

        trace("View destroyed.");
    }
}
}
