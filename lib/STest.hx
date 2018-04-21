package lib;

import haxe.ds.Vector;
import sk.thenet.app.JamState;
import sk.thenet.app.Keyboard.Key;
import sk.thenet.anim.Phaser;
import sk.thenet.bmp.*;
import sk.thenet.bmp.manip.*;
import sk.thenet.plat.Platform;

using sk.thenet.FM;

class STest extends JamState {
  var p3d:P3D;
  var plot:Plot;
  
  var build:P3DBuild;
  
  public function new(app) super("test", app);
  
  override public function to() {
    p3d = new P3D();
    plot = new Plot();
    
    phasers["t"] = new Phaser(3);
    
    var rv = amB("rv").fluent;
    build = P3DBuild.build(
         Anchor("rv")
        ,[
          Offset([Box(rv >> new Cut(0, 56, 64, 32), [
               rv >> new Cut(0, 8, 64, 46)
              ,rv >> new Cut(64, 8, 32, 46)
              ,rv >> new Cut(96, 8, 64, 46)
              ,rv >> new Cut(160, 8, 32, 46)
            ])], -32, -16, 0, 0)
          ,Offset([Wall(rv >> new Cut(64, 56, 32, 46), 9)], 24, -16, 0, 0)
          ,Offset([Floor(rv >> new Cut(96, 56, 13, 32), 0, 32)], 22, -16, 22, 0)
        ]
        ,null
      );
  }
  
  override public function tick() {
    p3d.renderBuild(plot, build);
    plot.render(ab);
    
    //build.angle = (app.mouse.x >> 2) % 36;
    //build.tilt = (app.mouse.y >> 2) % 36;
    if (ak(ArrowRight) && ph("t") == 0) build.angle++;
    build.angle %= 36;
    if (ak(ArrowUp) && ph("t") == 0) build.tilt++;
    build.tilt %= 36;
    build.x = 150;
    build.y = 250;
  }
}
