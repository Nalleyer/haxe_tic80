package tic;

extern class Tic {
	@:native("cls")
	static function cls(?color:Int):Void;

	@:native("print")
	static function print(text:String, ?x:Int, ?y:Int, ?color:Int, ?fixed:Bool, ?scale:Int, ?smallfont:Bool):Int;

	@:native("spr")
	static function spr(id:Int, x:Int, y:Int, ?colorkey:Int, ?scale:Int, ?flip:Int, ?rotate:Int, ?w:Int, ?h:Int):Void;

	@:native("pix")
	static function pix(x:Int, y:Int, ?color:Int):Int;

	@:native("line")
	static function line(x0:Int, y0:Int, x1:Int, y1:Int, color:Int):Void;

	@:native("rect")
	static function rect(x:Int, y:Int, w:Int, h:Int, color:Int):Void;

	@:native("rectb")
	static function rectb(x:Int, y:Int, w:Int, h:Int, color:Int):Void;

	@:native("circ")
	static function circ(x:Int, y:Int, r:Int, color:Int):Void;

	@:native("circb")
	static function circb(x:Int, y:Int, r:Int, color:Int):Void;

	@:native("tri")
	static function tri(x1:Int, y1:Int, x2:Int, y2:Int, x3:Int, y3:Int, color:Int):Void;

	@:native("trib")
	static function trib(x1:Int, y1:Int, x2:Int, y2:Int, x3:Int, y3:Int, color:Int):Void;

	@:native("map")
	static function map(?x:Int, ?y:Int, ?w:Int, ?h:Int, ?sx:Int, ?sy:Int, ?colorkey:Int, ?scale:Int, ?remap:Dynamic):Void;

	@:native("mget")
	static function mget(x:Int, y:Int):Int;

	@:native("mset")
	static function mset(x:Int, y:Int, id:Int):Void;

	@:native("btn")
	static function btn(id:Int):Bool;

	@:native("btnp")
	static function btnp(id:Int, ?hold:Int, ?period:Int):Bool;

	@:native("key")
	static function key(code:Int):Bool;

	@:native("keyp")
	static function keyp(code:Int, ?hold:Int, ?period:Int):Bool;

	@:native("mouse")
	static function mouse():Dynamic;

	@:native("time")
	static function time():Int;

	@:native("tstamp")
	static function tstamp():Int;

	@:native("music")
	static function music(track:Int, ?frame:Int, ?row:Int, ?loop:Bool, ?sustain:Bool, ?tempo:Int, ?speed:Int):Void;

	@:native("sfx")
	static function sfx(id:Int, ?note:Int, ?duration:Int, ?channel:Int, ?volume:Int, ?speed:Int):Void;

	@:native("memcpy")
	static function memcpy(dest:Int, src:Int, size:Int):Void;

	@:native("memset")
	static function memset(dest:Int, value:Int, size:Int):Void;

	@:native("peek")
	static function peek(addr:Int, ?bits:Int):Int;

	@:native("poke")
	static function poke(addr:Int, value:Int, ?bits:Int):Void;
}
