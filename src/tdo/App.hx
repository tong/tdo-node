package tdo;

import js.node.Os;
import js.node.readline.Interface;
import js.node.Readline;
import om.Term;
import om.ansi.EscapeSequence.CSI;
import om.ansi.Color;
import om.ansi.BackgroundColor;
import om.ansi.SGR;

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

class App {

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

	static var task : Task;
	static var log : Log;
	static var readline : Interface;

	static function main() {

		var logFile = Log.DEFAULT_PATH;

		Log.init( logFile ).then( log -> {
			
			App.log = log;

			var args = Sys.args();
			switch args[0] {
			case 'history':
				for( entry in log.data ) {
					Sys.println( entry.timeStart+' '+entry.context+' '+entry.message );
				}
				exit();
			}

			var _context : String = null;
			var _message : String = null;
			var usage : String = null;
			var argHandler = hxargs.Args.generate([
				@doc("Context")["-c"] => (context:String) -> _context = context,
				@doc("Message")["-m"] => (message:String) -> _message = message,
				//@doc("Estimated time")["-t"] => (hours:Float) -> timeEstimated = hours,
				["--help","-help","-h"] => () -> exit( 0, usage ),
				//_ => (arg:String) -> exit( 1, 'Unknown argument [$arg]' )
			]);
			
			argHandler.parse( args );
			usage = argHandler.getDoc();
			if( args.length == 0 ) {
				_context = Path.directory( Sys.getCwd() ).withoutDirectory();
			} else {
				if( _context == null && _message == null ) {
					_context = args[0];
					_message = args[1];
				}
			}

			task = new Task( _context, _message );

			function exitHandler(code:Int,options:Dynamic) {
				if (code != null ) console.log(code);
				if (options != null ) {
					if (options.save) {
						console.log('save');
						log.add( cast task );
						log.save();
					}
					if (options.exit) process.exit();
				}
			}
			process.on( 'SIGINT', exitHandler.bind( Os.constants.signals.SIGINT, { exit: true, save: true } ) );
			
			/* readline = Readline.createInterface({
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
			}); */

			Term.clear();
			task.start();
		});
	}

	public static function formatTimePart( v : Int ) : String {
		var str = '$v';
		if( v < 10 ) str = '0$str';
		return str;
	}

	public static function print( str : String, ?ansi_codes : Array<Int> ) {
		if( ansi_codes == null ) Sys.print( str ) else {
			var s : String = CSI;
			if( ansi_codes != null ) s += ansi_codes.join(';');
			s += 'm';
			s += str;
			s += CSI;
			Sys.print(s);
		}
	}

	public static function exit( code = 0, ?info : String ) {
		if( info != null ) Sys.println( info );
		process.exit( code );
	}
}
