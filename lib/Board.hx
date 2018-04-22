package lib;

import sk.thenet.app.Keyboard.Key;
import sk.thenet.bmp.manip.*;

class Board {
  static var as:Map<String, Bitmap>;
  
  public static function init(b:Bitmap):Void {
    var f = b.fluent;
    as = [
         "carrot" => f >> new Cut(0, 8, 232, 64)
        ,"tomato" => f >> new Cut(0, 72, 88, 80)
        ,"bun" => f >> new Cut(88, 72, 144, 80)
        ,"patty" => f >> new Cut(0, 152, 184, 72)
        ,"knife" => f >> new Cut(232, 16, 168, 48)
        ,"knife_ghost" => f >> new Cut(232, 64, 168, 48)
        ,"tenderiser" => f >> new Cut(232, 112, 168, 56)
        ,"interiour" => f >> new Cut(0, 232, 320 * 2, 240)
        ,"plate" => f >> new Cut(184, 168, 104, 56)
        ,"plate_shadow" => f >> new Cut(184 + 104, 168, 104, 56)
      ];
  }
  
  public var task:BoardTask = None;
  public var obj:Bitmap;
  public var objX:Float = 0;
  public var objY:Float = 240;
  public var objW:Int;
  public var objTX:Float = 0;
  public var objTY:Float = 240;
  public var knife:Bitmap;
  public var knifeX:Float = Main.W + 10;
  public var knifeY:Float = 40;
  public var knifeTX:Float = Main.W + 10;
  public var knifeTY:Float = 40;
  public var knifeDip:Int = 0;
  public var bpieces = new Array<Piece>();
  public var pieces = new List<Piece>();
  public var timer:Int;
  public var space:Int = 0;
  public var spaceX:Float = 0;
  public var spaceTX:Float = 0;
  var taskLen:Int;
  var plots:Array<Plot>;
  var slots:Array<Unit>;
  var p3d:P3D;
  
  public function new() {
    //start(CutCarrot(null));
    start(Tenderise);
    plots = [ for (i in 0...3) new Plot(106, 126) ];
    slots = [ for (i in 0...3) null ];
    
    p3d = new P3D();
    p3d.zoom = 3;
    p3d.camAngle = 3;
    
    var b = new Burger();
    b.addLayer(BunBottom);
    /*
    b.addLayer(Tomato);
    b.addLayer(Carrot);
    b.addLayer(Patty(1));
    b.addLayer(Cheese);
    b.addLayer(Cucumber);
    b.addLayer(Lettuce);
    b.addLayer(BunTop);*/
    slots[0] = b;
    
  }
  
  public function start(task:BoardTask) {
    bpieces = null;
    space = 1;
    this.task = (switch (task) {
        case CutCarrot(_):
        obj = as["carrot"];
        objW = as["carrot"].width;
        objTX = 40;
        objTY = 80;
        taskLen = 640;
        CutCarrot([ for (i in 1...6) {
            55 + i * 38 + FM.prng.nextMod(18);
          } ]);
        case Tenderise:
        taskLen = 640;
        obj = null;
        objTX = 60;
        objTY = 120;
        objW = 0;
        knifeTX = 160;
        knife = as["tenderiser"];
        bpieces = [ for (y in 0...4) for (x in 0...6) {
             b: as["patty"]
            ,bx: x * 32
            ,by: y * 18
            ,bw: 32
            ,bh: 18
            ,x: x * 32
            ,y: y * 18
            ,vx: 0
            ,vy: 0
          } ];
        Tenderise;
        case _: task;
      });
    timer = 0;
  }
  
  static var platePosX = [40, 112, 184];
  static var platePosY = [103, 160, 103];
  
