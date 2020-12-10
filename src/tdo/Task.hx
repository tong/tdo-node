package tdo;

import haxe.Timer;
import js.Node.console;
import js.Node.process;
import js.node.readline.Interface;
import js.node.Readline;
import om.Term;
import om.ansi.Color;
import om.ansi.BackgroundColor;
import om.ansi.SGR;

using StringTools;
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

	static var readline : Interface;

	public var context : String;
	public var message : String;
	//public var timeEstimated = 0.0;

	public var timeStart(default,null) : Date;
	public var running(default,null) = false;

	public var timeStartStr(default,null) : String;
	public var elapsedStr(default,null) : String;

	var timer : Timer;

	public function new() {}

	public function start( interval = 1000 ) {
		running = true;
		timeStart = Date.now();
		timeStartStr =  DateTools.format( timeStart, "%H:%M" );
		update();
		printUpdate();
		timer = new Timer( Std.int( interval ) );
		timer.run = () -> {
			update();
			printUpdate();
		}
	}

	public function update() {
		var now = Date.now();
		var elapsed = Std.int( (now.getTime() - timeStart.getTime()) / 1000 );
		elapsedStr = '';
		if( elapsed <= 60 ) {
			elapsedStr = elapsed+'s';
		} else if( elapsed <= 3600 ) {
			elapsedStr = Std.int( elapsed/60)+'mins';
		} else {
			var minsTotal = Std.int( elapsed / 60 );
			var hours = Std.int( minsTotal / 60 );
			var mins = minsTotal % 60;
			elapsedStr = formatTimePart(hours)+":"+formatTimePart(mins);
		}
	}

	public function printUpdate() {
		var metaCodes = THEME.meta.style.concat( [THEME.meta.color,THEME.meta.background] );
		print( '\r $timeStartStr ', metaCodes );
		if( context != null ) print( ' '+context.toUpperCase()+' ', [1,THEME.context.color,THEME.context.background] );
		if( message != null ) print( ' $message ', [THEME.message.color,THEME.message.background] );
		print( ' $elapsedStr ', metaCodes );
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
	
		readline = Readline.createInterface({
			input: process.stdin,
			  output: process.stdout,
			  prompt: ' > '
		});
		readline.on('line', (line:String) -> {
			line = line.trim();
			console.log( 'Received: ${line}' );
			switch line {
			case 'pause':
				trace("TODO pause task");
			case _:
				trace('Unknown command');
			}
			readline.prompt();
		}).on( 'close', () -> {
			console.log('Well done!');
			process.exit(0);
		});

		Term.clear();
		task.start();
	}

	static function formatTimePart( v : Int ) : String {
		var str = '$v';
		if( v < 10 ) str = '0$str';
		return str;
	}

	static function print( str : String, ?ansi_codes : Array<Int> ) {
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
