package lib;

import sk.thenet.bmp.manip.*;

class GUI {
  public static var as:Map<String, Bitmap>;
  public static var dropArrow:Array<Bitmap>;
  
  public static function init(b:FluentBitmap):Void {
    as = [
         "timer1" => b >> new Cut(0, 8, 32, 40)
        ,"timer2" => b >> new Cut(32, 8, 32, 40)
        ,"trash" => b >> new Cut(0, 48, 48, 48)
        ,"deploy" => b >> new Cut(48 * 2, 48, 48, 48)
        ,"drop" => b >> new Cut(0, 96, 64, 64)
        ,"dropArrow" => b >> new Cut(64, 96, 64, 64)
      ];
    dropArrow = [ for (i in 0...Trig.densityAngle)
      as["dropArrow"].fluent
        >> new Rotate((i / Trig.densityAngle) * Math.PI * 2)
        >> new Grow(-32, -32, -32, -32) ];
  }
}
