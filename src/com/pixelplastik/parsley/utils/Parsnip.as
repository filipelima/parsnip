/*
 The MIT License

 Copyright (c) 2011 Filipe Prata de Lima
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
package com.pixelplastik.parsley.utils
{
import flash.display.DisplayObject;
import flash.system.ApplicationDomain;

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.asconfig.ActionScriptConfig;
import org.spicefactory.parsley.core.bootstrap.ConfigurationProcessor;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.state.GlobalState;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.dsl.context.ContextBuilderSetup;
import org.spicefactory.parsley.dsl.view.Configure;
import org.spicefactory.parsley.flex.FlexConfig;

/**
 * Parsnip is a helper class to simplify the usability of the Spicefactory Parsley framework in modular scenarios.
 *
 * @author filipelima.com
 *
 * @see http://www.spicefactory.org/parsley/docs/2.4/manual/
 * @see http://www.spicefactory.org/parsley/docs/2.4/api/parsley-flash/
 * @see http://www.spicefactory.org/parsley/docs/2.4/api/parsley-flex/
 *
 */
public class Parsnip
{
    private var _instance:Parsnip;

    private static var _contextList:Vector.<Context>;
    private static var _mainContext:Context;
    private static var _applicationDomain:ApplicationDomain;

    public function Parsnip(singleton:SingletonEnforcer)
    {
        if(!_instance)
        {
            _instance = new Parsnip(new SingletonEnforcer());
        }
    }

    /**
     * Kickstarts the creation of a global Context holder
     * @param viewRoot Application root view
     */
    public static function initialize(viewRoot:DisplayObject):void
    {
        if(_mainContext
                && _mainContext.initialized) throw("Main context was already Initialised");

        _applicationDomain = viewRoot.loaderInfo.applicationDomain;

        var setup:ContextBuilderSetup = new ContextBuilderSetup();
        setup.description("Main Context");
        setup.domain(_applicationDomain);
        setup.viewRoot(viewRoot);

        var builder:ContextBuilder = setup.newBuilder();
        _mainContext = builder.build();

        // add to context list
        _contextList = new Vector.<Context>();
        _contextList.push(_mainContext);
    }

    /**
     * Destroys a given Context. If no context given, it will default to destroy all <code>Context</code> objects
     * This includes processing all lifecycle listeners for all objects instantiated and calling
     * their methods marked with [Destroy].
     * A Context may no longer be used after calling this method.
     *
     * @param <code>Context</code> object to destroy. Defaults to destroying all Contexts
     */
    public static function destroyContext(context:Context = null):void
    {
        if(context)
        {
            context.destroy();
        }
        else
        {
            for each(context in _contextList)
            {
                trace("Destroying context: " + ClassInfo.forInstance(context).name);
                context.destroy();
            }
        }
    }

    /**
     * Returns the context for a given instance
     * @param instance
     * @return <code>Context</code>
     */
    public static function getContextOf(instance:Object):Context
    {
        var context:Context = GlobalState.objects.getContext(instance);
        return context;
    }

    /**
     *  Returns a reference to the global Context
     */
    public static function get mainContext():Context
    {
        checkInitialized();

        return _mainContext;
    }

    /**
     * Returns the current list of created <code>Context</code> objects
     */
    public static function get contextList():Vector.<Context>
    {
        return _contextList;
    }

    /**
     * Registers a ViewRoot
     * @param view
     */
    public static function registerViewRoot(view:DisplayObject):void
    {
        mainContext.viewManager.addViewRoot(view);
    }

    /**
     * Registers an object instance dynamically
     * @param instance
     * @param id
     * @param scopeName
     * @param parent
     * @param viewRoot
     * @param description
     */
    public static function registerActor(instance:Object, id:String, parent:Context = null, viewRoot:DisplayObject = null, description:String = null):void
    {
        checkInitialized();

        parent = parent ? parent : getLastUsableContext();
        description = description ? description : "Instance of " + ClassInfo.forInstance(instance).name;

        var setup:ContextBuilderSetup = new ContextBuilderSetup();
        setup.description(description);
        setup.parent(parent);

        var builder:ContextBuilder = setup.newBuilder();
        builder.object(instance, id);
        builder.objectDefinition().forInstance(instance);

        var context:Context = builder.build();

        _contextList.push(context);
    }

    /**
     * Not built yet
     */
    [Deprecated]
    public static function registerCommand():void
    {
        checkInitialized();
        //TODO: not currently needed, will complete later
    }

    /**
     * Registers a Mediator, which is essentially an Actor object
     * @param instance
     * @param id
     * @param scopeName
     * @param parent
     * @param viewRoot
     * @param description
     */
    public static function registerMediator(instance:Object, id:String, parent:Context = null, viewRoot:DisplayObject = null, description:String = null):void
    {
        registerActor(instance, id, parent, viewRoot, description);
    }

    /**
     * Register a view in the framework
     * While Views can listen to messages from the framework, they cannot be injected with previous objects,
     * for this use a mediator instance
     * @param view
     */
    public static function registerView(view:DisplayObject):void
    {
        checkInitialized();

        Configure.view(view).execute();
    }

    /**
     * Register instances from a <code>ActionScriptConfig</code> config file
     * @param config can be a Actionscript configuration <code>Class</code> or a <code>Array</code> of Actionscript configuration Classes
     */
    public static function registerFromASConfig(config:*):void
    {
        checkInitialized();

        var processor:ConfigurationProcessor = arguments.length > 1 ?
                ActionScriptConfig.forClasses(arguments) : ActionScriptConfig.forClass(arguments[0]);

        processFromConfig(processor);
    }

    /**
     * Register instances from a <code>FlexConfig</code> config file
     * @param config can be a configuration <code>Class</code> or an <code>Array</code> of configuration Classes
     */
    public static function registerFromFlexConfig(config:*):void
    {
        checkInitialized();

        var processor:ConfigurationProcessor = arguments.length > 1 ?
                FlexConfig.forClasses(arguments) : FlexConfig.forClass(arguments[0]);

        processFromConfig(processor);
    }

    /**
     * Dispatch a message through the framework
     * @param message Message Object
     * @param selector
     */
    public static function dispatchMessage(message:Object, selector:* = null):void
    {
        checkInitialized();

        mainContext.scopeManager.dispatchMessage(message, selector);
    }

    /**
     * Process based on a <code>ConfigurationProcessor</code> Object
     * @param processor <code>ConfigurationProcessor</code>
     */
    private static function processFromConfig(processor:ConfigurationProcessor):void
    {
        var parent:Context = getLastUsableContext();

        var setup:ContextBuilderSetup = new ContextBuilderSetup();
        setup.parent(parent);

        var builder:ContextBuilder = setup.newBuilder();
        builder.config(processor);

        var context:Context = builder.build();

        _contextList.push(context);
    }

    /**
     * Returns the last usable/valid parent context in the tree structure
     * @return
     */
    private static function getLastUsableContext():Context
    {
        var context:Context;

        var i:int = _contextList.length - 1;
        for(; i >= 0; i--)
        {
            context = _contextList[i];
            if(!context.destroyed) return context;
        }

        throw("No more usable contexts found! Please initialize.");
        return null;
    }

    /**
     * Is initialized
     */
    private static function checkInitialized():void
    {
        if(!_mainContext) throw("Main context not yet initialised! " +
                "Please use '.initialise(viewRoot:DisplayObject)' first.");
    }
}
}

class SingletonEnforcer
{
}
