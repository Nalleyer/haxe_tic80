import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.ds.Option;
import StringTools;

class Build {
	static function main():Void {
		var cartPath = "cart/main.lua";
		var assetsPath = "assets/assets.lua";
		var genPath = "build/gen.lua";
		var outPath = cartPath;
		ensureDir("cart");

		var cart = FileSystem.exists(cartPath) ? File.getContent(cartPath) : "";
		var gen = File.getContent(genPath);

		var extractedData = extractDataPart(cart);
		if (cart.length > 0 && extractedData.length > 0) {
			ensureDir("assets");
			File.saveContent(assetsPath, normalizeTrailingNewline(extractedData));
		}

		var assetsData = FileSystem.exists(assetsPath) ? File.getContent(assetsPath) : "";
		var dataToUse = assetsData.length > 0 ? assetsData : extractedData;

		var out = merge(cart, gen, dataToUse);
		File.saveContent(outPath, out);
	}

	static function merge(cart:String, gen:String, dataPartOverride:String):String {
		var beginMarker = "-- HAXE_BEGIN";
		var endMarker = "-- HAXE_END";

		var dataStart = findFirstDataSectionIndex(cart);
		var codePart = dataStart >= 0 ? cart.substr(0, dataStart) : cart;
		var dataPart = dataPartOverride != null ? dataPartOverride : (dataStart >= 0 ? cart.substr(dataStart) : "");

		var genTrimmed = StringTools.trim(gen);

		var header = "";
		var bi = codePart.indexOf(beginMarker);
		var ei = codePart.indexOf(endMarker);
		if (bi >= 0) {
			header = codePart.substr(0, bi);
		} else {
			header = extractHeader(codePart);
		}
		if (StringTools.trim(header).length == 0) {
			header = defaultHeader();
		}

		var mergedCode = rtrim(header);
		if (mergedCode.length > 0) {
			mergedCode += "\n\n";
		}
		mergedCode += beginMarker + "\n" + shim() + "\n" + genTrimmed + "\n" + endMarker + "\n\n";
		return mergedCode + normalizeTrailingNewline(dataPart);
	}

	static function extractDataPart(cart:String):String {
		if (cart == null || cart.length == 0) {
			return "";
		}
		var dataStart = findFirstDataSectionIndex(cart);
		return dataStart >= 0 ? cart.substr(dataStart) : "";
	}

	static function ensureDir(path:String):Void {
		if (!FileSystem.exists(path)) {
			FileSystem.createDirectory(path);
		}
	}

	static function normalizeTrailingNewline(s:String):String {
		if (s == null || s.length == 0) {
			return "";
		}
		var t = rtrim(s);
		return t + "\n";
	}

	static function defaultHeader():String {
		return "-- title:   haxe_tic80\n" +
			"-- script:  lua\n";
	}

	static function shim():String {
		return "local _hx_pkg = rawget(_G,'package')\n" +
			"local _hx_os = rawget(_G,'os')\n" +
			"if _hx_os == nil then _hx_os = {}; rawset(_G,'os', _hx_os) end\n" +
			"if _hx_os.time == nil then\n" +
			"  _hx_os.time = function()\n" +
			"    local ts = rawget(_G,'tstamp')\n" +
			"    if ts ~= nil then return ts() end\n" +
			"    return 0\n" +
			"  end\n" +
			"end\n" +
			"local _hx_tic = rawget(_G,'tic')\n" +
			"if _hx_tic == nil then _hx_tic = {}; rawset(_G,'tic', _hx_tic) end\n" +
			"if _hx_tic.Tic == nil then _hx_tic.Tic = {} end\n" +
			"local _hx_t = _hx_tic.Tic\n" +
			"if _hx_t.cls == nil then _hx_t.cls = rawget(_G,'cls') or function() end end\n" +
			"if _hx_t.spr == nil then _hx_t.spr = rawget(_G,'spr') or function() end end\n" +
			"if _hx_t.print == nil then _hx_t.print = rawget(_G,'print') or function() end end\n" +
			"if _hx_t.btn == nil then _hx_t.btn = rawget(_G,'btn') or function() return false end end\n" +
			"if _hx_t.btnp == nil then _hx_t.btnp = rawget(_G,'btnp') or function() return false end end\n" +
			"if _hx_t.tstamp == nil then _hx_t.tstamp = rawget(_G,'tstamp') or function() return 0 end end\n" +
			"if _hx_pkg == nil then _hx_pkg = {preload = {}, loaded = {}}; rawset(_G,'package', _hx_pkg) end\n" +
			"if _hx_pkg.preload == nil then _hx_pkg.preload = {} end\n" +
			"if _hx_pkg.loaded == nil then _hx_pkg.loaded = {} end\n" +
			"_hx_pkg.preload['lua-utf8'] = _hx_pkg.preload['lua-utf8'] or function()\n" +
			"  local u = rawget(_G,'utf8')\n" +
			"  if u ~= nil then return u end\n" +
			"  return {\n" +
			"    len = function(s) return #s end,\n" +
			"    sub = function(s,i,j) return string.sub(s,i,j) end,\n" +
			"    byte = function(s,i) return string.byte(s,i) end,\n" +
			"    char = function(c) return string.char(c) end,\n" +
			"    find = function(s,p,init,plain) return string.find(s,p,init,plain) end,\n" +
			"    upper = function(s) return string.upper(s) end,\n" +
			"    lower = function(s) return string.lower(s) end\n" +
			"  }\n" +
			"end\n" +
			"_hx_pkg.preload['rex_pcre2'] = _hx_pkg.preload['rex_pcre2'] or function() return {} end\n";
	}

	static function findFirstDataSectionIndex(s:String):Int {
		var patterns = [
			"\n-- <TILES>",
			"\n-- <SPRITES>",
			"\n-- <MAP>",
			"\n-- <WAVES>",
			"\n-- <SFX>",
			"\n-- <TRACKS>",
			"\n-- <MUSIC>",
			"\n-- <PALETTE>",
			"\n-- <FLAGS>"
		];

		var best = -1;
		for (p in patterns) {
			var idx = s.indexOf(p);
			if (idx >= 0) {
				idx += 1;
				if (best < 0 || idx < best) {
					best = idx;
				}
			}
		}
		return best;
	}

	static function extractHeader(codePart:String):String {
		var lines = codePart.split("\n");
		var out = new Array<String>();
		var i = 0;
		while (i < lines.length) {
			var l = lines[i];
			var trimmed = StringTools.trim(l);
			if (trimmed == "" || StringTools.startsWith(trimmed, "--")) {
				if (trimmed == "-- HAXE_BEGIN") {
					break;
				}
				out.push(l);
				i++;
				continue;
			}
			break;
		}
		return out.join("\n");
	}

	static function rtrim(s:String):String {
		var i = s.length;
		while (i > 0) {
			var c = s.charCodeAt(i - 1);
			if (c == 10 || c == 13 || c == 9 || c == 32) {
				i--;
				continue;
			}
			break;
		}
		return s.substr(0, i);
	}
}
