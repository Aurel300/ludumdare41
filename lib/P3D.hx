package lib;

import sk.thenet.bmp.*;
import sk.thenet.geom.*;

using sk.thenet.geom.Point;

class P3D {
  public var pers:Float = .5;
  public var zoom:Float = 1;
  public var camX:Float = 0;
  public var camY:Float = 0;
  public var camTX:Float = 0;
  public var camTY:Float = 0;
  public var camAngle:Int = 0;
  public var lightMatrix:Vector<Int>;
  
  public function new() {
    lightMatrix = new Vector<Int>(Trig.densityAngle * Trig.densityAngle * 4 * 4);
    for (tilt in 0...Trig.densityAngle) {
      var tiltVal = Math.sin((tilt / Trig.densityAngle) * Math.PI * 2).square();
      for (angle in 0...Trig.densityAngle) {
        for (y in 0...4) for (x in 0...4) {
        lightMatrix[tilt * 576 + angle * 16 + y * 4 + x]
          = (OrderedDither.BAYER_4[y * 4 + x] * .1
            + tiltVal * 6
            + (1 - tiltVal) * Math.sin((angle / Trig.densityAngle * .75) * Math.PI * 2) * 5).floor().clampI(0, 7);
        }
      }
    }
  }
  
  public function renderBuild(to:Plot, b:P3DBuild):Void {
    b.update();
    for (p in b.parts) render(to, p);
  }
  
  public function render(to:Plot, p:P3DPart):Void {
    for (s in p.sub) render(to, s);
    if (!p.display) return;
    
    var angle = (p.angle + camAngle) % Trig.densityAngle;
    var mxx:Float = Trig.cosAngle[angle] * Trig.cosAngle[p.tilt];
    var mxy:Float = 0;
    var myx:Float = Trig.sinAngle[angle] * Trig.cosAngle[p.tilt];
    var myy:Float = 0;
    var mzx:Float = Trig.sinAngle[p.tilt];
    var mzy:Float = 0;
    if (p.vert) {
      //mxx = Trig.cosAngle[p.angle] * Trig.cosAngle[p.tilt];
      mxy = Trig.cosAngle[angle] * Trig.sinAngle[p.tilt];
      //myx = Trig.sinAngle[p.angle] * Trig.cosAngle[p.tilt];
      myy = Trig.sinAngle[angle] * Trig.sinAngle[p.tilt];
      //mzx = Trig.sinAngle[p.tilt];
      mzy = -Trig.cosAngle[p.tilt];
    } else {
      //mxx = Trig.cosAngle[p.angle] * Trig.cosTilt[p.tilt];
      mxy = -Trig.sinAngle[angle];
      //myx = Trig.sinAngle[p.angle] * Trig.cosTilt[p.tilt];
      myy = Trig.cosAngle[angle];
      //mzx = Trig.sinTilt[p.tilt];
      //mzy = 0;
    }
    
    // initial
    var prex:Float = p.x - camX;
    var prey:Float = p.y - camY;
    var bx:Float = (prex * Trig.cosAngle[camAngle] - prey * Trig.sinAngle[camAngle]) * zoom + Main.W2;
    var by:Float = (prex * Trig.sinAngle[camAngle] + prey * Trig.cosAngle[camAngle]) * zoom + Main.H;
    var bz:Float = p.z * zoom;
    var scw = p.w * zoom;
    var sch = p.h * zoom;
    
    // corners of rect
    var p1 = new Point3DF(bx, by * pers - bz, bz);
    var p2 = new Point3DF(
         bx + mxx * scw
        ,(by + myx * scw) * pers - mzx * scw - bz
        ,bz + mzx * scw
      );
    var p3 = new Point3DF(
         bx + mxy * sch
        ,(by + myy * sch) * pers - mzy * sch - bz
        ,bz + mzy * sch
      );
    var p4 = new Point3DF(
         bx + mxx * scw + mxy * sch
        ,(by + myx * scw + myy * sch) * pers - mzx * scw - mzy * sch - bz
        ,bz + mzx * scw + mzy * sch
      );
    
    // 2D projected rect corners
    var pr1 = p1.project(2);
    var pr2 = p2.project(2);
    var pr3 = p3.project(2);
    var pr4 = p4.project(2);
    
    // floored rect corners
    var fr1 = pr1.cloneI();
    var fr2 = pr2.cloneI();
    var fr3 = pr3.cloneI();
    var fr4 = pr4.cloneI();
    
    // rect bounds
    var minx = fr1.x.minI(fr2.x).minI(fr3.x).minI(fr4.x);
    var miny = fr1.y.minI(fr2.y).minI(fr3.y).minI(fr4.y);
    var maxx = fr1.x.maxI(fr2.x).maxI(fr3.x).maxI(fr4.x);
    var maxy = fr1.y.maxI(fr2.y).maxI(fr3.y).maxI(fr4.y);
    var recw = maxx - minx;
    var rech = maxy - miny;
    
    if (recw != 0 && rech != 0
        && minx < Main.W && maxx >= 0
        && miny < Main.H && maxy >= 0) {
      minx = minx.maxI(0);
      miny = miny.maxI(0);
      maxx = maxx.minI(Main.W - 1);
      maxy = maxy.minI(Main.H - 1);
      
      // side vectors
      var vw = pr2.subtractC(pr1);
      var vh = pr3.subtractC(pr1);
      
      // side vector z coords
      var zw = p2.z - p1.z;
      var zh = p3.z - p1.z;
      
      // side vector normals
      var nw = vw.normalC().scaleM(-1).unitM();
      var nh = vh.normalC().scaleM(-1).unitM();
      
      // proj bounds
      var diag = pr4.subtractC(pr1);
      var boundX = diag.dot(nw);
      var boundY = -diag.dot(nh);
      
      // render loop
      var lval = (p.vert ? 0 : (p.tilt + 9) % Trig.densityAngle) * 576
          + ((angle + p.lightAngle + Trig.densityAngle - camAngle) % Trig.densityAngle) * 16;
      for (y in miny...maxy) for (x in minx...maxx) {
        var d1x = (x - p1.x);
        var d1y = (y - p1.y);
        var projX = (d1x * nw.x + d1y * nw.y) / boundX;
        var projY = -(d1x * nh.x + d1y * nh.y) / boundY;
        if (projX.withinF(0, 1) && projY.withinF(0, 1)) {
          to.plot(
               x, y
              ,(p1.z + projY * zw + projX * zh).floor()
              ,p.data[(projY * p.w).floor().clampI(0, p.w - 1) + (projX * p.h).floor().clampI(0, p.h - 1) * p.w]
              ,lightMatrix[lval + (y % 4) * 4 + (x % 4)]
            );
        }
      }
    }
  }
}
