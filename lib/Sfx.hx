package lib;

import sk.thenet.app.AssetManager;

class Sfx {
  static var am:AssetManager;
  
  public static function init(am):Void {
    Sfx.am = am;
  }
  
  public static function play(s:String):Void {
    am.getSound('snd-$s').play();
  }
}
