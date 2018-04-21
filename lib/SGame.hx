package lib;

import haxe.ds.Vector;
import sk.thenet.app.JamState;
import sk.thenet.app.Keyboard.Key;
import sk.thenet.anim.Phaser;
import sk.thenet.bmp.*;
import sk.thenet.bmp.manip.*;
import sk.thenet.plat.Platform;

using sk.thenet.FM;

class SGame extends JamState {
  var mode:GMode = TBS;
  
  var p3d:P3D;
  var plot:Plot;
  
  var build:P3DBuild;
  
  var grid:Grid;
  
  public function new(app) super("game", app);
  
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
    
    grid = new Grid(5, 5);
  }
  
  override public function tick() {
    plot.prerender();
    
    var zoomTarget = 1.0;
    switch (mode) {
      case Roam:
      case TBS:
      zoomTarget = .5;
      grid.render(plot, p3d);
      p3d.renderBuild(plot, build);
    }
    
    plot.render(ab);
    
    if (ph("t") == 0) {
      p3d.camAngle = (p3d.camAngle + Trig.densityAngle + (1).negposI(ak(KeyQ), ak(KeyE))) % Trig.densityAngle;
    }
    {
      var cmx = (3.3).negposF(ak(KeyA), ak(KeyD));
      var cmy = (3.3).negposF(ak(KeyW), ak(KeyS));
      if (cmx != 0 || cmy != 0) {
        var c = Trig.cosAngle[p3d.camAngle] * (2.1 * p3d.zoom);
        var s = Trig.sinAngle[p3d.camAngle] * (2.1 * p3d.zoom);
        p3d.camTX += c * cmx + s * cmy;
        p3d.camTY += -s * cmx + c * cmy;
      }
    };
    
    p3d.camX.target(p3d.camTX, 29);
    p3d.camY.target(p3d.camTY, 29);
    
    //p3d.zoom.target(zoomTarget, 19);
    
    //build.angle = (app.mouse.x >> 2) % 36;
    //build.tilt = (app.mouse.y >> 2) % 36;
    /*
    build.angle %= 36;
    if (ak(ArrowUp) && ph("t") == 0) build.tilt++;
    build.tilt %= 36;
    build.x = 150;
    build.y = 250;
    */
  }
  
  override public function mouseClick(mx, my) {
    plot.click(mx, my);
  }
}

enum GMode {
  Roam;
  TBS;
}
