package cases
{
import cases.subjects.ASConfiguration;
import cases.subjects.Actor;
import cases.subjects.Mediator;
import cases.subjects.Message;
import cases.subjects.View;

import com.imagination.core.framework.Parsnip;

import flash.events.Event;

import mx.core.UIComponent;

import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;
import org.flexunit.async.Async;
import org.fluint.uiImpersonation.UIImpersonator;
import org.spicefactory.parsley.core.context.Context;

public class FrameworkTest
{
    private var _viewRoot:UIComponent;
    private var _actorA:Actor;
    private var _actorB:Actor;
    private var _view:View;
    private var _mediator:Mediator;

    [Before(async, ui)]
    public function before():void
    {
        _viewRoot = new UIComponent();
        Async.proceedOnEvent(this, _viewRoot, Event.ADDED_TO_STAGE, 1000);
        UIImpersonator.addChild(_viewRoot);

        // build objects
        _actorA = new Actor("actorA");
        _actorB = new Actor("actorB");
        _view = new View();
        _viewRoot.addChild(_view);
        _mediator = new Mediator(_view);

        var actA:Actor = new Actor("actA");
        var actB:Actor = new Actor("actB");
        var mediator:Mediator = new Mediator(_view);

        //add root context
        Parsnip.initialize(_viewRoot);

        //add actor 1
        Parsnip.registerActor(_actorA, "actorA");

        //add actor 2
        Parsnip.registerActor(_actorB, "actorB");

        //wire view
        Parsnip.registerView(_view);

        //wire mediator
        Parsnip.registerMediator(_mediator, "mediator");
    }

    [After(ui)]
    public function after():void
    {
        UIImpersonator.removeChild(_viewRoot);
        _viewRoot.removeChild(_view);
        _viewRoot = null;

        Parsnip.destroyContext();

        _actorA = null;
        _actorB = null;
        _view = null;
        _mediator = null;
    }

    /**
     * Test basic dependency injection
     */
    [Test(async, description="injection")]
    public function testInjection():void
    {
        assertTrue("mediator was injected with 'actorA' object", _mediator.actorA == _actorA);
        assertTrue("mediator was injected with 'actorB' object", _mediator.actorB == _actorB);
    }

    /**
     * Injection persistence after branch removal
     */
    [Test(async, description="injection persistence after branch removal")]
    public function testInjectionAfterRemoval():void
    {
        // destroy context of actorB
        var contextOfB:Context = Parsnip.getContextOf(_actorB);
        Parsnip.destroyContext(contextOfB);

        assertTrue("context for 'actorB' was destroyed", contextOfB.destroyed == true);

        // create new mediator under tree
        var newMediator:Mediator = new Mediator(_view);
        Parsnip.registerMediator(newMediator, "newMediator", null, null, "newMediator");

        assertTrue("newMediator was still injected with actorA", newMediator.actorA == _actorA);
    }

    /**
     *
     */
    [Test(async, description="setup from ActionscriptConfig")]
    public function testInjectionFromActionscriptConfig():void
    {
        // destroy previous modular approach
        Parsnip.destroyContext();

        // initialize new mainContext
        Parsnip.initialize(_viewRoot);

        Parsnip.registerFromASConfig(ASConfiguration);

        var contextList:Vector.<Context> = Parsnip.contextList;
        var actorA:Actor = ( contextList[1] as Context ).getObject("actorA") as Actor;
        var actorB:Actor = ( contextList[1] as Context ).getObject("actorB") as Actor;
        var mediator:Mediator = ( contextList[1] as Context ).getObject("mediator") as Mediator;

        assertTrue("mediator was injected with 'actorA' object", mediator.actorA == actorA);
        assertTrue("mediator was injected with 'actorB' object", mediator.actorB == actorB);
    }

    //TODO: needs reviewing
//    [Test(async, description="setup from FlexConfig")]
//    public function testInjectionFromFlexConfig():void
//    {
//        // destroy previous modular approach
//        Parsnip.destroyContext();
//
//        // initialize new mainContext
//        Parsnip.initialize(_viewRoot);
//
//        Parsnip.registerFromASConfig(new FlexConfiguration());
//
//        assertTrue("mediator was injected with 'actorA' object", _mediator.actorA == _actorA);
//        assertTrue("mediator was injected with 'actorB' object", _mediator.actorB == _actorB);
//    }

    /**
     * Test component messaging
     */
    [Test(async, description="messaging")]
    public function testMessaging():void
    {
        // message view from actor
        var payload:String = "Hello view from " + _actorA.id;
        _actorA.sendMessage(payload, Message.SELECTOR_FORVIEW);
        assertTrue("view received the message from actorA", _view.receivedMessage == payload);

        // message view from subActor
        payload = "Hello view from " + _actorB.id;
        _actorB.sendMessage(payload, Message.SELECTOR_FORVIEW);
        assertTrue("view received the message from actorB", _view.receivedMessage == payload);

        // message only Actors
        payload = "Hello actors";
        _actorA.sendMessage(payload, Message.SELECTOR_FORACTOR);
        assertFalse("view didnt received the message for actors", _view.receivedMessage == payload);
        assertTrue("actorA received the message from actorA", _actorA.receivedMessage == payload);
        assertTrue("actorB received the message from actorA", _actorB.receivedMessage == payload);

        // global messaging
        payload = "Hello from Parsnip";
        var message:Message = new Message(payload);
        Parsnip.dispatchMessage(message, "forView");
        assertTrue("global message was not received by non subscriber", _actorA.receivedMessage != payload);
        assertTrue("global message was received by subscriber", _view.receivedMessage == payload);
    }
}
}
