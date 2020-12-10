package tdo;

import om.Term;
import om.ansi.Color;
import om.ansi.BackgroundColor;
import om.ansi.SGR;

using haxe.io.Path;

typedef Style = {
	var color : om.ansi.Color;
	var background : om.ansi.BackgroundColor;
	var style : Array<Int>;
}

typedef Theme = {
	context : Style,
	message : Style,
	meta : Style,
}

class Task {

	public static var THEME : Theme = {
		context : {
			color: Color.black,
			background: BackgroundColor.blue,
			style: [SGR.italic]
		},
		message : {
			color: Color.black,
			background: BackgroundColor.yellow,
			style: []
		},
		meta : {
			color: Color.bright_blue,
			background: BackgroundColor.black,
			style: []
		},
	};

	public var context : String;
	public var message : String;
	//public var timeEstimated = 0.0;

	public var timeStart(default,null) : Date;
	public var running(default,null) = false;

	public var timeStartStr(default,null) : String;
	public var elapsedStr(default,null) : String;

	public function new() {
	}

	public function start( interval = 1.0 ) {
		running = true;
		timeStart = Date.now();
		timeStartStr =  DateTools.format( timeStart, "%H:%M" );
		var metaCodes = THEME.meta.style.concat( [THEME.meta.color,THEME.meta.background] );
		while( running ) {
			update();
			printLine( '\r $timeStartStr ', metaCodes );
			if( context != null ) printLine( ' '+context.toUpperCase()+' ', [1,THEME.context.color,THEME.context.background] );
			if( message != null ) printLine( ' $message ', [THEME.message.color,THEME.message.background] );
			printLine( ' $elapsedStr ', metaCodes );
			Sys.sleep( interval );
		}
	}

	public function update() {
		var now = Date.now();
		var elapsed = (now.getTime() - timeStart.getTime()) / 1000;
		elapsedStr = '';
		if( elapsed <= 60 ) {
			elapsedStr = elapsed+'secs';
		} else if( elapsed <= 3600 ) {
			elapsedStr = Std.int( elapsed/60)+'mins';
		} else {
			var minsTotal = Std.int( elapsed / 60 );
			var hours = Std.int( minsTotal / 60 );
			var mins = minsTotal % 60;
			elapsedStr = formatTimePart(hours)+":"+formatTimePart(mins);
		}
	}

	static function main() {
		var task = new Task();
		var usage : String = null;
		var argHandler = hxargs.Args.generate([
			@doc("Context")["-c"] => (context:String) -> task.context = context,
			@doc("Message")["-m"] => (message:String) -> task.message = message,
			//@doc("Estimated time")["-t"] => (hours:Float) -> timeEstimated = hours,
			["--help","-help","-h"] => () -> exit( 0, usage ),
			//_ => (arg:String) -> exit( 1, 'Unknown argument [$arg]' )
		]);
		var args = Sys.args();
		argHandler.parse( args );
		usage = argHandler.getDoc();
		if( args.length == 0 ) {
			task.context = Path.directory( Sys.getCwd() ).withoutDirectory();
		} else {
			if( task.context == null && task.message == null ) {
				task.context = args[0];
				task.message = args[1];
			}
		}
		Term.clear();
		task.start();
	}

	static function formatTimePart( v : Int ) : String {
		var str = '$v';
		if( v < 10 ) str = '0$str';
		return str;
	}

	static function printLine( str : String, ?ansi_codes : Array<Int> ) {
		if( ansi_codes == null ) Sys.print( str ) else {
			var s = '\x1b[';
			if( ansi_codes != null ) s += ansi_codes.join(';');
			s += 'm';
			s += str;
			s += '\x1b[0m';
			Sys.print(s);
		}
	}

	static function exit( code = 0, ?info : String ) {
		if( info != null ) Sys.println( info );
		Sys.exit( code );
	}
}
