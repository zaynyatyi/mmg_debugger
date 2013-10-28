package mmg;

import cpp.vm.Deque;
import cpp.vm.Debugger;
import cpp.vm.Thread;
import haxe.CallStack;

/**
 * ...
 * @author gordev
 */
class Base
{
	var threadStopped:Bool;
	var stillDebugging:Bool;
	var inputThread:Thread;
	var debugQueue:Deque<Dynamic>;
	var files:Array<String>;
	var frame:Int;
	var stack:Array<StackItem>;
	var vars:Array<String>;
	var dbg:Dynamic;
	var arrayLimit:Int;
	
	public function new(startStopped:Bool)
	{
		frame = -1;
		stillDebugging = init();
		arrayLimit = 100;
		dbg = {};
		if (stillDebugging)
		{
			files = Debugger.getFiles();
			threadStopped = false;
			Debugger.setThread();
			Debugger.setHandler(onDebug);
			debugQueue= new Deque<Dynamic>();
			inputThread = Thread.create(inputLoop);
			if (startStopped)
				Debugger.breakBad();
		}
	}
	
	// init just for override
	function init() : Bool
	{
		return false;
	}
	
	function onDebug()
	{
		threadStopped = true;
		onStopped();
		while(threadStopped && stillDebugging)
		{
			var job = debugQueue.pop(true);
			job();
		}
	}

	function onStopped() { }
	
	function onCloseInput() { }
	
	function inputLoop()
	{
		while (stillDebugging)
		{
			
		}
		onCloseInput();
	}
}