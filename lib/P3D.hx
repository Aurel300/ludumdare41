package lib;

import sk.thenet.bmp.*;

using sk.thenet.FM;

class P3D {
  public var pers:Float = .5;
  
  public function new() {
    
  }
  
  public function renderBuild(to:Plot, b:P3DBuild, ox:Int, oy:Int, oz:Int):Void {
    for (p in b.parts) render(to, p, ox, oy, oz);
  }
  
  public function render(to:Plot, p:P3DPart, ox:Int, oy:Int, oz:Int):Void {
    var mxx:Float = Trig.cosAngle[p.angle] * Trig.cosTilt[p.tilt];
    var mxy:Float = 0;
    var myx:Float = Trig.sinAngle[p.angle] * Trig.cosTilt[p.tilt];
    var myy:Float = 0;
    var mzx:Float = Trig.sinTilt[p.tilt];
    var mzy:Float = 0;
    if (p.vert) {
      //mxx = Trig.cosAngle[p.angle] * Trig.cosTilt[p.tilt];
      mxy = Trig.cosAngle[p.angle] * Trig.sinTilt[p.tilt];
      //myx = Trig.sinAngle[p.angle] * Trig.cosTilt[p.tilt];
      myy = Trig.sinAngle[p.angle] * Trig.sinTilt[p.tilt];
      //mzx = Trig.sinTilt[p.tilt];
      mzy = -Trig.cosTilt[p.tilt];
    } else {
      //mxx = Trig.cosAngle[p.angle] * Trig.cosTilt[p.tilt];
      mxy = -Trig.sinAngle[p.angle];
      //myx = Trig.sinAngle[p.angle] * Trig.cosTilt[p.tilt];
      myy = Trig.cosAngle[p.angle];
      //mzx = Trig.sinTilt[p.tilt];
      //mzy = 0;
    }
    var bx:Float = ox + p.x;
    var by:Float = oy + p.y;
    var bz:Float = oz + p.z;
    var vi = 0;
    var lx:Int = -1;
    var ly:Int = -1;
    
    var cx:Int = -1;
    var cyy:Int = -1;
    var cyz:Int = -1;
    var cye:Int = -1;
    for (y in 0...p.h) for (x in 0...p.w) {
      for (off in 0...2) {
        cx  = (bx + mxx * (x + off * .5) + mxy * (y + off * .5)).floorZ();
        cyy = ((bx + myx * (x + off * .5) + myy * (y + off * .5)) * pers).floorZ();
        cyz = (bz + mzx * (x + off * .5) + mzy * (y + off * .5)).floorZ();
        cye = cyy - cyz;
        if (cx == lx && cye == ly) continue;
        lx = cx;
        ly = cye;
        to.plot(cx, cyy, cyz, p.data[vi]);
      }
      vi++;
    }
    for (s in p.sub) render(to, s, ox + p.x, oy + p.y, oz + p.z);
  }
}
