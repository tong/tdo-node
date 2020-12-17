package tdo;

import js.node.readline.Interface;
import js.node.Readline;
import om.ansi.Color;
import om.ansi.BackgroundColor;
import om.ansi.SGR;

using StringTools;
using haxe.io.Path;

class Task {

	public var user : String;
	public var context : String;
	public var message : String;
	
	public var time(default,null) : Date;
	public var running(default,null) = false;
	
	public var timeStartStr(default,null) : String;
	public var elapsedStr(default,null) : String;
	//public var timeEstimated = 0.0;
	
	public var clear = true;

	var timer : Timer;

	public function new( user : String, context : String, message : String ) {
		this.user = user;
		this.context = context;
		this.message = message;
	}

	public function start( interval = 1000 ) {
		running = true;
		time = Date.now();
		timeStartStr =  DateTools.format( time, "%H:%M" );
		update();
		print();
		timer = new Timer( Std.int( interval ) );
		timer.run = () -> {
			update();
			print();
		}
	}

	public function update() {
		var now = Date.now();
		var elapsed = ( (now.getTime() - time.getTime()) / 1000 );
		elapsedStr = '';
		if( elapsed <= 60 ) {
			elapsedStr = Std.int( elapsed )+'s';
		} else if( elapsed <= 3600 ) {
			elapsedStr = Std.int( elapsed/60 )+'m';
		} else {
			var minsTotal = Std.int( elapsed / 60 );
			var hours = Std.int( minsTotal / 60 );
			var mins = minsTotal % 60;
			// var secs = Std.int( elapsed );
			// var now = Date.now();
			// var date = new Date( now.getFullYear(), now.getMonth(), now.getDay(), hours, mins, secs );
			// //var date = Date.fromString( '$hours:$mins' );
			//elapsedStr = DateTools.format( date, '%H:%M:%S' );
			elapsedStr = App.formatTimePart(hours)+":"+App.formatTimePart(mins);
		}
	}

	public function print() {
		if( clear ) om.Term.clear(); //Sys.print('\r');
		var theme = App.THEME;
		var metaCodes = theme.meta.style.concat( [theme.meta.color,theme.meta.background] );
		App.print( '$timeStartStr ', metaCodes );
		if( context != null ) App.print( ' '+context.toUpperCase()+' ', [1,theme.context.color,theme.context.background] );
		if( message != null ) App.print( ' $message ', [theme.message.color,theme.message.background] );
		App.print( ' $elapsedStr ', metaCodes );
	}
}
