package lib;

import sk.thenet.bmp.manip.*;

class World {
  static var wb:Bitmap;
  static var it:Array<Vector<Bool>>;
  public static var unit:FluentBitmap;
  
  public static function init(w:FluentBitmap, i:FluentBitmap, u:FluentBitmap):Void {
    wb = w;
    it = [ for (y in 0...4) for (x in 0...4) (i >> new Cut(x * 16, y * 16, 16, 16)).getVector().map(p -> !p.isTransparent) ];
    unit = u;
  }
  
  public var parts:Array<P3DPart>;
  var markers:Array<WorldMarker>;
  
  static var WLVL = Vector.fromArrayCopy(([ for (i in 0...10) 0xFFFFFF00 | (i * 0x10) ]:Array<Colour>));
  static var WPAL = Vector.fromArrayCopy(([
       0xFFFFFFFF, 0xFF444444, 0xFF000000
      ,0xFF00FF00, 0xFF00AA00
    ]:Array<Colour>));
  
  public function new() {
    parts = [];
    markers = [];
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
          var q = 0;
          if (ovec[vi].ri == 0xFF && ovec[vi].gi == 0xFF && ovec[vi].bi < 0x80) {
            var levelNum = ovec[vi].bi >> 4;
            var m = new WorldMarker(levelNum, x * 16, y * 16);
            markers.push(m);
            m.addParts(parts);
          } else q = Colour.quantise(ovec[vi], WPAL);
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
    GUI.hide("levelStart");
    for (m in markers) {
      m.parts[1].angle = -Main.g.p3d.camAngle;
      for (p in m.parts) {
        p.display = (Main.g.mode == Roam);
        if (p.display) {
          var dist = (m.x - Main.g.rv.x).absI() + (m.y - Main.g.rv.y).absI();
          if (dist < 100) {
            GUI.showLevelStart(m.id, m.x, m.y);
          }
        }
      }
    }
  }
}

class WorldMarker {
  public var parts:Array<P3DPart> = [];
  var mouse = false;
  public var id:String;
  
  public var x:Int;
  public var y:Int;
  
  public function new(n:Int, x:Int, y:Int) {
    this.x = x;
    this.y = y;
    id = ["cactus", "3scorp", "umlaut", "quick", "6scorp", "islands", "toxic"][n];
    var f = new P3DPart(null);
    f.vert = false;
    f.x = x - 20;
    f.y = y - 20;
    f.z = 4;
    f.bitmap = World.unit >> new Cut(208, 115, 40, 40);
    parts.push(f);
    f = new P3DPart(null);
    f.x = x - 4;
    f.y = y;
    f.z = 4 + 72;
    f.bitmap = World.unit >> new Cut(208, 43, 27, 72);
    parts.push(f);
  }
  
  public function addParts(to:Array<P3DPart>):Void {
    for (p in parts) to.push(p);
  }
}
