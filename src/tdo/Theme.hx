package tdo;

typedef Style = {
	var color : om.ansi.Color;
	var background : om.ansi.BackgroundColor;
	var style : Array<Int>;
}

typedef Theme = {
	//user : Style,
	context : Style,
	message : Style,
	meta : Style,
}
