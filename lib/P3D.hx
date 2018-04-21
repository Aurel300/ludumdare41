package lib;

import sk.thenet.bmp.*;

class P3D {
  public function new() {
    
  }
  
  public function renderBuild(to:Plot, b:P3DBuild, ox:Int, oy:Int, oz:Int):Void {
    for (p in b.parts) render(to, p, ox, oy, oz);
  }
  
  public function render(to:Plot, p:P3DPart, ox:Int, oy:Int, oz:Int):Void {
    var vi = 0;
    for (y in 0...p.h) {
      for (x in 0...p.w) {
        to.pbuf[x + y * Main.W] = p.data[vi++];
      }
    }
    for (s in p.sub) render(to, s, ox + p.x, oy + p.y, oz + p.z);
  }
}
