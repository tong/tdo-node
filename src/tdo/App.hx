package tdo;

import js.node.readline.Interface;
import js.node.Readline;
import om.Term;
import om.ansi.EscapeSequence.CSI;
import om.ansi.Color;
import om.ansi.BackgroundColor;
import om.ansi.SGR;

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
	static var noColors = false;
	//static var noClear = false;

	static function main() {

		var userName : String;
		var logPath : String = null;
		var _context : String = null;
		var _message : String = null;
		var args = Sys.args();
		var usage : String = null;
		var argHandler = hxargs.Args.generate([
			@doc("Context")["-c"] => (context:String) -> _context = context,
			@doc("Description")["-d"] => (message:String) -> _message = message,
			@doc("Set user")["-u"] => (name:String) -> userName = name,
			//@doc("Estimated time")["-t"] => (hours:Float) -> timeEstimated = hours,
			@doc("Path to log file")["--log-path"] => (path:String) -> logPath = path,
			@doc("Disable colored output")["--no-colors"] => () -> noColors = true,
			//@doc("Do not clear line")["--no-clear"] => () -> noClear = true,
			["--help","-help","-h"] => () -> exit( 0, usage ),
			_ => (arg:String) -> {
				//cmd = arg;
				//return;
				//exit( 1, 'Unknown argument [$arg]' )
			}
		]);
		usage = 'tdo <cmd> [params]\n'+argHandler.getDoc();
		argHandler.parse( args );

		if( args.length == 0 ) {
			exit( usage );
		}
		
		if( userName == null ) userName = Os.userInfo().username;
		if( logPath == null ) logPath = Log.DEFAULT_PATH;

		function printLogEntry( entry : tdo.Log.Entry ) {
			if( entry.user != null ) Sys.print( entry.user+' ' );
			if( entry.time != null ) Sys.print( entry.time+' ' );
			if( entry.context != null ) Sys.print( entry.context );
			if( entry.message != null ) Sys.print( ': '+entry.message );
			Sys.print( '\n' );
		}

		Log.init( logPath ).then( log -> {
			var task : Task = null;
			var cmd = args[0];
			switch cmd {
			case 'start':
				if( _context == null && _message == null ) {
					_context = args[1];
					_message = args[2];
				}
				if( _context == null ) {
					_context = Sys.getCwd().withoutDirectory();
				}
				task = new Task( userName, _context, _message );
				task.clear = true;
				task.start();
			case 'now':
				var entry = log.data[log.data.length-1];
				printTask( entry.user, null, entry.context, entry.message );
				exit();
			case 'list':
				for( entry in log.data ) {
					printLogEntry( entry );
				}
				exit();
			case _:
				//exit( 1, 'Unknown argument [$cmd]' );
			}

			function exitHandler(code:Int,options:Dynamic) {
				if (code != null ) console.log(code);
				if (options != null ) {
					if (options.save && task != null ) {
						log.add( cast task );
						log.save();
					}
					if (options.exit) process.exit();
				}
			}
			process.on( 'SIGINT', exitHandler.bind( Os.constants.signals.SIGINT, { exit: true, save: true } ) );

		}).catchError( function(e) {
			//Sys.println( 'log file not found: '+e.path  );
			trace(e);
			exit( e.errno );
		});

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
	}

	static function printTask( user : String, time : Date, context : String, message : String, ?elapsed : String ) {
		var theme = App.THEME;
		var metaCodes = theme.meta.style.concat( [theme.meta.color,theme.meta.background] );
		if( time != null ) App.print( '$time ', metaCodes );
		if( context != null ) App.print( context.toUpperCase()+' ', [1,theme.context.color,theme.context.background] );
		if( message != null ) App.print( ' $message ', [theme.message.color,theme.message.background] );
		if( elapsed != null ) App.print( ' $elapsed ', metaCodes );
	}

	public static function formatTimePart( v : Int ) : String {
		var str = '$v';
		if( v < 10 ) str = '0$str';
		return str;
	}

	public static function print( str : String, ?ansi_codes : Array<Int> ) {
		if( noColors || ansi_codes == null ) Sys.print( str ) else {
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
