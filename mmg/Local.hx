package mmg;

import haxe.CallStack;
import cpp.vm.Debugger;
import haxe.io.Input;
import mmg.Base;

/**
 * ...
 * @author gordev
 */
class Local extends mmg.Base
{
	var input:Input;

	public function new(startStopped:Bool) 
	{
		super(startStopped);
	}
	
	override function init():Bool
	{
		input = Sys.stdin();
		return true;
	}
	
	override function onStopped()
	{
		sendOutput("stopped.");
	}
	
	override function onRunning()
	{
		sendOutput("running.");
	}
	
	override function onCloseInput()
	{
		if (input!=null)
			input.close();
	}
	
	override function onResult(inResult:String)
	{
		sendOutput(inResult);
	}
	
	override function getNextCommand() : String
	{
		Sys.print("debug>");
		return input.readLine();
	}
	
	function sendOutput(inString:String)
	{
		Sys.println(inString);
	}
}