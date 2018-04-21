package lib;

import sk.thenet.app.JamState;
import sk.thenet.bmp.*;
import sk.thenet.plat.Platform;

class STest extends JamState {
  var p3d:P3D;
  var plot:Plot;
  
  var part:P3DPart;
  
  public function new(app) super("test", app);
  
  override public function to() {
    p3d = new P3D();
    plot = new Plot();
    
    part = new P3DPart(null);
    part.bitmap = Platform.createBitmap(30, 20, 0xFFAA0000);
    part.z = 20;
  }
  
  override public function tick() {
    p3d.render(plot, part, 50, 50, 0);
    plot.render(ab);
    part.angle++;
    part.angle %= Trig.densityAngle;
  }
}
