package lib;

import haxe.ds.Vector;
import sk.thenet.app.JamState;
import sk.thenet.app.Keyboard.Key;
import sk.thenet.anim.*;
import sk.thenet.bmp.*;
import sk.thenet.bmp.manip.*;
import sk.thenet.geom.*;
import sk.thenet.plat.Platform;

using sk.thenet.FM;

class SGame extends JamState {
  public var mode:GMode = Roam;
  
  public static var musicOn:Bool = true;
  public static var soundOn:Bool = true;
  
  public var p3d:P3D;
  var plot:Plot;
  
  public var world:World;
  public var grid:Grid;
  public var board:Board;
  public var boardBT:Bitween;
  public var rv:P3DBuild;
  public var mdown:Bool = false;
  public var rvSpeed:Float = 0;
  public var rvSubX:Float = 0;
  public var rvSubY:Float = 0;
  
  var musicRoam:Crossfade;
  var musicBattle:Crossfade;
  var engine:Crossfade;
  var levelId:String;
  
  public function new(app) super("game", app);
  
  override public function to() {
    musicRoam = new Crossfade("music-roam");
    musicBattle = new Crossfade("music-battle");
    engine = new Crossfade("engine");
    
    GUI.showPlot([
         Text("Welcome to the overworld!")
        ,Text("Drive around using the mouse.")
        ,Text("Q and E orbit the camera.")
        ,Text("Approach a flag and press the button that appears to play a level.")
      ]);
    
    p3d = new P3D();
    plot = new Plot(Main.W, Main.H);
    
    phasers["t"] = new Phaser(3);
    
    world = new World();
    grid = new Grid();
    board = new Board();
    boardBT = new Bitween(40);
    
    rv = P3DBuild.build(Anchor(""), Unit.ss["rv"], null);
    
    rv.x = 700;
    rv.y = 650;
    p3d.camX = p3d.camTX = rv.x;
    p3d.camY = p3d.camTY = rv.y;
  }
  
  public function enterRoam(win:Bool):Void {
    if (win) Grid.levels[levelId].beaten = true;
    GUI.hide("hud_battle");
    GUI.showTransition(win ? "win" : "loss");
    mode = Roam;
    rv.x = grid.rv.layers[0].x;
    rv.y = grid.rv.layers[0].y;
    rv.z = grid.rv.layers[0].z;
    rv.angle = grid.rv.layers[0].angle;
  }
  
  public function enterBattle(id:String, x:Int, y:Int):Void {
    levelId = id;
    var level = Grid.levels[id];
    if (level.plot != null) {
      GUI.showPlot(level.plot);
    }
    grid.resetLevel(x, y, level);
    GUI.show("hud_battle");
    Sfx.play("tune-battle");
    GUI.showTransition("fight");
    mode = TBS;
    board.reset();
    boardBT.setTo(false, true);
  }
  
  static inline var rvMul = 1.2;
  static inline var rvMaxSpeed = 7;
  
  public function boardY():Int {
    return ((1 - Timing.quadInOut.getF(boardBT.valueF)) * Main.H).floor();
  }
  
  public function enemyTurn():Bool {
    if (mode == TBS) switch (grid.state) {
      case Turn(false, _): return true;
      case _:
    }
    return false;
  }
  
  override public function tick() {
    musicRoam.tick(mode == Roam);
    musicBattle.tick(mode == TBS, mode == TBS ? (1 - boardBT.valueF * .3) : 1);
    engine.tick(mode == Roam, (rvSpeed / rvMaxSpeed) * .4);
    
    plot.prerender(false);
    p3d.renderWorld(plot, world);
    
    var zoomTarget = 1.0;
    switch (mode) {
      case Roam:
      zoomTarget = 0.4;
      p3d.renderBuild(plot, rv);
      plot.render(ab, 0, 0);
      GUI.renderAll(ab, app.mouse.x, app.mouse.y);
      
      var speedTgt = mdown ? rvMaxSpeed : 0;
      rvSpeed.target(speedTgt, mdown ? 59 : 21);
      if (mdown) {
        var dir = new Point2DF(app.mouse.x - Main.W2, (app.mouse.y - Main.H2) * 2);
        var magn = dir.magnitude;
        if (magn > 30) {
          var angle = ((Math.atan2(dir.y, dir.x) + Math.PI * 2) / (Math.PI * 2) * Trig.densityAngle).floor();
          angle += 36 - p3d.camAngle;
          angle %= Trig.densityAngle;
          if (ph("t") == 0) {
            rv.angle += 36 + Trig.shortestAngle(rv.angle, angle);
            rv.angle %= Trig.densityAngle;
          }
        }
      }
      rvSubX += Trig.cosAngle[rv.angle] * rvSpeed;
      rvSubY += Trig.sinAngle[rv.angle] * rvSpeed;
      while (rvSubX > rvMul) { rv.x++; rvSubX -= rvMul; }
      while (rvSubX < -rvMul) { rv.x--; rvSubX += rvMul; }
      while (rvSubY > rvMul) { rv.y++; rvSubY -= rvMul; }
      while (rvSubY < -rvMul) { rv.y--; rvSubY += rvMul; }
      
      p3d.camTX = rv.x + Trig.cosAngle[rv.angle] * rvSpeed * 20;
      p3d.camTY = rv.y + Trig.sinAngle[rv.angle] * rvSpeed * 20;
      
      if (ph("t") == 0) {
        p3d.camAngle = (p3d.camAngle + Trig.densityAngle + (1).negposI(ak(KeyQ), ak(KeyE))) % Trig.densityAngle;
      }
      
      case TBS:
      zoomTarget = 0.9 + boardBT.valueF;
      p3d.renderGrid(plot, grid);
      
      plot.render(ab, 0, 0);
      board.render(ab, boardY(), app.mouse.x, app.mouse.y);
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
    }
    
    p3d.camX.target(p3d.camTX, 13);
    p3d.camY.target(p3d.camTY, 13);
    
    if (mode == TBS && ak(KeyR) != ak(KeyF)) zoomTarget += ak(KeyR) ? -0.3 : 1.2;
    p3d.zoom.target(zoomTarget, 19);
  }
  
  override public function mouseMove(mx, my) {
    plot.mouseMove(mx, my);
  }
  
  override public function mouseClick(mx, my) {
    if (mode == TBS && !boardBT.isOn && !boardBT.isOff) return;
       GUI.clickAll(mx, my)
    || (boardBT.isOn ? board.click(mx, my) : false)
    || plot.click(mx, my);
  }
  
  override public function mouseDown(_, _) {
    mdown = true;
  }
  
  override public function mouseUp(_, _) {
    mdown = false;
  }
  
  override public function keyUp(k:Key) {
    switch (k) {
      case KeyM: musicOn = !musicOn;
      case KeyK: soundOn = !soundOn;
      case _:
    }
    switch (mode) {
      case Roam:
      case TBS:
      if (boardBT.isOn && board.keyUp(k)) return;
      switch (k) {
        case Space: boardBT.toggle();
        case _:
      }
    }
  }
}

enum GMode {
  Roam;
  TBS;
}
