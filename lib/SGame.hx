package lib;

import haxe.ds.Vector;
import sk.thenet.app.JamState;
import sk.thenet.app.Keyboard.Key;
import sk.thenet.anim.*;
import sk.thenet.bmp.*;
import sk.thenet.bmp.manip.*;
import sk.thenet.plat.Platform;

using sk.thenet.FM;

class SGame extends JamState {
  var mode:GMode = TBS;
  
  var p3d:P3D;
  var plot:Plot;
  
  public var grid:Grid;
  public var board:Board;
  public var boardBT:Bitween;
  
  public function new(app) super("game", app);
  
  override public function to() {
    p3d = new P3D();
    plot = new Plot(Main.W, Main.H);
    
    phasers["t"] = new Phaser(3);
    
    grid = new Grid(5, 5);
    
    board = new Board();
    boardBT = new Bitween(40);
  }
  
  override public function tick() {
    plot.prerender(false);
    
    var zoomTarget = 1.0;
    switch (mode) {
      case Roam:
      //p3d.renderBuild(plot, build);
      case TBS:
      zoomTarget = 0.9 + boardBT.valueF;
      p3d.renderGrid(plot, grid);
    }
    
    plot.render(ab, 0, 0);
    board.render(ab, ((1 - Timing.quadInOut.getF(boardBT.valueF)) * Main.H).floor(), app.mouse.x, app.mouse.y);
    GUI.renderAll(ab, app.mouse.x, app.mouse.y);
    
    if (boardBT.isOff) {
      if (ph("t") == 0) {
        p3d.camAngle = (p3d.camAngle + Trig.densityAngle + (1).negposI(ak(KeyQ), ak(KeyE))) % Trig.densityAngle;
      }
      var cmx = (3.3).negposF(ak(KeyA), ak(KeyD));
      var cmy = (3.3).negposF(ak(KeyW), ak(KeyS));
      if (cmx != 0 || cmy != 0) {
        var c = Trig.cosAngle[p3d.camAngle] * (2.1 / p3d.zoom);
        var s = Trig.sinAngle[p3d.camAngle] * (2.1 / p3d.zoom);
        p3d.camTX += c * cmx + s * cmy;
        p3d.camTY += -s * cmx + c * cmy;
      }
    }
    
    boardBT.tick();
    p3d.camX.target(p3d.camTX, 29);
    p3d.camY.target(p3d.camTY, 29);
    p3d.zoom.target(zoomTarget + (2.0).negposF(ak(KeyR), ak(KeyF)), 19);
  }
  
  override public function mouseMove(mx, my) {
    plot.mouseMove(mx, my);
  }
  
  override public function mouseClick(mx, my) {
    if (!boardBT.isOn && !boardBT.isOff) return;
       GUI.clickAll(mx, my)
    || (boardBT.isOn ? board.click(mx, my) : false)
    || plot.click(mx, my);
  }
  
  override public function keyUp(k:Key) {
    if (boardBT.isOn && board.keyUp(k)) return;
    switch (k) {
      case Space: boardBT.toggle();
      case _:
    }
  }
}

enum GMode {
  Roam;
  TBS;
}
