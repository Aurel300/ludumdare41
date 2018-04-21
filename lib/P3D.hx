package lib;

import haxe.ds.Vector;
import sk.thenet.bmp.*;
import sk.thenet.geom.*;

using sk.thenet.FM;
using sk.thenet.geom.Point;

class P3D {
  public var pers:Float = .5;
  
  public function new() {
    
  }
  
  public function renderBuild(to:Plot, b:P3DBuild, ox:Int, oy:Int, oz:Int):Void {
    for (p in b.parts) render(to, p, ox, oy, oz);
  }
  
  public function render(to:Plot, p:P3DPart, ox:Int, oy:Int, oz:Int):Void {
    var mxx:Float = Trig.cosAngle[p.angle] * Trig.cosAngle[p.tilt];
    var mxy:Float = 0;
    var myx:Float = Trig.sinAngle[p.angle] * Trig.cosAngle[p.tilt];
    var myy:Float = 0;
    var mzx:Float = Trig.sinAngle[p.tilt];
    var mzy:Float = 0;
    if (p.vert) {
      //mxx = Trig.cosAngle[p.angle] * Trig.cosAngle[p.tilt];
      mxy = Trig.cosAngle[p.angle] * Trig.sinAngle[p.tilt];
      //myx = Trig.sinAngle[p.angle] * Trig.cosAngle[p.tilt];
      myy = Trig.sinAngle[p.angle] * Trig.sinAngle[p.tilt];
      //mzx = Trig.sinAngle[p.tilt];
      mzy = -Trig.cosAngle[p.tilt];
    } else {
      //mxx = Trig.cosAngle[p.angle] * Trig.cosTilt[p.tilt];
      mxy = -Trig.sinAngle[p.angle];
      //myx = Trig.sinAngle[p.angle] * Trig.cosTilt[p.tilt];
      myy = Trig.cosAngle[p.angle];
      //mzx = Trig.sinTilt[p.tilt];
      //mzy = 0;
    }
    
    // initial
    var bx:Float = ox + p.x;
    var by:Float = oy + p.y;
    var bz:Float = oz + p.z;
    
    // corners of rect
    var p1 = new Point3DF(bx, by * pers - bz, bz);
    var p2 = new Point3DF(
         bx + mxx * p.w
        ,(by + myx * p.w) * pers - mzx * p.w - bz
        ,bz + mzx * p.w
      );
    var p3 = new Point3DF(
         bx + mxy * p.h
        ,(by + myy * p.h) * pers - mzy * p.h - bz
        ,bz + mzy * p.h
      );
    var p4 = new Point3DF(
         bx + mxx * p.w + mxy * p.h
        ,(by + myx * p.w + myy * p.h) * pers - mzx * p.w - mzy * p.h - bz
        ,bz + mzx * p.w + mzy * p.h
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
      for (y in miny...maxy) for (x in minx...maxx) {
        var d1x = (x - p1.x);
        var d1y = (y - p1.y);
        var projX = (d1x * nw.x + d1y * nw.y) / boundX;
        var projY = -(d1x * nh.x + d1y * nh.y) / boundY;
        if (projX.withinF(0, 1) && projY.withinF(0, 1)) {
          to.plot(
               x, y
              ,(p1.z + projY * zw + projX * zh).floor()
              ,p.data[(projY * p.w).floorZ() + (projX * p.h).floorZ() * p.w]
            );
        }
      }
    }
    
    for (s in p.sub) render(to, s, ox + p.x, oy + p.y, oz + p.z);
  }
}
