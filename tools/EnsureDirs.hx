import sys.FileSystem;
#if macro
import haxe.macro.Expr;
#end

class EnsureDirs {
	#if macro
	public static function ensure():Expr {
		ensureDir("build");
		return macro null;
	}

	static function ensureDir(path:String):Void {
		if (!FileSystem.exists(path)) {
			FileSystem.createDirectory(path);
		}
	}
	#end
}
