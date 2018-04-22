package lib;

import haxe.ds.Vector;
import sk.thenet.bmp.Bitmap;
import sk.thenet.bmp.manip.*;

class P3DBuild {
  public static function autoBox(b:Bitmap, x:Int, y:Int, w:Int, h:Int, d:Int):P3DSkeleton {
    var f = b.fluent;
    return Box(f >> new Cut(x, y + d, w, h), [
         f >> new Cut(x, y, w, d)
        ,f >> new Cut(x + w, y, h, d)
        ,f >> new Cut(x + w + h, y, w, d)
        ,f >> new Cut(x + w + h + w, y, h, d)
      ]);
  }
  
  public static function build(r:P3DSkeleton, s:Array<P3DSkeleton>, ent:Entity):P3DBuild {
    var ret = new P3DBuild();
    var parts:Array<P3DPart> = null;
    var constr:Array<Void->Void> = [];
    function subBuild(root:P3DPart, s:P3DSkeleton):Array<P3DPart> {
      return (switch (s) {
        case Wall(b, oa):
        var p = new P3DPart(ent);
        p.bitmap = b;
        constr.push(() -> {
            p.angle = (root.angle + oa) % Trig.densityAngle;
            p.lightAngle = 18;
            p.tilt = root.tilt;
            p.x = root.x;
            p.y = root.y;
            p.z = root.z + b.height;
          });
        [p];
        case Floor(b, oa, ot):
        var p = new P3DPart(ent);
        p.bitmap = b;
        p.vert = false;
        constr.push(() -> {
            p.angle = (root.angle + oa) % Trig.densityAngle;
            p.tilt = (root.tilt + ot) % Trig.densityAngle;
            p.x = root.x;
            p.y = root.y;
            p.z = root.z;
          });
        [p];
        case Offset(sub, ox, oy, oz, oa):
        var p = new P3DPart(ent);
        p.display = false;
        var r = [p];
        for (ss in sub) r = r.concat(subBuild(p, ss));
        constr.push(() -> {
            p.angle = (root.angle + oa) % Trig.densityAngle;
            p.tilt = root.tilt;
            p.x = root.x + (Trig.cosAngle[root.angle] * ox - Trig.sinAngle[root.angle] * oy).floor();
            p.y = root.y + (Trig.sinAngle[root.angle] * ox + Trig.cosAngle[root.angle] * oy).floor();
            p.z = root.z + oz;
          });
        r;
        case Anchor(id):
        var p = new P3DPart(ent);
        p.display = false;
        [p];
        case Box(top, sides):
        var topp = {
          var p = new P3DPart(ent);
          p.bitmap = top;
          p.vert = false;
          constr.push(() -> {
              p.angle = root.angle;
              p.tilt = root.tilt;
              p.x = root.x;
              p.y = root.y;
              p.z = root.z + sides[0].height - 1;
            });
          p;
        };
        [topp].concat([ for (i in 0...sides.length.minI(4)) {
          if (sides[i] == null) continue;
          var p = new P3DPart(ent);
          switch (i) {
            case 0:
            p.bitmap = sides[i];
            constr.push(() -> {
                p.angle = root.angle;
                p.tilt = root.tilt;
                p.x = root.x + (Trig.cosAngle[(root.angle + 9) % Trig.densityAngle] * (top.height - 1)).floor();
                p.y = root.y + (Trig.sinAngle[(root.angle + 9) % Trig.densityAngle] * (top.height - 1)).floor();
                p.z = root.z + sides[i].height;
              });
            case 1:
            p.bitmap = sides[i].fluent >> new Turn(3);
            p.vert = false;
            p.lightAngle = 27;
            constr.push(() -> {
                p.angle = root.angle;
                p.tilt = (27 + root.tilt) % Trig.densityAngle;
                p.x = root.x + (Trig.cosAngle[root.angle] * (top.width - 1)).floor();
                p.y = root.y + (Trig.sinAngle[root.angle] * (top.width - 1)).floor();
                p.z = (Trig.sinAngle[root.tilt] * (top.width - 1)).floor() + root.z + sides[i].height;
              });
            case 2:
            p.bitmap = sides[i].fluent >> new Flip();
            p.lightAngle = 18;
            constr.push(() -> {
                p.angle = root.angle;
                p.tilt = root.tilt;
                p.x = root.x + (Trig.cosAngle[(root.angle + 9) % Trig.densityAngle] * 1).floor();
                p.y = root.y + (Trig.sinAngle[(root.angle + 9) % Trig.densityAngle] * 1).floor();
                p.z = root.z + sides[i].height;
              });
            case 3:
            p.bitmap = sides[i].fluent >> new Turn(3) >> new Flip(true);
            p.vert = false;
            p.lightAngle = 9;
            constr.push(() -> {
                p.angle = root.angle % Trig.densityAngle;
                p.tilt = (27 + root.tilt) % Trig.densityAngle;
                p.x = root.x + (Trig.cosAngle[root.angle] * 1).floor();
                p.y = root.y + (Trig.sinAngle[root.angle] * 1).floor();
                p.z = root.z + sides[i].height;
              });
            case _:
          }
          p;
        } ]);
        case _: null;
      });
    }
    parts = subBuild(null, r);
    ret.root = parts[0];
    constr.push(() -> {
        ret.root.angle = ret.angle;
        ret.root.tilt = ret.tilt;
        ret.root.x = ret.x;
        ret.root.y = ret.y;
        ret.root.z = ret.z;
      });
    for (sub in s) parts = parts.concat(subBuild(ret.root, sub));
    ret.parts = Vector.fromArrayCopy(parts);
    ret.constr = Vector.fromArrayCopy(constr);
    return ret;
  }
  
  public var parts:Vector<P3DPart>;
  public var root:P3DPart;
  public var angle:Int = 0;
  public var tilt:Int = 0;
  public var x:Int = 0;
  public var y:Int = 0;
  public var z:Int = 0;
  
  var constr:Vector<Void->Void>;
  
  public function update():Void {
    for (c in constr) c();
  }
  
  public function new() {}
}

enum P3DSkeleton {
  None;
  Anchor(id:String);
  Box(top:Bitmap, sides:Array<Bitmap>);
  Offset(s:Array<P3DSkeleton>, ox:Int, oy:Int, oz:Int, oa:Int);
  Wall(b:Bitmap, a:Int);
  Floor(b:Bitmap, a:Int, t:Int);
}
