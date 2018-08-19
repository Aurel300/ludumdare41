package lib;

import sk.thenet.app.AssetManager;

using StringTools;

class Sfx {
  static var am:AssetManager;
  
  public static function isMusic(s:String):Bool {
    return s.startsWith("tune") || s.startsWith("music");
  }
  
  public static function init(am):Void {
    Sfx.am = am;
  }
  
  public static function play(s:String, ?forever:Bool = false) {
    var shouldPlay = isMusic(s) ? SGame.musicOn : SGame.soundOn;
    return am.getSound('snd-$s').play(forever ? Forever : Once, shouldPlay ? 1 : 0);
  }
}
