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
  
  public static function render(to:Bitmap, x:Int, y:Int, t:String) {
    return fonts[0].render(to, x, y, t, fonts);
  }
  
  static var tmp = Platform.createBitmap(1, 1, 0);
  
  public static function justify(txt:String, width:Int):Bitmap {
    var words = txt.split(" ").map(w -> {
         txt: w
        ,width: fonts[0].render(tmp, 0, 0, w, fonts).x
      });
    var lines = [];
    var lineWidths = [];
    var lineWords = [];
    var lineWidth = 0;
    var minSpace = width * 0.04;
    var maxSpacing = 4.0;
    while (words.length > 0) {
      var curWord = words.shift();
      if (width - (curWord.width + lineWidth) >= minSpace) {
        lineWords.push(curWord);
        lineWidth += curWord.width;
      } else {
        lines.push(lineWords);
        lineWidths.push(lineWidth);
        lineWords = [curWord];
        lineWidth = curWord.width;
      }
    }
    if (lineWords.length > 0) {
      lines.push(lineWords);
      lineWidths.push(lineWidth);
    }
    var res = Platform.createBitmap(width, lines.length.maxI(1) * 16, 0);
    var cy = 0;
    for (l in lines) {
      var spacing = ((width - lineWidths.shift()) / (l.length - 1)).minF(maxSpacing);
      var cx = 0.0;
      for (w in l) {
        fonts[0].render(
            res, cx.floor() + 1, cy, w.txt, fonts
          );
        cx += w.width + spacing;
      }
      cy += 16;
    }
    return res;
  }
}
