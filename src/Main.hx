import tic.Tic.*;

class Main {
	static inline var cell:Int = 8;
	static inline var cols:Int = 30;
	static inline var rows:Int = 17;
	static inline var stepFrames:Int = 6;

	static var frame:Int = 0;
	static var score:Int = 0;

	static var snakeX:Array<Int> = [];
	static var snakeY:Array<Int> = [];

	static var dirX:Int = 1;
	static var dirY:Int = 0;
	static var nextX:Int = 1;
	static var nextY:Int = 0;

	static var foodX:Int = 10;
	static var foodY:Int = 8;

	static function main() {
		untyped __lua__("_G.BOOT = {0}", BOOT);
		untyped __lua__("_G.TIC = {0}", TIC);
	}

	static function BOOT():Void {
		untyped __lua__("math.randomseed({0})", tstamp());
		reset();
	}

	static function TIC():Void {
		readInput();

		frame++;
		if (frame % stepFrames == 0) {
			step();
		}

		draw();
	}

	static function reset():Void {
		score = 0;
		frame = 0;

		snakeX = [15, 14, 13];
		snakeY = [8, 8, 8];

		dirX = 1;
		dirY = 0;
		nextX = 1;
		nextY = 0;

		spawnFood();
	}

	static function readInput():Void {
		if (btnp(0) && dirY != 1) {
			nextX = 0;
			nextY = -1;
		} else if (btnp(1) && dirY != -1) {
			nextX = 0;
			nextY = 1;
		} else if (btnp(2) && dirX != 1) {
			nextX = -1;
			nextY = 0;
		} else if (btnp(3) && dirX != -1) {
			nextX = 1;
			nextY = 0;
		}
	}

	static function step():Void {
		dirX = nextX;
		dirY = nextY;

		var hx = snakeX[0] + dirX;
		var hy = snakeY[0] + dirY;

		if (hx < 0 || hx >= cols || hy < 0 || hy >= rows) {
			reset();
			return;
		}
		if (contains(hx, hy)) {
			reset();
			return;
		}

		snakeX.unshift(hx);
		snakeY.unshift(hy);

		if (hx == foodX && hy == foodY) {
			score++;
			spawnFood();
		} else {
			snakeX.pop();
			snakeY.pop();
		}
	}

	static function spawnFood():Void {
		var tries = 0;
		while (tries < 1024) {
			var fx = Std.random(cols);
			var fy = Std.random(rows);
			if (!contains(fx, fy)) {
				foodX = fx;
				foodY = fy;
				return;
			}
			tries++;
		}
		foodX = 0;
		foodY = 0;
	}

	static function contains(x:Int, y:Int):Bool {
		for (i in 0...snakeX.length) {
			if (snakeX[i] == x && snakeY[i] == y) {
				return true;
			}
		}
		return false;
	}

	static function draw():Void {
		cls(0);
		for (i in 0...snakeX.length) {
			spr(33, snakeX[i] * cell, snakeY[i] * cell);
		}
		spr(34, foodX * cell, foodY * cell);
		print("SCORE: " + score, 2, 2, 12);
	}
}
