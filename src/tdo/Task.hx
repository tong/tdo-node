package tdo;

import haxe.Timer;
import js.Node.console;
import js.Node.process;
import js.node.readline.Interface;
import js.node.Readline;
import om.Term;
import om.ansi.EscapeSequence.CSI;
import om.ansi.Color;
import om.ansi.BackgroundColor;
import om.ansi.SGR;

using StringTools;
using haxe.io.Path;

class Task {

	public static var THEME : tdo.App.Theme = {
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

	public function new( context : String, message : String ) {
		this.context = context;
		this.message = message;
	}

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
			elapsedStr = App.formatTimePart(hours)+":"+App.formatTimePart(mins);
		}
	}

	public function printUpdate() {
		var metaCodes = THEME.meta.style.concat( [THEME.meta.color,THEME.meta.background] );
		App.print( '\r $timeStartStr ', metaCodes );
		if( context != null ) App.print( ' '+context.toUpperCase()+' ', [1,THEME.context.color,THEME.context.background] );
		if( message != null ) App.print( ' $message ', [THEME.message.color,THEME.message.background] );
		App.print( ' $elapsedStr ', metaCodes );
	}
}
