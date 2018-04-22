package lib;

import sk.thenet.app.AssetManager;
import sk.thenet.bmp.manip.*;
import sk.thenet.plat.Platform;
import font.FontNS;

class Text {
  public static var fonts:Array<Font>;
  
  public static function init(am:AssetManager):Void {
    fonts = [
         FontNS.initAuto(am, Pal.reg[7], Pal.reg[2], Pal.reg[1])
        ,FontNS.initAuto(am, Pal.reg[4], Pal.reg[5], Pal.reg[6])
      ];
  }
  
  public static function banner(to:Bitmap, t:String):Bitmap {
    var tmp = Platform.createBitmap(to.width, to.height, 0);
    fonts[1].render(tmp, 0, 0, t, fonts);
    tmp = tmp.fluent >> new Scale(3, 3);
    for (y in 0...to.height) {
      to.blitAlphaRect(tmp, (to.height - 1 - y) >> 1, y, 0, y, to.width, 1);
    }
    return to;
  }
  
  public static function render(to:Bitmap, x:Int, y:Int, t:String):Void {
    fonts[0].render(to, x, y, t, fonts);
  }
}
