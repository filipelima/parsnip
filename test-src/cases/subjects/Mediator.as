package cases.subjects
{
import flash.display.DisplayObject;

import org.spicefactory.parsley.core.context.Context;

public class Mediator
{
    [Inject]
    public var context:Context;

    [Inject(id="actorA")]
    public var actorA:Actor;

    [Inject(id="actorB", required="false")]
    public var actorB:Actor;

    [MessageDispatcher]
    public var dispatcher:Function;

    private var _view:DisplayObject;

    public function Mediator(view:DisplayObject = null)
    {
        _view = view;
    }

    [Init]
    public function init():void
    {
        trace("Mediator initialized.");
    }

    [Destroy]
    public function destroy():void
    {
        dispatcher = null;
        _view = null;
        actorA = null;
        actorB = null;

        trace("Mediator destroyed.");
    }

    public function get view():DisplayObject
    {
        return _view;
    }

    public function set view(view:DisplayObject):void
    {
        _view = view;
    }
}
}