  public function render(to:Bitmap, y:Int):Void {
    if (y >= Main.H) return;
    to.blitAlpha(as["interiour"], -spaceX.floor(), y);
    for (i in 0...plots.length) {
      plots[i].prerender(true);
      to.blitAlpha(as["plate_shadow"], platePosX[i] - spaceX.floor(), platePosY[i] + 2 + y);
      to.blitAlpha(as["plate"], platePosX[i] - spaceX.floor(), platePosY[i] + y);
      if (slots[i] != null) p3d.renderUnit(plots[i], slots[i]);
      p3d.camX = Grid.TILE_HALF;
      p3d.camY = Grid.TILE_HALF;
      plots[i].renderAlpha(to, platePosX[i] - spaceX.floor(), platePosY[i] - 30 + y);
    }
    
    switch (task) {
      case None:
      knifeTX = Main.W + 10;
      knifeTY = 40;
      objTY = Main.H + 10;
      case CutCarrot(marks):
      knifeTY = 40;
      if (timer == 0 || timer == 320) Sfx.play("cut-start");
      if (timer < 320) {
        knife = as["knife_ghost"];
        knifeTX = Main.W - timer;
        if (marks.indexOf(timer) != -1) {
          Sfx.play("cut");
          knifeDip += 1;
        }
      } else {
        knife = as["knife"];
        knifeTX = Main.W - (timer - 320);
      }
      case Tenderise:
      knifeTY = 50;
    }
    if (timer >= taskLen) {
      //start(CutCarrot(null));
      task = None;
      timer = 0;
    }
    
    // cutting board
    var space2X = -320 + spaceX;
    if (bpieces != null) for (p in bpieces) {
      to.blitAlphaRect(p.b, (objX + p.x - space2X).floor(), (objY + p.y).floor() + y, p.bx, p.by, p.bw, p.bh);
    }
    to.blitAlpha(knife, (knifeX - space2X).floor(), knifeY.floor() + y);
    if (obj != null) to.blitAlphaRect(obj, (objX - space2X).floor(), objY.floor() + y, 0, 0, objW, obj.height);
    for (p in pieces) {
      if (p.y > Main.H) pieces.remove(p);
      to.blitAlphaRect(p.b, (p.x - space2X).floor(), p.y.floor() + y, p.bx, p.by, p.bw, p.bh);
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.09;
    }
    
    // tween
    objX.target(objTX, 19);
    objY.target(objTY, 19);
    spaceTX = space * Main.W;
    spaceX.targetMin(spaceTX, 29, .5);
    if (task == None) {
      knifeX.target(knifeTX, 29);
      knifeY.target((knifeDip > 0 ? 200 : 0) + knifeTY, 29);
    } else {
      knifeX.target(knifeTX, 7);
      knifeY.target((knifeDip > 0 ? 200 : 0) + knifeTY, 7);
    }
    if (knifeDip > 0) knifeDip--;
    timer++;
  }
  
  public function click(mx, my):Bool {
    switch (task) {
      case CutCarrot(marks):
      if (timer.withinI(320, 640)) {
        Sfx.play("cut");
        knifeDip += 2;
        var prevW = objW;
        objW = (knifeX + 20 - objX).floor();
        var bestDist = 500;
        var bestFit = -1;
        for (i in 0...marks.length) {
          var dist = ((timer - 320) - marks[i]).absI();
          if (dist < bestDist) {
            bestDist = dist;
            bestFit = i;
          }
        }
        if (bestFit != -1 && bestDist < 50) {
          marks.splice(bestFit, 1);
        }
        pieces.push({
             b: as["carrot"]
            ,bx: objW
            ,by: 0
            ,bw: prevW - objW
            ,bh: obj.height
            ,x: objX + objW
            ,y: objY
            ,vx: .3 + Math.random() * 1.4
            ,vy: -1.3 - Math.random() * .9
          });
      }
      case Tenderise:
      Sfx.play("cut");
      knifeTX = 80 + FM.prng.nextMod(100);
      knifeTY = 50 + FM.prng.nextMod(30);
      knifeDip += 1;
      var ex = FM.prng.nextMod(6);
      var ey = FM.prng.nextMod(3);
      for (i in 0...ey + 1) {
        bpieces[ex + i * 6].y += 1;
      }
      case _:
    }
    return true;
  }
  
  public function keyUp(k:Key):Bool {
    return (switch (k) {
        case (KeyA | KeyD) if (task == None):
        space = (space + (1).negposI(k == KeyA, k == KeyD)).clampI(0, 1);
        true;
        case _: false;
      });
  }
}

enum BoardTask {
  None;
  CutCarrot(marks:Array<Int>);
  Tenderise;
}

typedef Piece = {
     b:Bitmap
    ,bx:Int
    ,by:Int
    ,bw:Int
    ,bh:Int
    ,x:Float
    ,y:Float
    ,vx:Float
    ,vy:Float
  };
