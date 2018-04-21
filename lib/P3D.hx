package lib;

import sk.thenet.bmp.*;

using sk.thenet.FM;

class P3D {
  public function new() {
    
  }
  
  public function renderBuild(to:Plot, b:P3DBuild, ox:Int, oy:Int, oz:Int):Void {
    for (p in b.parts) render(to, p, ox, oy, oz);
  }
  
  public function render(to:Plot, p:P3DPart, ox:Int, oy:Int, oz:Int):Void {
    if (p.vert) {
      var c = Trig.cosAngle[p.angle];
      var s = Trig.sinAngle[p.angle];
      var bx:Float = ox + p.x;
      var by:Float = oy + p.y;
      var bz:Float = oz + p.z;
      var cx:Float = ox + p.x;
      var cy:Float = oy + p.y;
      var cz:Float = oz + p.z;
      var vi = 0;
      for (y in 0...p.h) {
        cx = bx;
        cy = by;
        for (x in 0...p.w) {
          to.plot(cx.floorZ(), cy.floorZ(), cz.floorZ(), p.data[vi++]);
          cx += c;
          cy += s;
        }
        cz += 1;
      }
    } else {
      
    }
    for (s in p.sub) render(to, s, ox + p.x, oy + p.y, oz + p.z);
  }
}
