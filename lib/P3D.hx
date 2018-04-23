package lib;

import sk.thenet.bmp.*;
import sk.thenet.geom.*;

using sk.thenet.geom.Point;

class P3D {
  public static var lightMatrix:Vector<Int> = {
      var ret = new Vector<Int>(Trig.densityAngle * Trig.densityAngle * 4 * 4);
      for (tilt in 0...Trig.densityAngle) {
        var tiltVal = Math.sin((tilt / Trig.densityAngle) * Math.PI * 2).square();
        for (angle in 0...Trig.densityAngle) {
          for (y in 0...4) for (x in 0...4) {
          ret[tilt * 576 + angle * 16 + y * 4 + x]
            = (OrderedDither.BAYER_4[y * 4 + x] * .1
              + tiltVal * 6
              + (1 - tiltVal) * Math.sin((angle / Trig.densityAngle * .75) * Math.PI * 2) * 5).floor().clampI(0, 7);
          }
        }
      }
      ret;
    };
  
  public var pers:Float = .5;
  public var zoom:Float = 1;
  public var camX:Float = 0;
  public var camY:Float = 0;
  public var camTX:Float = 0;
  public var camTY:Float = 0;
  public var camAngle:Int = 0;
  public var offX:Float = 0;
  public var offY:Float = 0;
  
  public function new() {
    
  }
  
  public function renderWorld(to:Plot, w:World):Void {
    w.update();
    for (p in w.parts) render(to, p);
  }
  
  public function renderBuild(to:Plot, b:P3DBuild):Void {
    b.update();
    for (p in b.parts) render(to, p);
  }
  
  public function renderGrid(to:Plot, g:Grid):Void {
    g.update();
    for (ti in 0...g.renTiles.length) {
      render(to, g.renTiles[ti]);
      if (g.units[ti] != null) renderUnit(to, g.units[ti]);
    }
  }
  
  public function renderUnit(to:Plot, u:Unit) {
    u.update();
    for (l in u.layers) renderBuild(to, l);
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
    var bx:Float = (prex * Trig.cosAngle[camAngle] - prey * Trig.sinAngle[camAngle]) * zoom + to.w / 2 + offX;
    var by:Float = (prex * Trig.sinAngle[camAngle] + prey * Trig.cosAngle[camAngle]) * zoom + to.h + offY;
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
        && minx < to.w && maxx >= 0
        && miny < to.h && maxy >= 0) {
      minx = minx.maxI(0);
      miny = miny.maxI(0);
      maxx = maxx.minI(to.w);
      maxy = maxy.minI(to.h);
      
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
      
      // entity
      var ent = 0;
      if (p.entity != null) {
        ent = to.registerEntity(p.entity);
      }
      
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
              ,p.data[(projY * p.dw).floor().clampI(0, p.dw - 1) + (projX * p.dh).floor().clampI(0, p.dh - 1) * p.dw]
              ,p.world ? 2 : lightMatrix[lval + (y % 4) * 4 + (x % 4)]
              ,ent
              ,p.world
            );
        }
      }
    }
  }
}
