package mmg;

/**
 * ...
 * @author gordev
 */
class Local extends mmg.Base
{
	var input:haxe.io.Input;

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
	
	override function onCloseInput()
	{
		if (input!=null)
			input.close();
	}
	
	function sendOutput(inString:String)
	{
		Sys.println(inString);
	}
}