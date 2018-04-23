package lib;

class Pal {
  public static var reg:Vector<Colour>;
  public static var light:Vector<Colour>;
  
  public static function init(b:Bitmap):Void {
    reg = new Vector<Colour>(28);
    light = new Vector<Colour>(32 * 8);
    for (i in 0...reg.length) {
      reg[i] = b.get(i * 4, 3);
    }
    for (x in 0...reg.length) {
      for (y in 0...8) {
        light[y * 32 + x] = b.get(x * 4, y);
      }
    }
  }
}
