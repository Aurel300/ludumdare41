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
    part.bitmap = Platform.createBitmap(90, 70, 0xFFAA0000);
    part.z = 1;
    part.vert = false;
  }
  
  override public function tick() {
    p3d.render(plot, part, 150, 100, 0);
    plot.render(ab);
    part.angle = (app.mouse.x >> 2).clampI(0, 35);
    part.tilt = (app.mouse.y >> 4).clampI(0, 8);
  }
  
  override public function mouseClick(mx, my) {
    trace(part.angle, part.tilt);
  }
}
