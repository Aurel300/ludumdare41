package lib;

import haxe.ds.Vector;
import sk.thenet.app.JamState;
import sk.thenet.app.Keyboard.Key;
import sk.thenet.anim.Phaser;
import sk.thenet.bmp.*;
import sk.thenet.plat.Platform;

using sk.thenet.FM;

class STest extends JamState {
  var p3d:P3D;
  var plot:Plot;
  
  var part:P3DPart;
  
  public function new(app) super("test", app);
  
  override public function to() {
    p3d = new P3D();
    plot = new Plot();
    
    part = new P3DPart(null);
    part.bitmap = amB("test");
    part.z = 0;
    part.vert = false;
    part.tilt = 3;
  }
  
  override public function tick() {
    p3d.render(plot, part, 150, 100, 0);
    plot.render(ab);
    part.angle = (app.mouse.x >> 2) % 36;
    //part.tilt = (app.mouse.y >> 4).clampI(0, 8);
    part.z = (app.mouse.y >> 2) - 10;
  }
  
  override public function mouseClick(mx, my) {
    part.vert = !part.vert;
  }
}
