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
	
	function onRunning() { }
	
	function onCloseInput() { }
	
	function onResult(inResult:String) { }
	
	function getNextCommand() : String { return "bye"; }
	
	function getStack()
	{
		stack = haxe.CallStack.callStack();
		setFrame(1);
	}
	
	function checkStack()
	{
		if (threadStopped && stack==null)
		{
			debugQueue.add( getStack );
			waitDebugger(false);
		}
	}

	function setFrame(inFrame:Int)
	{
		if (stack!=null && inFrame>0 && inFrame <= stack.length )
		{
			frame = inFrame;
			vars = Debugger.getStackVars(frame);
		}
	}
	
	function run()
	{
		stack = null;
		vars = null;
		debugQueue.add( function() { threadStopped = false; inputThread.sendMessage("running"); }  );
		var result = Thread.readMessage(true);
		onRunning();
		onResult("ok");
	}
	
	function waitDebugger(inSendResult:Bool=true)
	{
		debugQueue.add( function() inputThread.sendMessage("ok")  );
		var result = Thread.readMessage(true);
		if (inSendResult)
		{
			if (result!="ok")
				onResult("Debugger out of sync");
			else
				onResult("ok");
		}
	}
	
	function inputLoop()
	{
		while (stillDebugging)
		{
			checkStack();
			var command = getNextCommand();
			var words = command.split(" ");
			switch(words[0])
			{
				case "":
				   onResult("");
				   // Do nothing

				case "bye":
				   stillDebugging = false;
				   debugQueue.add( function() { trace("bye"); }  );
				   onResult("bye");

				case "exit","quit":
				   onResult("ok");
				   Debugger.exit();
				
				case "cont","c":
					if (!threadStopped)
						onResult("Already running.");
					else
						run();
				_:
					onResult("Unknown command:" + command);
			}
		}
		onCloseInput();
	}
}