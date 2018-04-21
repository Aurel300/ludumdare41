package lib;

import haxe.ds.Vector;
import sk.thenet.bmp.*;
import sk.thenet.geom.*;

using sk.thenet.FM;

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
    //var tiltNum = 1 + tiltNums[p.tilt * Trig.densityAngle + p.angle];
    //var tiltMul = tiltMuls[p.tilt * Trig.densityAngle + p.angle];
    var bx:Float = ox + p.x;
    var by:Float = oy + p.y;
    var bz:Float = oz + p.z;
    var vi = 0;
    
    var cx:Int = -1;
    var cyy:Int = -1;
    var cyz:Int = -1;
    var cye:Int = -1;
    
    // corners of rect
    var p1 = new Point2DF(bx, by * pers - bz);
    var p2 = new Point2DF(bx + mxx * p.w, (by + myx * p.w) * pers - mzx * p.w);
    var p3 = new Point2DF(bx + mxy * p.h, (by + myy * p.h) * pers - mzy * p.h);
    var p4 = new Point2DF(bx + mxx * p.w + mxy * p.h, (by + myx * p.w + myy * p.h) * pers - mzx * p.w - mzy * p.h);
    
    // side vectors
    var vw = p2.subtractC(p1);
    var vh = p3.subtractC(p1);
    
    // side vector normals, step1
    var mw = vw.normalC();
    var mh = vh.normalC();
    
    // side vector normals
    var nw = mw.scaleC(-1).unitM(); // / -vh.dot(mw));
    var nh = mh.scaleC(-1).unitM(); // / -vw.dot(mh));
    
    // floored rect corners
    var pr1 = p1.cloneI();
    var pr2 = p2.cloneI();
    var pr3 = p3.cloneI();
    var pr4 = p4.cloneI();
    
    // rect bounds
    var minx = pr1.x.minI(pr2.x).minI(pr3.x).minI(pr4.x);
    var miny = pr1.y.minI(pr2.y).minI(pr3.y).minI(pr4.y);
    var maxx = pr1.x.maxI(pr2.x).maxI(pr3.x).maxI(pr4.x);
    var maxy = pr1.y.maxI(pr2.y).maxI(pr3.y).maxI(pr4.y);
    var recw = maxx - minx;
    var rech = maxy - miny;
    
    // proj bounds
    var p4dx = p4.x - p1.x;
    var p4dy = p4.y - p1.y;
    var p4x = (p4dx * nw.x + p4dy * nw.y);
    var p4y = -(p4dx * nh.x + p4dy * nh.y);
    
    if (recw != 0 && rech != 0) { // TODO: out of screen cull
      var vws = vw.magnitude;
      var vhs = vh.magnitude;
      for (y in miny...maxy) for (x in minx...maxx) {
        var d1x = (x - p1.x);
        var d1y = (y - p1.y);
        var d2x = (x - p4.x);
        var d2y = (y - p4.y);
        to.plot(x, y, 1, 2);
        var p1x = (d1x * nw.x + d1y * nw.y) / p4x;
        var p1y = -(d1x * nh.x + d1y * nh.y) / p4y;
        if (p1x.withinF(0, 1) && p1y.withinF(0, 1)) {
          to.plot(x, y, 2, p.data[(p1y * p.w).floorZ() + (p1x * p.h).floorZ() * p.w]);
        }
      }
    }
    
    to.plot(50, 50, 4, 3);
    to.plot(nw.x.floor() + 50, nw.y.floor() + 50, 4, 3);
    to.plot(nh.x.floor() + 50, nh.y.floor() + 50, 4, 3);
    
    //to.plot(pr1.x, pr1.y, 4, 3);
    //to.plot(pr2.x, pr2.y, 4, 3);
    //to.plot(pr3.x, pr3.y, 4, 3);
    //to.plot(pr4.x, pr4.y, 4, 3);
    
    for (s in p.sub) render(to, s, ox + p.x, oy + p.y, oz + p.z);
  }
}
