package lib;

import sk.thenet.bmp.manip.*;

class World {
  static var wb:Bitmap;
  static var it:Array<Vector<Bool>>;
  
  public static function init(w:FluentBitmap, i:FluentBitmap):Void {
    wb = w;
    it = [ for (y in 0...4) for (x in 0...4) (i >> new Cut(x * 16, y * 16, 16, 16)).getVector().map(p -> !p.isTransparent) ];
  }
  
  public var parts:Array<P3DPart>;
  
  static var WPAL = Vector.fromArrayCopy(([
       0xFFFFFFFF, 0xFF444444, 0xFF000000
      ,0xFF00FF00, 0xFF00AA00
    ]:Array<Colour>));
  
  public function new() {
    parts = [];
    var perm = [
         [0,  12, 3,  15]
        ,[8,  4,  11, 7 ]
        ,[2,  14, 1,  13]
        ,[10, 6,  9,  5 ]
      ];
    for (h in 0...3) {
      var f = new P3DPart(null);
      f.vert = false;
      f.z = 1 + h * 24;
      f.data = new Vector(wb.width * wb.height);
      f.dw = wb.width;
      f.dh = wb.height;
      f.world = h == 0;
      var ovec = wb.getVector();
      var vi = 0;
      for (y in 0...wb.height) {
        for (x in 0...wb.width) {
          var q = Colour.quantise(ovec[vi], WPAL);
          f.data[vi++] = (switch [h, q] {
              case [0, _]: [
                 1, 23, 7
                ,12, 11
              ][q];
              case [1 | 2, 2]: 7;
              case [1, 1]: 23;
              case _: 0;
            });
        }
      }
      f.w = f.dw * 16;
      f.h = f.dh * 16;
      /*
      var ovec = wb.getVector();
      var lastY = Vector.fromArrayCopy([ for (x in 0...wb.width) true ]);
      var vi = 0;
      for (y in 0...wb.height) {
        var lastX = true;
        for (x in 0...wb.width) {
          var q = Colour.quantise(ovec[vi], WPAL);
          var col = (switch [h, q] {
              case [0, _]: [
                 1, 23, 7
                ,12, 11
              ][q];
              case [1 | 2, 2]: 7;
              case [1, 1]: 23;
              case _: 0;
            });
          var cur = col != 0;
          if (!cur) {
            vi++;
            continue;
          }
          var ngh = 0;
          ngh += (x == wb.width - 1 ? 1 : (!ovec[vi + 1].isTransparent ? 1 : 0));
          ngh += (y == wb.height - 1 ? 2 : (!ovec[vi + wb.width].isTransparent ? 2 : 0));
          ngh += (lastX ? 4 : 0);
          ngh += (lastY[x] ? 8 : 0);
          lastY[x] = cur;
          var pix = it[ngh];
          for (oy in 0...16) for (ox in 0...16) {
            f.data[x * 16 + ox + (y * 16 + oy) * wb.width * 16] = pix[ox + oy * 16] ? col : 0;
          }
          vi++;
        }
      }
      f.w = f.dw;
      f.h = f.dh;
      */
      parts.push(f);
    }
  }
  
  public function update():Void {
    
  }
}
